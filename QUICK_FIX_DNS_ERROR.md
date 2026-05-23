# 🚨 Quick Fix - Store Creation DNS Error

## The Problem
Mobile app can't reach `api.linkkart.shop` - DNS/network issue.

## Quick Test
Open this in your phone's browser:
```
https://api.linkkart.shop/api/health
```

**If it loads** → DNS is working, different issue
**If it doesn't load** → DNS not working yet

## Fastest Fix: Use Server IP

### Step 1: Get Your Server IP
SSH to your server:
```bash
curl ifconfig.me
```
Copy the IP address (e.g., `123.45.67.89`)

### Step 2: Update Mobile App
Edit `mobile-app/lib/utils/constants.dart`:

Find this line:
```dart
static const List<String> baseUrls = [
  'https://api.linkkart.shop',
];
```

Change to (replace with YOUR actual IP):
```dart
static const List<String> baseUrls = [
  'http://YOUR_SERVER_IP',           // e.g., 'http://123.45.67.89'
  'https://api.linkkart.shop',       // Keep for when DNS works
];
```

### Step 3: Rebuild APK
```bash
cd mobile-app
flutter clean
flutter build apk --release
```

### Step 4: Install and Test
Install the new APK on your phone and try creating a store.

## Alternative: Wait for DNS
If you just set up the domain, DNS can take 24-48 hours to propagate. You can:
1. Wait for DNS to propagate
2. Use the IP address fix above temporarily

## Check DNS Status
```bash
# On your computer or server
nslookup api.linkkart.shop
```

Should show your server's IP address.

## Still Not Working?
Check if your backend is running:
```bash
# SSH to server
sudo systemctl status nginx
sudo systemctl status php8.2-fpm

# Test locally
curl http://localhost/api/health
```

Send me the output and I'll help further!
