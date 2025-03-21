#!/bin/bash
# Script to add a new website to the server
# Usage: ./add-new-website.sh domain.com [static|nextjs|php]

# Check if domain name is provided
if [ -z "$1" ]; then
    echo "Error: Domain name is required."
    echo "Usage: ./add-new-website.sh domain.com [static|nextjs|php]"
    exit 1
fi

DOMAIN=$1
TYPE=${2:-static}  # Default to static website if not specified

echo "Adding new website: $DOMAIN (Type: $TYPE)"

# Create document root
echo "Creating document root..."
sudo mkdir -p /var/www/$DOMAIN
sudo chown -R www-data:www-data /var/www/$DOMAIN

# Obtain SSL certificate
echo "Obtaining SSL certificate..."
sudo certbot certonly --webroot -w /var/www/$DOMAIN -d $DOMAIN -d www.$DOMAIN

# Create Nginx configuration based on website type
echo "Creating Nginx configuration..."

if [ "$TYPE" == "static" ]; then
    # Static website configuration
    sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null << EOL
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    
    # Redirect to HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $DOMAIN www.$DOMAIN;
    
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
    root /var/www/$DOMAIN;
    index index.html;
    
    location / {
        try_files \$uri \$uri/ /index.html;
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

elif [ "$TYPE" == "nextjs" ]; then
    # Next.js website configuration
    sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null << EOL
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    
    # Redirect to HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $DOMAIN www.$DOMAIN;
    
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
    root /var/www/$DOMAIN;
    index index.html;
    
    # Serve Next.js static files
    location /_next/static {
        alias /var/www/$DOMAIN/.next/static;
        expires 365d;
        access_log off;
    }
    
    # Serve images and other static files
    location /img {
        alias /var/www/$DOMAIN/public/img;
        expires 30d;
        access_log off;
    }
    
    location /favicon.ico {
        alias /var/www/$DOMAIN/public/favicon.ico;
        expires 30d;
        access_log off;
    }
    
    # Handle all other requests
    location / {
        try_files \$uri \$uri/ /index.html;
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

elif [ "$TYPE" == "php" ]; then
    # PHP website configuration (proxied to Apache)
    sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null << EOL
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    
    # Redirect to HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $DOMAIN www.$DOMAIN;
    
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
    # Proxy all requests to Apache
    location / {
        proxy_pass http://127.0.0.1:8081;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
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

    # Create Apache configuration for PHP site
    echo "Creating Apache configuration..."
    sudo tee /etc/apache2/sites-available/$DOMAIN.conf > /dev/null << EOL
<VirtualHost 127.0.0.1:8081>
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    
    DocumentRoot /var/www/$DOMAIN
    
    <Directory /var/www/$DOMAIN>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/${DOMAIN}_error.log
    CustomLog \${APACHE_LOG_DIR}/${DOMAIN}_access.log combined
</VirtualHost>
EOL

    # Enable Apache site
    sudo a2ensite $DOMAIN.conf
    sudo systemctl restart apache2
else
    echo "Error: Invalid website type. Must be one of: static, nextjs, php"
    exit 1
fi

# Enable Nginx site
echo "Enabling Nginx site..."
sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx

echo "Website setup complete!"
echo "Domain: $DOMAIN"
echo "Type: $TYPE"
echo "Document Root: /var/www/$DOMAIN"
echo ""
echo "Next steps:"
echo "1. Upload your website files to /var/www/$DOMAIN"
echo "2. If using Next.js, build your application and copy the .next directory"
echo "3. Ensure proper permissions: sudo chown -R www-data:www-data /var/www/$DOMAIN"
echo ""
echo "Your website should now be accessible at https://$DOMAIN"
