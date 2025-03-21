#!/bin/bash
# Script to troubleshoot common server issues
# Usage: ./troubleshoot-server.sh [domain]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if domain is provided
DOMAIN=$1

echo -e "${BLUE}=== Server Troubleshooting Tool ===${NC}"
echo "This script will check for common issues with the server configuration."
echo ""

# Check if Nginx is running
echo -e "${BLUE}Checking Nginx status...${NC}"
if systemctl is-active --quiet nginx; then
    echo -e "${GREEN}✓ Nginx is running${NC}"
else
    echo -e "${RED}✗ Nginx is not running${NC}"
    echo "  Try: sudo systemctl start nginx"
fi

# Check if Apache is running
echo -e "${BLUE}Checking Apache status...${NC}"
if systemctl is-active --quiet apache2; then
    echo -e "${GREEN}✓ Apache is running${NC}"
else
    echo -e "${RED}✗ Apache is not running${NC}"
    echo "  Try: sudo systemctl start apache2"
fi

# Check port conflicts
echo -e "${BLUE}Checking for port conflicts...${NC}"
PORT_80=$(sudo lsof -i:80 | grep LISTEN)
PORT_443=$(sudo lsof -i:443 | grep LISTEN)
PORT_8081=$(sudo lsof -i:8081 | grep LISTEN)
PORT_8443=$(sudo lsof -i:8443 | grep LISTEN)

if [[ -z "$PORT_80" ]]; then
    echo -e "${RED}✗ No service is listening on port 80${NC}"
else
    echo -e "${GREEN}✓ Port 80 is being used by: $(echo "$PORT_80" | awk '{print $1}')${NC}"
fi

if [[ -z "$PORT_443" ]]; then
    echo -e "${RED}✗ No service is listening on port 443${NC}"
else
    echo -e "${GREEN}✓ Port 443 is being used by: $(echo "$PORT_443" | awk '{print $1}')${NC}"
fi

if [[ -z "$PORT_8081" ]]; then
    echo -e "${YELLOW}⚠ No service is listening on port 8081 (Apache HTTP)${NC}"
else
    echo -e "${GREEN}✓ Port 8081 is being used by: $(echo "$PORT_8081" | awk '{print $1}')${NC}"
fi

if [[ -z "$PORT_8443" ]]; then
    echo -e "${YELLOW}⚠ No service is listening on port 8443 (Apache HTTPS)${NC}"
else
    echo -e "${GREEN}✓ Port 8443 is being used by: $(echo "$PORT_8443" | awk '{print $1}')${NC}"
fi

# Check Nginx configuration
echo -e "${BLUE}Checking Nginx configuration...${NC}"
NGINX_TEST=$(sudo nginx -t 2>&1)
if [[ "$NGINX_TEST" == *"successful"* ]]; then
    echo -e "${GREEN}✓ Nginx configuration is valid${NC}"
else
    echo -e "${RED}✗ Nginx configuration has errors:${NC}"
    echo "$NGINX_TEST"
fi

# Check Apache configuration
echo -e "${BLUE}Checking Apache configuration...${NC}"
APACHE_TEST=$(sudo apachectl configtest 2>&1)
if [[ "$APACHE_TEST" == *"Syntax OK"* ]]; then
    echo -e "${GREEN}✓ Apache configuration is valid${NC}"
else
    echo -e "${RED}✗ Apache configuration has errors:${NC}"
    echo "$APACHE_TEST"
fi

# Check SSL certificates
echo -e "${BLUE}Checking SSL certificates...${NC}"
if [ -n "$DOMAIN" ]; then
    SSL_PATH="/etc/letsencrypt/live/$DOMAIN"
    if [ -d "$SSL_PATH" ]; then
        CERT_EXPIRY=$(sudo openssl x509 -dates -noout -in "$SSL_PATH/cert.pem" | grep notAfter | cut -d= -f2)
        echo -e "${GREEN}✓ SSL certificate for $DOMAIN exists${NC}"
        echo "  Expires: $CERT_EXPIRY"
    else
        echo -e "${RED}✗ SSL certificate for $DOMAIN not found${NC}"
        echo "  Try: sudo certbot certonly --webroot -w /var/www/$DOMAIN -d $DOMAIN -d www.$DOMAIN"
    fi
else
    echo -e "${YELLOW}⚠ No domain specified, skipping SSL certificate check${NC}"
    echo "  To check SSL certificates, run: ./troubleshoot-server.sh domain.com"
fi

# Check Nginx enabled sites
echo -e "${BLUE}Checking Nginx enabled sites...${NC}"
ENABLED_SITES=$(ls -la /etc/nginx/sites-enabled/)
echo "$ENABLED_SITES"

# Check Apache enabled sites
echo -e "${BLUE}Checking Apache enabled sites...${NC}"
ENABLED_APACHE_SITES=$(ls -la /etc/apache2/sites-enabled/)
echo "$ENABLED_APACHE_SITES"

# Check for specific domain configuration
if [ -n "$DOMAIN" ]; then
    echo -e "${BLUE}Checking configuration for $DOMAIN...${NC}"
    
    # Check Nginx site configuration
    if [ -f "/etc/nginx/sites-available/$DOMAIN" ]; then
        echo -e "${GREEN}✓ Nginx configuration for $DOMAIN exists${NC}"
        
        # Check if it's enabled
        if [ -L "/etc/nginx/sites-enabled/$DOMAIN" ]; then
            echo -e "${GREEN}✓ Nginx site for $DOMAIN is enabled${NC}"
        else
            echo -e "${RED}✗ Nginx site for $DOMAIN is not enabled${NC}"
            echo "  Try: sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/"
        fi
        
        # Check server_name directive
        SERVER_NAME=$(grep -E "server_name.*$DOMAIN" /etc/nginx/sites-available/$DOMAIN)
        if [ -n "$SERVER_NAME" ]; then
            echo -e "${GREEN}✓ server_name directive for $DOMAIN is properly configured${NC}"
        else
            echo -e "${RED}✗ server_name directive for $DOMAIN is missing or incorrect${NC}"
        fi
        
        # Check SSL configuration
        SSL_CONFIG=$(grep -E "ssl_certificate.*$DOMAIN" /etc/nginx/sites-available/$DOMAIN)
        if [ -n "$SSL_CONFIG" ]; then
            echo -e "${GREEN}✓ SSL configuration for $DOMAIN is present${NC}"
        else
            echo -e "${RED}✗ SSL configuration for $DOMAIN is missing${NC}"
        fi
    else
        echo -e "${RED}✗ Nginx configuration for $DOMAIN does not exist${NC}"
    fi
    
    # Check Apache site configuration for PHP sites
    if [ -f "/etc/apache2/sites-available/$DOMAIN.conf" ]; then
        echo -e "${GREEN}✓ Apache configuration for $DOMAIN exists${NC}"
        
        # Check if it's enabled
        if [ -L "/etc/apache2/sites-enabled/$DOMAIN.conf" ]; then
            echo -e "${GREEN}✓ Apache site for $DOMAIN is enabled${NC}"
        else
            echo -e "${RED}✗ Apache site for $DOMAIN is not enabled${NC}"
            echo "  Try: sudo a2ensite $DOMAIN.conf"
        fi
        
        # Check ServerName directive
        SERVER_NAME=$(grep -E "ServerName.*$DOMAIN" /etc/apache2/sites-available/$DOMAIN.conf)
        if [ -n "$SERVER_NAME" ]; then
            echo -e "${GREEN}✓ ServerName directive for $DOMAIN is properly configured${NC}"
        else
            echo -e "${RED}✗ ServerName directive for $DOMAIN is missing or incorrect${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ Apache configuration for $DOMAIN does not exist (this is normal for static or Next.js sites)${NC}"
    fi
    
    # Check document root
    if [ -d "/var/www/$DOMAIN" ]; then
        echo -e "${GREEN}✓ Document root for $DOMAIN exists${NC}"
        
        # Check permissions
        OWNER=$(stat -c '%U:%G' /var/www/$DOMAIN)
        if [ "$OWNER" == "www-data:www-data" ]; then
            echo -e "${GREEN}✓ Document root has correct ownership${NC}"
        else
            echo -e "${RED}✗ Document root has incorrect ownership: $OWNER${NC}"
            echo "  Try: sudo chown -R www-data:www-data /var/www/$DOMAIN"
        fi
        
        # Check for index file
        if [ -f "/var/www/$DOMAIN/index.html" ]; then
            echo -e "${GREEN}✓ index.html exists${NC}"
        else
            echo -e "${YELLOW}⚠ index.html does not exist${NC}"
        fi
        
        # Check for Next.js files
        if [ -d "/var/www/$DOMAIN/.next" ]; then
            echo -e "${GREEN}✓ Next.js build directory exists${NC}"
            
            # Check for static directory
            if [ -d "/var/www/$DOMAIN/.next/static" ]; then
                echo -e "${GREEN}✓ Next.js static directory exists${NC}"
            else
                echo -e "${RED}✗ Next.js static directory is missing${NC}"
            fi
        fi
    else
        echo -e "${RED}✗ Document root for $DOMAIN does not exist${NC}"
        echo "  Try: sudo mkdir -p /var/www/$DOMAIN"
    fi
    
    # Check DNS resolution
    echo -e "${BLUE}Checking DNS resolution for $DOMAIN...${NC}"
    DNS_RESULT=$(dig +short $DOMAIN)
    if [ -n "$DNS_RESULT" ]; then
        echo -e "${GREEN}✓ DNS resolves to: $DNS_RESULT${NC}"
        
        # Check if it resolves to the current server
        SERVER_IP=$(hostname -I | awk '{print $1}')
        if [[ "$DNS_RESULT" == *"$SERVER_IP"* ]]; then
            echo -e "${GREEN}✓ DNS resolves to this server${NC}"
        else
            echo -e "${RED}✗ DNS does not resolve to this server (IP: $SERVER_IP)${NC}"
        fi
    else
        echo -e "${RED}✗ DNS resolution failed for $DOMAIN${NC}"
    fi
    
    # Test HTTP and HTTPS access
    echo -e "${BLUE}Testing HTTP access to $DOMAIN...${NC}"
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN)
    if [ "$HTTP_STATUS" == "301" ] || [ "$HTTP_STATUS" == "302" ]; then
        echo -e "${GREEN}✓ HTTP redirects as expected (status code: $HTTP_STATUS)${NC}"
    elif [ "$HTTP_STATUS" == "200" ]; then
        echo -e "${YELLOW}⚠ HTTP returns 200 OK - should redirect to HTTPS${NC}"
    else
        echo -e "${RED}✗ HTTP returns unexpected status code: $HTTP_STATUS${NC}"
    fi
    
    echo -e "${BLUE}Testing HTTPS access to $DOMAIN...${NC}"
    HTTPS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -k https://$DOMAIN)
    if [ "$HTTPS_STATUS" == "200" ]; then
        echo -e "${GREEN}✓ HTTPS works correctly (status code: $HTTPS_STATUS)${NC}"
    else
        echo -e "${RED}✗ HTTPS returns unexpected status code: $HTTPS_STATUS${NC}"
    fi
fi

echo ""
echo -e "${BLUE}=== Troubleshooting Complete ===${NC}"
echo "For more detailed information, check the logs:"
echo "  Nginx error log: /var/log/nginx/error.log"
echo "  Apache error log: /var/log/apache2/error.log"
echo "  Domain-specific logs may be in /var/log/nginx/ or /var/log/apache2/"
echo ""
echo "For additional help, refer to the Multi-Site Server Configuration Guide."
