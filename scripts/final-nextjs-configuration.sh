#!/bin/bash
# This script documents the final configuration for serving the Next.js application at voiceforpalestine.xyz
# while maintaining the separation from pmimrankhan.xyz

# Configure Nginx for voiceforpalestine.xyz with proper Next.js support
sudo tee /etc/nginx/sites-available/voiceforpalestine.xyz > /dev/null << 'EOL'
server {
    listen 80;
    server_name voiceforpalestine.xyz www.voiceforpalestine.xyz;
    
    # Redirect to HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name voiceforpalestine.xyz www.voiceforpalestine.xyz;
    
    ssl_certificate /etc/letsencrypt/live/voiceforpalestine.xyz/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/voiceforpalestine.xyz/privkey.pem;
    
    root /var/www/voiceforpalestine.xyz;
    index index.html;
    
    # Serve Next.js static files
    location /_next/static {
        alias /var/www/voiceforpalestine.xyz/.next/static;
        expires 365d;
        access_log off;
    }
    
    # Serve images and other static files
    location /img {
        alias /var/www/voiceforpalestine.xyz/public/img;
        expires 30d;
        access_log off;
    }
    
    location /favicon.ico {
        alias /var/www/voiceforpalestine.xyz/public/favicon.ico;
        expires 30d;
        access_log off;
    }
    
    # Handle all other requests
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Security headers
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    
    # Enable compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}
EOL

# Make sure the Next.js index.html is copied to the root directory
sudo cp /var/www/voiceforpalestine.xyz/.next/server/pages/index.html /var/www/voiceforpalestine.xyz/index.html

# Ensure proper permissions
sudo chown -R www-data:www-data /var/www/voiceforpalestine.xyz

# Restart Nginx
sudo systemctl restart nginx

echo "Next.js configuration for voiceforpalestine.xyz is complete!"
echo "The site should now be properly serving all static assets and working correctly."
echo "The pmimrankhan.xyz site continues to be served by Apache through Nginx."
