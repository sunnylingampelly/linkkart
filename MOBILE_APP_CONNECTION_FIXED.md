# ✅ Mobile App Connection Fixed

**Date:** May 13, 2026  
**Your Computer IP:** 192.168.0.9  
**Status:** Backend Now Accessible on Network

---

## 🔧 Issues Fixed

### Issue 1: Wrong IP Address
**Problem:** Mobile app was trying to connect to `192.168.1.30:8000`  
**Your Actual IP:** `192.168.0.9`  
**Solution:** ✅ Updated `mobile-app/lib/utils/constants.dart`

### Issue 2: Backend Only on Localhost
**Problem:** Backend was running on `localhost:8000` (not accessible from mobile)  
**Solution:** ✅ Restarted backend on `0.0.0.0:8000` (accessible from network)

---

## 🚀 Current Configuration

### Backend Server
- **Network URL:** http://192.168.0.9:8000
- **Local URL:** http://localhost:8000
- **Status:** ✅ Running and accessible from network
- **Listening on:** All interfaces (0.0.0.0)

### Mobile App
- **Primary API:** http://192.168.0.9:8000
- **Fallback URLs:** 12 other IPs (auto-discovery enabled)
- **Status:** ✅ Updated to use correct IP

### Storefront
- **URL:** http://localhost:3002
- **Network URL:** http://192.168.0.9:3002
- **Status:** ✅ Running

---

## 📱 How to Test Mobile App

### Step 1: Rebuild the App
Since we changed the constants file, you need to rebuild:

**Option A: Hot Restart (Faster)**
1. In your IDE, press `Ctrl+Shift+F5` (VS Code) or `Cmd+Shift+\` (Android Studio)
2. Or click the "Hot Restart" button

**Option B: Full Rebuild**
```bash
cd mobile-app
flutter clean
flutter pub get
flutter run
```

### Step 2: Clear App Data (Important!)
The app caches the old IP address. You need to:

**Method 1: Uninstall and Reinstall**
1. Uninstall the app from your device
2. Reinstall using `flutter run`

**Method 2: Clear App Data**
1. Go to Settings → Apps → LinkKart
2. Tap "Storage"
3. Tap "Clear Data"
4. Restart the app

### Step 3: Test Connection
1. Open the app
2. Check the console/logs for:
   ```
   ✅ API Discovery: Found reachable backend at http://192.168.0.9:8000
   ```
3. Navigate to Products tab
4. Products should load successfully

---

## 🧪 Verify Backend is Accessible

### From Your Computer
```bash
curl http://192.168.0.9:8000/api/health
```
**Expected Response:**
```json
{
  "success": true,
  "message": "LinkKart API is running with MySQL",
  "version": "1.0.0",
  "database": "Connected"
}
```

### From Your Mobile Device
1. Open browser on your phone
2. Go to: `http://192.168.0.9:8000/api/health`
3. You should see the JSON response above

**If you can't access it from mobile:**
- Check if your phone is on the same WiFi network
- Check Windows Firewall (see below)

---

## 🔥 Windows Firewall Configuration

If your mobile still can't connect, you may need to allow PHP through Windows Firewall:

### Option 1: Allow PHP (Recommended)
```powershell
# Run PowerShell as Administrator
New-NetFirewallRule -DisplayName "PHP Development Server" -Direction Inbound -Program "C:\php\php.exe" -Action Allow
```

### Option 2: Allow Port 8000
```powershell
# Run PowerShell as Administrator
New-NetFirewallRule -DisplayName "LinkKart Backend" -Direction Inbound -LocalPort 8000 -Protocol TCP -Action Allow
```

### Option 3: Temporarily Disable Firewall (Testing Only)
1. Open Windows Security
2. Go to Firewall & network protection
3. Click on your active network
4. Turn off Windows Defender Firewall (temporarily)
5. Test the app
6. **Remember to turn it back on!**

---

## 📊 Test Endpoints from Mobile Browser

Before testing the app, verify these URLs work in your mobile browser:

### 1. Health Check
```
http://192.168.0.9:8000/api/health
```

### 2. Get All Stores
```
http://192.168.0.9:8000/api/v1/stores
```

### 3. Get Store Products (Store ID 2)
```
http://192.168.0.9:8000/api/v1/stores/2/products
```

### 4. Get Store Statistics (Store ID 2)
```
http://192.168.0.9:8000/api/v1/stores/2/statistics
```

**If these work in mobile browser but not in app:**
- The issue is with the app's cached configuration
- Clear app data and rebuild

**If these DON'T work in mobile browser:**
- The issue is network/firewall related
- Check firewall settings above

---

## 🔍 Troubleshooting

### Error: "Network is unreachable"
**Causes:**
1. Phone not on same WiFi network as computer
2. Windows Firewall blocking connections
3. Backend not running

**Solutions:**
1. Verify both devices on same WiFi
2. Configure firewall (see above)
3. Check backend is running: `curl http://192.168.0.9:8000/api/health`

### Error: "Connection refused"
**Causes:**
1. Backend not running
2. Backend running on wrong interface

**Solutions:**
1. Start backend: `cd backend && php -S 0.0.0.0:8000 -t public`
2. Verify it's on 0.0.0.0, not localhost

### Products Still Not Loading
**Solutions:**
1. Clear app data (Settings → Apps → LinkKart → Storage → Clear Data)
2. Uninstall and reinstall app
3. Check console logs for actual error
4. Verify API works in mobile browser first

---

## 📝 Updated Files

### mobile-app/lib/utils/constants.dart
```dart
static const List<String> baseUrls = [
  'http://192.168.0.9:8000',   // ✅ Updated to your current IP
  // ... other fallback IPs
];

static String _baseUrl = 'http://192.168.0.9:8000';  // ✅ Updated

static const String storefrontUrl = 'http://192.168.0.9:3002';  // ✅ Updated
```

---

## 🎯 Quick Test Checklist

- [ ] Backend running on `0.0.0.0:8000`
- [ ] Can access `http://192.168.0.9:8000/api/health` from computer
- [ ] Can access `http://192.168.0.9:8000/api/health` from mobile browser
- [ ] Mobile app rebuilt/restarted
- [ ] App data cleared
- [ ] Phone on same WiFi network
- [ ] Windows Firewall configured (if needed)

---

## 🚀 Commands to Run

### Start Backend (Network Accessible)
```bash
cd backend
php -S 0.0.0.0:8000 -t public
```

### Rebuild Mobile App
```bash
cd mobile-app
flutter clean
flutter pub get
flutter run
```

### Test from Computer
```bash
curl http://192.168.0.9:8000/api/health
curl http://192.168.0.9:8000/api/v1/stores
```

---

## 📱 Expected Mobile App Behavior

### On App Start
Console should show:
```
🔍 Starting parallel API discovery...
✅ API Discovery: Found reachable backend at http://192.168.0.9:8000
```

### On Products Tab
- Loading spinner appears
- Products load from store
- Images display
- No error messages

### On Dashboard
- Statistics load correctly
- Revenue, orders, products count display
- No "Network unreachable" errors

---

## 🎉 Success Indicators

You'll know it's working when:
- ✅ Mobile browser can access `http://192.168.0.9:8000/api/health`
- ✅ App console shows "API Discovery: Found reachable backend"
- ✅ Products tab loads products
- ✅ Dashboard shows statistics
- ✅ No "Network unreachable" errors

---

## 💡 Important Notes

1. **IP Address Changes:** If you restart your router or computer, your IP might change. You'll need to update the constants file again.

2. **Same Network Required:** Your phone and computer must be on the same WiFi network.

3. **Firewall:** Windows Firewall might block incoming connections. Configure it if needed.

4. **Clear Cache:** Always clear app data after changing the IP address.

5. **Auto-Discovery:** The app has auto-discovery enabled, so it will try multiple IPs. But it's faster if the primary IP is correct.

---

**Current Status: READY FOR MOBILE TESTING** 📱

Backend is now accessible from your network at `http://192.168.0.9:8000`!
