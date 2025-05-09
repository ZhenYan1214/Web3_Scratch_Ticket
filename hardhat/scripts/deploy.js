// scripts/deploy.js
const hre = require("hardhat");

async function main() {
  const LuckyScratch = await hre.ethers.getContractFactory("LuckyScratch");
  const lucky = await LuckyScratch.deploy();

  await lucky.deployed();

  console.log("LuckyScratch deployed to:", lucky.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
