# Fix Store Creation DNS Error

## The Error
```
ClientException with SocketException:
Failed host lookup: 'api.linkkart.shop'
(OS Error: No address associated with hostname, errno = 7)
```

## What This Means
The mobile app can't reach `api.linkkart.shop`. This is a **network/DNS issue**, not a database issue.

## Possible Causes

### 1. DNS Not Propagated Yet
If you just set up the domain, DNS changes can take 24-48 hours to propagate globally.

**Check if DNS is working:**
```bash
# On your server
ping api.linkkart.shop

# Or check DNS
nslookup api.linkkart.shop
```

### 2. SSL Certificate Issue
The app is trying HTTPS but the certificate might not be set up.

**Check if API is accessible:**
```bash
curl https://api.linkkart.shop/api/health
```

### 3. Server Not Running
The backend might not be running on the server.

**Check if backend is running:**
```bash
# SSH to your server
ps aux | grep php
# or
systemctl status php-fpm
systemctl status nginx
```

### 4. Firewall Blocking
Server firewall might be blocking external connections.

**Check firewall:**
```bash
# On your server
sudo ufw status
sudo iptables -L
```

## Quick Fixes

### Fix 1: Use IP Address Temporarily (FASTEST)

Edit `mobile-app/lib/utils/constants.dart`:

```dart
static const List<String> baseUrls = [
  'http://YOUR_SERVER_IP:80',      // Replace with your actual server IP
  'https://api.linkkart.shop',     // Keep this for when DNS works
];
```

Replace `YOUR_SERVER_IP` with your actual server IP address.

Then rebuild the APK:
```bash
cd mobile-app
flutter clean
flutter build apk --release
```

### Fix 2: Add HTTP Fallback

If HTTPS isn't working, add HTTP fallback:

```dart
static const List<String> baseUrls = [
  'https://api.linkkart.shop',     // Try HTTPS first
  'http://api.linkkart.shop',      // Fallback to HTTP
];
```

### Fix 3: Check Server Configuration

SSH to your server and verify:

```bash
# Check if nginx is running
sudo systemctl status nginx

# Check if PHP-FPM is running
sudo systemctl status php8.2-fpm

# Check nginx configuration
sudo nginx -t

# Check if API responds locally
curl http://localhost/api/health

# Check if API responds externally
curl http://YOUR_SERVER_IP/api/health
```

### Fix 4: Verify DNS Setup

Check your DNS records:

```bash
# Check A record
dig api.linkkart.shop

# Check if it resolves to your server IP
nslookup api.linkkart.shop
```

Expected output should show your server's IP address.

## Testing the Fix

### Test 1: Check API Health from Browser
Open in browser:
```
https://api.linkkart.shop/api/health
```

Should return:
```json
{
  "success": true,
  "message": "API is running",
  "timestamp": "2026-05-21 12:59:00"
}
```

### Test 2: Check from Mobile Device
On your phone, open browser and go to:
```
https://api.linkkart.shop/api/health
```

If this doesn't work, your phone can't reach the server.

### Test 3: Check Store Creation Endpoint
```bash
curl -X POST https://api.linkkart.shop/api/v1/seller/stores \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Store",
    "phone": "1234567890",
    "description": "Test"
  }'
```

Should return store data or validation errors (not DNS error).

## Recommended Solution

**For immediate testing:**
1. Find your server's IP address
2. Edit `mobile-app/lib/utils/constants.dart`
3. Add your server IP as first option in `baseUrls`
4. Rebuild APK
5. Test store creation

**For production:**
1. Ensure DNS is properly configured
2. Set up SSL certificate (Let's Encrypt)
3. Configure nginx to serve API on port 443 (HTTPS)
4. Update mobile app to use HTTPS URL

## Check Your Server IP

SSH to your server and run:
```bash
curl ifconfig.me
```

This will show your public IP address.

## Next Steps

1. **Verify DNS is working:**
   ```bash
   ping api.linkkart.shop
   ```

2. **Check if API responds:**
   ```bash
   curl https://api.linkkart.shop/api/health
   ```

3. **If DNS not working:** Use IP address temporarily in mobile app

4. **If API not responding:** Check nginx and PHP-FPM are running

5. **If SSL issue:** Set up Let's Encrypt certificate

Send me the results of these checks and I'll help you fix it!
