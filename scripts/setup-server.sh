#!/bin/bash
# Server setup script for Palestine NFT Project
# This script sets up the server environment for hosting the application

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

echo -e "${YELLOW}Starting server setup for Palestine NFT Project${NC}"
echo -e "${YELLOW}Target: ssh $SERVER_USER (IP: $SERVER_IP)${NC}"

# Create setup script to run on the server
cat > server-setup.sh << 'EOF'
#!/bin/bash

# Install required packages
echo "Installing required packages..."
sudo apt-get update
sudo apt-get install -y nginx certbot python3-certbot-nginx nodejs npm

# Create deployment directory
echo "Creating deployment directory..."
sudo mkdir -p /var/www/voiceforpalestine.xyz
sudo chown -R $USER:$USER /var/www/voiceforpalestine.xyz

# Install PM2 for process management (if using server-side rendering)
echo "Installing PM2..."
sudo npm install -g pm2

# Set up Nginx
echo "Setting up Nginx..."
if [ ! -f /etc/nginx/sites-available/voiceforpalestine.xyz ]; then
    echo "Creating Nginx configuration..."
    sudo tee /etc/nginx/sites-available/voiceforpalestine.xyz > /dev/null << 'NGINX_CONF'
server {
    listen 80;
    server_name voiceforpalestine.xyz www.voiceforpalestine.xyz;
    
    root /var/www/voiceforpalestine.xyz;
    index index.html;
    
    # Handle Next.js routes
    location / {
        try_files $uri $uri.html $uri/ /index.html;
    }
    
    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }
    
    # Security headers
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    
    # Enable compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}
NGINX_CONF

    # Enable the site
    sudo ln -sf /etc/nginx/sites-available/voiceforpalestine.xyz /etc/nginx/sites-enabled/
    
    # Test Nginx configuration
    sudo nginx -t
    
    # Reload Nginx
    sudo systemctl reload nginx
fi

# Set up SSL with Let's Encrypt
echo "Setting up SSL with Let's Encrypt..."
sudo certbot --nginx -d voiceforpalestine.xyz -d www.voiceforpalestine.xyz --non-interactive --agree-tos --email admin@voiceforpalestine.xyz

echo "Server setup completed!"
EOF

# Copy setup script to server
echo -e "${YELLOW}Copying setup script to server...${NC}"
scp server-setup.sh $SERVER_USER:~/server-setup.sh

# Make script executable and run it
echo -e "${YELLOW}Running setup script on server...${NC}"
ssh $SERVER_USER "chmod +x ~/server-setup.sh && ~/server-setup.sh"

# Clean up local script
rm server-setup.sh

echo -e "${GREEN}Server setup completed successfully!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Run the deployment script: ${GREEN}./deploy-to-production.sh${NC}"
echo -e "2. Verify the application is running at: ${GREEN}https://$DOMAIN${NC}"
