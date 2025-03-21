# Deployment Guide for Palestine NFT Project

This guide provides detailed instructions for deploying the Palestine NFT project to the baremetal server.

## Server Information
- **SSH Access**: `echoesofstreet`
- **Server IP**: `95.216.25.234`
- **Web Server**: Nginx (installed on port 8080)
- **Domain**: `voiceforpalestine.xyz`

## Prerequisites
Before deployment, ensure you have:
1. SSH access to the server
2. The domain `voiceforpalestine.xyz` configured to point to the server
3. The smart contract deployed to Polygon Mainnet
4. The deployed contract address

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

2. Add the following configuration:
   ```nginx
   server {
       listen 8080;
       server_name voiceforpalestine.xyz www.voiceforpalestine.xyz;

       root /var/www/voiceforpalestine.xyz;
       index index.html;

       location / {
           try_files $uri $uri.html $uri/ /index.html;
       }

       # Cache static assets
       location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
           expires 30d;
           add_header Cache-Control "public, no-transform";
       }
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
