#!/usr/bin/env node
require("dotenv").config();
const { ethers } = require("ethers");

const CONTRACT_ADDRESS = "0x16E8D265dd429E8592A98188c74FE7ba75648818";
const ABI = ["function addToPool() external payable"];

async function main() {
  const provider = new ethers.providers.JsonRpcProvider(process.env.ALCHEMY_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, wallet);

  const amountEth = "0.3"; // 要添加的 ETH 數量
  const amountWei = ethers.utils.parseEther(amountEth);
  console.log(`開始添加 ${amountEth} ETH 到獎池…`);

  const tx = await contract.addToPool({
    value: amountWei
  });
  console.log("txHash:", tx.hash);
  const receipt = await tx.wait();
  console.log(`添加完成，區塊：${receipt.blockNumber}`);
}

main().catch(err => {
  console.error("執行失敗：", err.message || err);
  process.exit(1);
});
