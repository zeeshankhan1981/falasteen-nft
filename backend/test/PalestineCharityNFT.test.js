const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PalestineCharityNFT", function () {
  let palestineNFT;
  let owner;
  let charityWallet;
  let buyer;
  const mintPrice = ethers.utils.parseEther("10"); // 10 MATIC

  beforeEach(async function () {
    [owner, charityWallet, buyer] = await ethers.getSigners();
    
    const PalestineNFT = await ethers.getContractFactory("PalestineCharityNFT");
    palestineNFT = await PalestineNFT.deploy(charityWallet.address);
    await palestineNFT.deployed();
  });

  it("Should set the correct charity wallet", async function () {
    expect(await palestineNFT.charityWallet()).to.equal(charityWallet.address);
  });

  it("Should set the correct mint price", async function () {
    expect(await palestineNFT.mintPrice()).to.equal(mintPrice);
  });

  it("Should allow owner to change mint price", async function () {
    const newPrice = ethers.utils.parseEther("15");
    await palestineNFT.setMintPrice(newPrice);
    expect(await palestineNFT.mintPrice()).to.equal(newPrice);
  });

  it("Should not allow non-owner to change mint price", async function () {
    const newPrice = ethers.utils.parseEther("15");
    await expect(
      palestineNFT.connect(buyer).setMintPrice(newPrice)
    ).to.be.reverted;
  });

  it("Should mint NFT and transfer funds to charity wallet", async function () {
    const metadataURI = "ipfs://QmTest";
    const initialBalance = await ethers.provider.getBalance(charityWallet.address);
    
    // Mint NFT
    await palestineNFT.connect(buyer).mintNFT(metadataURI, { value: mintPrice });
    
    // Check token ownership
    expect(await palestineNFT.ownerOf(1)).to.equal(buyer.address);
    
    // Check token URI
    expect(await palestineNFT.tokenURI(1)).to.equal(metadataURI);
    
    // Check charity wallet received funds
    const finalBalance = await ethers.provider.getBalance(charityWallet.address);
    expect(finalBalance.sub(initialBalance)).to.equal(mintPrice);
  });

  it("Should fail if not enough MATIC is sent", async function () {
    const metadataURI = "ipfs://QmTest";
    const insufficientValue = ethers.utils.parseEther("5"); // 5 MATIC
    
    await expect(
      palestineNFT.connect(buyer).mintNFT(metadataURI, { value: insufficientValue })
    ).to.be.revertedWith("Not enough MATIC sent.");
  });
});
