const hre = require("hardhat");

async function main() {
  const contractAddress = "0x578D06162196A3C88FB99FEa121a73E56BB62354";
  const contract = await hre.ethers.getContractAt("DirectFundingConsumer", contractAddress);

  // 只 owner 可以執行，請用部署用的私鑰跑這個 script
  const tx = await contract.requestRandomWords(true, {
    gasLimit: 600000  
  });
  console.log("requestRandomWords tx sent:", tx.hash)   ;

  // 等待交易確認
  await tx.wait();
  console.log("請求已發送！等待 VRF 回調中...");
  process.exit(0);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
