import { ethers } from "ethers";
import Web3Modal from "web3modal";
import { CHAIN_ID, CHAIN_NAME, CURRENCY_NAME, CURRENCY_SYMBOL, RPC_URL, BLOCK_EXPLORER_URL } from "./config";

// Setup web3modal for connecting to MetaMask
const providerOptions = {};

let web3Modal;
let provider;

if (typeof window !== "undefined") {
  web3Modal = new Web3Modal({
    network: "mainnet", // optional
    cacheProvider: true, // optional
    providerOptions, // required
  });
}

// Connect to MetaMask
export const connectWallet = async () => {
  try {
    provider = await web3Modal.connect();
    const ethersProvider = new ethers.providers.Web3Provider(provider);
    
    // Check if we're on the correct network
    const { chainId } = await ethersProvider.getNetwork();
    
    if (chainId !== CHAIN_ID) {
      try {
        // Try to switch to the correct network
        await provider.request({
          method: "wallet_switchEthereumChain",
          params: [{ chainId: `0x${CHAIN_ID.toString(16)}` }],
        });
      } catch (switchError) {
        // If the chain is not added to MetaMask, add it
        if (switchError.code === 4902) {
          await provider.request({
            method: "wallet_addEthereumChain",
            params: [
              {
                chainId: `0x${CHAIN_ID.toString(16)}`,
                chainName: CHAIN_NAME,
                nativeCurrency: {
                  name: CURRENCY_NAME,
                  symbol: CURRENCY_SYMBOL,
                  decimals: 18,
                },
                rpcUrls: [RPC_URL],
                blockExplorerUrls: BLOCK_EXPLORER_URL ? [BLOCK_EXPLORER_URL] : [],
              },
            ],
          });
        } else {
          throw switchError;
        }
      }
      
      // After switching networks, get the updated provider
      ethersProvider = new ethers.providers.Web3Provider(provider);
    }
    
    // Add event listener for network changes
    provider.on("chainChanged", (chainId) => {
      // Handle the new network
      window.location.reload();
    });
    
    // Add event listener for account changes
    provider.on("accountsChanged", (accounts) => {
      // Handle the new account
      window.location.reload();
    });
    
    const signer = ethersProvider.getSigner();
    const address = await signer.getAddress();
    
    return {
      provider: ethersProvider,
      signer,
      address,
    };
  } catch (error) {
    console.error("Error connecting to wallet:", error);
    throw error;
  }
};

// Disconnect wallet
export const disconnectWallet = async () => {
  if (web3Modal) {
    web3Modal.clearCachedProvider();
    
    // Remove listeners if provider exists
    if (provider && provider.removeAllListeners) {
      provider.removeAllListeners();
    }
  }
};
