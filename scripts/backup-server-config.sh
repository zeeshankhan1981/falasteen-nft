#!/bin/bash
# Script to backup server configuration
# Usage: ./backup-server-config.sh [backup_dir]

# Default backup directory
BACKUP_DIR=${1:-/backup}
DATE=$(date +%Y%m%d)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="server_backup_$TIMESTAMP"
FULL_BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

echo "=== Server Configuration Backup Tool ==="
echo "Backing up server configuration to: $FULL_BACKUP_PATH"

# Create backup directory if it doesn't exist
sudo mkdir -p $FULL_BACKUP_PATH

# Backup Nginx configuration
echo "Backing up Nginx configuration..."
sudo tar -czf $FULL_BACKUP_PATH/nginx-config.tar.gz /etc/nginx/

# Backup Apache configuration
echo "Backing up Apache configuration..."
sudo tar -czf $FULL_BACKUP_PATH/apache-config.tar.gz /etc/apache2/

# Backup SSL certificates
echo "Backing up SSL certificates..."
sudo tar -czf $FULL_BACKUP_PATH/letsencrypt.tar.gz /etc/letsencrypt/

# Backup website content (excluding large files and logs)
echo "Backing up website content..."
sudo tar -czf $FULL_BACKUP_PATH/websites.tar.gz --exclude="*.log" --exclude="node_modules" --exclude=".git" /var/www/

# Backup system configuration
echo "Backing up system configuration..."
sudo cp /etc/hosts $FULL_BACKUP_PATH/
sudo cp /etc/hostname $FULL_BACKUP_PATH/
sudo cp /etc/resolv.conf $FULL_BACKUP_PATH/

# Backup user configuration
echo "Backing up user configuration..."
sudo cp /etc/passwd $FULL_BACKUP_PATH/
sudo cp /etc/group $FULL_BACKUP_PATH/
sudo cp /etc/shadow $FULL_BACKUP_PATH/

# Backup firewall configuration
echo "Backing up firewall configuration..."
sudo ufw status verbose > $FULL_BACKUP_PATH/ufw-status.txt

# Backup cron jobs
echo "Backing up cron jobs..."
sudo crontab -l > $FULL_BACKUP_PATH/crontab-root.txt 2>/dev/null || echo "No crontab for root" > $FULL_BACKUP_PATH/crontab-root.txt
sudo -u www-data crontab -l > $FULL_BACKUP_PATH/crontab-www-data.txt 2>/dev/null || echo "No crontab for www-data" > $FULL_BACKUP_PATH/crontab-www-data.txt

# Backup installed packages
echo "Backing up list of installed packages..."
dpkg --get-selections > $FULL_BACKUP_PATH/installed-packages.txt

# Backup systemd service configurations
echo "Backing up systemd service configurations..."
sudo cp /etc/systemd/system/*.service $FULL_BACKUP_PATH/ 2>/dev/null || echo "No custom systemd services found"

# Create a manifest file
echo "Creating backup manifest..."
cat > $FULL_BACKUP_PATH/manifest.txt << EOL
Server Configuration Backup
Created on: $(date)
Server: $(hostname)
IP Address: $(hostname -I | awk '{print $1}')

Contents:
- nginx-config.tar.gz: Nginx configuration
- apache-config.tar.gz: Apache configuration
- letsencrypt.tar.gz: SSL certificates
- websites.tar.gz: Website content
- hosts: Hosts file
- hostname: Hostname file
- resolv.conf: DNS resolver configuration
- passwd, group, shadow: User configuration
- ufw-status.txt: Firewall configuration
- crontab-*.txt: Cron jobs
- installed-packages.txt: List of installed packages
- *.service: Systemd service configurations

Domains:
$(ls -1 /etc/nginx/sites-enabled/)

Restore Instructions:
1. Extract all archives to their original locations
2. Restart services: sudo systemctl restart nginx apache2
3. Check configuration: sudo nginx -t && sudo apache2ctl configtest
EOL

# Set proper permissions
sudo chmod -R 600 $FULL_BACKUP_PATH
sudo chown -R root:root $FULL_BACKUP_PATH

# Create a compressed archive of the entire backup
echo "Creating final backup archive..."
cd $BACKUP_DIR
sudo tar -czf $BACKUP_NAME.tar.gz $BACKUP_NAME
sudo rm -rf $BACKUP_NAME

echo "Backup completed successfully!"
echo "Backup archive: $BACKUP_DIR/$BACKUP_NAME.tar.gz"
echo ""
echo "To restore this backup, use:"
echo "1. Extract the archive: sudo tar -xzf $BACKUP_NAME.tar.gz -C /tmp"
echo "2. Follow the instructions in /tmp/$BACKUP_NAME/manifest.txt"
