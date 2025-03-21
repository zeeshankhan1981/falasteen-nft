#!/bin/bash
# Script to completely fix domain conflict by ensuring each domain is served by the correct server

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Completely fixing domain conflict between Apache and Nginx${NC}"

# Connect to server and execute commands
ssh echoesofstreet "
    echo 'Stopping all web servers...'
    sudo systemctl stop apache2
    sudo systemctl stop nginx
    
    echo 'Removing any proxy configurations for voiceforpalestine.xyz in Apache...'
    sudo rm -f /etc/apache2/sites-enabled/voiceforpalestine-proxy.conf
    sudo rm -f /etc/apache2/sites-available/voiceforpalestine-proxy.conf
    
    echo 'Updating Apache configuration to ONLY serve pmimrankhan.xyz...'
    sudo tee /etc/apache2/sites-available/imran-khan-vote.conf > /dev/null << 'EOL'
<VirtualHost *:80>
    ServerName pmimrankhan.xyz
    ServerAlias www.pmimrankhan.xyz
    
    DocumentRoot /var/www/html
    
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog /error.log
    CustomLog /access.log combined
    
    RewriteEngine on
    RewriteCond %{SERVER_NAME} =pmimrankhan.xyz [OR]
    RewriteCond %{SERVER_NAME} =www.pmimrankhan.xyz
    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>
EOL

    echo 'Configuring Apache to ONLY listen for pmimrankhan.xyz...'
    sudo tee /etc/apache2/ports.conf > /dev/null << 'EOL'
# If you just change the port or add more ports here, you will likely also
# have to change the VirtualHost statement in
# /etc/apache2/sites-enabled/000-default.conf

Listen 127.0.0.1:80

<IfModule ssl_module>
	Listen 443
</IfModule>

<IfModule mod_gnutls.c>
	Listen 443
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
EOL

    echo 'Updating Nginx configuration to serve voiceforpalestine.xyz on port 80...'
    sudo tee /etc/nginx/sites-available/voiceforpalestine.xyz > /dev/null << 'EOL'
server {
    listen 80;
    server_name voiceforpalestine.xyz www.voiceforpalestine.xyz;
    
    root /var/www/voiceforpalestine.xyz;
    index index.html;
    
    # Handle Next.js routes
    location / {
        try_files \$uri \$uri.html \$uri/ /index.html;
    }
    
    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 30d;
        add_header Cache-Control \"public, no-transform\";
    }
    
    # Security headers
    add_header X-Content-Type-Options \"nosniff\" always;
    add_header X-XSS-Protection \"1; mode=block\" always;
    add_header X-Frame-Options \"SAMEORIGIN\" always;
    
    # Enable compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}
EOL

    echo 'Removing default Nginx site...'
    sudo rm -f /etc/nginx/sites-enabled/default
    
    echo 'Enabling Nginx site...'
    sudo ln -sf /etc/nginx/sites-available/voiceforpalestine.xyz /etc/nginx/sites-enabled/
    
    echo 'Testing configurations...'
    sudo apache2ctl configtest
    sudo nginx -t
    
    echo 'Starting Nginx first (to claim port 80 for voiceforpalestine.xyz)...'
    sudo systemctl start nginx
    
    echo 'Starting Apache (will only listen on 127.0.0.1:80)...'
    sudo systemctl start apache2
    
    echo 'Verifying services are running...'
    sudo systemctl status apache2 --no-pager
    sudo systemctl status nginx --no-pager
    
    echo 'Checking which processes are listening on which ports...'
    sudo netstat -tulpn | grep -E ':80|:8080'
"

echo -e "${GREEN}Domain conflict should now be fixed!${NC}"
echo -e "${YELLOW}Please try accessing the sites again after clearing your browser cache:${NC}"
echo -e "1. In Firefox, press Command+Shift+Delete (Mac)"
echo -e "2. Select 'Everything' for the time range"
echo -e "3. Check 'Cache' and 'Cookies'"
echo -e "4. Click 'Clear Now'"
echo -e "5. Close and reopen Firefox"
echo -e "6. Try accessing http://voiceforpalestine.xyz and http://pmimrankhan.xyz again"
