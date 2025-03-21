# Palestine NFT Charity Project

A fully decentralized NFT minting application to support Palestine charity using Polygon (Mainnet), IPFS, and Unstoppable Domains.

## Overview

This project allows users to mint NFTs on the Polygon network, with all proceeds going directly to a charity wallet supporting Palestine. The application is built with decentralization in mind, using IPFS for storage and supporting Web3 wallets like MetaMask.

## Important Details

### Wallet Information
- **Charity Wallet Address**: `0x4801449746c17a07Af227253745B13Ab81Cf7a00`

### Server Information
- **SSH Access**: `echoesofstreet`
- **Server IP**: `95.216.25.234`
- **Web Server**: Nginx installed using port 8080
- **Domain**: voiceforpalestine.xyz hosted on server pointing to 95.216.25.234
- **MISCELLANEOUS**: This server is also hosting pmimrankhan.xyz on the apache2 server

## Tech Stack

- **Blockchain**: Polygon (Mainnet) - Low gas fees, Ethereum-compatible
- **Smart Contract**: Solidity (ERC-721) - NFT standard
- **Framework**: Next.js (React-based) - Fast, SEO-friendly
- **Blockchain Library**: Ethers.js - Lightweight, works well with Next.js
- **Wallet Support**: MetaMask - Most widely used Web3 wallet
- **Storage**: IPFS (NFTs & Frontend) - Decentralized, permanent storage
- **Domain**: Unstoppable Domains / ENS - Web3-native, censorship-resistant
- **Deployment**: Hardhat - Smart contract testing & deployment

## Project Structure

```
falasteen-nft/
├── backend/                 # Smart contract & deployment
│   ├── contracts/           # Solidity smart contracts
│   ├── scripts/             # Deployment scripts
│   ├── test/                # Contract tests
│   └── hardhat.config.js    # Hardhat configuration
├── frontend/                # Next.js frontend
│   ├── components/          # React components
│   ├── lib/                 # Utility functions
│   ├── pages/               # Next.js pages
│   ├── public/              # Static assets
│   │   └── img/             # NFT images for web access
│   │       └── falasteen-child-nft.png  # Main NFT image
│   ├── styles/              # CSS styles
│   └── img/                 # Original NFT images (source files)
├── ipfs/                    # IPFS metadata and images
│   ├── metadata/            # NFT metadata JSON files
│   └── images/              # NFT images for IPFS
└── DEPLOYMENT.md            # Deployment instructions
```

## Getting Started

### Backend Setup
1. Navigate to the backend directory
2. Install dependencies: `npm install`
3. Configure your `.env` file with private keys and RPC URLs
4. Deploy the contract: `npx hardhat run scripts/deploy.js --network polygon`

### Frontend Setup
1. Navigate to the frontend directory
2. Install dependencies: `npm install`
3. Update the contract address in `lib/config.js`
4. Run the development server: `npm run dev`
5. Build for production: `npm run build`

## Ethers.js and Hardhat Compatibility

### Important Compatibility Notes

Ethers.js and Hardhat have specific version dependencies that must be maintained to avoid compatibility issues:

| Hardhat Version | Compatible ethers.js Version | Notes |
|----------------|------------------------------|-------|
| Hardhat ≥ 2.14.0 | ethers v6.x | Requires @nomicfoundation/hardhat-ethers |
| Hardhat < 2.14.0 | ethers v5.x | Requires @nomiclabs/hardhat-ethers |

#### Common Issues and Solutions:

1. **Version Mismatch Errors**:
   - Error: `Error HH606: The project cannot be compiled` - This often occurs when OpenZeppelin contracts require a newer Solidity version than specified in hardhat.config.js
   - Solution: Update the `solidity` version in hardhat.config.js to match the pragma in your contracts

2. **Dependency Conflicts**:
   - Error: `Error: Cannot find module '@nomicfoundation/hardhat-toolbox'` - Missing dependencies
   - Solution: Install the correct toolbox version compatible with your ethers version
   
3. **Ethers v5 vs v6 Breaking Changes**:
   - `ethers.utils` (v5) → `ethers` (v6)
   - `ethers.BigNumber` (v5) → `ethers.BigInt` (v6)
   - `provider.getBalance()` returns different types

4. **Ownable Constructor Changes**:
   - OpenZeppelin v5.x requires explicit owner in constructor: `Ownable(msg.sender)`
   - OpenZeppelin v4.x doesn't require this parameter

#### Recommended Setup for This Project:
```
// package.json dependencies
"ethers": "^5.7.2",
"hardhat": "^2.12.0",
"@nomiclabs/hardhat-ethers": "^2.2.3",
"@openzeppelin/contracts": "^5.0.0"
```

```javascript
// hardhat.config.js
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
// NOT require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.20", // Match this with OpenZeppelin contracts
  // ...
}
```

#### Testing Locally:
When testing locally, always ensure your hardhat node is running with the same configuration as your deployment environment.

### Next.js Image Handling

Next.js requires static assets like images to be placed in the `public` directory to be accessible from the browser. In this project:

1. Original image files are stored in `frontend/img/` (source files)
2. Web-accessible images are stored in `frontend/public/img/` 
3. When referencing images in HTML/JSX, use the path `/img/filename.png` (without 'public')
4. For IPFS metadata, use either relative paths (`/img/filename.png`) or absolute URLs

The project includes three distinct NFT images:
- `falasteen-child-nft.png` - Used for the first NFT
- `falasteen-brutal.png` - Used for the second NFT
- `falasteen-nft.png` - Used for the third NFT

Common image issues:
- If images don't load, ensure they exist in the `public/img/` directory
- For local development, restart the Next.js server after adding new images
- For production, ensure images are included in the build

### NFT Metadata Handling

For local testing, the project uses Next.js API routes to serve NFT metadata:
- API endpoints are available at `/api/metadata/[id]` where `id` is the NFT ID (1, 2, or 3)
- For production, metadata should be uploaded to IPFS and referenced using IPFS URIs
- Local metadata files are stored in `ipfs/local/` for testing
- Production metadata files are stored in `ipfs/metadata/` for IPFS upload

### Mobile Optimization

The application is optimized for mobile devices, which is critical as 99% of users will access the site via mobile browsers:

- Responsive design with mobile-first approach
- Optimized viewport settings to prevent scaling issues
- Adjusted font sizes and spacing for small screens
- Full-width buttons for better touch targets
- Simplified layout for narrow screens
- Properly sized images for mobile data connections

To test the mobile experience:
1. Use browser developer tools to simulate mobile devices
2. Test on actual mobile devices when possible
3. Verify wallet connection works properly on mobile wallets

### Wallet Connection Troubleshooting

When testing the NFT minting functionality, you may encounter the following issues:

#### Network Mismatch Errors
- Error: `underlying network changed` or `network error`
- Solution: Ensure your wallet is connected to the correct network (Hardhat Local for local testing)
- In MetaMask, add a custom network with:
  - Network Name: Hardhat Local
  - RPC URL: http://localhost:8545
  - Chain ID: 31337
  - Currency Symbol: ETH

#### Wallet Connection Issues
- If the wallet doesn't connect, check browser console for errors
- For mobile testing, use a wallet that supports WalletConnect
- Make sure the Hardhat node is running: `npx hardhat node`
- Ensure the contract is deployed to the local network: `npx hardhat run scripts/deploy-local.js --network localhost`

#### Transaction Failures
- If transactions fail, check that you have enough ETH in your wallet
- For local testing, import one of the Hardhat test accounts into MetaMask
- Private keys for test accounts are shown when running `npx hardhat node`

## Deployment Status

The application is successfully deployed and accessible at:
- https://voiceforpalestine.xyz

### Deployment Notes
- The application is deployed on a server with IP 95.216.25.234
- Nginx is configured as the main web server listening on ports 80 and 443
- Nginx directly serves voiceforpalestine.xyz as a Next.js application with proper static asset handling
- Apache is running locally on ports 8081 and 8443
- Nginx proxies requests for pmimrankhan.xyz to Apache
- This configuration ensures that each domain serves the correct content
- The deployment scripts are available in the `scripts` directory

### Multi-Site Server Configuration

This server is configured to host multiple websites simultaneously. For detailed information about the server configuration, conflicts, and solutions, see:

- [Multi-Site Server Configuration Guide](./MULTI_SITE_SERVER_CONFIGURATION.md) - Comprehensive documentation of the server setup
- [DEPLOYMENT.md](./DEPLOYMENT.md) - Detailed deployment instructions

### Server Management Scripts

The following scripts are available to help manage the server:

- [add-new-website.sh](./scripts/add-new-website.sh) - Script to add a new website to the server
- [troubleshoot-server.sh](./scripts/troubleshoot-server.sh) - Script to troubleshoot common server issues
- [backup-server-config.sh](./scripts/backup-server-config.sh) - Script to backup the server configuration
- [final-nextjs-configuration.sh](./scripts/final-nextjs-configuration.sh) - Script documenting the Next.js configuration

These scripts are designed to make it easy to manage multiple websites on the same server while avoiding conflicts.

## Production Deployment

### Environment Configuration

The application supports different environments through environment variables:

1. **Copy the example environment files**:
   ```bash
   # For development
   cp frontend/.env.local.example frontend/.env.local
   
   # For production
   cp frontend/.env.production.example frontend/.env.production
   ```

2. **Configure environment variables**:
   - `NEXT_PUBLIC_NETWORK`: Network to use (`hardhat`, `sepolia`, or `mainnet`)
   - `NEXT_PUBLIC_ENABLE_SIMULATION`: Enable simulation mode (`true` or `false`)
   - `NEXT_PUBLIC_INFURA_KEY`: Your Infura API key

### Simulation Mode

The application includes a simulation mode for testing without requiring actual blockchain transactions:

- When simulation mode is enabled, the app will generate fake token IDs and transaction hashes
- No MetaMask popups or gas fees are required
- User feedback indicates when a mint is simulated vs. real

To enable simulation mode:
```
NEXT_PUBLIC_ENABLE_SIMULATION=true
```

### Deployment to Production

1. **Deploy smart contracts to mainnet**:
   ```bash
   cd backend
   npx hardhat run scripts/deploy.js --network mainnet
   ```

2. **Update contract addresses**:
   - Update the contract address in `frontend/lib/config.js` in the mainnet section
   - Or set the `NEXT_PUBLIC_CONTRACT_ADDRESS` environment variable

3. **Build and deploy the frontend**:
   ```bash
   cd frontend
   npm run build
   npm run export  # Creates a static export in the 'out' directory
   ```

4. **Deploy to your web server**:
   ```bash
   # Example using rsync to deploy to your server
   rsync -avz --delete frontend/out/ echoesofstreet@95.216.25.234:/var/www/voiceforpalestine.xyz/
   ```

5. **Configure Nginx**:
   - See `DEPLOYMENT.md` for detailed Nginx configuration instructions

## Deployment

### Smart Contract Deployment
1. Update the charity wallet address in `deploy.js` with: `0x4801449746c17a07Af227253745B13Ab81Cf7a00`
2. Deploy to Polygon Mainnet: `npx hardhat run scripts/deploy.js --network polygon`
3. Save the deployed contract address for frontend configuration

### Frontend Deployment
1. Build the frontend: `cd frontend && npm run build`
2. Deploy to the baremetal server:
   - SSH into the server: `ssh echoesofstreet`
   - Copy the build files to the Apache web root
   - Configure Apache to serve the Next.js application
   - Set up the domain `voiceforpalestine.xyz` to point to the server

### Server Configuration
1. Apache2 is already installed on the server
2. For Next.js deployment, consider installing:
   - Node.js for server-side rendering
   - PM2 for process management
   - Optional: Install Nginx as a reverse proxy (not currently installed)

## License
MIT
