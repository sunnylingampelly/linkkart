# 🚀 DEPLOY STOREFRONT TO PRODUCTION

## ✅ BUILD COMPLETE!

Your storefront is built and ready in: `D:\linkkart\storefront\build`

---

## 🎯 DEPLOYMENT OPTIONS

### Option 1: Deploy to Existing Server (Recommended)

If you already have linkkart.shop hosted, upload the build folder contents.

#### Via FTP/SFTP:
1. Connect to your server via FTP (FileZilla, WinSCP, etc.)
2. Navigate to your web root (usually `/public_html` or `/var/www/html`)
3. Upload ALL contents from `storefront/build/` folder
4. Make sure files are in the root, not in a "build" subfolder

#### Via SSH/Command Line:
```bash
# On your local machine, zip the build folder
cd D:\linkkart\storefront
tar -czf storefront-build.tar.gz build/

# Upload to server
scp storefront-build.tar.gz user@your-server:/tmp/

# On server, extract to web root
ssh user@your-server
cd /var/www/html  # or your web root
tar -xzf /tmp/storefront-build.tar.gz --strip-components=1
```

---

### Option 2: Test Locally First

Before deploying to production, test locally:

```bash
# Install serve globally (one time only)
npm install -g serve

# Serve the build folder
cd D:\linkkart\storefront
serve -s build -p 3000

# Open in browser
# http://localhost:3000
```

**Test checklist:**
- [ ] Homepage loads
- [ ] Store images appear
- [ ] Store cards are clickable
- [ ] No console errors
- [ ] API calls work

---

## 📁 WHAT'S IN THE BUILD FOLDER

```
build/
├── index.html          (Main HTML file)
├── static/
│   ├── css/           (Compiled CSS)
│   ├── js/            (Compiled JavaScript)
│   └── media/         (Images, fonts)
├── manifest.json      (PWA manifest)
├── robots.txt         (SEO)
└── asset-manifest.json
```

---

## 🔧 SERVER CONFIGURATION

### Apache (.htaccess)

Create/update `.htaccess` in your web root:

```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteCond %{REQUEST_FILENAME} !-l
  RewriteRule . /index.html [L]
</IfModule>

# Enable CORS for API calls
<IfModule mod_headers.c>
  Header set Access-Control-Allow-Origin "*"
</IfModule>

# Enable compression
<IfModule mod_deflate.c>
  AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript
</IfModule>

# Cache static assets
<IfModule mod_expires.c>
  ExpiresActive On
  ExpiresByType image/jpg "access plus 1 year"
  ExpiresByType image/jpeg "access plus 1 year"
  ExpiresByType image/gif "access plus 1 year"
  ExpiresByType image/png "access plus 1 year"
  ExpiresByType text/css "access plus 1 month"
  ExpiresByType application/javascript "access plus 1 month"
</IfModule>
```

### Nginx

Add to your nginx config:

```nginx
server {
    listen 80;
    server_name linkkart.shop www.linkkart.shop;
    root /var/www/html;
    index index.html;

    # Serve static files
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Enable gzip
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
}
```

---

## 🔍 POST-DEPLOYMENT VERIFICATION

### Step 1: Check Files Uploaded
```bash
# SSH into server
ssh user@your-server

# Check files exist
ls -la /var/www/html/
# Should see: index.html, static/, manifest.json, etc.
```

### Step 2: Test Homepage
```bash
curl https://linkkart.shop
# Should return HTML content
```

### Step 3: Test API Connection
Open browser console (F12) and check:
```
✅ No CORS errors
✅ API calls to https://api.linkkart.shop work
✅ Stores load successfully
✅ Images display
```

### Step 4: Test All Pages
- [ ] Homepage (/)
- [ ] Store page (/store/luxury-fashion-boutique)
- [ ] 404 page (any invalid URL should show homepage)

---

## 🚨 TROUBLESHOOTING

### Issue: "404 Not Found" on refresh

**Cause:** Server not configured for SPA routing  
**Fix:** Add .htaccess (Apache) or update nginx config (see above)

### Issue: Images not loading

**Cause:** API URL incorrect or CORS issue  
**Fix:** 
1. Check `storefront/src/config.js` has correct API URL
2. Rebuild: `npm run build`
3. Redeploy

### Issue: Blank page

**Cause:** JavaScript errors or wrong base path  
**Fix:**
1. Open browser console (F12)
2. Check for errors
3. Verify all files uploaded correctly

### Issue: API calls fail

**Cause:** CORS not enabled on backend  
**Fix:** Check backend has CORS headers:
```php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
```

---

## 📊 DEPLOYMENT CHECKLIST

### Pre-Deployment
- [x] Storefront built successfully
- [x] API URL updated to production
- [ ] Demo stores imported to database
- [ ] Tested locally with `serve -s build`

### Deployment
- [ ] Files uploaded to server
- [ ] .htaccess or nginx config updated
- [ ] File permissions correct (644 for files, 755 for directories)
- [ ] SSL certificate active (HTTPS)

### Post-Deployment
- [ ] Homepage loads at https://linkkart.shop
- [ ] Store images display
- [ ] Store pages work
- [ ] No console errors
- [ ] API calls successful
- [ ] Mobile responsive
- [ ] Fast loading (< 3 seconds)

---

## 🎯 QUICK DEPLOYMENT COMMANDS

### For cPanel/Shared Hosting:

1. **Zip the build folder:**
```bash
cd D:\linkkart\storefront
powershell Compress-Archive -Path build\* -DestinationPath storefront-deploy.zip
```

2. **Upload via cPanel:**
   - Login to cPanel
   - Go to File Manager
   - Navigate to public_html
   - Upload storefront-deploy.zip
   - Extract archive
   - Delete zip file

### For VPS/Dedicated Server:

```bash
# On local machine
cd D:\linkkart\storefront
scp -r build/* user@your-server:/var/www/html/

# On server
ssh user@your-server
cd /var/www/html
chown -R www-data:www-data *
chmod -R 755 *
```

---

## 🔄 FUTURE UPDATES

When you make changes to the storefront:

```bash
# 1. Make your changes in src/
# 2. Rebuild
cd D:\linkkart\storefront
npm run build

# 3. Redeploy (upload build folder contents)
```

---

## 📱 MOBILE OPTIMIZATION

The storefront is already mobile-optimized, but verify:

1. **Test on mobile devices:**
   - iPhone Safari
   - Android Chrome
   - Tablet browsers

2. **Check responsive design:**
   - Open DevTools (F12)
   - Toggle device toolbar
   - Test different screen sizes

3. **Performance:**
   - Use Google PageSpeed Insights
   - Target: 90+ score

---

## 🎨 BRANDING FILES

Make sure these files are in your build:

- [ ] `/lk_luxury_monogram_only.png` - Logo
- [ ] `/hero_bg.png` - Hero background
- [ ] `/favicon.ico` - Browser icon
- [ ] `/manifest.json` - PWA config

If missing, copy from `storefront/public/` to `storefront/build/`

---

## 🌐 DNS CONFIGURATION

Ensure your domain points to the server:

```
Type    Name              Value
A       linkkart.shop     YOUR_SERVER_IP
A       www.linkkart.shop YOUR_SERVER_IP
```

Check DNS propagation:
```bash
nslookup linkkart.shop
# Should return your server IP
```

---

## 🔐 SSL CERTIFICATE

Ensure HTTPS is working:

```bash
# Test SSL
curl -I https://linkkart.shop
# Should return 200 OK with SSL

# Check certificate
openssl s_client -connect linkkart.shop:443 -servername linkkart.shop
```

If SSL not working, install Let's Encrypt:
```bash
sudo certbot --nginx -d linkkart.shop -d www.linkkart.shop
```

---

## ✅ SUCCESS CRITERIA

Your storefront is successfully deployed when:

✅ https://linkkart.shop loads without errors  
✅ Store images display correctly  
✅ Store cards are clickable  
✅ Store pages load (/store/slug)  
✅ No console errors  
✅ API calls work  
✅ Mobile responsive  
✅ Fast loading (< 3 seconds)  
✅ HTTPS enabled  
✅ SEO meta tags present  

---

## 📞 NEED HELP?

### Check Server Logs
```bash
# Apache
tail -f /var/log/apache2/error.log

# Nginx
tail -f /var/log/nginx/error.log
```

### Check Browser Console
1. Open DevTools (F12)
2. Go to Console tab
3. Look for errors
4. Check Network tab for failed requests

### Test API Separately
```bash
curl https://api.linkkart.shop/api/health
curl https://api.linkkart.shop/api/v1/stores
```

---

## 🎉 NEXT STEPS AFTER DEPLOYMENT

1. **Import Demo Stores:**
   ```bash
   mysql -u root -p linkkart < ADD_DEMO_STORES_WITH_IMAGES.sql
   ```

2. **Test Everything:**
   - Browse stores
   - Click on store cards
   - Check images load
   - Test on mobile

3. **Monitor:**
   - Check server logs
   - Monitor API calls
   - Track page load times

4. **Optimize:**
   - Enable CDN if needed
   - Optimize images
   - Enable caching

---

**Your storefront is ready to deploy! 🚀**

**Time to Deploy:** 10-15 minutes  
**Difficulty:** Easy  
**Impact:** High (beautiful storefront live!)

