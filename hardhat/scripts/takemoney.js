#!/usr/bin/env node
// hardhat/scripts/takeContractMoney.js
//
// 取用合約 withdrawNative 提領 ETH 到 owner。
// 執行前請先在 hardhat 資料夾下：
//   npm install ethers dotenv
//   建立 .env

require("dotenv").config();
const { ethers } = require("ethers");

// 你的合約地址
const CONTRACT_ADDRESS = "0xF689Df063700A11b5916309c382Ed5d93401927B";
// 只需要 withdrawNative 這個 ABI 片段
const ABI = ["function withdrawNative(uint256 amount) external"];

async function main() {
  // 1. 連到你在 .env 裡設定的 RPC
  if (!process.env.ALCHEMY_URL) {
    console.error("請在 .env 裡填入 RPC_URL");
    process.exit(1);
  }
  const provider = new ethers.providers.JsonRpcProvider(process.env.ALCHEMY_URL);

  // 2. 用 PRIVATE_KEY 建立 signer（必須為合約 owner）
  if (!process.env.PRIVATE_KEY) {
    console.error("請在 .env 裡填入 PRIVATE_KEY（不帶 0x 前綴）");
    process.exit(1);
  }
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

  // 3. 建立合約實例
  const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, wallet);

  // 4. 設定你要提領的金額（ETH 單位）
  const amountEth = "0.1";
  const amountWei = ethers.utils.parseEther(amountEth);
  console.log(`開始從 ${CONTRACT_ADDRESS} 提領 ${amountEth} ETH…`);

  try {
    // 5. 呼叫 withdrawNative
    const tx = await contract.withdrawNative(amountWei);
    console.log("交易已送出，txHash:", tx.hash);

    // 6. 等待鏈上確認
    const receipt = await tx.wait();
    console.log(`✅ 提領完成，交易區塊號：${receipt.blockNumber}`);
  } catch (err) {
    console.error("提領失敗：", err.message || err);
    process.exit(1);
  }
}

main();
