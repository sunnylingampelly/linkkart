# 🚀 Complete Deployment Guide for linkkart.shop

**Domain:** linkkart.shop  
**Date:** May 13, 2026  
**Project:** LinkKart - Multi-Store E-commerce Platform

---

## 📋 System Architecture Overview

Your LinkKart platform consists of **4 separate systems**:

### 1. **Backend API** (Laravel/PHP)
- **Purpose:** Core API for all applications
- **Technology:** PHP 8.1+, Laravel, MySQL
- **Serves:** Mobile app, Admin dashboard, Storefront
- **Domain:** `api.linkkart.shop`

### 2. **Storefront** (React)
- **Purpose:** Public-facing website where customers browse stores
- **Technology:** React, Node.js
- **Domain:** `www.linkkart.shop` or `linkkart.shop`

### 3. **Admin Dashboard** (React)
- **Purpose:** Admin panel for managing the platform
- **Technology:** React, Node.js
- **Domain:** `admin.linkkart.shop`

### 4. **Mobile App** (Flutter)
- **Purpose:** Seller app for store owners to manage their stores
- **Technology:** Flutter/Dart
- **Distribution:** Google Play Store, APK download
- **Connects to:** `api.linkkart.shop`

---

## 🌐 Domain & Subdomain Setup

### DNS Configuration

You need to configure these subdomains in your domain registrar:

```
linkkart.shop              → Storefront (Main website)
www.linkkart.shop          → Storefront (Redirect to main)
api.linkkart.shop          → Backend API
admin.linkkart.shop        → Admin Dashboard
```

### DNS Records (Add these in your domain panel)

```
Type    Name    Value                           TTL
A       @       YOUR_SERVER_IP                  3600
A       www     YOUR_SERVER_IP                  3600
A       api     YOUR_SERVER_IP                  3600
A       admin   YOUR_SERVER_IP                  3600
```

**Example with IP 203.0.113.45:**
```
A       @       203.0.113.45                    3600
A       www     203.0.113.45                    3600
A       api     203.0.113.45                    3600
A       admin   203.0.113.45                    3600
```

---

## 🖥️ Server Requirements

### Recommended Hosting Options

#### Option 1: Shared Hosting (Budget: $5-15/month)
**Providers:** Hostinger, Namecheap, Bluehost
- ✅ Good for: Starting out, low traffic
- ❌ Limited: Performance, customization
- **Best for:** Testing, MVP launch

#### Option 2: VPS (Budget: $10-50/month) ⭐ RECOMMENDED
**Providers:** DigitalOcean, Linode, Vultr, AWS Lightsail
- ✅ Full control, better performance
- ✅ Can run all 3 systems on one server
- **Best for:** Production launch

#### Option 3: Cloud Platform (Budget: $20-100/month)
**Providers:** AWS, Google Cloud, Azure
- ✅ Scalable, professional
- ❌ More complex setup
- **Best for:** Scaling up

### Minimum Server Specs (VPS)
```
CPU:     2 cores
RAM:     4 GB
Storage: 50 GB SSD
OS:      Ubuntu 22.04 LTS
```

---

## 📦 Deployment Architecture

### Single Server Setup (Recommended for Start)

```
┌─────────────────────────────────────────┐
│         YOUR SERVER (VPS)               │
│         IP: YOUR_SERVER_IP              │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────────────────────────┐  │
│  │  Nginx (Web Server)              │  │
│  │  - Handles all incoming traffic  │  │
│  │  - SSL/HTTPS certificates        │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │  Backend API (Port 8000)         │  │
│  │  Domain: api.linkkart.shop       │  │
│  │  Path: /var/www/backend          │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │  Storefront (Port 3001)          │  │
│  │  Domain: linkkart.shop           │  │
│  │  Path: /var/www/storefront       │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │  Admin Dashboard (Port 3000)     │  │
│  │  Domain: admin.linkkart.shop     │  │
│  │  Path: /var/www/admin-dashboard  │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │  MySQL Database                  │  │
│  │  Database: linkkart              │  │
│  └──────────────────────────────────┘  │
│                                         │
└─────────────────────────────────────────┘
```

---

## 🚀 Step-by-Step Deployment

### PHASE 1: Server Setup

#### Step 1.1: Get a VPS Server

**Recommended: DigitalOcean Droplet**

1. Go to https://www.digitalocean.com
2. Create account
3. Create a Droplet:
   - **Image:** Ubuntu 22.04 LTS
   - **Plan:** Basic ($12/month - 2GB RAM)
   - **Datacenter:** Choose closest to your users
   - **Authentication:** SSH Key (recommended) or Password
4. Note your server IP address

**Alternative: AWS Lightsail**
1. Go to https://lightsail.aws.amazon.com
2. Create instance
3. Choose Ubuntu 22.04 LTS
4. Select $10/month plan

#### Step 1.2: Connect to Your Server

**Windows (PowerShell):**
```powershell
ssh root@YOUR_SERVER_IP
```

**Enter password when prompted**

#### Step 1.3: Initial Server Setup

```bash
# Update system
apt update && apt upgrade -y

# Install essential packages
apt install -y curl wget git unzip software-properties-common

# Create a non-root user (recommended)
adduser linkkart
usermod -aG sudo linkkart
su - linkkart
```

---

### PHASE 2: Install Required Software

#### Step 2.1: Install Nginx (Web Server)

```bash
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Test: Visit http://YOUR_SERVER_IP in browser
# You should see "Welcome to nginx"
```

#### Step 2.2: Install PHP 8.1

```bash
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install -y php8.1 php8.1-fpm php8.1-mysql php8.1-mbstring \
  php8.1-xml php8.1-curl php8.1-zip php8.1-gd php8.1-bcmath

# Verify installation
php -v
```

#### Step 2.3: Install MySQL

```bash
sudo apt install -y mysql-server

# Secure MySQL installation
sudo mysql_secure_installation
# Answer: Y to all questions
# Set a strong root password

# Create database
sudo mysql -u root -p
```

**In MySQL prompt:**
```sql
CREATE DATABASE linkkart CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'linkkart_user'@'localhost' IDENTIFIED BY 'YOUR_STRONG_PASSWORD';
GRANT ALL PRIVILEGES ON linkkart.* TO 'linkkart_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

#### Step 2.4: Install Node.js & npm

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installation
node -v
npm -v
```

#### Step 2.5: Install Composer (PHP Package Manager)

```bash
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
composer --version
```

#### Step 2.6: Install PM2 (Process Manager for Node.js)

```bash
sudo npm install -g pm2
pm2 startup
# Run the command it outputs
```

---

### PHASE 3: Deploy Backend API

#### Step 3.1: Upload Backend Code

**Option A: Using Git (Recommended)**
```bash
cd /var/www
sudo mkdir -p backend
sudo chown -R $USER:$USER backend
cd backend

# If you have GitHub repo
git clone https://github.com/YOUR_USERNAME/linkkart-backend.git .

# Or upload via SFTP (see below)
```

**Option B: Using SFTP (FileZilla, WinSCP)**
1. Connect to server via SFTP
2. Upload `backend` folder to `/var/www/backend`

#### Step 3.2: Configure Backend

```bash
cd /var/www/backend

# Install dependencies
composer install --no-dev --optimize-autoloader

# Copy environment file
cp .env.example .env
nano .env
```

**Edit .env file:**
```env
APP_NAME=LinkKart
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://api.linkkart.shop

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=linkkart
DB_USERNAME=linkkart_user
DB_PASSWORD=YOUR_STRONG_PASSWORD

RAZORPAY_KEY_ID=your_razorpay_key
RAZORPAY_KEY_SECRET=your_razorpay_secret

JWT_SECRET=your_jwt_secret_key_here
JWT_TTL=86400

FRONTEND_URL=https://linkkart.shop
STOREFRONT_URL=https://linkkart.shop
ADMIN_URL=https://admin.linkkart.shop
```

**Save and exit (Ctrl+X, Y, Enter)**

#### Step 3.3: Generate Application Key

```bash
php artisan key:generate
```

#### Step 3.4: Import Database

```bash
# Upload your database_setup.sql file to server
# Then import it:
mysql -u linkkart_user -p linkkart < /path/to/database_setup.sql

# Or run migrations if you have them
php artisan migrate --force
```

#### Step 3.5: Set Permissions

```bash
sudo chown -R www-data:www-data /var/www/backend
sudo chmod -R 755 /var/www/backend
sudo chmod -R 775 /var/www/backend/storage
sudo chmod -R 775 /var/www/backend/bootstrap/cache
```

#### Step 3.6: Configure Nginx for Backend

```bash
sudo nano /etc/nginx/sites-available/api.linkkart.shop
```

**Add this configuration:**
```nginx
server {
    listen 80;
    server_name api.linkkart.shop;
    root /var/www/backend/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

**Enable site:**
```bash
sudo ln -s /etc/nginx/sites-available/api.linkkart.shop /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### Step 3.7: Test Backend

```bash
curl http://api.linkkart.shop/api/health
```

Should return:
```json
{"success":true,"message":"LinkKart API is running with MySQL"}
```

---

### PHASE 4: Deploy Storefront

#### Step 4.1: Upload Storefront Code

```bash
cd /var/www
sudo mkdir -p storefront
sudo chown -R $USER:$USER storefront
cd storefront

# Upload via Git or SFTP
```

#### Step 4.2: Configure Storefront

```bash
cd /var/www/storefront

# Update API URL in config
nano src/config.js
```

**Update config.js:**
```javascript
export const API_BASE_URL = 'https://api.linkkart.shop';
export const API_VERSION = '/api/v1';
```

#### Step 4.3: Build Storefront

```bash
npm install
npm run build

# This creates a 'build' folder with optimized production files
```

#### Step 4.4: Configure Nginx for Storefront

```bash
sudo nano /etc/nginx/sites-available/linkkart.shop
```

**Add this configuration:**
```nginx
server {
    listen 80;
    server_name linkkart.shop www.linkkart.shop;
    root /var/www/storefront/build;

    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /static/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

**Enable site:**
```bash
sudo ln -s /etc/nginx/sites-available/linkkart.shop /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

### PHASE 5: Deploy Admin Dashboard

#### Step 5.1: Upload Admin Dashboard Code

```bash
cd /var/www
sudo mkdir -p admin-dashboard
sudo chown -R $USER:$USER admin-dashboard
cd admin-dashboard
```

#### Step 5.2: Configure Admin Dashboard

```bash
# Update API URL
nano .env
```

**Add:**
```env
REACT_APP_API_URL=https://api.linkkart.shop
```

#### Step 5.3: Build Admin Dashboard

```bash
npm install
npm run build
```

#### Step 5.4: Configure Nginx for Admin

```bash
sudo nano /etc/nginx/sites-available/admin.linkkart.shop
```

**Add this configuration:**
```nginx
server {
    listen 80;
    server_name admin.linkkart.shop;
    root /var/www/admin-dashboard/build;

    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

**Enable site:**
```bash
sudo ln -s /etc/nginx/sites-available/admin.linkkart.shop /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

### PHASE 6: SSL Certificates (HTTPS)

#### Step 6.1: Install Certbot

```bash
sudo apt install -y certbot python3-certbot-nginx
```

#### Step 6.2: Get SSL Certificates

```bash
# For API
sudo certbot --nginx -d api.linkkart.shop

# For Storefront
sudo certbot --nginx -d linkkart.shop -d www.linkkart.shop

# For Admin
sudo certbot --nginx -d admin.linkkart.shop
```

**Follow prompts:**
- Enter email address
- Agree to terms
- Choose to redirect HTTP to HTTPS (recommended)

#### Step 6.3: Auto-Renewal

```bash
# Test renewal
sudo certbot renew --dry-run

# Certbot automatically sets up auto-renewal
```

---

### PHASE 7: Mobile App Configuration

#### Step 7.1: Update Mobile App Constants

**Edit `mobile-app/lib/utils/constants.dart`:**
```dart
static const List<String> baseUrls = [
  'https://api.linkkart.shop',   // Production API
];

static String _baseUrl = 'https://api.linkkart.shop';

static const String storefrontUrl = 'https://linkkart.shop';
```

#### Step 7.2: Build Production APK

```bash
cd mobile-app

# Build release APK
flutter build apk --release

# APK location: build/app/outputs/flutter-apk/app-release.apk
```

#### Step 7.3: Distribute Mobile App

**Option A: Google Play Store**
1. Create Google Play Developer account ($25 one-time)
2. Create app listing
3. Upload APK
4. Submit for review

**Option B: Direct Download**
1. Upload APK to your server
2. Create download page: `https://linkkart.shop/download`
3. Users download and install

---

## ✅ Post-Deployment Checklist

### Test All Systems

- [ ] **Backend API**
  - [ ] Visit https://api.linkkart.shop/api/health
  - [ ] Should return success JSON

- [ ] **Storefront**
  - [ ] Visit https://linkkart.shop
  - [ ] Stores should load
  - [ ] Can view store pages
  - [ ] WhatsApp buttons work

- [ ] **Admin Dashboard**
  - [ ] Visit https://admin.linkkart.shop
  - [ ] Can login
  - [ ] Can view stores
  - [ ] Can manage data

- [ ] **Mobile App**
  - [ ] Install APK on device
  - [ ] App connects to API
  - [ ] Can create store
  - [ ] Can add products
  - [ ] Can view dashboard

### Security Checklist

- [ ] SSL certificates installed (HTTPS)
- [ ] Database password is strong
- [ ] `.env` file permissions set correctly
- [ ] Firewall configured (UFW)
- [ ] Regular backups scheduled
- [ ] Error logging enabled

---

## 🔧 Maintenance & Monitoring

### Daily Backups

```bash
# Create backup script
nano /home/linkkart/backup.sh
```

**Add:**
```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/home/linkkart/backups"

# Backup database
mysqldump -u linkkart_user -pYOUR_PASSWORD linkkart > $BACKUP_DIR/db_$DATE.sql

# Backup files
tar -czf $BACKUP_DIR/files_$DATE.tar.gz /var/www

# Keep only last 7 days
find $BACKUP_DIR -type f -mtime +7 -delete
```

**Make executable and schedule:**
```bash
chmod +x /home/linkkart/backup.sh
crontab -e
```

**Add:**
```
0 2 * * * /home/linkkart/backup.sh
```

### Monitor Server

```bash
# Install monitoring tools
sudo apt install -y htop

# Check server resources
htop

# Check disk space
df -h

# Check logs
sudo tail -f /var/log/nginx/error.log
```

---

## 💰 Cost Breakdown

### Monthly Costs

| Item | Provider | Cost |
|------|----------|------|
| Domain | Any registrar | $10-15/year |
| VPS Server | DigitalOcean | $12/month |
| SSL Certificates | Let's Encrypt | FREE |
| **Total** | | **~$12/month** |

### Optional Costs

| Item | Cost |
|------|------|
| Google Play Developer | $25 (one-time) |
| Razorpay Payment Gateway | 2% per transaction |
| Email Service (SendGrid) | Free tier available |

---

## 🆘 Troubleshooting

### Issue: "502 Bad Gateway"
**Solution:**
```bash
sudo systemctl restart php8.1-fpm
sudo systemctl restart nginx
```

### Issue: "Database connection failed"
**Solution:**
```bash
# Check MySQL is running
sudo systemctl status mysql

# Check credentials in .env file
nano /var/www/backend/.env
```

### Issue: "Permission denied"
**Solution:**
```bash
sudo chown -R www-data:www-data /var/www/backend
sudo chmod -R 755 /var/www/backend
```

### Issue: Mobile app can't connect
**Solution:**
- Verify API URL is `https://api.linkkart.shop`
- Check SSL certificate is valid
- Rebuild mobile app with correct URL

---

## 📞 Support & Resources

### Documentation
- Laravel: https://laravel.com/docs
- React: https://react.dev
- Flutter: https://flutter.dev
- Nginx: https://nginx.org/en/docs

### Community
- Stack Overflow
- Laravel Forums
- React Community
- Flutter Discord

---

## 🎉 You're Live!

Once deployed, your platform will be accessible at:

- **Main Website:** https://linkkart.shop
- **Admin Panel:** https://admin.linkkart.shop
- **API:** https://api.linkkart.shop
- **Mobile App:** Download from your website or Play Store

**Congratulations on launching LinkKart! 🚀**

---

## 📋 Quick Reference Commands

```bash
# Restart all services
sudo systemctl restart nginx
sudo systemctl restart php8.1-fpm
sudo systemctl restart mysql

# View logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/www/backend/storage/logs/laravel.log

# Update code
cd /var/www/backend && git pull
cd /var/www/storefront && git pull && npm run build
cd /var/www/admin-dashboard && git pull && npm run build

# Backup database
mysqldump -u linkkart_user -p linkkart > backup.sql

# Check server status
sudo systemctl status nginx
sudo systemctl status php8.1-fpm
sudo systemctl status mysql
```

---

**Need help? Create an issue or contact support!**
