#!/bin/bash
# Script to fix port conflict between Nginx and Apache

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Fixing port conflict between Nginx and Apache${NC}"

# Create Nginx config file locally
cat > voiceforpalestine.conf << EOF
server {
    listen 8080;
    server_name voiceforpalestine.xyz www.voiceforpalestine.xyz;
    
    root /var/www/voiceforpalestine.xyz;
    index index.html;
    
    # Handle Next.js routes
    location / {
        try_files \$uri \$uri.html \$uri/ /index.html;
    }
    
    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)\$ {
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
EOF

# Copy Nginx config to server
echo -e "${YELLOW}Copying Nginx configuration to server...${NC}"
scp voiceforpalestine.conf echoesofstreet:/tmp/voiceforpalestine.conf

# Move Nginx config to proper location and restart Nginx
echo -e "${YELLOW}Installing Nginx configuration and restarting...${NC}"
ssh echoesofstreet "sudo mv /tmp/voiceforpalestine.conf /etc/nginx/sites-available/voiceforpalestine.xyz && \
sudo ln -sf /etc/nginx/sites-available/voiceforpalestine.xyz /etc/nginx/sites-enabled/ && \
sudo nginx -t && \
sudo systemctl stop nginx && \
sudo systemctl start nginx"

# Clean up local Nginx config
rm voiceforpalestine.conf

echo -e "${GREEN}Port conflict fixed!${NC}"
echo -e "${GREEN}Your application should now be available at: http://voiceforpalestine.xyz:8080${NC}"
