import { useState, useEffect } from "react";
import { ethers } from "ethers";
import { connectWallet, disconnectWallet } from "../lib/connectWallet";
import { mintNFT } from "../lib/mintNFT";
import { NFT_PRICE, APP_NAME, APP_DESCRIPTION, CHARITY_WALLET } from "../lib/config";

export default function Home() {
  const [walletInfo, setWalletInfo] = useState(null);
  const [status, setStatus] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [selectedNFT, setSelectedNFT] = useState(1);

  // Using the actual NFT image
  const nfts = [
    {
      id: 1,
      name: "Falasteen Child NFT",
      description: "Support Palestine with this NFT. All proceeds go directly to charity.",
      image: "/img/falasteen-child-nft.png",
      metadataURI: "/api/metadata/1", // Local testing endpoint without hostname
    },
    {
      id: 2,
      name: "Falasteen Brutal NFT",
      description: "Support Palestine with this NFT. All proceeds go directly to charity.",
      image: "/img/falasteen-brutal.png",
      metadataURI: "/api/metadata/2", // Local testing endpoint without hostname
    },
    {
      id: 3,
      name: "Falasteen NFT",
      description: "Support Palestine with this NFT. All proceeds go directly to charity.",
      image: "/img/falasteen-nft.png",
      metadataURI: "/api/metadata/3", // Local testing endpoint without hostname
    },
  ];

  // Handle wallet connection
  const handleConnectWallet = async () => {
    try {
      setIsLoading(true);
      setStatus("Connecting wallet...");
      const info = await connectWallet();
      setWalletInfo(info);
      setStatus(`Connected: ${info.address.slice(0, 6)}...${info.address.slice(-4)}`);
    } catch (error) {
      console.error("Error connecting wallet:", error);
      
      // Handle specific error types
      if (error.code === 4001) {
        // User rejected the request
        setStatus("Connection rejected. Please approve the connection request.");
      } else if (error.message && error.message.includes("network")) {
        // Network related error
        setStatus(`Network error: Please connect to the correct network (Hardhat Local).`);
      } else {
        setStatus(`Error: ${error.message || "Could not connect to wallet"}`);
      }
    } finally {
      setIsLoading(false);
    }
  };

  // Handle wallet disconnection
  const handleDisconnectWallet = async () => {
    try {
      await disconnectWallet();
      setWalletInfo(null);
      setStatus("");
    } catch (error) {
      console.error("Error disconnecting wallet:", error);
    }
  };

  // Handle NFT minting
  const handleMintNFT = async (nft) => {
    try {
      // Check if wallet is connected
      if (!walletInfo) {
        setStatus("Please connect your wallet first");
        return;
      }

      setSelectedNFT(nft.id);
      setIsLoading(true);
      setStatus(`Minting ${nft.name}...`);
      console.log("Starting mint process for:", nft.name);
      console.log("Using metadata URI:", nft.metadataURI);

      // Mint the NFT
      const result = await mintNFT(walletInfo.signer, nft.metadataURI);
      console.log("Mint result:", result);

      if (result.success) {
        if (result.simulated) {
          setStatus(`Successfully minted ${nft.name}! (Simulated for local testing)`);
        } else {
          setStatus(`Successfully minted ${nft.name}! Token ID: ${result.tokenId}`);
        }
        // Show success message or redirect to a success page
      } else {
        setStatus(`Error: ${result.error}`);
      }
    } catch (error) {
      console.error("Error in handleMintNFT:", error);
      // More detailed error logging
      console.error("Error details:", JSON.stringify(error, Object.getOwnPropertyNames(error)));
      setStatus(`Error: ${error.message || "Unknown error occurred"}`);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="container">
      <header className="header">
        <h1>{APP_NAME}</h1>
        {!walletInfo ? (
          <button className="connect-wallet" onClick={handleConnectWallet} disabled={isLoading}>
            Connect Wallet
          </button>
        ) : (
          <button onClick={handleDisconnectWallet}>
            Disconnect: {walletInfo.address.slice(0, 6)}...{walletInfo.address.slice(-4)}
          </button>
        )}
      </header>

      <section className="hero">
        <h1>Support Palestine through NFTs</h1>
        <p>{APP_DESCRIPTION}</p>
      </section>

      <div className="card">
        <h2>How It Works</h2>
        <div className="how-it-works">
          <p>
            1. Connect your MetaMask wallet<br />
            2. Select an NFT to mint<br />
            3. Pay {NFT_PRICE === "0" ? "Free" : `${NFT_PRICE} ETH`} to mint your NFT<br />
            4. 100% of proceeds go directly to the charity wallet
          </p>
          <p>
            <strong>Charity Wallet:</strong> {CHARITY_WALLET}
          </p>
        </div>
      </div>

      <h2>Available NFTs</h2>
      <div className="nft-grid">
        {nfts.map((nft) => (
          <div 
            key={nft.id} 
            className={`nft-card ${selectedNFT === nft.id ? 'selected' : ''}`}
            onClick={() => handleMintNFT(nft)}
          >
            <div className="nft-image-container">
              <img src={nft.image} alt={nft.name} className="nft-image" />
            </div>
            <h3>{nft.name}</h3>
            <p>{nft.description}</p>
            <div className="nft-price">
              <strong>{NFT_PRICE === "0" ? "Free" : `${NFT_PRICE} ETH`}</strong>
            </div>
          </div>
        ))}
      </div>

      <button 
        className="mint-button" 
        onClick={() => handleMintNFT(nfts.find(n => n.id === selectedNFT))} 
        disabled={!walletInfo || isLoading}
      >
        {isLoading ? "Processing..." : `Mint NFT for ${NFT_PRICE === "0" ? "Free" : `${NFT_PRICE} ETH`}`}
      </button>

      {status && (
        <div className={`status ${status.includes("Error") ? "error" : status.includes("Success") ? "success" : ""}`}>
          {status}
        </div>
      )}

      <footer className="footer">
        <p> {new Date().getFullYear()} Palestine Charity NFT. All rights reserved.</p>
        <p>All proceeds go directly to support Palestine.</p>
      </footer>
    </div>
  );
}
