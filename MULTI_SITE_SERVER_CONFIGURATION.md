# Multi-Site Server Configuration Guide

This document provides comprehensive documentation for hosting multiple websites on a single bare metal server using Nginx and Apache. It details the configuration, potential conflicts, and solutions implemented for the server at IP 95.216.25.234.

## Table of Contents

1. [Current Server Setup](#current-server-setup)
2. [Domain Configuration](#domain-configuration)
3. [Port Allocation](#port-allocation)
4. [Resolved Conflicts](#resolved-conflicts)
5. [Adding New Websites](#adding-new-websites)
6. [Maintenance Procedures](#maintenance-procedures)
7. [Troubleshooting](#troubleshooting)
8. [Security Considerations](#security-considerations)

## Current Server Setup

### Server Specifications
- **IP Address**: 95.216.25.234
- **Operating System**: Ubuntu
- **Web Servers**: Nginx and Apache
- **SSH Access**: User `echoesofstreet`

### Web Server Roles
- **Nginx**: Primary web server listening on ports 80 and 443
- **Apache**: Secondary web server listening on local ports 8081 and 8443

### Current Websites
1. **voiceforpalestine.xyz**
   - Served by: Nginx
   - Document Root: `/var/www/voiceforpalestine.xyz`
   - Type: Next.js application

2. **pmimrankhan.xyz**
   - Served by: Apache (proxied through Nginx)
   - Document Root: `/var/www/html`
   - Type: Static HTML website

## Domain Configuration

### Nginx Configuration Files
- Main configuration: `/etc/nginx/nginx.conf`
- Site configurations: `/etc/nginx/sites-available/`
- Enabled sites: `/etc/nginx/sites-enabled/`

### Apache Configuration Files
- Main configuration: `/etc/apache2/apache2.conf`
- Ports configuration: `/etc/apache2/ports.conf`
- Site configurations: `/etc/apache2/sites-available/`
- Enabled sites: `/etc/apache2/sites-enabled/`

### SSL Certificates
- Location: `/etc/letsencrypt/live/[domain-name]/`
- Renewal: Managed by Certbot

## Port Allocation

| Service | Public Port | Internal Port | Purpose |
|---------|------------|---------------|---------|
| Nginx   | 80         | 80            | HTTP traffic |
| Nginx   | 443        | 443           | HTTPS traffic |
| Apache  | N/A        | 8081          | HTTP for local services |
| Apache  | N/A        | 8443          | HTTPS for local services |

## Resolved Conflicts

### 1. Port Binding Conflicts

**Problem**: Both Nginx and Apache attempted to bind to ports 80 and 443, causing service startup failures.

**Solution**: 
- Configured Apache to listen only on localhost (127.0.0.1) and on alternate ports (8081, 8443)
- Configured Nginx to listen on all interfaces for ports 80 and 443
- Set up Nginx to proxy requests for Apache-served sites to the appropriate local ports

**Implementation**:
```bash
# Apache ports.conf
Listen 127.0.0.1:8081

<IfModule ssl_module>
    Listen 127.0.0.1:8443
</IfModule>
```

### 2. Domain Serving Conflicts

**Problem**: Apache was inadvertently serving content for voiceforpalestine.xyz due to default virtual host configurations.

**Solution**:
- Implemented domain-specific virtual hosts in both Nginx and Apache
- Ensured Apache only responds to requests for pmimrankhan.xyz
- Configured Nginx to handle all requests for voiceforpalestine.xyz

**Implementation**:
```nginx
# Nginx configuration for pmimrankhan.xyz
server {
    listen 80;
    server_name pmimrankhan.xyz www.pmimrankhan.xyz;
    
    # Redirect to HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name pmimrankhan.xyz www.pmimrankhan.xyz;
    
    ssl_certificate /etc/letsencrypt/live/pmimrankhan.xyz/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/pmimrankhan.xyz/privkey.pem;
    
    location / {
        proxy_pass http://127.0.0.1:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 3. Next.js Static Asset Serving Issues

**Problem**: Next.js static assets (CSS, JS, images) were not loading correctly due to incorrect path configurations.

**Solution**:
- Added specific location blocks in Nginx for Next.js static assets
- Configured proper caching headers for different asset types
- Ensured the main application HTML is served from the root path

**Implementation**:
```nginx
# Nginx configuration for Next.js assets
location /_next/static {
    alias /var/www/voiceforpalestine.xyz/.next/static;
    expires 365d;
    access_log off;
}

location /img {
    alias /var/www/voiceforpalestine.xyz/public/img;
    expires 30d;
    access_log off;
}
```

### 4. SSL Certificate Conflicts

**Problem**: SSL certificates needed to be properly configured for both domains without interference.

**Solution**:
- Used separate SSL certificates for each domain
- Configured Nginx to handle SSL termination for all domains
- Set up proper SSL parameters in the virtual host configurations

## Adding New Websites

Follow these steps to add a new website to the server:

### 1. Prepare the Document Root
```bash
sudo mkdir -p /var/www/newdomain.com
sudo chown -R www-data:www-data /var/www/newdomain.com
```

### 2. Obtain SSL Certificate
```bash
sudo certbot certonly --webroot -w /var/www/newdomain.com -d newdomain.com -d www.newdomain.com
```

### 3. Create Nginx Configuration
```bash
sudo tee /etc/nginx/sites-available/newdomain.com > /dev/null << 'EOL'
server {
    listen 80;
    server_name newdomain.com www.newdomain.com;
    
    # Redirect to HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name newdomain.com www.newdomain.com;
    
    ssl_certificate /etc/letsencrypt/live/newdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/newdomain.com/privkey.pem;
    
    root /var/www/newdomain.com;
    index index.html index.php;
    
    # For static sites
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # For PHP sites (proxied to Apache)
    # location ~ \.php$ {
    #     proxy_pass http://127.0.0.1:8081;
    #     proxy_set_header Host $host;
    #     proxy_set_header X-Real-IP $remote_addr;
    #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #     proxy_set_header X-Forwarded-Proto $scheme;
    # }
    
    # Security headers
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    
    # Enable compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}
EOL
```

### 4. Enable the Site
```bash
sudo ln -sf /etc/nginx/sites-available/newdomain.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 5. For Apache-Served Sites (if needed)
```bash
sudo tee /etc/apache2/sites-available/newdomain.com.conf > /dev/null << 'EOL'
<VirtualHost 127.0.0.1:8081>
    ServerName newdomain.com
    ServerAlias www.newdomain.com
    
    DocumentRoot /var/www/newdomain.com
    
    <Directory /var/www/newdomain.com>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/newdomain.com_error.log
    CustomLog ${APACHE_LOG_DIR}/newdomain.com_access.log combined
</VirtualHost>
EOL

sudo a2ensite newdomain.com.conf
sudo systemctl restart apache2
```

## Maintenance Procedures

### SSL Certificate Renewal
Certbot is configured to automatically renew certificates. To manually renew:
```bash
sudo certbot renew
```

### Log Rotation
Logs are automatically rotated using logrotate. Configuration is at `/etc/logrotate.d/nginx` and `/etc/logrotate.d/apache2`.

### Backup Procedure
1. Back up configuration files:
```bash
sudo tar -czf /backup/nginx-config-$(date +%Y%m%d).tar.gz /etc/nginx/
sudo tar -czf /backup/apache-config-$(date +%Y%m%d).tar.gz /etc/apache2/
```

2. Back up website content:
```bash
sudo tar -czf /backup/websites-$(date +%Y%m%d).tar.gz /var/www/
```

3. Back up SSL certificates:
```bash
sudo tar -czf /backup/letsencrypt-$(date +%Y%m%d).tar.gz /etc/letsencrypt/
```

## Troubleshooting

### Common Issues and Solutions

#### 1. "Address already in use" Error
**Problem**: A service fails to start because the port is already in use.
**Solution**: 
```bash
# Check what's using the port
sudo lsof -i :80
sudo lsof -i :443

# Stop the conflicting service
sudo systemctl stop [service-name]
```

#### 2. SSL Certificate Issues
**Problem**: SSL certificates not working or expired.
**Solution**:
```bash
# Check certificate validity
sudo certbot certificates

# Renew if needed
sudo certbot renew --force-renewal -d domain.com
```

#### 3. 502 Bad Gateway Error
**Problem**: Nginx cannot connect to the backend server.
**Solution**: 
```bash
# Check if the backend service is running
sudo systemctl status apache2

# Check Nginx error logs
sudo tail -f /var/log/nginx/error.log
```

#### 4. Static Assets Not Loading
**Problem**: CSS, JS, or images not loading.
**Solution**: 
- Check Nginx configuration for proper path mappings
- Verify file permissions
- Check browser console for specific 404 errors

## Security Considerations

### Firewall Configuration
The server uses UFW (Uncomplicated Firewall) to restrict access:
```bash
sudo ufw status
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### SSL Configuration
All sites use modern SSL configurations with strong ciphers:
```nginx
ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers on;
ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
```

### Regular Updates
Keep the server updated with security patches:
```bash
sudo apt update
sudo apt upgrade
```

---

## Reference Scripts

All configuration scripts are stored in the repository at `/Users/zeeshankhan/falasteen-nft/scripts/`:

1. `server-setup-documentation.sh` - Documents the server setup
2. `final-nextjs-configuration.sh` - Configures Nginx for Next.js applications
3. `fix-domain-conflict.sh` - Resolves domain conflicts between Nginx and Apache
4. `fix-server-conflict.sh` - Fixes server conflicts by properly configuring ports

---

This documentation was last updated on March 21, 2025.
