# 🧪 TEST EVERYTHING LOCALLY - COMPLETE GUIDE

## 🎯 GOAL
Test the complete LinkKart system on your local machine before deploying to production.

---

## 📋 PREREQUISITES

Make sure you have:
- ✅ XAMPP running (Apache + MySQL)
- ✅ Node.js installed
- ✅ Flutter installed (for mobile app)
- ✅ All project files in `D:\linkkart`

---

## 🚀 STEP-BY-STEP LOCAL SETUP

### STEP 1: Setup Database (5 minutes)

#### 1.1 Start XAMPP
```bash
# Start Apache and MySQL from XAMPP Control Panel
```

#### 1.2 Import Complete Database
```bash
# Open browser: http://localhost/phpmyadmin
# Or use command line:

mysql -u root -p linkkart < COMPLETE_DATABASE_SETUP_PRODUCTION.sql
```

#### 1.3 Add Demo Stores with Images
```bash
mysql -u root -p linkkart < ADD_DEMO_STORES_WITH_IMAGES.sql
```

#### 1.4 Verify Database
```bash
php check_current_stores.php
```

**Expected output:**
```
✅ Database connection successful
TOTAL STORES: 8
✅ With Full URL Images: 8
🎉 ALL STORES HAVE PROPER IMAGE URLS!
```

---

### STEP 2: Start Backend API (2 minutes)

#### 2.1 Navigate to Backend
```bash
cd D:\linkkart\backend\public
```

#### 2.2 Start PHP Server
```bash
php -S localhost:8000
```

**Expected output:**
```
PHP 8.x Development Server (http://localhost:8000) started
```

#### 2.3 Test API
Open new terminal and test:
```bash
curl http://localhost:8000/api/health
```

**Expected:**
```json
{
  "success": true,
  "status": "healthy",
  "timestamp": 1234567890
}
```

#### 2.4 Test Stores API
```bash
curl http://localhost:8000/api/v1/stores
```

**Expected:** JSON with 8 stores, each with logo URL

---

### STEP 3: Start Storefront (3 minutes)

#### 3.1 Open New Terminal
```bash
cd D:\linkkart\storefront
```

#### 3.2 Install Dependencies (if not done)
```bash
npm install
```

#### 3.3 Start Development Server
```bash
npm start
```

**Expected output:**
```
Compiled successfully!

You can now view storefront in the browser.

  Local:            http://localhost:3000
  On Your Network:  http://192.168.x.x:3000
```

#### 3.4 Open in Browser
Browser should automatically open: http://localhost:3000

---

### STEP 4: Test Storefront (5 minutes)

#### 4.1 Check Homepage
- [ ] Page loads without errors
- [ ] Hero section displays
- [ ] "Our Stores" section shows 8 stores
- [ ] **Store images are visible** ✨
- [ ] Store names display correctly

#### 4.2 Check Browser Console (F12)
```
Expected logs:
=== FETCHING STORES ===
Trying URL: http://localhost:8000/api/v1/stores
Response received: {success: true, data: Array(8)}
✅ SUCCESS! Found 8 stores
Setting stores: (8) [{…}, {…}, …]
=== FETCH COMPLETE ===
```

**No errors should appear!**

#### 4.3 Click on a Store
- [ ] Store page loads
- [ ] Store details display
- [ ] Products show (if any)
- [ ] WhatsApp button works

#### 4.4 Test Responsive Design
- Press F12 → Toggle device toolbar
- Test on different screen sizes:
  - [ ] Mobile (375px)
  - [ ] Tablet (768px)
  - [ ] Desktop (1920px)

---

### STEP 5: Start Admin Dashboard (Optional - 3 minutes)

#### 5.1 Open New Terminal
```bash
cd D:\linkkart\admin-dashboard
```

#### 5.2 Install Dependencies (if not done)
```bash
npm install
```

#### 5.3 Start Development Server
```bash
npm start
```

**Opens at:** http://localhost:3001

#### 5.4 Login
- Email: `admin@linkkart.com`
- Password: `password`

#### 5.5 Test Admin Features
- [ ] Dashboard loads
- [ ] Stores list displays
- [ ] Analytics show
- [ ] Plans management works

---

### STEP 6: Test Mobile App (Optional - 5 minutes)

#### 6.1 Update Mobile App Config
```bash
# File: mobile-app/lib/utils/constants.dart
# Should already be set to:
static const String apiUrl = 'http://192.168.0.9:8000';
```

**Note:** Replace `192.168.0.9` with your actual local IP

#### 6.2 Find Your Local IP
```bash
# Windows
ipconfig
# Look for: IPv4 Address

# Example: 192.168.1.100
```

#### 6.3 Update Constants
```dart
// mobile-app/lib/utils/constants.dart
static const String apiUrl = 'http://YOUR_LOCAL_IP:8000';
```

#### 6.4 Run Mobile App
```bash
cd D:\linkkart\mobile-app
flutter run
```

#### 6.5 Test Features
- [ ] Login works
- [ ] Dashboard loads
- [ ] Products list displays
- [ ] Add product works
- [ ] Subscription screen loads

---

## 🔍 VERIFICATION CHECKLIST

### Database ✅
- [ ] 11 tables exist
- [ ] 8 demo stores with images
- [ ] 3 subscription plans
- [ ] Admin account exists

### Backend API ✅
- [ ] Running on http://localhost:8000
- [ ] Health check works
- [ ] Stores API returns 8 stores
- [ ] All stores have logo URLs
- [ ] CORS headers enabled

### Storefront ✅
- [ ] Running on http://localhost:3000
- [ ] Homepage loads
- [ ] **Store images display** ✨
- [ ] Store cards clickable
- [ ] Store pages work
- [ ] No console errors
- [ ] Mobile responsive

### Admin Dashboard ✅
- [ ] Running on http://localhost:3001
- [ ] Login works
- [ ] Dashboard displays
- [ ] Stores list shows
- [ ] Plans management works

### Mobile App ✅
- [ ] Connects to local API
- [ ] Login works
- [ ] Products load
- [ ] Add product works
- [ ] Subscription works

---

## 🚨 TROUBLESHOOTING

### Issue: Storefront images not showing

**Check 1: API URL**
```javascript
// storefront/src/config.js
console.log(API_BASE_URL);
// Should be: http://localhost:8000
```

**Check 2: Backend running**
```bash
curl http://localhost:8000/api/health
# Should return success
```

**Check 3: Database has images**
```bash
php check_current_stores.php
# Should show stores with image URLs
```

**Check 4: Browser console**
- Open F12 → Console
- Look for errors
- Check Network tab for failed requests

### Issue: CORS errors

**Fix:** Check backend has CORS headers in `backend/public/index.php`:
```php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
```

### Issue: Database connection failed

**Fix:**
1. Start XAMPP MySQL
2. Check credentials in `backend/public/index.php`:
   ```php
   define('DB_HOST', 'localhost');
   define('DB_NAME', 'linkkart');
   define('DB_USER', 'root');
   define('DB_PASS', ''); // Empty for XAMPP
   ```

### Issue: Port already in use

**Backend (8000):**
```bash
# Use different port
php -S localhost:8001
# Update storefront config to use 8001
```

**Storefront (3000):**
```bash
# Set PORT environment variable
set PORT=3001
npm start
```

### Issue: npm install fails

**Fix:**
```bash
# Clear cache
npm cache clean --force

# Delete node_modules and package-lock.json
rm -rf node_modules package-lock.json

# Reinstall
npm install
```

---

## 📊 EXPECTED RESULTS

### Homepage Should Look Like:
```
┌─────────────────────────────────────────────────┐
│  [LK Logo]              Stores Features About   │
│                                    Get Started   │
├─────────────────────────────────────────────────┤
│                                                  │
│     Build Beautiful Storefronts.                │
│     Sell Faster on WhatsApp.                    │
│                                                  │
│     [Get Started]  [Learn More]                 │
│                                                  │
├─────────────────────────────────────────────────┤
│                                                  │
│           OUR STORES                             │
│   Designer Stores Like High Fashion Houses      │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │ [Image]  │  │ [Image]  │  │ [Image]  │     │
│  │ Luxury   │  │ Tech     │  │ Home     │     │
│  │ Fashion  │  │ Gadgets  │  │ Decor    │     │
│  └──────────┘  └──────────┘  └──────────┘     │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │ [Image]  │  │ [Image]  │  │ [Image]  │     │
│  │ Organic  │  │ Sports   │  │ Artisan  │     │
│  │ Wellness │  │ Fitness  │  │ Jewelry  │     │
│  └──────────┘  └──────────┘  └──────────┘     │
│                                                  │
└─────────────────────────────────────────────────┘
```

### Browser Console Should Show:
```
=== FETCHING STORES ===
Trying URL: http://localhost:8000/api/v1/stores
Response received: {success: true, data: Array(8)}
✅ SUCCESS! Found 8 stores
Setting stores: (8) [{…}, {…}, {…}, {…}, {…}, {…}, {…}, {…}]
=== FETCH COMPLETE ===
```

### Network Tab Should Show:
```
✅ GET http://localhost:8000/api/v1/stores  200 OK
✅ GET https://images.unsplash.com/...      200 OK (x8)
```

---

## 🎯 QUICK START COMMANDS

Open 3 terminals and run:

**Terminal 1 - Backend:**
```bash
cd D:\linkkart\backend\public
php -S localhost:8000
```

**Terminal 2 - Storefront:**
```bash
cd D:\linkkart\storefront
npm start
```

**Terminal 3 - Admin (Optional):**
```bash
cd D:\linkkart\admin-dashboard
npm start
```

Then open:
- Storefront: http://localhost:3000
- Admin: http://localhost:3001
- API: http://localhost:8000/api/health

---

## ✅ SUCCESS CRITERIA

Everything is working when:

✅ Backend API responds at localhost:8000  
✅ Storefront loads at localhost:3000  
✅ **Store images display on homepage** ✨  
✅ 8 demo stores visible  
✅ No console errors  
✅ Store pages clickable  
✅ API calls successful  
✅ Mobile responsive  

---

## 📸 SCREENSHOT CHECKLIST

Take screenshots of:
1. Homepage with store images
2. Browser console (no errors)
3. Network tab (successful API calls)
4. Store detail page
5. Mobile view

---

## 🎉 NEXT STEPS

Once everything works locally:

1. **Test thoroughly** - Click everything, test all features
2. **Fix any issues** - Debug and resolve problems
3. **Document changes** - Note any customizations
4. **Prepare for production** - Update URLs to live domains
5. **Deploy** - Upload to production servers

---

**Time Required:** 20 minutes  
**Difficulty:** Easy  
**Goal:** See beautiful storefront with images locally! 🖼️

**Ready? Start with STEP 1! 🚀**

