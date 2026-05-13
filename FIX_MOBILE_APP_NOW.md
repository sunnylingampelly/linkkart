# 🚀 Fix Mobile App - Quick Steps

## ✅ What I Fixed

1. **Updated IP Address** in `mobile-app/lib/utils/constants.dart`
   - Changed from: `192.168.1.30:8000`
   - Changed to: `192.168.0.9:8000` (your current IP)

2. **Restarted Backend** to listen on network
   - Changed from: `localhost:8000` (only accessible from computer)
   - Changed to: `0.0.0.0:8000` (accessible from all devices on network)

---

## 📱 What You Need to Do

### Step 1: Rebuild the Mobile App
```bash
cd mobile-app
flutter clean
flutter pub get
flutter run
```

### Step 2: Clear App Data
**Option A: Uninstall & Reinstall (Easiest)**
- Uninstall the app from your phone
- Run `flutter run` again

**Option B: Clear Data Manually**
- Settings → Apps → LinkKart → Storage → Clear Data

### Step 3: Test
1. Open the app
2. Go to Products tab
3. Products should load! ✅

---

## 🧪 Quick Test (Before Rebuilding App)

**Test in your mobile browser first:**
```
http://192.168.0.9:8000/api/health
```

**If this works in browser:**
- ✅ Backend is accessible
- Just rebuild the app

**If this DOESN'T work in browser:**
- ❌ Firewall might be blocking
- See firewall fix below

---

## 🔥 If Mobile Browser Can't Access Backend

### Quick Firewall Fix (Run as Administrator)
```powershell
New-NetFirewallRule -DisplayName "LinkKart Backend" -Direction Inbound -LocalPort 8000 -Protocol TCP -Action Allow
```

**Or temporarily disable firewall for testing:**
1. Windows Security → Firewall & network protection
2. Turn off for your active network
3. Test the app
4. Turn it back on

---

## ✅ Verification

### Backend is Running
```bash
curl http://192.168.0.9:8000/api/health
```
Should return:
```json
{"success":true,"message":"LinkKart API is running with MySQL"}
```

### Mobile Can Access
Open in mobile browser:
```
http://192.168.0.9:8000/api/health
```

### App Console Shows
```
✅ API Discovery: Found reachable backend at http://192.168.0.9:8000
```

---

## 🎯 Current Status

- ✅ Backend running on `0.0.0.0:8000`
- ✅ Accessible at `http://192.168.0.9:8000`
- ✅ Mobile app code updated
- ⏳ **You need to:** Rebuild app & clear data

---

## 💡 Quick Commands

```bash
# Rebuild app
cd mobile-app
flutter clean && flutter pub get && flutter run

# Test backend from computer
curl http://192.168.0.9:8000/api/health

# Test backend from mobile browser
# Open: http://192.168.0.9:8000/api/health
```

---

**Next:** Rebuild the app and test! 🚀
