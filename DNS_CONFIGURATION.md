# DNS Configuration for voiceforpalestine.xyz

## Current Setup
Currently, both domains (pmimrankhan.xyz and voiceforpalestine.xyz) point to the same server IP (95.216.25.234).

- pmimrankhan.xyz is served by Apache on port 80/443
- voiceforpalestine.xyz is served by Nginx on port 8080

## Recommended DNS Changes

To make voiceforpalestine.xyz accessible without specifying the port in the URL, you have a few options:

### Option 1: Use a Different Server
The cleanest solution would be to host voiceforpalestine.xyz on a different server, so both domains can use the standard ports (80/443).

### Option 2: Configure Port Forwarding
If you have access to the server's network configuration, you could set up port forwarding so that external port 80 for voiceforpalestine.xyz is forwarded to internal port 8080.

### Option 3: Use a Subdomain
Create a subdomain like app.voiceforpalestine.xyz that points to the same IP but is configured to use port 8080.

## Implementation Steps for Option 3

1. In your DNS provider's dashboard, add an A record:
   - Name: app
   - Value: 95.216.25.234
   - TTL: 3600 (or as recommended by your provider)

2. Update the Nginx configuration to handle the subdomain:
   ```bash
   ssh echoesofstreet
   sudo nano /etc/nginx/sites-available/voiceforpalestine.xyz
   ```

3. Add the subdomain to the server_name directive:
   ```nginx
   server {
       listen 8080;
       server_name voiceforpalestine.xyz www.voiceforpalestine.xyz app.voiceforpalestine.xyz;
       
       # Rest of the configuration...
   }
   ```

4. Test and reload Nginx:
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   ```

5. The application will then be accessible at:
   - http://app.voiceforpalestine.xyz:8080

## Long-term Solution

For a production environment, it's recommended to:

1. Host each domain on a separate server
2. Use a reverse proxy like Cloudflare to handle traffic routing
3. Configure proper SSL certificates for secure HTTPS access
