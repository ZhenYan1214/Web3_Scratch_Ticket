const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // Deploy YearnConnector
  const YearnConnector = await hre.ethers.getContractFactory("YearnConnector");
  const yearnConnector = await YearnConnector.deploy(
    process.env.YEARN_VAULT_ADDRESS,
    process.env.USDC_ADDRESS
  );
  await yearnConnector.waitForDeployment();
  console.log("YearnConnector deployed to:", await yearnConnector.getAddress());

  // Deploy PiggyVault
  const PiggyVault = await hre.ethers.getContractFactory("PiggyVault");
  const piggyVault = await PiggyVault.deploy(
    process.env.USDC_ADDRESS,
    "Piggy Vault",
    "PIGGY"
  );
  await piggyVault.waitForDeployment();
  console.log("PiggyVault deployed to:", await piggyVault.getAddress());

  // Set YearnConnector in PiggyVault
  await piggyVault.setYearnConnector(await yearnConnector.getAddress());
  console.log("YearnConnector set in PiggyVault");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 