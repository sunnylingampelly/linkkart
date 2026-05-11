# 🚀 LinkKart - Production Deployment Guide

This guide covers deploying LinkKart to production environments.

---

## 📋 Pre-Deployment Checklist

- [ ] All features tested locally
- [ ] Database migrations reviewed
- [ ] Environment variables configured
- [ ] SSL certificates obtained
- [ ] Domain names configured
- [ ] Backup strategy in place
- [ ] Monitoring tools set up
- [ ] Error tracking configured

---

## 🖥️ Backend Deployment (Laravel)

### Option 1: Traditional VPS (DigitalOcean, AWS EC2, Linode)

#### 1. Server Requirements
- Ubuntu 22.04 LTS
- PHP 8.1+
- MySQL 8.0+
- Nginx or Apache
- Composer
- Node.js (for asset compilation)

#### 2. Server Setup
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install PHP and extensions
sudo apt install php8.1-fpm php8.1-mysql php8.1-mbstring php8.1-xml \
  php8.1-bcmath php8.1-curl php8.1-gd php8.1-zip -y

# Install MySQL
sudo apt install mysql-server -y

# Install Nginx
sudo apt install nginx -y

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

#### 3. Deploy Application
```bash
# Clone repository
cd /var/www
sudo git clone https://github.com/yourusername/linkkart.git
cd linkkart/backend

# Install dependencies
composer install --optimize-autoloader --no-dev

# Set permissions
sudo chown -R www-data:www-data /var/www/linkkart
sudo chmod -R 755 /var/www/linkkart
sudo chmod -R 775 storage bootstrap/cache
```

#### 4. Configure Environment
```bash
# Copy environment file
cp .env.example .env

# Edit environment variables
nano .env
```

**Production .env:**
```env
APP_NAME=LinkKart
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://api.linkkart.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=linkkart_prod
DB_USERNAME=linkkart_user
DB_PASSWORD=strong_password_here

JWT_SECRET=your_jwt_secret_here

# AWS S3 for file storage
FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=linkkart-uploads

FRONTEND_URL=https://admin.linkkart.com
STOREFRONT_URL=https://linkkart.com
```

#### 5. Run Migrations
```bash
php artisan key:generate
php artisan jwt:secret
php artisan migrate --force
php artisan db:seed --force
php artisan storage:link
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

#### 6. Configure Nginx
```bash
sudo nano /etc/nginx/sites-available/linkkart-api
```

**Nginx Configuration:**
```nginx
server {
    listen 80;
    server_name api.linkkart.com;
    root /var/www/linkkart/backend/public;

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

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/linkkart-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### 7. SSL Certificate (Let's Encrypt)
```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d api.linkkart.com
```

#### 8. Set Up Cron Jobs
```bash
sudo crontab -e
```

Add:
```
* * * * * cd /var/www/linkkart/backend && php artisan schedule:run >> /dev/null 2>&1
```

#### 9. Set Up Supervisor (for queues)
```bash
sudo apt install supervisor -y
sudo nano /etc/supervisor/conf.d/linkkart-worker.conf
```

```ini
[program:linkkart-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/linkkart/backend/artisan queue:work --sleep=3 --tries=3
autostart=true
autorestart=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/linkkart/backend/storage/logs/worker.log
```

```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start linkkart-worker:*
```

### Option 2: Laravel Forge

1. Connect your server to Forge
2. Create a new site: `api.linkkart.com`
3. Deploy from Git repository
4. Configure environment variables
5. Enable SSL
6. Set up deployment script

**Deployment Script:**
```bash
cd /home/forge/api.linkkart.com
git pull origin main
composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan queue:restart
```

---

## 🌐 Frontend Deployment (React Apps)

### Option 1: Vercel (Recommended)

#### Storefront Deployment

1. **Push to GitHub**
```bash
cd storefront
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/yourusername/linkkart-storefront.git
git push -u origin main
```

2. **Deploy on Vercel**
- Go to [vercel.com](https://vercel.com)
- Import GitHub repository
- Configure:
  - Framework Preset: Create React App
  - Root Directory: `storefront`
  - Build Command: `npm run build`
  - Output Directory: `build`

3. **Environment Variables**
```
REACT_APP_API_URL=https://api.linkkart.com/api/v1
REACT_APP_BACKEND_URL=https://api.linkkart.com
```

4. **Custom Domain**
- Add domain: `linkkart.com`
- Configure DNS records

#### Admin Dashboard Deployment

Same process as storefront:
- Root Directory: `admin-dashboard`
- Domain: `admin.linkkart.com`
- Environment Variables:
```
REACT_APP_API_URL=https://api.linkkart.com/api/v1
```

### Option 2: Netlify

1. **Build Locally**
```bash
cd storefront
npm run build
```

2. **Deploy**
```bash
npm install -g netlify-cli
netlify login
netlify deploy --prod
```

3. **Configure**
- Set environment variables in Netlify dashboard
- Configure custom domain
- Enable HTTPS

### Option 3: Traditional VPS

```bash
# Build application
cd storefront
npm install
npm run build

# Copy to server
scp -r build/* user@server:/var/www/linkkart-storefront/

# Configure Nginx
sudo nano /etc/nginx/sites-available/linkkart-storefront
```

**Nginx Configuration:**
```nginx
server {
    listen 80;
    server_name linkkart.com www.linkkart.com;
    root /var/www/linkkart-storefront;

    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

---

## 📱 Mobile App Deployment

### Android (Google Play Store)

#### 1. Prepare for Release
```bash
cd mobile-app

# Update version in pubspec.yaml
version: 1.0.0+1

# Update API URL in lib/utils/constants.dart
static const String baseUrl = 'https://api.linkkart.com/api/v1';
```

#### 2. Generate Keystore
```bash
keytool -genkey -v -keystore ~/linkkart-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias linkkart
```

#### 3. Configure Signing
Create `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=linkkart
storeFile=/path/to/linkkart-key.jks
```

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### 4. Build Release APK/AAB
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

#### 5. Upload to Play Store
1. Go to [Google Play Console](https://play.google.com/console)
2. Create new application
3. Fill in store listing details
4. Upload AAB file
5. Complete content rating questionnaire
6. Set pricing and distribution
7. Submit for review

### iOS (App Store)

#### 1. Configure Xcode
```bash
cd mobile-app
flutter build ios --release
open ios/Runner.xcworkspace
```

#### 2. In Xcode:
- Select Runner > Signing & Capabilities
- Select your team
- Configure bundle identifier: `com.linkkart.app`
- Update version and build number

#### 3. Create Archive
- Product > Archive
- Wait for archive to complete
- Click "Distribute App"
- Select "App Store Connect"
- Follow the wizard

#### 4. App Store Connect
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Create new app
3. Fill in app information
4. Upload screenshots
5. Submit for review

---

## 🗄️ Database Management

### Backup Strategy

#### Automated Daily Backups
```bash
# Create backup script
sudo nano /usr/local/bin/backup-linkkart-db.sh
```

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/linkkart"
mkdir -p $BACKUP_DIR

mysqldump -u linkkart_user -p'password' linkkart_prod | gzip > $BACKUP_DIR/linkkart_$DATE.sql.gz

# Keep only last 30 days
find $BACKUP_DIR -name "linkkart_*.sql.gz" -mtime +30 -delete
```

```bash
chmod +x /usr/local/bin/backup-linkkart-db.sh

# Add to crontab
sudo crontab -e
0 2 * * * /usr/local/bin/backup-linkkart-db.sh
```

### Database Optimization

```sql
-- Add indexes for better performance
CREATE INDEX idx_stores_slug ON stores(slug);
CREATE INDEX idx_products_store_id ON products(store_id);
CREATE INDEX idx_analytics_store_id ON analytics_events(store_id);
CREATE INDEX idx_analytics_created_at ON analytics_events(created_at);
```

---

## 📊 Monitoring & Logging

### Application Monitoring

#### 1. Laravel Telescope (Development/Staging)
```bash
composer require laravel/telescope
php artisan telescope:install
php artisan migrate
```

#### 2. Error Tracking (Sentry)
```bash
composer require sentry/sentry-laravel
php artisan sentry:publish --dsn=your_dsn_here
```

### Server Monitoring

#### Install Monitoring Tools
```bash
# Install htop
sudo apt install htop -y

# Install netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh)
```

### Log Management

```bash
# View Laravel logs
tail -f /var/www/linkkart/backend/storage/logs/laravel.log

# View Nginx logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

---

## 🔐 Security Hardening

### 1. Firewall Configuration
```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 2. Fail2Ban
```bash
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### 3. Security Headers (Nginx)
```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
```

### 4. Rate Limiting (Laravel)
```php
// In app/Http/Kernel.php
protected $middlewareGroups = [
    'api' => [
        'throttle:60,1',
        \Illuminate\Routing\Middleware\SubstituteBindings::class,
    ],
];
```

---

## 🎯 Performance Optimization

### Backend
```bash
# Enable OPcache
sudo nano /etc/php/8.1/fpm/php.ini
```

```ini
opcache.enable=1
opcache.memory_consumption=256
opcache.max_accelerated_files=20000
opcache.validate_timestamps=0
```

### Database
```sql
-- Optimize tables
OPTIMIZE TABLE stores, products, analytics_events;

-- Analyze tables
ANALYZE TABLE stores, products, analytics_events;
```

### CDN Setup
- Use Cloudflare for CDN and DDoS protection
- Configure caching rules
- Enable Brotli compression

---

## 📞 Post-Deployment

### 1. Smoke Testing
- [ ] API health check
- [ ] Create test store
- [ ] Add test product
- [ ] View storefront
- [ ] Test WhatsApp integration
- [ ] Admin login
- [ ] View analytics

### 2. Monitoring Setup
- [ ] Set up uptime monitoring (UptimeRobot)
- [ ] Configure error alerts
- [ ] Set up performance monitoring
- [ ] Enable log aggregation

### 3. Documentation
- [ ] Update API documentation
- [ ] Create user guides
- [ ] Document deployment process
- [ ] Create runbooks for common issues

---

## 🆘 Troubleshooting

### Common Issues

**Issue: 500 Internal Server Error**
```bash
# Check logs
tail -f storage/logs/laravel.log

# Check permissions
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache

# Clear cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

**Issue: Database Connection Failed**
```bash
# Test MySQL connection
mysql -u linkkart_user -p linkkart_prod

# Check MySQL status
sudo systemctl status mysql

# Restart MySQL
sudo systemctl restart mysql
```

**Issue: File Upload Not Working**
```bash
# Check storage permissions
ls -la storage/

# Recreate storage link
php artisan storage:link

# Check PHP upload limits
php -i | grep upload_max_filesize
php -i | grep post_max_size
```

---

## 📈 Scaling Strategy

### Horizontal Scaling
1. Set up load balancer
2. Deploy multiple app servers
3. Use centralized session storage (Redis)
4. Implement database replication

### Vertical Scaling
1. Upgrade server resources
2. Optimize database queries
3. Implement caching (Redis/Memcached)
4. Use CDN for static assets

---

## 🎉 Success!

Your LinkKart platform is now live in production!

**Access URLs:**
- API: https://api.linkkart.com
- Admin: https://admin.linkkart.com
- Storefront: https://linkkart.com
- Mobile App: Available on Play Store & App Store

---

**Need Help?**
- Email: support@linkkart.com
- Documentation: https://docs.linkkart.com
- Community: https://community.linkkart.com
