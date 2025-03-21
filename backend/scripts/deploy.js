const hre = require("hardhat");

async function main() {
    // Use the charity wallet address provided
    const charityWallet = "0x4801449746c17a07Af227253745B13Ab81Cf7a00";
    const PalestineNFT = await hre.ethers.getContractFactory("PalestineCharityNFT");
    const nftContract = await PalestineNFT.deploy(charityWallet);

    await nftContract.deployed();
    console.log(`NFT Contract deployed to: ${nftContract.address}`);
    console.log(`Charity wallet set to: ${charityWallet}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
