# 🚀 START HERE: Deploy linkkart.shop

**Your Domain:** linkkart.shop ✅  
**Time Needed:** 2-3 hours  
**Monthly Cost:** $12

---

## 🎯 What You're Building

```
┌─────────────────────────────────────────────────────┐
│                  linkkart.shop                      │
│              (Your E-commerce Platform)             │
└─────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  Storefront  │  │  Admin Panel │  │  Backend API │
│              │  │              │  │              │
│ linkkart.shop│  │admin.linkkart│  │api.linkkart  │
│              │  │    .shop     │  │    .shop     │
│              │  │              │  │              │
│ Customers    │  │ Platform     │  │ Powers       │
│ browse stores│  │ management   │  │ everything   │
└──────────────┘  └──────────────┘  └──────────────┘
                                            │
                                            ▼
                                    ┌──────────────┐
                                    │  Mobile App  │
                                    │              │
                                    │ Sellers      │
                                    │ manage stores│
                                    └──────────────┘
```

---

## ⚡ Quick Decision Tree

### Question 1: Do you know Linux/command line?

**YES** → Go to [Path A: DIY Deployment](#path-a-diy-deployment)  
**NO** → Go to [Path B: Hire Someone](#path-b-hire-someone)

### Question 2: What's your budget?

**$12/month** → VPS (DigitalOcean) - Best option  
**$5-10/month** → Shared hosting (Hostinger) - Easier but limited  
**$50-200 one-time** → Hire freelancer - Easiest

---

## 🎯 Path A: DIY Deployment

**Time:** 2-3 hours  
**Cost:** $12/month  
**Difficulty:** Intermediate

### Step 1: Get Server (10 minutes)

1. Go to **https://www.digitalocean.com**
2. Sign up (use credit card or PayPal)
3. Click **"Create"** → **"Droplets"**
4. Select:
   ```
   Image:      Ubuntu 22.04 LTS
   Plan:       Basic $12/month (2GB RAM, 50GB SSD)
   Datacenter: Bangalore (closest to India)
   Password:   Create a strong password
   ```
5. Click **"Create Droplet"**
6. **Copy your server IP** (e.g., 203.0.113.45)

### Step 2: Configure Domain (15 minutes)

1. Go to where you bought **linkkart.shop**
2. Find **DNS Settings** or **DNS Management**
3. Add these records:

```
Type    Name    Value               TTL
────────────────────────────────────────
A       @       203.0.113.45        3600
A       www     203.0.113.45        3600
A       api     203.0.113.45        3600
A       admin   203.0.113.45        3600
```

Replace `203.0.113.45` with YOUR server IP

4. **Wait 10-30 minutes** for DNS to update

### Step 3: Connect to Server (5 minutes)

**Windows:**
```powershell
# Open PowerShell
ssh root@203.0.113.45
# Replace with YOUR server IP
# Enter password when prompted
```

**Mac/Linux:**
```bash
# Open Terminal
ssh root@203.0.113.45
# Replace with YOUR server IP
```

### Step 4: Run Auto-Install (30 minutes)

Copy and paste this into your server:

```bash
# Download installation script
wget https://raw.githubusercontent.com/YOUR_USERNAME/linkkart/main/install-server.sh

# Make it executable
chmod +x install-server.sh

# Run it
./install-server.sh
```

**The script will ask you:**
- Domain name: `linkkart.shop`
- MySQL root password: (create a strong password)
- MySQL user password: (create another strong password)
- Email: (your email for SSL certificates)

**Then it will automatically:**
- Install Nginx, PHP, MySQL, Node.js
- Create database
- Configure web server
- Set up firewall
- Create directory structure

### Step 5: Upload Code (30 minutes)

**Option A: Using Git (if you have GitHub)**
```bash
# Backend
cd /var/www/backend
git clone https://github.com/YOUR_USERNAME/linkkart-backend.git .
composer install --no-dev

# Storefront
cd /var/www/storefront
git clone https://github.com/YOUR_USERNAME/linkkart-storefront.git .
npm install
npm run build

# Admin
cd /var/www/admin-dashboard
git clone https://github.com/YOUR_USERNAME/linkkart-admin.git .
npm install
npm run build
```

**Option B: Using SFTP (easier)**
1. Download **FileZilla** or **WinSCP**
2. Connect to your server:
   - Host: `203.0.113.45` (your server IP)
   - Username: `root`
   - Password: (your server password)
   - Port: `22`
3. Upload folders:
   - `backend/` → `/var/www/backend/`
   - `storefront/` → `/var/www/storefront/`
   - `admin-dashboard/` → `/var/www/admin-dashboard/`

### Step 6: Configure Backend (15 minutes)

```bash
cd /var/www/backend

# Copy environment file
cp .env.example .env

# Edit it
nano .env
```

**Update these values:**
```env
APP_URL=https://api.linkkart.shop
DB_PASSWORD=YOUR_MYSQL_PASSWORD
FRONTEND_URL=https://linkkart.shop
RAZORPAY_KEY_ID=your_razorpay_key
RAZORPAY_KEY_SECRET=your_razorpay_secret
```

**Save:** Press `Ctrl+X`, then `Y`, then `Enter`

**Generate key and migrate:**
```bash
php artisan key:generate
php artisan migrate --force
```

### Step 7: Import Database (5 minutes)

```bash
# Upload database_setup.sql to server, then:
mysql -u linkkart_user -p linkkart < database_setup.sql
# Enter your MySQL user password
```

### Step 8: Install SSL (10 minutes)

```bash
# For API
certbot --nginx -d api.linkkart.shop --email your@email.com --agree-tos --non-interactive

# For Storefront
certbot --nginx -d linkkart.shop -d www.linkkart.shop --email your@email.com --agree-tos --non-interactive

# For Admin
certbot --nginx -d admin.linkkart.shop --email your@email.com --agree-tos --non-interactive
```

### Step 9: Test Everything (10 minutes)

**Test Backend:**
```
https://api.linkkart.shop/api/health
```
Should show: `{"success":true,"message":"LinkKart API is running"}`

**Test Storefront:**
```
https://linkkart.shop
```
Should show: Your storefront homepage

**Test Admin:**
```
https://admin.linkkart.shop
```
Should show: Admin login page

### Step 10: Update Mobile App (15 minutes)

```bash
# On your local computer
cd mobile-app

# Edit constants file
nano lib/utils/constants.dart
```

**Change:**
```dart
static String _baseUrl = 'https://api.linkkart.shop';
static const String storefrontUrl = 'https://linkkart.shop';
```

**Build APK:**
```bash
flutter build apk --release
```

**APK location:** `build/app/outputs/flutter-apk/app-release.apk`

---

## 🎯 Path B: Hire Someone

**Time:** 3-4 days  
**Cost:** $50-200  
**Difficulty:** Easy

### Step 1: Create Job Post

**Go to:** Fiverr.com or Upwork.com

**Job Title:**
```
Deploy Laravel + React Application to VPS
```

**Job Description:**
```
I need help deploying my LinkKart e-commerce platform to a VPS server.

The project consists of:
- Backend API (Laravel/PHP)
- Storefront (React)
- Admin Dashboard (React)
- Mobile App (Flutter)

Domain: linkkart.shop

Requirements:
- Set up VPS server (DigitalOcean or similar)
- Configure DNS and subdomains
- Deploy all 3 web applications
- Install SSL certificates
- Configure database
- Test all systems
- Provide documentation

I have:
- Complete source code
- Domain name (linkkart.shop)
- Deployment guides
- Database backup

Budget: $50-200
Timeline: 2-3 days
```

### Step 2: Share Files

Send the freelancer:
- Access to your code (GitHub or ZIP)
- `COMPLETE_DEPLOYMENT_GUIDE_LINKKART_SHOP.md`
- `install-server.sh`
- Database backup file
- Domain registrar login (for DNS)

### Step 3: Provide Access

Give them:
- VPS server access (create account for them)
- Domain DNS access
- Any API keys (Razorpay, Firebase)

### Step 4: Review & Test

Once they're done:
- Test all URLs
- Verify all features work
- Get documentation
- Change all passwords

---

## 📋 Deployment Checklist

### Before Starting:
- [ ] Domain purchased (linkkart.shop) ✅
- [ ] VPS server account created
- [ ] Code ready to upload
- [ ] Database backup ready
- [ ] Razorpay API keys ready
- [ ] Firebase config ready

### During Deployment:
- [ ] Server created and accessible
- [ ] DNS configured
- [ ] Software installed
- [ ] Code uploaded
- [ ] Database imported
- [ ] Environment configured
- [ ] SSL certificates installed

### After Deployment:
- [ ] Backend API tested
- [ ] Storefront tested
- [ ] Admin dashboard tested
- [ ] Mobile app updated
- [ ] All features working
- [ ] Backups configured
- [ ] Monitoring set up

---

## 💰 Cost Summary

### DIY Path:
```
Domain:         $10-15/year
VPS Server:     $12/month
SSL:            FREE (Let's Encrypt)
────────────────────────────
Total:          ~$12/month
```

### Hired Help Path:
```
Domain:         $10-15/year
VPS Server:     $12/month
SSL:            FREE
Deployment:     $50-200 (one-time)
────────────────────────────
First month:    ~$62-212
After:          ~$12/month
```

---

## 🆘 Common Issues & Solutions

### "Can't connect to server"
```bash
# Check if server is running
ping YOUR_SERVER_IP

# Check SSH is working
ssh -v root@YOUR_SERVER_IP
```

### "DNS not working"
- Wait 30 minutes for propagation
- Check DNS: https://dnschecker.org
- Verify A records are correct

### "502 Bad Gateway"
```bash
# Restart services
sudo systemctl restart nginx
sudo systemctl restart php8.1-fpm
```

### "Database connection failed"
```bash
# Check MySQL is running
sudo systemctl status mysql

# Verify credentials in .env
cat /var/www/backend/.env
```

---

## 📚 Documentation Files

**Start with:**
- `START_DEPLOYMENT_HERE.md` ← You are here
- `DEPLOYMENT_SUMMARY_LINKKART_SHOP.md` - Overview

**For DIY:**
- `DEPLOY_LINKKART_SHOP_QUICK_START.md` - Quick guide
- `COMPLETE_DEPLOYMENT_GUIDE_LINKKART_SHOP.md` - Detailed guide
- `install-server.sh` - Auto-install script

**For Reference:**
- `BACKEND_API_TEST_RESULTS.md` - API testing
- `FRONTEND_BACKEND_RUNNING.md` - Local testing
- `MOBILE_APP_CONNECTION_FIXED.md` - Mobile setup

---

## 🎯 Success Criteria

You're successfully deployed when:

✅ `https://api.linkkart.shop/api/health` returns success  
✅ `https://linkkart.shop` shows storefront  
✅ `https://admin.linkkart.shop` shows admin panel  
✅ Mobile app connects to production API  
✅ Can create stores and products  
✅ Payments work (Razorpay)  
✅ All features functional

---

## 🚀 Ready to Start?

### Choose Your Path:

**Path A: DIY** → Follow steps above  
**Path B: Hire** → Post job on Fiverr/Upwork

### Need More Details?

Read: `DEPLOY_LINKKART_SHOP_QUICK_START.md`

### Have Questions?

Check: `COMPLETE_DEPLOYMENT_GUIDE_LINKKART_SHOP.md`

---

## 🎉 After Deployment

Once live:

1. **Test Everything** - Thoroughly test all features
2. **Set Up Backups** - Daily automated backups
3. **Monitor** - Use UptimeRobot (free)
4. **Market** - Start promoting your platform
5. **Onboard Users** - Get first sellers
6. **Collect Feedback** - Improve based on feedback
7. **Scale** - Upgrade server as you grow

---

**Let's get linkkart.shop live! 🚀**

**Choose your path and start deploying!**
