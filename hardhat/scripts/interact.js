const hre = require("hardhat");

async function main() {
  const [signer] = await hre.ethers.getSigners();
  console.log("Interacting with contracts using account:", signer.address);

  // Get contract instances
  const piggyVault = await hre.ethers.getContractAt("PiggyVault", process.env.PIGGY_VAULT_ADDRESS);
  const usdc = await hre.ethers.getContractAt("IERC20", process.env.USDC_ADDRESS);

  // Approve USDC spending
  const depositAmount = hre.ethers.parseUnits("100", 6); // 100 USDC
  await usdc.approve(await piggyVault.getAddress(), depositAmount);
  console.log("Approved USDC spending");

  // Deposit USDC
  await piggyVault.deposit(depositAmount, signer.address);
  console.log("Deposited USDC");

  // Get vault balance
  const balance = await piggyVault.balanceOf(signer.address);
  console.log("Vault balance:", hre.ethers.formatUnits(balance, 18));

  // Withdraw USDC
  await piggyVault.withdraw(depositAmount, signer.address, signer.address);
  console.log("Withdrawn USDC");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 