# Web3 Scratch Ticket - On-Chain Luck with Chainlink VRF

**[Live Demo →](https://luck0613.vercel.app)**  
*Make sure to switch your wallet to the Sepolia Testnet.*  
It takes around **60 seconds** for the random number to be revealed.

## Overview

This is a fully on-chain scratch card DApp built with **Vue** and **Ethers.js**, powered by **Chainlink VRF** for verifiable randomness and **Hardhat** for smart contract development. Deployed on the **Sepolia Testnet**, this project showcases how blockchain-based games can provide transparency, fairness, and trust—all in one lucky spin!

## Contract Details

- **Contract Address:** [`0x16E8D265dd429E8592A98188c74FE7ba75648818`](https://sepolia.etherscan.io/address/0x16E8D265dd429E8592A98188c74FE7ba75648818)
- **Network:** Sepolia Testnet
- **Randomness Provider:** Chainlink VRF v2

## 🎮 Game Rules

Each scratch card costs a fixed amount (in ETH), and prizes are determined based on the **current prize pool balance** multiplied by the **prize percentage**.

### Prize Tiers

| Prize Name             | % of Pool | Odds    |
|------------------------|-----------|---------|
| Grand Prize          | 40%       | 1%      |
| Lucky Prize          | 15%       | 5%      |
| Small Joy            | 5%        | 10%     |
| Thank You Reward     | 2%        | 24%     |
| No Prize             | 0%        | 60%     |

- The prize amount is calculated as:  
  `Prize = prizePool × prizePercentage`

### Fairness Mechanism

To ensure **unpredictable and tamper-proof outcomes**, the project integrates **Chainlink VRF**, which guarantees cryptographically secure randomness both off-chain and on-chain. No one—neither the user nor the contract owner—can predict or manipulate the result.

## Tech Stack

- **Frontend:** Vue 3 + Ethers.js
- **Smart Contract:** Solidity (ERC-721), Chainlink VRF
- **Development:** Hardhat + Sepolia Testnet
- **Deployment:** Vercel

## 🛠 How It Works

1. User connects wallet and purchases a scratch ticket.
2. Contract requests a random number via Chainlink VRF.
3. After a short delay (~60 seconds), the result is revealed on-chain.
4. If the ticket is a winner, the prize is instantly allocated based on pool percentage.

## Try It Now

🔗 [https://luck0613.vercel.app](https://luck0613.vercel.app)  
> Switch your wallet to **Sepolia Testnet** before interacting.

## License

This project is open-source under the [MIT License](LICENSE).
