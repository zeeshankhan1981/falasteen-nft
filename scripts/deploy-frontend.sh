#!/bin/bash
# Script to deploy the frontend to the server

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Building the frontend...${NC}"
cd /Users/zeeshankhan/falasteen-nft/frontend
npm run build

echo -e "${YELLOW}Creating deployment directory on server...${NC}"
ssh echoesofstreet "mkdir -p /var/www/voiceforpalestine.xyz"

echo -e "${YELLOW}Copying frontend files to server...${NC}"
scp -r /Users/zeeshankhan/falasteen-nft/frontend/.next /Users/zeeshankhan/falasteen-nft/frontend/public /Users/zeeshankhan/falasteen-nft/frontend/package.json /Users/zeeshankhan/falasteen-nft/frontend/package-lock.json echoesofstreet:/var/www/voiceforpalestine.xyz/

echo -e "${GREEN}Deployment completed!${NC}"
echo -e "${GREEN}Your application should now be available at: http://voiceforpalestine.xyz:8080${NC}"
