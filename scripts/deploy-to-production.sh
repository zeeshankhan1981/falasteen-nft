#!/bin/bash
# Deployment script for Palestine NFT Project
# This script builds and deploys the frontend to the production server

# Configuration
SERVER_USER="echoesofstreet"
SERVER_IP="95.216.25.234"
DOMAIN="voiceforpalestine.xyz"
DEPLOY_PATH="/var/www/$DOMAIN"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting deployment process for Palestine NFT Project${NC}"
echo -e "${YELLOW}Target: $SERVER_USER@$SERVER_IP:$DEPLOY_PATH${NC}"

# Step 1: Build the frontend
echo -e "${YELLOW}Building frontend application...${NC}"
cd "$(dirname "$0")/../frontend"

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
  echo -e "${YELLOW}Installing dependencies...${NC}"
  npm install
fi

# Create production environment file if it doesn't exist
if [ ! -f ".env.production" ]; then
  echo -e "${YELLOW}Creating .env.production from example...${NC}"
  cp .env.production.example .env.production
  echo -e "${RED}WARNING: You should edit .env.production with your actual values!${NC}"
  echo -e "${RED}Press Enter to continue or Ctrl+C to abort${NC}"
  read
fi

# Build the application
echo -e "${YELLOW}Running production build...${NC}"
npm run build

# Create out directory if next export is needed
if [ ! -d "out" ]; then
  echo -e "${YELLOW}Exporting static site...${NC}"
  npm run export || echo -e "${YELLOW}Skipping export, using .next directory...${NC}"
fi

# Step 2: Deploy to server
echo -e "${YELLOW}Deploying to server...${NC}"

# Check if we're using static export or server-side rendering
if [ -d "out" ]; then
  DEPLOY_SOURCE="out/"
  echo -e "${YELLOW}Deploying static export...${NC}"
else
  DEPLOY_SOURCE=".next/"
  echo -e "${YELLOW}Deploying Next.js build (.next)...${NC}"
fi

# Create deployment directory on server
echo -e "${YELLOW}Creating deployment directory on server...${NC}"
ssh $SERVER_USER@$SERVER_IP "mkdir -p $DEPLOY_PATH"

# Copy package.json and package-lock.json for dependencies
echo -e "${YELLOW}Copying package files...${NC}"
scp package.json package-lock.json $SERVER_USER@$SERVER_IP:$DEPLOY_PATH/

# Copy the build files
echo -e "${YELLOW}Copying build files...${NC}"
rsync -avz --delete $DEPLOY_SOURCE $SERVER_USER@$SERVER_IP:$DEPLOY_PATH/

# Copy public directory
echo -e "${YELLOW}Copying public assets...${NC}"
rsync -avz public/ $SERVER_USER@$SERVER_IP:$DEPLOY_PATH/public/

# If using .next, also copy node_modules
if [ "$DEPLOY_SOURCE" = ".next/" ]; then
  echo -e "${YELLOW}Installing production dependencies on server...${NC}"
  ssh $SERVER_USER@$SERVER_IP "cd $DEPLOY_PATH && npm install --production"
fi

# Step 3: Configure Nginx
echo -e "${YELLOW}Creating Nginx configuration...${NC}"

# Create Nginx config file locally
cat > nginx.conf << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    
    location / {
        root $DEPLOY_PATH;
        try_files \$uri \$uri.html \$uri/ /index.html;
        
        # Enable compression
        gzip on;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    }
    
    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        root $DEPLOY_PATH;
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }
    
    # Security headers
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
}
EOF

# Copy Nginx config to server
echo -e "${YELLOW}Copying Nginx configuration to server...${NC}"
scp nginx.conf $SERVER_USER@$SERVER_IP:/tmp/nginx-$DOMAIN.conf

# Move Nginx config to proper location and reload Nginx
echo -e "${YELLOW}Installing Nginx configuration and reloading...${NC}"
ssh $SERVER_USER@$SERVER_IP "sudo mv /tmp/nginx-$DOMAIN.conf /etc/nginx/sites-available/$DOMAIN && \
sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/ && \
sudo nginx -t && sudo systemctl reload nginx"

# Clean up local Nginx config
rm nginx.conf

echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}Your application should now be available at: http://$DOMAIN${NC}"
echo -e "${YELLOW}Note: For HTTPS, you should set up SSL with Let's Encrypt${NC}"
