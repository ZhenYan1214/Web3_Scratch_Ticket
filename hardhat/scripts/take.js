#!/usr/bin/env node
require("dotenv").config();
const { ethers } = require("ethers");

const CONTRACT_ADDRESS = "0x16E8D265dd429E8592A98188c74FE7ba75648818";
const ABI = ["function withdrawNative(uint256 amount) external"];

async function main() {
  const provider = new ethers.providers.JsonRpcProvider(process.env.ALCHEMY_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, wallet);

  const amountEth = "0.1"; 
  const amountWei = ethers.utils.parseEther(amountEth);
  console.log(`開始提領 ${amountEth} ETH…`);

  const tx = await contract.withdrawNative(amountWei);
  console.log("txHash:", tx.hash);
  const receipt = await tx.wait();
  console.log(`提領完成，區塊：${receipt.blockNumber}`);
}

main().catch(err => {
  console.error("執行失敗：", err.message || err);
  process.exit(1);
});
