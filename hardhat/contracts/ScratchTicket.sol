// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

//VRF
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {VRFV2PlusWrapperConsumerBase} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFV2PlusWrapperConsumerBase.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

//ERC721
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract ScratchTicket is VRFV2PlusWrapperConsumerBase, Ownable, ERC721URIStorage, ReentrancyGuard  {
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords, uint256 payment);
    event PrizeClaimed(address user, uint256 tokenId, Prize prize, uint256 amount);
    event PoolWithdrawn(address indexed to, uint256 amount); //獎池提領

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

    //刮刮樂遊戲配置
    uint32 public numWords = 1;
    uint256 public nextTokenId = 1;
    uint256 public poolBalance; // 獎池
    uint256 public platformFee; // 目前累積的 fee
    uint256 public constant TICKET_PRICE = 0.01 ether;
    uint256 public constant POOL_PERCENTAGE = 90;
    uint256 public constant PLATFORM_FEE_PERCENTAGE = 10;

    // 獎項百分比配置
    uint256 public constant GRAND_PRIZE_PERCENTAGE = 40;      // 40%
    uint256 public constant FIRST_PRIZE_PERCENTAGE = 15;      // 15%  
    uint256 public constant SECOND_PRIZE_PERCENTAGE = 5;      // 5%
    uint256 public constant CONSOLATION_PRIZE_PERCENTAGE = 2; // 2%

    // address WRAPPER - hardcoded for Sepolia
    address public wrapperAddress = 0x195f15F2d49d693cE265b4fB0fdDbE15b1850Cc1;

    constructor()
        VRFV2PlusWrapperConsumerBase(wrapperAddress)
        ERC721("LuckyScratch", "LUCK")
        Ownable(msg.sender) 
    {}

     function mint() external payable returns (uint256) {
        require(msg.value >= TICKET_PRICE, "Insufficient payment");
        
        uint256 tokenId = nextTokenId++;
        _safeMint(msg.sender, tokenId);

        // 分配資金
        uint256 toPool = (TICKET_PRICE * POOL_PERCENTAGE) / 100;
        uint256 fee = TICKET_PRICE - toPool;
        poolBalance += toPool;
        platformFee += fee;

        // 退還多餘款項
        if (msg.value > TICKET_PRICE) {
            payable(msg.sender).transfer(msg.value - TICKET_PRICE);
        }

        // 請求隨機數
        uint256 requestId = requestRandomWords(true);
        tokenIdToRequestId[tokenId] = requestId;
        requestIdToTokenId[requestId] = tokenId;

        return tokenId;
    }

    function reveal(uint256 tokenId) external {   //記得要解決 如果獎池沒錢怎麼辦  的問題
        require(ownerOf(tokenId) == msg.sender, "Not the owner!");
        require(!isRevealed[tokenId], "Already revealed!");
        require(tokenIdToRandomNumber[tokenId] != 0, "Random not ready!"); //確保 fulfillRandomWords 已執行

        isRevealed[tokenId] = true; // 標記已揭曉

        Prize prize = tokenIdToPrize[tokenId];
        uint256 prizeAmount = calculatePrizeAmount(prize);

        //獎金分配
        if (prizeAmount > 0) {
            require(poolBalance >= prizeAmount, "Insufficient pool balance");
            poolBalance -= prizeAmount;
            payable(msg.sender).transfer(prizeAmount);
        }
        
        emit PrizeClaimed(msg.sender, tokenId, prize, prizeAmount);
    }

    function calculatePrizeAmount(Prize prize) public view returns (uint256) { //計算中獎金額
        if (prize == Prize.Grand) {
            return (poolBalance * GRAND_PRIZE_PERCENTAGE) / 100;
        } else if (prize == Prize.First) {
            return (poolBalance * FIRST_PRIZE_PERCENTAGE) / 100;
        } else if (prize == Prize.Second) {
            return (poolBalance * SECOND_PRIZE_PERCENTAGE) / 100;
        } else if (prize == Prize.Consolation) {
            return (poolBalance * CONSOLATION_PRIZE_PERCENTAGE) / 100;
        }
        return 0;
    }

    function withdrawFee(address payable to, uint256 amount) external onlyOwner nonReentrant { //開發者領取的收益
        require(amount <= platformFee, "Insufficient fee balance");
        require(to != address(0), "Invalid address");
        
        platformFee -= amount;
        to.transfer(amount);
    }

    function requestRandomWords( //發送請求隨機數字
        bool enableNativePayment
    ) internal returns (uint256) {
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
            fulfilled: true
        });
        requestIds.push(requestId);
        lastRequestId = requestId;

        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords( // 生成隨機數字
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].paid > 0, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;

        uint256 tokenId = requestIdToTokenId[_requestId];
        if (tokenId != 0) { // 預設 uint 為 0，防呆
            uint256 rand = (_randomWords[0] % 10000) + 1; //因為是256bits的數字，所以我只取後面的餘數 共1~10000
            tokenIdToRandomNumber[tokenId] = rand;

            // 中獎機率
            Prize prize;
            if (rand <= 100) {
                prize = Prize.Grand;      // 1%
            } else if (rand <= 600) {
                prize = Prize.First;      // 5%
            } else if (rand <= 1599) {
                prize = Prize.Second;     // 10%
            } else if (rand <= 3998) {
                prize = Prize.Consolation;// 24%
            } else {
                prize = Prize.None;       // 60%
            }
            tokenIdToPrize[tokenId] = prize;
        }

        emit RequestFulfilled(
            _requestId,
            _randomWords,
            s_requests[_requestId].paid
        );
    }
/*
    function getRequestStatus( // 查看狀況
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

    /// @notice withdrawNative withdraws the amount specified in amount to the owner
    /// @param amount the amount to withdraw, in wei
*/
    function withdrawNative(uint256 amount) external onlyOwner { 
        require(amount <= address(this).balance, "Insufficient contract balance");
        (bool success, ) = payable(owner()).call{value: amount}("");
        // solhint-disable-next-line gas-custom-errors
        require(success, "withdrawNative failed");
    }
    // 開發者注入獎池資金
    function addToPool() external payable onlyOwner {
        require(msg.value > 0, "Must send ETH");
        poolBalance += msg.value;
    }

    /// @notice Owner 緊急提領獎池 ETH
    /// @param to 接收地址
    /// @param amount 要提領的金額（wei）

    function withdrawPool(address payable to,uint256 amount) external onlyOwner nonReentrant{
        require(amount <= poolBalance, "Insufficient pool balance");
        require(to != address(0), "Invalid address");
        
        poolBalance -= amount;// 更新池內餘額
        
        (bool success, ) = to.call{ value: amount }(""); // 轉帳
        require(success, "Pool withdrawal failed");
        emit PoolWithdrawn(to, amount);
    }

    // 前端查詢函數用
    function getTokenInfo(uint256 tokenId) external view returns (
        bool revealed,
        uint256 randomNumber,
        Prize prize,
        uint256 potentialPrize
    ) {
        revealed = isRevealed[tokenId];
        randomNumber = tokenIdToRandomNumber[tokenId];
        prize = tokenIdToPrize[tokenId];
        potentialPrize = calculatePrizeAmount(prize);
    }
/*
    function getContractStats() external view returns (  //查看合約狀況
        uint256 totalSupply,
        uint256 currentPoolBalance,
        uint256 currentPlatformFee
    ) {
        totalSupply = nextTokenId - 1;
        currentPoolBalance = poolBalance;
        currentPlatformFee = platformFee;
    }
*/
    event Received(address, uint256);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

}

