// Network configurations
const networks = {
  // Local Hardhat Network
  hardhat: {
    chainId: 31337,
    chainName: "Hardhat Local",
    currencyName: "Ethereum",
    currencySymbol: "ETH",
    rpcUrl: "http://127.0.0.1:8545",
    blockExplorerUrl: "",
    contractAddress: "0x5FbDB2315678afecb367f032d93F642f64180aa3", // Local contract address
    nftPrice: "0", // Free for local testing
    charityWallet: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8", // Local test account
    appName: "Palestine Charity NFT",
    appDescription: "Support Palestine by minting an NFT. All proceeds go directly to charity.",
    serverDomain: "voiceforpalestine.xyz",
    nftMetadataBaseUri: "ipfs://", // Update with your IPFS CID
  },
  
  // Sepolia Testnet
  sepolia: {
    chainId: 11155111,
    chainName: "Sepolia",
    currencyName: "Sepolia Ethereum",
    currencySymbol: "ETH",
    rpcUrl: "https://sepolia.infura.io/v3/YOUR_INFURA_KEY", // Replace with your Infura key
    blockExplorerUrl: "https://sepolia.etherscan.io",
    contractAddress: "0x0000000000000000000000000000000000000000", // Replace with actual deployed contract
    nftPrice: "0.01", // Low price for testnet
    charityWallet: "0x0000000000000000000000000000000000000000", // Replace with actual charity wallet
    appName: "Palestine Charity NFT",
    appDescription: "Support Palestine by minting an NFT. All proceeds go directly to charity.",
    serverDomain: "voiceforpalestine.xyz",
    nftMetadataBaseUri: "ipfs://", // Update with your IPFS CID
  },
  
  // Ethereum Mainnet
  mainnet: {
    chainId: 1,
    chainName: "Ethereum",
    currencyName: "Ethereum",
    currencySymbol: "ETH",
    rpcUrl: "https://mainnet.infura.io/v3/YOUR_INFURA_KEY", // Replace with your Infura key
    blockExplorerUrl: "https://etherscan.io",
    contractAddress: "0x0000000000000000000000000000000000000000", // Replace with actual deployed contract
    nftPrice: "0.05", // Actual price for mainnet
    charityWallet: "0x0000000000000000000000000000000000000000", // Replace with actual charity wallet
    appName: "Palestine Charity NFT",
    appDescription: "Support Palestine by minting an NFT. All proceeds go directly to charity.",
    serverDomain: "voiceforpalestine.xyz",
    nftMetadataBaseUri: "ipfs://", // Update with your IPFS CID
  }
};

// Determine which network to use
// In production, this would be determined by environment variables
const getNetworkConfig = () => {
  // For local development, default to Hardhat
  if (typeof window === 'undefined') {
    return networks.hardhat;
  }
  
  // Check if simulation mode is enabled via environment variable
  const enableSimulation = process.env.NEXT_PUBLIC_ENABLE_SIMULATION === 'true';
  if (enableSimulation) {
    console.log("Simulation mode enabled - using Hardhat network config");
    return networks.hardhat;
  }
  
  // For production, determine network based on environment
  const networkEnv = process.env.NEXT_PUBLIC_NETWORK || 'hardhat';
  return networks[networkEnv] || networks.hardhat;
};

// Get the active network configuration
const activeNetwork = getNetworkConfig();

// Export the active network configuration
export const CHAIN_ID = activeNetwork.chainId;
export const CHAIN_NAME = activeNetwork.chainName;
export const CURRENCY_NAME = activeNetwork.currencyName;
export const CURRENCY_SYMBOL = activeNetwork.currencySymbol;
export const RPC_URL = activeNetwork.rpcUrl;
export const BLOCK_EXPLORER_URL = activeNetwork.blockExplorerUrl;
export const CONTRACT_ADDRESS = activeNetwork.contractAddress;
export const NFT_PRICE = activeNetwork.nftPrice;
export const CHARITY_WALLET = activeNetwork.charityWallet;
export const APP_NAME = activeNetwork.appName;
export const APP_DESCRIPTION = activeNetwork.appDescription;
export const SERVER_DOMAIN = activeNetwork.serverDomain;
export const NFT_METADATA_BASE_URI = activeNetwork.nftMetadataBaseUri;

// Export a flag for simulation mode
export const SIMULATION_ENABLED = 
  CHAIN_ID === 31337 || process.env.NEXT_PUBLIC_ENABLE_SIMULATION === 'true';
