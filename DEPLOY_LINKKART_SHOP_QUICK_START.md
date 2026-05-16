# 🚀 Deploy linkkart.shop - Quick Start Guide

**Your Domain:** linkkart.shop  
**Time Required:** 2-3 hours  
**Difficulty:** Intermediate

---

## 📊 What You're Deploying

You have **4 systems** to deploy:

1. **Backend API** → `api.linkkart.shop` (PHP/Laravel)
2. **Storefront** → `linkkart.shop` (React - Public website)
3. **Admin Dashboard** → `admin.linkkart.shop` (React - Admin panel)
4. **Mobile App** → APK download (Flutter - Seller app)

---

## ⚡ Quick Deployment Path

### Option 1: Managed Hosting (Easiest) ⭐ RECOMMENDED FOR BEGINNERS

**Use:** Hostinger, Namecheap, or Bluehost  
**Cost:** $5-15/month  
**Time:** 1-2 hours  
**Difficulty:** Easy

#### Steps:
1. **Buy hosting** with cPanel
2. **Upload files** via File Manager
3. **Create database** in cPanel
4. **Import database** using phpMyAdmin
5. **Configure domains** in cPanel
6. **Done!**

**Pros:** Easy, no command line needed  
**Cons:** Limited control, may be slower

---

### Option 2: VPS Server (Recommended) ⭐ BEST FOR PRODUCTION

**Use:** DigitalOcean, Linode, or AWS Lightsail  
**Cost:** $10-20/month  
**Time:** 2-3 hours  
**Difficulty:** Intermediate

#### Steps:
1. **Create VPS** (Ubuntu 22.04)
2. **Install software** (Nginx, PHP, MySQL, Node.js)
3. **Upload code** via Git or SFTP
4. **Configure domains** in Nginx
5. **Install SSL** (free with Let's Encrypt)
6. **Done!**

**Pros:** Full control, better performance  
**Cons:** Requires command line knowledge

---

## 🎯 Recommended: DigitalOcean Deployment

### Step 1: Create Server (5 minutes)

1. Go to https://www.digitalocean.com
2. Sign up and add payment method
3. Click "Create" → "Droplets"
4. Choose:
   - **Image:** Ubuntu 22.04 LTS
   - **Plan:** Basic $12/month (2GB RAM)
   - **Datacenter:** Closest to your users
   - **Authentication:** Password (easier) or SSH Key
5. Click "Create Droplet"
6. **Note your server IP address** (e.g., 203.0.113.45)

### Step 2: Configure DNS (10 minutes)

Go to your domain registrar (where you bought linkkart.shop):

**Add these DNS records:**
```
Type    Name    Value               TTL
A       @       YOUR_SERVER_IP      3600
A       www     YOUR_SERVER_IP      3600
A       api     YOUR_SERVER_IP      3600
A       admin   YOUR_SERVER_IP      3600
```

**Example:**
```
A       @       203.0.113.45        3600
A       www     203.0.113.45        3600
A       api     203.0.113.45        3600
A       admin   203.0.113.45        3600
```

**Wait 10-30 minutes for DNS to propagate**

### Step 3: Connect to Server (2 minutes)

**Windows:**
```powershell
ssh root@YOUR_SERVER_IP
```

**Enter password when prompted**

### Step 4: Run Auto-Install Script (30 minutes)

I'll create an automated installation script for you:

```bash
# Download and run installation script
curl -o install.sh https://raw.githubusercontent.com/YOUR_REPO/install.sh
chmod +x install.sh
./install.sh
```

**The script will:**
- Install Nginx, PHP, MySQL, Node.js
- Create database
- Configure all 3 systems
- Set up SSL certificates
- Start all services

### Step 5: Upload Your Code (15 minutes)

**Option A: Using Git (Recommended)**
```bash
cd /var/www/backend
git clone YOUR_GITHUB_REPO .
composer install
```

**Option B: Using SFTP**
1. Download FileZilla or WinSCP
2. Connect to your server
3. Upload folders to `/var/www/`

### Step 6: Configure Environment (10 minutes)

```bash
cd /var/www/backend
nano .env
```

**Update these values:**
```env
APP_URL=https://api.linkkart.shop
DB_DATABASE=linkkart
DB_USERNAME=linkkart_user
DB_PASSWORD=YOUR_STRONG_PASSWORD
FRONTEND_URL=https://linkkart.shop
```

### Step 7: Import Database (5 minutes)

```bash
mysql -u linkkart_user -p linkkart < database_setup.sql
```

### Step 8: Install SSL (5 minutes)

```bash
sudo certbot --nginx -d api.linkkart.shop
sudo certbot --nginx -d linkkart.shop -d www.linkkart.shop
sudo certbot --nginx -d admin.linkkart.shop
```

### Step 9: Test Everything (10 minutes)

**Test Backend:**
```
https://api.linkkart.shop/api/health
```

**Test Storefront:**
```
https://linkkart.shop
```

**Test Admin:**
```
https://admin.linkkart.shop
```

### Step 10: Update Mobile App (15 minutes)

**Edit mobile app config:**
```dart
// mobile-app/lib/utils/constants.dart
static const String _baseUrl = 'https://api.linkkart.shop';
```

**Build APK:**
```bash
cd mobile-app
flutter build apk --release
```

**Upload APK to your website for download**

---

## 🎉 You're Live!

Your platform is now accessible at:

- **Website:** https://linkkart.shop
- **Admin:** https://admin.linkkart.shop
- **API:** https://api.linkkart.shop
- **Mobile App:** Download from website

---

## 📋 Simplified Checklist

### Pre-Deployment
- [ ] Domain purchased (linkkart.shop) ✅
- [ ] VPS server created
- [ ] DNS records configured
- [ ] Code ready to upload

### Deployment
- [ ] Server software installed
- [ ] Code uploaded
- [ ] Database created and imported
- [ ] Environment configured
- [ ] SSL certificates installed

### Post-Deployment
- [ ] Backend API tested
- [ ] Storefront tested
- [ ] Admin dashboard tested
- [ ] Mobile app updated and built
- [ ] All systems working

---

## 💰 Total Cost

| Item | Cost |
|------|------|
| Domain (linkkart.shop) | $10-15/year |
| VPS Server (DigitalOcean) | $12/month |
| SSL Certificates | FREE |
| **Total** | **~$12/month** |

---

## 🆘 Need Help?

### Common Issues

**"Can't connect to server"**
- Check if DNS has propagated (use https://dnschecker.org)
- Verify server IP is correct
- Check firewall settings

**"502 Bad Gateway"**
- Restart services: `sudo systemctl restart nginx php8.1-fpm`
- Check logs: `sudo tail -f /var/log/nginx/error.log`

**"Database connection failed"**
- Verify database credentials in `.env`
- Check MySQL is running: `sudo systemctl status mysql`

**"Mobile app can't connect"**
- Verify API URL is `https://api.linkkart.shop`
- Rebuild app with correct URL
- Check SSL certificate is valid

---

## 📞 Professional Help Options

If you need assistance:

1. **Hire on Fiverr/Upwork**
   - Search: "Deploy Laravel React app"
   - Cost: $50-200
   - Time: 1-2 days

2. **Managed Deployment Services**
   - Cloudways, Ploi, Laravel Forge
   - Cost: $10-30/month extra
   - Benefit: Automated deployment

3. **DevOps Consultant**
   - One-time setup
   - Cost: $200-500
   - Benefit: Professional setup + training

---

## 🎯 Next Steps After Deployment

1. **Test thoroughly** - Check all features work
2. **Set up backups** - Daily database backups
3. **Monitor performance** - Use tools like UptimeRobot
4. **Add analytics** - Google Analytics for website
5. **Marketing** - Start promoting your platform
6. **Get users** - Onboard first sellers
7. **Collect feedback** - Improve based on user input
8. **Scale up** - Upgrade server as you grow

---

## 📚 Full Documentation

For detailed step-by-step instructions, see:
- `COMPLETE_DEPLOYMENT_GUIDE_LINKKART_SHOP.md`

---

**Ready to deploy? Let's go! 🚀**
