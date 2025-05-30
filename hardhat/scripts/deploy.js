// scripts/deploy.js

const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const DirectFundingConsumer = await hre.ethers.getContractFactory("DirectFundingConsumer");
  const contract = await DirectFundingConsumer.deploy();
  await contract.deployed();

  console.log("DirectFundingConsumer contract deployed to:", contract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
