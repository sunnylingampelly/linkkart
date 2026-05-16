#!/bin/bash

###############################################################################
# LinkKart Server Installation Script
# Domain: linkkart.shop
# This script automates the complete server setup
###############################################################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_error "Please run as root (use: sudo bash install-server.sh)"
    exit 1
fi

print_info "==================================================================="
print_info "LinkKart Server Installation Script"
print_info "==================================================================="
echo ""

# Get user input
read -p "Enter your domain (e.g., linkkart.shop): " DOMAIN
read -p "Enter MySQL root password: " -s MYSQL_ROOT_PASSWORD
echo ""
read -p "Enter MySQL linkkart user password: " -s MYSQL_USER_PASSWORD
echo ""
read -p "Enter your email for SSL certificates: " EMAIL

print_info "Starting installation..."
echo ""

###############################################################################
# STEP 1: Update System
###############################################################################
print_info "Step 1/10: Updating system packages..."
apt update && apt upgrade -y
print_success "System updated"
echo ""

###############################################################################
# STEP 2: Install Essential Packages
###############################################################################
print_info "Step 2/10: Installing essential packages..."
apt install -y curl wget git unzip software-properties-common ufw
print_success "Essential packages installed"
echo ""

###############################################################################
# STEP 3: Install Nginx
###############################################################################
print_info "Step 3/10: Installing Nginx..."
apt install -y nginx
systemctl start nginx
systemctl enable nginx
print_success "Nginx installed and started"
echo ""

###############################################################################
# STEP 4: Install PHP 8.1
###############################################################################
print_info "Step 4/10: Installing PHP 8.1..."
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php8.1 php8.1-fpm php8.1-mysql php8.1-mbstring \
    php8.1-xml php8.1-curl php8.1-zip php8.1-gd php8.1-bcmath php8.1-intl
print_success "PHP 8.1 installed"
echo ""

###############################################################################
# STEP 5: Install MySQL
###############################################################################
print_info "Step 5/10: Installing MySQL..."
apt install -y mysql-server

# Secure MySQL installation
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql -e "FLUSH PRIVILEGES;"

# Create database and user
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
CREATE DATABASE IF NOT EXISTS linkkart CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'linkkart_user'@'localhost' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON linkkart.* TO 'linkkart_user'@'localhost';
FLUSH PRIVILEGES;
EOF

print_success "MySQL installed and configured"
echo ""

###############################################################################
# STEP 6: Install Node.js
###############################################################################
print_info "Step 6/10: Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs
print_success "Node.js installed (version: $(node -v))"
echo ""

###############################################################################
# STEP 7: Install Composer
###############################################################################
print_info "Step 7/10: Installing Composer..."
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer
print_success "Composer installed (version: $(composer --version))"
echo ""

###############################################################################
# STEP 8: Install PM2
###############################################################################
print_info "Step 8/10: Installing PM2..."
npm install -g pm2
print_success "PM2 installed"
echo ""

###############################################################################
# STEP 9: Configure Firewall
###############################################################################
print_info "Step 9/10: Configuring firewall..."
ufw --force enable
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
print_success "Firewall configured"
echo ""

###############################################################################
# STEP 10: Create Directory Structure
###############################################################################
print_info "Step 10/10: Creating directory structure..."
mkdir -p /var/www/backend
mkdir -p /var/www/storefront
mkdir -p /var/www/admin-dashboard
mkdir -p /home/linkkart/backups

# Set permissions
chown -R www-data:www-data /var/www
chmod -R 755 /var/www

print_success "Directory structure created"
echo ""

###############################################################################
# Create Nginx Configuration Files
###############################################################################
print_info "Creating Nginx configuration files..."

# Backend API configuration
cat > /etc/nginx/sites-available/api.${DOMAIN} <<EOF
server {
    listen 80;
    server_name api.${DOMAIN};
    root /var/www/backend/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;
    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF

# Storefront configuration
cat > /etc/nginx/sites-available/${DOMAIN} <<EOF
server {
    listen 80;
    server_name ${DOMAIN} www.${DOMAIN};
    root /var/www/storefront/build;

    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location /static/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Admin Dashboard configuration
cat > /etc/nginx/sites-available/admin.${DOMAIN} <<EOF
server {
    listen 80;
    server_name admin.${DOMAIN};
    root /var/www/admin-dashboard/build;

    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

# Enable sites
ln -sf /etc/nginx/sites-available/api.${DOMAIN} /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/admin.${DOMAIN} /etc/nginx/sites-enabled/

# Remove default site
rm -f /etc/nginx/sites-enabled/default

# Test and reload Nginx
nginx -t
systemctl reload nginx

print_success "Nginx configured"
echo ""

###############################################################################
# Install Certbot for SSL
###############################################################################
print_info "Installing Certbot for SSL certificates..."
apt install -y certbot python3-certbot-nginx
print_success "Certbot installed"
echo ""

###############################################################################
# Create Environment File Template
###############################################################################
print_info "Creating environment file template..."
cat > /var/www/backend/.env.example <<EOF
APP_NAME=LinkKart
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://api.${DOMAIN}

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=linkkart
DB_USERNAME=linkkart_user
DB_PASSWORD=${MYSQL_USER_PASSWORD}

RAZORPAY_KEY_ID=your_razorpay_key_here
RAZORPAY_KEY_SECRET=your_razorpay_secret_here
TAX_RATE=0.00
WEBHOOK_SECRET=your_webhook_secret_here

JWT_SECRET=$(openssl rand -base64 32)
JWT_TTL=86400

FRONTEND_URL=https://${DOMAIN}
STOREFRONT_URL=https://${DOMAIN}
ADMIN_URL=https://admin.${DOMAIN}
EOF

print_success "Environment template created"
echo ""

###############################################################################
# Create Backup Script
###############################################################################
print_info "Creating backup script..."
cat > /home/linkkart/backup.sh <<'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/home/linkkart/backups"

# Backup database
mysqldump -u linkkart_user -p${MYSQL_USER_PASSWORD} linkkart > $BACKUP_DIR/db_$DATE.sql

# Backup files
tar -czf $BACKUP_DIR/files_$DATE.tar.gz /var/www

# Keep only last 7 days
find $BACKUP_DIR -type f -mtime +7 -delete

echo "Backup completed: $DATE"
EOF

chmod +x /home/linkkart/backup.sh
print_success "Backup script created"
echo ""

###############################################################################
# Installation Complete
###############################################################################
echo ""
print_success "==================================================================="
print_success "Installation Complete!"
print_success "==================================================================="
echo ""
print_info "Next Steps:"
echo ""
echo "1. Upload your code to:"
echo "   - Backend: /var/www/backend"
echo "   - Storefront: /var/www/storefront"
echo "   - Admin: /var/www/admin-dashboard"
echo ""
echo "2. Configure backend:"
echo "   cd /var/www/backend"
echo "   cp .env.example .env"
echo "   composer install --no-dev"
echo "   php artisan key:generate"
echo "   php artisan migrate --force"
echo ""
echo "3. Build frontend applications:"
echo "   cd /var/www/storefront && npm install && npm run build"
echo "   cd /var/www/admin-dashboard && npm install && npm run build"
echo ""
echo "4. Install SSL certificates:"
echo "   certbot --nginx -d api.${DOMAIN} --email ${EMAIL} --agree-tos --non-interactive"
echo "   certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --email ${EMAIL} --agree-tos --non-interactive"
echo "   certbot --nginx -d admin.${DOMAIN} --email ${EMAIL} --agree-tos --non-interactive"
echo ""
echo "5. Test your sites:"
echo "   https://api.${DOMAIN}/api/health"
echo "   https://${DOMAIN}"
echo "   https://admin.${DOMAIN}"
echo ""
print_info "Database Credentials:"
echo "   Database: linkkart"
echo "   Username: linkkart_user"
echo "   Password: ${MYSQL_USER_PASSWORD}"
echo ""
print_info "Backup script location: /home/linkkart/backup.sh"
echo ""
print_success "Server is ready for deployment!"
echo ""
