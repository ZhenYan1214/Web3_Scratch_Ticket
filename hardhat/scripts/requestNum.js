const hre = require("hardhat");

async function main() {
  const contractAddress = "0x578D06162196A3C88FB99FEa121a73E56BB62354"; // 例如 0x578D06162196A3C88FB99FEa121a73E56BB62354
  const contract = await hre.ethers.getContractAt("DirectFundingConsumer", contractAddress);

  // 取得最新一次 requestId
  const lastRequestId = await contract.lastRequestId();
  console.log("lastRequestId:", lastRequestId.toString());

  // 查詢該 requestId 的狀態與隨機數
  const [paid, fulfilled, randomWords] = await contract.getRequestStatus(lastRequestId);
  console.log("paid:", paid.toString());
  console.log("fulfilled:", fulfilled);
  console.log("randomWords:", randomWords.map(x => x.toString()));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
