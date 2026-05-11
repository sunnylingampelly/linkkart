# 🚀 Start All Servers - Complete Guide

## ✅ Current Status:

### Running:
- ✅ **Admin Dashboard**: http://localhost:3000 (Running)
- ✅ **Storefront**: http://localhost:3001 (Running)

### Not Running:
- ❌ **Backend API**: http://192.168.1.2:8000 (Need to start)

---

## 🔥 Start Backend Now:

### Open New Terminal and Run:

```bash
cd D:\linkkart\backend
php artisan serve --host=0.0.0.0 --port=8000
```

**Keep this terminal open!**

You should see:
```
Starting Laravel development server: http://0.0.0.0:8000
[Mon May 3 23:00:00 2026] PHP 8.x.x Development Server (http://0.0.0.0:8000) started
```

---

## 🌐 Access URLs:

Once backend is running:

### Admin Dashboard:
- **Local**: http://localhost:3000
- **Network**: http://192.168.1.2:3000

### Storefront:
- **Local**: http://localhost:3001
- **Network**: http://192.168.1.2:3001

### Backend API:
- **Local**: http://localhost:8000
- **Network**: http://192.168.1.2:8000
- **API**: http://192.168.1.2:8000/api/v1

---

## 📱 Mobile App:

Once backend is running, your mobile app will connect to:
- **API URL**: http://192.168.1.2:8000/api/v1

**Try creating store again** - it should work! ✅

---

## 🧪 Test Backend is Running:

Open browser and visit:
```
http://192.168.1.2:8000
```

Should see Laravel welcome page or API response.

---

## 🐛 If Backend Won't Start:

### Check if port 8000 is already in use:

```bash
netstat -ano | findstr :8000
```

If something is using port 8000, kill it:
```bash
taskkill /PID <PID_NUMBER> /F
```

Or use different port:
```bash
php artisan serve --host=0.0.0.0 --port=8080
```

Then update app to use port 8080 in `mobile-app/lib/utils/constants.dart`

---

## ✅ All Systems Running Checklist:

- [ ] Backend running on port 8000
- [ ] Admin Dashboard on port 3000
- [ ] Storefront on port 3001
- [ ] Mobile app installed
- [ ] Database updated
- [ ] Firebase enabled

---

## 🎯 Quick Commands:

### Start Backend:
```bash
cd D:\linkkart\backend
php artisan serve --host=0.0.0.0 --port=8000
```

### Start Admin Dashboard:
```bash
cd D:\linkkart\admin-dashboard
npm start
```

### Start Storefront:
```bash
cd D:\linkkart\storefront
npm start
```

---

## 🎉 Once All Running:

1. **Open Admin Dashboard**: http://localhost:3000
2. **Open Storefront**: http://localhost:3001/store/demo-store
3. **Open Mobile App**: Create store should work!

---

**Start the backend now and test your app!** 🚀
