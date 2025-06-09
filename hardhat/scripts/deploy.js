const { ethers } = require("hardhat");

async function main() {

  const Contract = await ethers.getContractFactory("ScratchTicket");
  const contract = await Contract.deploy();

  await contract.deployed();

  console.log("Deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
