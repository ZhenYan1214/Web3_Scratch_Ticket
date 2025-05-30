// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

//VRF
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {VRFV2PlusWrapperConsumerBase} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFV2PlusWrapperConsumerBase.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

//ERC721
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";

contract DirectFundingConsumer is VRFV2PlusWrapperConsumerBase, Ownable, ERC721, ERC721URIStorage {
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(
        uint256 requestId,
        uint256[] randomWords,
        uint256 payment
    );

    struct RequestStatus {
        uint256 paid; // amount paid in link
        bool fulfilled; // whether the request has been successfully fulfilled
        uint256[] randomWords;
    }

    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */ 
    mapping(uint256 => uint256) public tokenIdToRequestId; // tokenId 對應 VRF 請求的 requestId
    mapping(uint256 => uint256) public requestIdToTokenId;
    mapping(uint256 => uint256) public tokenIdToRandomNumber; //tokenId 與 VRF 數字對應
    mapping(uint256 => Prize) public tokenIdToPrize; //獎項等級
    mapping(uint256 => bool) public isRevealed; //確認有沒有刮過

    //獎項等級
    enum Prize { None, Consolation, Second, First, Grand }

    // VRF
    uint256[] public requestIds;
    uint256 public lastRequestId;
    uint32 public callbackGasLimit = 100000;
    uint16 public requestConfirmations = 3;

    //刮刮樂
    uint32 public numWords = 1;
    uint256 public nextTokenId = 1;
    uint256 public poolBalance; // 獎池
    uint256 public platformFee; // 目前累積的 fee

    // address WRAPPER - hardcoded for Sepolia
    address public wrapperAddress = 0x195f15F2d49d693cE265b4fB0fdDbE15b1850Cc1;

    constructor()
        Ownable()
        VRFV2PlusWrapperConsumerBase(wrapperAddress)
    {}

    function mint() external payable returns (uint256) {
        require(msg.value <= 0.01 ether, "Not enough ETH"); //要求最低金額
        require(msg.value == 0.01 ether, "Price is 0.01 ETH"); //確保金額是剛好的
        uint256 tokenId = nextTokenId++;
        _safeMint(msg.sender, tokenId);

        uint256 price = 0.01 ether; // 刮刮樂價格
        uint256 toPool = (price * 90) / 100; // 90% 進獎池
        uint256 fee = price - toPool;        // 10% 作為平台抽成
        poolBalance += toPool;               // 加到獎池
        platformFee += fee; //開發者的收入

        
        uint256 requestId = requestRandomWords(numWords); // 發出 VRF 隨機數請求，回傳 requestId
        tokenIdToRequestId[tokenId] = requestId; //tokenId 與 requestId 的雙向對應
        requestIdToTokenId[requestId] = tokenId;

        return tokenId;
    }

    function reveal(uint256 tokenId) external {   //記得要解決 如果獎池沒錢怎麼辦  的問題
        require(ownerOf(tokenId) == msg.sender, "Not the owner!");
        require(!isRevealed[tokenId], "Already revealed!");
        require(tokenIdToRandomNumber[tokenId] != 0, "Random not ready!"); //確保 fulfillRandomWords 已執行

        isRevealed[tokenId] = true; // 標記已揭曉

        Prize prize = tokenIdToPrize[tokenId];
        uint256 prizeAmount = 0;

        //獎金分配
        if (prize == Prize.Grand) {
            prizeAmount = (poolBalance * 40) / 100; // 40% of pool
        } else if (prize == Prize.First) {
            prizeAmount = (poolBalance * 15) / 100; // 15% of pool
        } else if (prize == Prize.Second) {
            prizeAmount = (poolBalance * 5) / 100;  // 5% of pool
        } else if (prize == Prize.Consolation) {
            prizeAmount = 0.005 ether;              // 半價
        }

        // 發獎：確認獎池足夠，才發
        if (prizeAmount > 0 && poolBalance >= prizeAmount) {
            poolBalance -= prizeAmount;
            payable(msg.sender).transfer(prizeAmount);
        }
    }

    function withdrawFee(address payable to, uint256 amount) external onlyOwner { //開發者用來領取10%的fee
        require(amount <= platformFee, "Not enough fee");
        platformFee -= amount;
        to.transfer(amount);
    }

    function requestRandomWords(
        bool enableNativePayment
    ) external onlyOwner returns (uint256) {
        bytes memory extraArgs = VRFV2PlusClient._argsToBytes(
            VRFV2PlusClient.ExtraArgsV1({nativePayment: enableNativePayment})
        );
        uint256 requestId;
        uint256 reqPrice;
        if (enableNativePayment) {
            (requestId, reqPrice) = requestRandomnessPayInNative(
                callbackGasLimit,
                requestConfirmations,
                numWords,
                extraArgs
            );
        } else {
            (requestId, reqPrice) = requestRandomness(
                callbackGasLimit,
                requestConfirmations,
                numWords,
                extraArgs
            );
        }
        s_requests[requestId] = RequestStatus({
            paid: reqPrice,
            randomWords: new uint256[](0),
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].paid > 0, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;

        uint256 tokenId = requestIdToTokenId[_requestId];
        if (tokenId != 0) { // 預設 uint 為 0，防呆
            uint256 rand = (_randomWords[0] % 9999) + 1; //因為是256bits的數字，所以我只取後面的餘數 共1~10000
            tokenIdToRandomNumber[tokenId] = rand;

            // 分配獎項等級
            Prize prize;
            if (rand <= 10) {
                prize = Prize.Grand;      // 1~10
            } else if (rand <= 200) {
                prize = Prize.First;      // 11~200
            } else if (rand <= 700) {
                prize = Prize.Second;     // 201~700
            } else if (rand <= 2200) {
                prize = Prize.Consolation;// 701~2200
            } else {
                prize = Prize.None;       // 2201~9999
            }
            tokenIdToPrize[tokenId] = prize;
        }

        emit RequestFulfilled(
            _requestId,
            _randomWords,
            s_requests[_requestId].paid
        );
    }

    function getRequestStatus(
        uint256 _requestId
    )
        external
        view
        returns (uint256 paid, bool fulfilled, uint256[] memory randomWords)
    {
        require(s_requests[_requestId].paid > 0, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.paid, request.fulfilled, request.randomWords);
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(linkAddress);
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

    /// @notice withdrawNative withdraws the amount specified in amount to the owner
    /// @param amount the amount to withdraw, in wei
    function withdrawNative(uint256 amount) external onlyOwner {
        (bool success, ) = payable(owner()).call{value: amount}("");
        // solhint-disable-next-line gas-custom-errors
        require(success, "withdrawNative failed");
    }

    event Received(address, uint256);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    
}

