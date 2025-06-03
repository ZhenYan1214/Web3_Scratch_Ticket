const { ethers } = require("hardhat");

async function main() {
  // 這裡填你的合約名稱，通常不是 test，除非 contract test {...}
  const Contract = await ethers.getContractFactory("test");
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
