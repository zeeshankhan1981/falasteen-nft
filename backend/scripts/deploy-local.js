const hre = require("hardhat");

async function main() {
  // Get the first account from hardhat node to use as charity wallet
  const [deployer, charityWallet] = await hre.ethers.getSigners();
  
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Charity wallet address:", charityWallet.address);

  // Deploy the contract
  const PalestineNFT = await hre.ethers.getContractFactory("PalestineCharityNFT");
  const nftContract = await PalestineNFT.deploy(charityWallet.address);

  await nftContract.deployed();
  console.log(`NFT Contract deployed to: ${nftContract.address}`);
  console.log(`Charity wallet set to: ${charityWallet.address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
