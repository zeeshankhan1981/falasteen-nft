# Deployment Guide for Palestine NFT Project

This guide provides detailed instructions for deploying the Palestine NFT project to the baremetal server.

## Server Information
- **SSH Access**: `echoesofstreet`
- **Server IP**: `95.216.25.234`
- **Web Server**: Nginx (installed on port 8080) and Apache (for other websites)
- **Domain**: `voiceforpalestine.xyz`

## Prerequisites
Before deployment, ensure you have:
1. SSH access to the server
2. The domain `voiceforpalestine.xyz` configured to point to the server
3. The smart contract deployed to Polygon Mainnet
4. The deployed contract address
5. Server with Ubuntu 22.04 or later
6. Nginx installed on the server
7. Apache installed on the server (for other websites)

## Smart Contract Deployment

1. Update the `.env` file in the backend directory with your private key:
   ```
   PRIVATE_KEY=your_wallet_private_key
   POLYGON_RPC_URL=https://polygon-rpc.com
   POLYGONSCAN_API_KEY=your_polygonscan_api_key
   ```

2. Deploy the contract to Polygon Mainnet:
   ```bash
   cd backend
   npx hardhat run scripts/deploy.js --network polygon
   ```

3. Save the deployed contract address for frontend configuration.

## Frontend Configuration

1. Update the contract address in `frontend/lib/config.js`:
   ```javascript
   export const CONTRACT_ADDRESS = "YOUR_DEPLOYED_CONTRACT_ADDRESS";
   ```

2. Build the frontend:
   ```bash
   cd frontend
   npm run build
   ```

## Server Configuration

The application is deployed on a server with the following specifications:
- IP Address: 95.216.25.234
- Operating System: Ubuntu
- Web Server: Nginx
- SSH Access: User `echoesofstreet`

For detailed information about the server configuration, including how multiple websites are hosted on this server, please refer to the [Multi-Site Server Configuration Guide](./MULTI_SITE_SERVER_CONFIGURATION.md).

### Domain Setup

The application is accessible at:
- https://voiceforpalestine.xyz

The domain is configured with:
- SSL certificate from Let's Encrypt
- HTTP to HTTPS redirection
- Proper Next.js static asset handling

### Web Server Configuration

Nginx is configured to serve the Next.js application with:
- Static asset caching
- Gzip compression
- Security headers
- Proper routing for Next.js

For detailed information about the Nginx configuration for Next.js, see the [final-nextjs-configuration.sh](./scripts/final-nextjs-configuration.sh) script.

### Multi-Site Hosting

This server hosts multiple websites:
1. voiceforpalestine.xyz (Nginx, Next.js)
2. pmimrankhan.xyz (Apache, proxied through Nginx)

The configuration ensures that each site is properly isolated and served correctly. For adding additional websites to this server, follow the guidelines in the [Multi-Site Server Configuration Guide](./MULTI_SITE_SERVER_CONFIGURATION.md#adding-new-websites).

### Potential Conflicts and Solutions

The server has been configured to avoid common conflicts when hosting multiple websites:
- Port binding conflicts between Nginx and Apache
- Domain serving conflicts
- SSL certificate conflicts
- Static asset serving issues

All these conflicts and their solutions are documented in the [Resolved Conflicts](./MULTI_SITE_SERVER_CONFIGURATION.md#resolved-conflicts) section of the Multi-Site Server Configuration Guide.

### Legacy Configuration Information

The following information is kept for historical reference but has been superseded by the current configuration:

### Nginx Configuration
Nginx is configured to serve the application on port 8080. This is because Apache is already using port 80 for other websites.

```nginx
server {
    listen 8080;
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
```

### Apache Reverse Proxy Configuration
Apache is configured as a reverse proxy to forward requests for voiceforpalestine.xyz from port 80 to Nginx on port 8080. This allows the application to be accessed without specifying the port.

```apache
<VirtualHost *:80>
    ServerName voiceforpalestine.xyz
    ServerAlias www.voiceforpalestine.xyz
    
    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/
    
    ErrorLog ${APACHE_LOG_DIR}/voiceforpalestine-error.log
    CustomLog ${APACHE_LOG_DIR}/voiceforpalestine-access.log combined
</VirtualHost>
```

## Current Configuration

The current server configuration uses Nginx as the primary web server listening on ports 80 and 443, with Apache running locally on ports 8081 and 8443. This setup is documented in detail in the [Multi-Site Server Configuration Guide](./MULTI_SITE_SERVER_CONFIGURATION.md).

## Server Deployment

### 1. SSH into the server
```bash
ssh echoesofstreet
```

### 2. Install Node.js and PM2 (if not already installed)
```bash
# Update package lists
sudo apt update

# Install Node.js and npm
sudo apt install -y nodejs npm

# Install PM2 globally
sudo npm install -g pm2
```

### 3. Install and configure Nginx

```bash
# Install Nginx
sudo apt update
sudo apt install -y nginx

# Start Nginx and enable it to start on boot
sudo systemctl start nginx
sudo systemctl enable nginx

# Check if Nginx is running
sudo systemctl status nginx
```

### 4. Set up the web server with Nginx

1. Create a virtual host configuration:
   ```bash
   sudo nano /etc/nginx/sites-available/voiceforpalestine.xyz
   ```

2. Add the Nginx configuration:
   ```nginx
   server {
       listen 8080;
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
   ```

3. Enable the site and restart Nginx:
   ```bash
   sudo ln -s /etc/nginx/sites-available/voiceforpalestine.xyz /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl restart nginx
   ```

### 5. Deploy the Next.js application

1. Create a directory for the application:
   ```bash
   sudo mkdir -p /var/www/voiceforpalestine.xyz
   sudo chown -R $USER:$USER /var/www/voiceforpalestine.xyz
   ```

2. Build the Next.js application locally:
   ```bash
   # On your local machine
   cd frontend
   npm run build
   ```

3. Copy the built files to the server:
   ```bash
   # From your local machine
   scp -r frontend/.next frontend/public frontend/package.json frontend/package-lock.json echoesofstreet:/var/www/voiceforpalestine.xyz/
   ```

4. The application will be served directly by Nginx as static files, no need for PM2.

## SSL Configuration (HTTPS)

To secure your site with HTTPS, you can use Let's Encrypt:

1. Install Certbot:
   ```bash
   sudo apt install certbot python3-certbot-nginx
   ```

2. Obtain and install SSL certificate:
   ```bash
   sudo certbot --nginx -d voiceforpalestine.xyz -d www.voiceforpalestine.xyz
   ```

3. Follow the prompts to complete the SSL setup.

## Troubleshooting

### Check Nginx status
```bash
sudo systemctl status nginx
```

### Check Nginx error logs
```bash
sudo tail -f /var/log/nginx/error.log
```

### Restart Nginx
```bash
sudo systemctl restart nginx
```
