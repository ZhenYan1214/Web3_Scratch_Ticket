// test/luckyScratch.test.js
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("LuckyScratch", function () {
  let LuckyScratch, luckyScratch, owner, user;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();
    LuckyScratch = await ethers.getContractFactory("LuckyScratch");
    luckyScratch = await LuckyScratch.deploy();
    await luckyScratch.deployed();
  });

  it("should mint a new NFT and store ticket info", async function () {
    const tx = await luckyScratch.connect(user).mint({ value: ethers.utils.parseEther("0.01") });
    await tx.wait();

    const ownerOfToken = await luckyScratch.ownerOf(1);
    expect(ownerOfToken).to.equal(user.address);

    const [isWinning, level] = await luckyScratch.viewResult(1);
    expect(typeof isWinning).to.equal("boolean");
    expect(level).to.be.a("number");
  });

  it("should allow claiming prize if winning", async function () {
    await luckyScratch.connect(user).mint({ value: ethers.utils.parseEther("0.01") });
    const [isWinning] = await luckyScratch.viewResult(1);

    if (isWinning) {
      const claimTx = await luckyScratch.connect(user).claimPrize(1);
      await claimTx.wait();
      const data = await luckyScratch.ticketData(1);
      expect(data.isClaimed).to.equal(true);
    } else {
      await expect(luckyScratch.connect(user).claimPrize(1)).to.be.revertedWith("Not a winning ticket");
    }
  });
});