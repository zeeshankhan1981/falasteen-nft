#!/bin/bash

# Palestine NFT Deployment Script
# This script automates the deployment process for the Palestine NFT project

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Palestine NFT Deployment Script ===${NC}"
echo -e "This script will help you deploy the Palestine NFT project to your server."

# Check if .env file exists in backend directory
if [ ! -f "./backend/.env" ]; then
  echo -e "${YELLOW}Warning: .env file not found in backend directory.${NC}"
  echo -e "Creating .env file from .env.example..."
  
  if [ -f "./backend/.env.example" ]; then
    cp ./backend/.env.example ./backend/.env
    echo -e "${GREEN}Created .env file. Please edit it with your private key and other details.${NC}"
  else
    echo -e "${RED}Error: .env.example file not found in backend directory.${NC}"
    exit 1
  fi
fi

# Function to deploy smart contract
deploy_contract() {
  echo -e "\n${GREEN}=== Deploying Smart Contract ===${NC}"
  
  cd backend
  
  # Install dependencies if node_modules doesn't exist
  if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
  fi
  
  # Compile contract
  echo "Compiling contract..."
  npx hardhat compile
  
  # Deploy to specified network
  echo "Deploying contract to $1 network..."
  npx hardhat run scripts/deploy.js --network $1
  
  cd ..
  
  echo -e "${GREEN}Contract deployment complete.${NC}"
  echo -e "${YELLOW}Make sure to update the contract address in frontend/lib/config.js${NC}"
}

# Function to build and deploy frontend
build_frontend() {
  echo -e "\n${GREEN}=== Building Frontend ===${NC}"
  
  cd frontend
  
  # Install dependencies if node_modules doesn't exist
  if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
  fi
  
  # Build frontend
  echo "Building frontend..."
  npm run build
  
  cd ..
  
  echo -e "${GREEN}Frontend build complete.${NC}"
}

# Function to deploy to server
deploy_to_server() {
  echo -e "\n${GREEN}=== Deploying to Server ===${NC}"
  
  SERVER_USER="echoesofstreet"
  SERVER_IP="95.216.25.234"
  SERVER_DIR="/var/www/voiceforpalestine.xyz"
  
  echo "Deploying to server: $SERVER_IP"
  echo "Target directory: $SERVER_DIR"
  
  # Create SSH command
  SSH_CMD="ssh $SERVER_USER@$SERVER_IP"
  
  # Check if server directory exists, create if not
  echo "Checking if server directory exists..."
  $SSH_CMD "sudo mkdir -p $SERVER_DIR && sudo chown -R $SERVER_USER:$SERVER_USER $SERVER_DIR"
  
  # Copy frontend files to server
  echo "Copying frontend files to server..."
  rsync -avz --delete frontend/.next $SERVER_USER@$SERVER_IP:$SERVER_DIR/
  rsync -avz --delete frontend/public $SERVER_USER@$SERVER_IP:$SERVER_DIR/
  rsync -avz frontend/package.json frontend/package-lock.json $SERVER_USER@$SERVER_IP:$SERVER_DIR/
  
  # Install dependencies and start the app on the server
  echo "Installing dependencies on server..."
  $SSH_CMD "cd $SERVER_DIR && npm install --production"
  
  # Check if PM2 is installed, install if not
  echo "Checking if PM2 is installed..."
  $SSH_CMD "command -v pm2 || sudo npm install -g pm2"
  
  # Start the app with PM2
  echo "Starting the app with PM2..."
  $SSH_CMD "cd $SERVER_DIR && pm2 delete palestine-nft 2>/dev/null || true && pm2 start npm --name 'palestine-nft' -- start && pm2 save"
  
  echo -e "${GREEN}Deployment to server complete.${NC}"
}

# Main menu
while true; do
  echo -e "\n${GREEN}=== Deployment Options ===${NC}"
  echo "1) Deploy smart contract to Mumbai testnet"
  echo "2) Deploy smart contract to Polygon mainnet"
  echo "3) Build frontend"
  echo "4) Deploy to server"
  echo "5) Full deployment (contract to mainnet + frontend + server)"
  echo "6) Exit"
  
  read -p "Select an option (1-6): " option
  
  case $option in
    1)
      deploy_contract "mumbai"
      ;;
    2)
      deploy_contract "polygon"
      ;;
    3)
      build_frontend
      ;;
    4)
      deploy_to_server
      ;;
    5)
      deploy_contract "polygon"
      build_frontend
      deploy_to_server
      ;;
    6)
      echo -e "${GREEN}Exiting deployment script.${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid option. Please select a number between 1 and 6.${NC}"
      ;;
  esac
done
