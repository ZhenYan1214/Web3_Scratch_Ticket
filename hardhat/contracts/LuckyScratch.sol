// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LuckyScratch is ERC721URIStorage, Ownable {
    uint256 public tokenId;
    uint256 public ticketPrice = 0.01 ether;
    uint256 public totalPool;

    enum PrizeLevel { None, Consolation, Third, Second, First, Jackpot }

    struct TicketInfo {
        bool isWinning;
        PrizeLevel level;
        bool isClaimed;
    }

    mapping(uint256 => TicketInfo) public ticketData;

    constructor() ERC721("LuckyScratch", "LSNFT") Ownable(msg.sender) {}

    function mint() external payable {
        require(msg.value == ticketPrice, "Incorrect ETH amount");

        tokenId++;
        _safeMint(msg.sender, tokenId);

        // 寫入中獎資訊（簡單隨機）
        uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, tokenId))) % 10000;
        TicketInfo memory info;

        if (rand < 10) {
            info = TicketInfo(true, PrizeLevel.Jackpot, false);
        } else if (rand < 110) {
            info = TicketInfo(true, PrizeLevel.First, false);
        } else if (rand < 610) {
            info = TicketInfo(true, PrizeLevel.Second, false);
        } else if (rand < 1610) {
            info = TicketInfo(true, PrizeLevel.Third, false);
        } else if (rand < 3110) {
            info = TicketInfo(true, PrizeLevel.Consolation, false);
        } else {
            info = TicketInfo(false, PrizeLevel.None, false);
        }

        ticketData[tokenId] = info;

        // 將票價加入獎池
        totalPool += (msg.value * 98) / 100;
    }

    function getPrizeAmount(PrizeLevel level) public view returns (uint256) {
        if (level == PrizeLevel.Jackpot) return (totalPool * 50) / 100;
        if (level == PrizeLevel.First) return (totalPool * 20) / 100;
        if (level == PrizeLevel.Second) return (totalPool * 10) / 100;
        if (level == PrizeLevel.Third) return (totalPool * 5) / 100;
        if (level == PrizeLevel.Consolation) return 0.005 ether;
        return 0;
    }

    function claimPrize(uint256 _tokenId) external {
        require(ownerOf(_tokenId) == msg.sender, "Not the owner");
        TicketInfo storage info = ticketData[_tokenId];
        require(info.isWinning, "Not a winning ticket");
        require(!info.isClaimed, "Already claimed");

        uint256 amount = getPrizeAmount(info.level);
        require(address(this).balance >= amount, "Insufficient contract balance");

        info.isClaimed = true;
        payable(msg.sender).transfer(amount);
    }

    // 可提取剩餘收益（如平台手續費）
    function withdraw() external onlyOwner {
        uint256 remain = address(this).balance - totalPool;
        payable(owner()).transfer(remain);
    }

    // 查看 NFT 是否中獎與等級
    function viewResult(uint256 _tokenId) external view returns (bool, PrizeLevel) {
        TicketInfo memory info = ticketData[_tokenId];
        return (info.isWinning, info.level);
    }
}
