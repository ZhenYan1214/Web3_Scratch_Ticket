// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// === Imports ===
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import { VRFV2PlusWrapperConsumerBase } 
    from "@chainlink/contracts/src/v0.8/vrf/dev/VRFV2PlusWrapperConsumerBase.sol";
import { VRFV2PlusClient } 
    from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/// @title LuckyScratch 刮刮樂 NFT 合約
contract ScratchCard is ERC721, VRFV2PlusWrapperConsumerBase, Ownable {
    using VRFV2PlusClient for VRFV2PlusClient.ExtraArgsV1;

    // --- Ticket 結構 ---
    struct Ticket {
        bool revealed;
        uint8 prizeLevel;     // 1=特獎, 2=一獎, 3=二獎, 4=安慰獎, 5=沒中
        uint256 randomNumber;
    }

    // --- State Variables ---
    mapping(uint256 => Ticket) public tickets;        // tokenId → Ticket
    mapping(uint256 => uint256) public requestToToken;// requestId → tokenId
    uint256 public nextTokenId = 1;                   // 自增 TokenId
    uint256 public constant PRICE = 0.01 ether;       // 每張 NFT 價格

    // Chainlink VRF 參數
    uint32  public callbackGasLimit     = 200_000;
    uint16  public requestConfirmations = 3;
    uint32  public numWords             = 1;

    // 揭曉事件
    event Reveal(uint256 indexed tokenId, uint8 prizeLevel);

    /// @param _wrapper Sepolia VRF v2+ wrapper address
    constructor(address _wrapper)
        ERC721("LuckyScratch", "LSCR")
        VRFV2PlusWrapperConsumerBase(_wrapper)
        Ownable()
    {}

    /// @notice Mint NFT 並請求 VRF 隨機數 (以 ETH 支付)
    function mintAndRequest() external payable returns (uint256 requestId) {
        require(msg.value == PRICE, "Must send exactly 0.01 ETH");

        // 1. Mint
        uint256 tokenId = nextTokenId++;
        _safeMint(msg.sender, tokenId);

        // 2. 構造 extraArgs (nativePayment = true)
        bytes memory extraArgs = VRFV2PlusClient._argsToBytes(
            VRFV2PlusClient.ExtraArgsV1({ nativePayment: true })
        );

        // 3. 送出 requestRandomness 並解構回傳 (requestId, requestPrice)
        (requestId, ) = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords,
            extraArgs
        );

        // 4. 紀錄並初始化 Ticket
        requestToToken[requestId] = tokenId;
        tickets[tokenId] = Ticket({
            revealed: false,
            prizeLevel: 0,
            randomNumber: 0
        });
    }

    /// @dev Chainlink VRF 回呼
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        uint256 tokenId = requestToToken[requestId];
        Ticket storage tk = tickets[tokenId];
        require(tk.prizeLevel == 0, "Prize already set");

        uint256 rnd = randomWords[0];
        tk.randomNumber = rnd;
        tk.prizeLevel  = _getPrize(rnd);
    }

    /// @dev 根據 rnd 決定獎項等級
    function _getPrize(uint256 rnd) internal pure returns (uint8) {
        uint256 mod = rnd % 10000; // 0–9999
        if (mod <    1) return 1;  // 0.01% → 特獎
        if (mod <  101) return 2;  // 1.00%  → 一獎
        if (mod <  601) return 3;  // 5.00%  → 二獎
        if (mod < 2499) return 4;  // 14.99% → 安慰獎
                         return 5;  // 79.00% → 沒中
    }

    /// @notice 使用者揭曉，並發放獎勵 (在同一 tx 完成)
    function reveal(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not NFT owner");
        Ticket storage tk = tickets[tokenId];
        require(tk.prizeLevel != 0, "Randomness not fulfilled");
        require(!tk.revealed, "Already revealed");

        tk.revealed = true;
        uint256 bal = address(this).balance;

        if (tk.prizeLevel == 1) {
            _payout(msg.sender, (bal * 40) / 100);
        } else if (tk.prizeLevel == 2) {
            _payout(msg.sender, (bal * 15) / 100);
        } else if (tk.prizeLevel == 3) {
            _payout(msg.sender, (bal * 5) / 100);
        } else if (tk.prizeLevel == 4) {
            _payout(msg.sender, PRICE / 2);
        }
        // prizeLevel == 5: no payout, keep NFT as collectible

        emit Reveal(tokenId, tk.prizeLevel);
    }

    /// @dev 安全發 ETH
    function _payout(address to, uint256 amount) internal {
        require(address(this).balance >= amount, "Insufficient balance");
        (bool ok, ) = to.call{ value: amount }("");
        require(ok, "ETH transfer failed");
    }

    /// @notice Owner 可提領合約 ETH
    function withdraw(uint256 amount) external onlyOwner {
        (bool ok, ) = payable(owner()).call{ value: amount }("");
        require(ok, "Withdraw failed");
    }

    /// @notice 接收者函式，可用來種子補 ETH
    receive() external payable {}
}
