# 🎰 Lucky Scratch - Web3 NFT Scratchcard on Polygon

**Lucky Scratch** is a fun, gamified NFT DApp where users can mint scratchcard NFTs and instantly reveal their luck. Built on Polygon, the game is fully decentralized, transparent, and 100% on-chain.

---

## 🕹 How It Works

1. Connect wallet (MetaMask)
2. Mint a scratchcard NFT (0.01 ETH)
3. Scratch visually on UI
4. Click "Reveal" → get instant results
5. If you win, ETH is sent directly from the prize pool!

---

## 💸 Prize Tiers

| Prize       | Chance  | Reward              |
|-------------|---------|---------------------|
| 🥇 Jackpot   | 0.1%    | 40% of prize pool   |
| 🥈 2nd Prize | 1%      | 15% of prize pool   |
| 🥉 3rd Prize | 5%      | 5% of prize pool    |
| ✨ Refund    | 15%     | 50% refund          |
| ❌ No Prize  | 78.9%   | No reward           |

> 95% of each mint funds the jackpot.  
> 5% is collected as platform fee.

---

## ⚙️ Tech Stack

- **Frontend**: Vue 3 + ethers.js  
- **Contracts**: Solidity + Hardhat  
- **Blockchain**: Polygon (Mumbai Testnet)  
- **Storage**: IPFS (Pinata)  

---

## 🧱 Core Features

- ERC721 NFT scratchcards  
- Chain-verified prize pool payout  
- IPFS-based image + metadata  
- Real-time mint and reveal logic  

---

## 🛠 Dev Commands

```bash
# Compile contracts
npx hardhat compile

# Deploy to testnet
npx hardhat run scripts/deploy.js --network mumbai
