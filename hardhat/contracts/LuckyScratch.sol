// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// OpenZeppelin Contracts for ERC721, security, ownership
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


/**
 * @title LuckyScratch
 * @dev A decentralized NFT scratch card game using ERC721 and Chainlink VRF for randomness.
 */
contract LuckyScratch is ERC721, Ownable, ReentrancyGuard {

    // Prize tiers
    enum Prize { None, Consolation, Tier2, Tier1, Grand }

    // Store scratch card state
    struct Scratch {
        bool revealed;     // whether this token has been revealed
        Prize prize;       // prize tier
    }

    // tokenId => Scratch info
    mapping(uint256 => Scratch) public scratches;
    // Chainlink requestId => tokenId
    mapping(uint256 => uint256) private requestIdToToken;

    ////////////////////////
    // Game Parameters   //
    ////////////////////////

    uint256 public nextTokenId = 1;      // incremental token ID
    uint256 public constant cardPrice = 0.01 ether; // price per scratch NFT
    uint256 public poolBalance;          // ETH balance reserved for prizes

    // Probability thresholds (in basis points, out of 10,000)
    uint16 private constant GRAND_RATE = 10;    // 0.1%
    uint16 private constant TIER1_RATE = 100;  // 1%
    uint16 private constant TIER2_RATE = 500;  // 5%
    uint16 private constant CONS_RATE = 1490;  // 14.9%
    uint16 private constant TOTAL_RATE = 10000; // 100%

    //////////////////////
    // Events           //
    //////////////////////

    event CardPurchased(address indexed buyer, uint256 indexed tokenId);
    event RevealRequested(uint256 indexed tokenId, uint256 indexed requestId);
    event Revealed(uint256 indexed tokenId, Prize prize, uint256 payout);

    /**
     * @param _subscriptionId Chainlink VRF subscription ID
     * @param vrfCoordinator Chainlink VRF coordinator address
     * @param _keyHash Gas lane key hash
     */
    constructor(
    ) ERC721("LuckyScratch", "SCRATCH") 
    }

    //////////////////////
    // Buy & Mint Logic //
    //////////////////////

    /**
     * @dev Purchase a scratch card NFT by paying `cardPrice`. 95% goes to prize pool.
     */
    function buyCard() external payable nonReentrant {
        require(msg.value == cardPrice, "Incorrect payment");

        // Mint new NFT to buyer
        uint256 tokenId = nextTokenId;
        _safeMint(msg.sender, tokenId);
        nextTokenId++;

        // Initialize scratch state
        scratches[tokenId] = Scratch({ revealed: false, prize: Prize.None });

        // Add 95% of sale to prize pool; keep 5% as platform fee
        uint256 toPool = (msg.value * 95) / 100;
        poolBalance += toPool;
        // Owner can withdraw platform fee separately

        emit CardPurchased(msg.sender, tokenId);
    }

    ////////////////////////////////////
    // Reveal & Randomness Functions //
    ////////////////////////////////////

    /**
     * @dev Reveal the prize for `tokenId`. Triggers Chainlink VRF request.
     */
    function reveal(uint256 tokenId) external nonReentrant {
        require(ownerOf(tokenId) == msg.sender, "Not token owner");
        require(!scratches[tokenId].revealed, "Already revealed");

        // Request randomness from Chainlink VRF
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        // Map request to this token
        requestIdToToken[requestId] = tokenId;
        // Mark as revealed to prevent reentry
        scratches[tokenId].revealed = true;

        emit RevealRequested(tokenId, requestId);
    }

    /**
     * @dev Callback from VRF coordinator with random words
     */
    