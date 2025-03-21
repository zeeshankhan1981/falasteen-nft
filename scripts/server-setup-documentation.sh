#!/bin/bash
# This script documents the final server setup for voiceforpalestine.xyz and pmimrankhan.xyz

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Server Setup Documentation${NC}"
echo -e "${GREEN}==========================${NC}"

echo -e "\n${YELLOW}Current Server Configuration:${NC}"
echo -e "1. Nginx is the main web server listening on ports 80 and 443"
echo -e "2. Apache is running locally on ports 8081 and 8443"
echo -e "3. voiceforpalestine.xyz is served directly by Nginx"
echo -e "4. pmimrankhan.xyz is proxied by Nginx to Apache"

echo -e "\n${YELLOW}Configuration Files:${NC}"

echo -e "\n${GREEN}Nginx Configuration for voiceforpalestine.xyz:${NC}"
ssh echoesofstreet "cat /etc/nginx/sites-available/voiceforpalestine.xyz"

echo -e "\n${GREEN}Nginx Configuration for pmimrankhan.xyz:${NC}"
ssh echoesofstreet "cat /etc/nginx/sites-available/pmimrankhan.xyz"

echo -e "\n${GREEN}Apache Ports Configuration:${NC}"
ssh echoesofstreet "cat /etc/apache2/ports.conf"

echo -e "\n${GREEN}Apache Configuration for pmimrankhan.xyz:${NC}"
ssh echoesofstreet "cat /etc/apache2/sites-available/imran-khan-vote.conf"

echo -e "\n${YELLOW}Service Status:${NC}"
echo -e "\n${GREEN}Nginx Status:${NC}"
ssh echoesofstreet "systemctl status nginx --no-pager"

echo -e "\n${GREEN}Apache Status:${NC}"
ssh echoesofstreet "systemctl status apache2 --no-pager"

echo -e "\n${YELLOW}Port Usage:${NC}"
ssh echoesofstreet "sudo lsof -i :80 | head -2 && sudo lsof -i :443 | head -2 && sudo lsof -i :8081 | head -2 && sudo lsof -i :8443 | head -2"

echo -e "\n${GREEN}Setup Complete!${NC}"
echo -e "voiceforpalestine.xyz is now accessible at http://voiceforpalestine.xyz"
echo -e "pmimrankhan.xyz is now accessible at http://pmimrankhan.xyz"
echo -e "\nPlease clear your browser cache to see the changes."
