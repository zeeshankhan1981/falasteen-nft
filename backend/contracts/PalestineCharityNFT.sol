// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PalestineCharityNFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;
    address payable public charityWallet;
    uint256 public mintPrice = 0 ether; // Free for local testing

    constructor(address payable _charityWallet) ERC721("PalestineNFT", "PNFT") Ownable(msg.sender) {
        charityWallet = _charityWallet;
    }

    function mintNFT(string memory metadataURI) public payable {
        // No payment required for local testing
        
        _tokenIdCounter++;
        _safeMint(msg.sender, _tokenIdCounter);
        _setTokenURI(_tokenIdCounter, metadataURI);

        // Only transfer funds if any were sent
        if (msg.value > 0) {
            charityWallet.transfer(msg.value);
        }
    }

    function setMintPrice(uint256 newPrice) external onlyOwner {
        mintPrice = newPrice;
    }
}
