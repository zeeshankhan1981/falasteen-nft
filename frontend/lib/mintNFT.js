import { ethers } from "ethers";
import { CONTRACT_ADDRESS, NFT_PRICE, CHAIN_ID, SIMULATION_ENABLED } from "./config";
import contractAbi from "./contractAbi.json";

export const mintNFT = async (signer, metadataURI) => {
  try {
    console.log("Starting NFT minting process...");
    console.log("Metadata URI:", metadataURI);
    console.log("NFT Price from config:", NFT_PRICE, "ETH");
    console.log("Chain ID:", CHAIN_ID);
    console.log("Simulation enabled:", SIMULATION_ENABLED);
    
    // For testing, simulate the mint if enabled
    if (SIMULATION_ENABLED) {
      console.log("Simulation mode active - simulating successful mint without transaction");
      
      // Generate a fake token ID (for testing only)
      const fakeTokenId = Math.floor(Math.random() * 1000) + 1;
      const fakeTxHash = "0x" + Array(64).fill(0).map(() => Math.floor(Math.random() * 16).toString(16)).join('');
      
      console.log("Simulated mint successful!");
      console.log("Fake token ID:", fakeTokenId);
      console.log("Fake transaction hash:", fakeTxHash);
      
      // Simulate a delay to make it feel more realistic
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      return {
        success: true,
        tokenId: fakeTokenId.toString(),
        txHash: fakeTxHash,
        simulated: true
      };
    }
    
    // For non-local networks, proceed with actual transaction
    // Verify we're on the correct network
    const network = await signer.provider.getNetwork();
    console.log("Current network:", network.chainId, "Expected network:", CHAIN_ID);
    
    if (network.chainId !== CHAIN_ID) {
      throw new Error(`Please switch to the correct network. Expected chainId: ${CHAIN_ID}, got: ${network.chainId}`);
    }

    // Create contract instance
    const contract = new ethers.Contract(CONTRACT_ADDRESS, contractAbi, signer);
    console.log("Contract address:", CONTRACT_ADDRESS);
    
    // Convert price to wei (ETH has 18 decimals)
    const price = ethers.utils.parseEther(NFT_PRICE);
    console.log("NFT price in wei:", price.toString());
    
    // Call the mint function
    console.log("Calling mintNFT function...");
    const tx = await contract.mintNFT(metadataURI, { 
      value: price,
      gasLimit: 500000 // Set a reasonable gas limit
    });
    
    console.log("Transaction hash:", tx.hash);
    
    // Wait for transaction to be mined
    console.log("Waiting for transaction confirmation...");
    const receipt = await tx.wait();
    console.log("Transaction confirmed:", receipt);
    
    // Get the token ID from the event
    const transferEvent = receipt.events.find(event => event.event === 'Transfer');
    const tokenId = transferEvent ? transferEvent.args.tokenId.toString() : 'unknown';
    console.log("Minted token ID:", tokenId);
    
    return {
      success: true,
      tokenId,
      txHash: receipt.transactionHash,
    };
  } catch (error) {
    console.error("Error minting NFT:", error);
    console.error("Error details:", JSON.stringify(error, Object.getOwnPropertyNames(error)));
    
    // Handle specific error types
    if (error.code === 'ACTION_REJECTED') {
      return {
        success: false,
        error: "Transaction was rejected by the user",
      };
    }
    
    if (error.code === 'NETWORK_ERROR') {
      return {
        success: false,
        error: `Network error: Please make sure you're connected to ${CHAIN_ID === 31337 ? 'the local Hardhat network' : 'the correct network'}`,
      };
    }
    
    if (error.code === 'INSUFFICIENT_FUNDS') {
      return {
        success: false,
        error: `Insufficient funds: You need at least ${NFT_PRICE} ETH to mint this NFT`,
      };
    }
    
    if (error.code === 'UNPREDICTABLE_GAS_LIMIT') {
      return {
        success: false,
        error: `Transaction error: The contract may be paused or there might be an issue with the transaction`,
      };
    }
    
    return {
      success: false,
      error: error.message || 'Unknown error occurred',
    };
  }
};
