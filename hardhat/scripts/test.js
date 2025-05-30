const { ethers } = require("hardhat");

async function main() {
  const contractAddress = "0x578D06162196A3C88FB99FEa121a73E56BB62354";
  const balance = await ethers.provider.getBalance(contractAddress);
  console.log("ETH Balance:", ethers.utils.formatEther(balance), "ETH");
}

main();
