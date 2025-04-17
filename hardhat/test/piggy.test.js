const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PiggyVault", function () {
  let piggyVault;
  let yearnConnector;
  let usdc;
  let owner;
  let user;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();

    // Deploy mock USDC
    const MockERC20 = await ethers.getContractFactory("MockERC20");
    usdc = await MockERC20.deploy("USD Coin", "USDC", 6);
    await usdc.waitForDeployment();

    // Deploy mock Yearn Vault
    const MockYearnVault = await ethers.getContractFactory("MockYearnVault");
    const mockYearnVault = await MockYearnVault.deploy(await usdc.getAddress());
    await mockYearnVault.waitForDeployment();

    // Deploy YearnConnector
    const YearnConnector = await ethers.getContractFactory("YearnConnector");
    yearnConnector = await YearnConnector.deploy(
      await mockYearnVault.getAddress(),
      await usdc.getAddress()
    );
    await yearnConnector.waitForDeployment();

    // Deploy PiggyVault
    const PiggyVault = await ethers.getContractFactory("PiggyVault");
    piggyVault = await PiggyVault.deploy(
      await usdc.getAddress(),
      "Piggy Vault",
      "PIGGY"
    );
    await piggyVault.waitForDeployment();

    // Set YearnConnector in PiggyVault
    await piggyVault.setYearnConnector(await yearnConnector.getAddress());

    // Mint USDC to user
    const amount = ethers.parseUnits("1000", 6);
    await usdc.mint(user.address, amount);
  });

  describe("Deposit", function () {
    it("Should accept USDC deposits and mint vault tokens", async function () {
      const depositAmount = ethers.parseUnits("100", 6);
      
      // Approve USDC spending
      await usdc.connect(user).approve(await piggyVault.getAddress(), depositAmount);
      
      // Deposit USDC
      await piggyVault.connect(user).deposit(depositAmount, user.address);
      
      // Check vault token balance
      const vaultBalance = await piggyVault.balanceOf(user.address);
      expect(vaultBalance).to.be.gt(0);
    });
  });

  describe("Withdraw", function () {
    it("Should allow withdrawals of USDC", async function () {
      const depositAmount = ethers.parseUnits("100", 6);
      
      // Approve and deposit
      await usdc.connect(user).approve(await piggyVault.getAddress(), depositAmount);
      await piggyVault.connect(user).deposit(depositAmount, user.address);
      
      // Get vault token balance
      const vaultBalance = await piggyVault.balanceOf(user.address);
      
      // Withdraw using maxWithdraw
      const maxWithdraw = await piggyVault.maxWithdraw(user.address);
      await piggyVault.connect(user).withdraw(maxWithdraw, user.address, user.address);
      
      // Check vault token balance is 0
      const finalVaultBalance = await piggyVault.balanceOf(user.address);
      expect(finalVaultBalance).to.equal(0);
      
      // Check USDC balance is restored
      const usdcBalance = await usdc.balanceOf(user.address);
      expect(usdcBalance).to.equal(ethers.parseUnits("1000", 6));
    });
  });
}); 