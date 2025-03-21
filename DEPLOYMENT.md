# Deployment Guide for Palestine NFT Project

This guide provides detailed instructions for deploying the Palestine NFT project to the baremetal server.

## Server Information
- **SSH Access**: `echoesofstreet`
- **Server IP**: `95.216.25.234`
- **Web Server**: Nginx (needs to be installed)
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
       listen 80;
       server_name voiceforpalestine.xyz www.voiceforpalestine.xyz;

       location / {
           proxy_pass http://localhost:3000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```

3. Enable the site and restart Nginx:
   ```bash
   sudo ln -s /etc/nginx/sites-available/voiceforpalestine.xyz /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl restart nginx
   ```

### 5. Deploy the Next.js application using PM2

1. Create a directory for the application:
   ```bash
   sudo mkdir -p /var/www/voiceforpalestine.xyz
   sudo chown -R $USER:$USER /var/www/voiceforpalestine.xyz
   ```

2. Copy the frontend files to the server:
   ```bash
   # From your local machine
   scp -r frontend/* echoesofstreet:/var/www/voiceforpalestine.xyz/
   ```

3. Install dependencies on the server:
   ```bash
   cd /var/www/voiceforpalestine.xyz
   npm install --production
   ```

4. Start the Next.js application with PM2:
   ```bash
   cd /var/www/voiceforpalestine.xyz
   pm2 start npm --name "palestine-nft" -- start
   pm2 save
   pm2 startup
   ```

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

### Check application logs
```bash
pm2 logs palestine-nft
```

### Restart the application
```bash
pm2 restart palestine-nft
```

### Restart Nginx
```bash
sudo systemctl restart nginx
```
