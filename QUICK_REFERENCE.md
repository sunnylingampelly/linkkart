# ⚡ Quick Reference Card

## 🚀 Start Servers

### Backend
```bash
cd backend/public
php -S localhost:8000 api.php
```

### Frontend Storefront
```bash
cd storefront
npm start
# Opens at http://localhost:3002
```

### Admin Dashboard
```bash
cd admin-dashboard
npm start
# Opens at http://localhost:3000
```

---

## 🔗 API Endpoints

### Base URL
```
http://localhost:8000/api/v1
```

### Store Endpoints
```bash
GET    /stores              # Get all stores
GET    /stores/{slug}       # Get store by slug
POST   /stores              # Create store
PUT    /stores/{id}         # Update store
DELETE /stores/{id}         # Delete store
```

### Product Endpoints
```bash
POST   /products            # Create product
PUT    /products/{id}       # Update product
DELETE /products/{id}       # Delete product
```

### Analytics
```bash
POST   /analytics/track     # Track event
```

### Health Check
```bash
GET    /health              # API health check
```

---

## 🧪 Quick Tests

### Test Health
```bash
curl http://localhost:8000/api/health
```

### Get All Stores
```bash
curl http://localhost:8000/api/v1/stores
```

### Create Store
```bash
curl -X POST http://localhost:8000/api/v1/stores \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Store","phone":"9876543210"}'
```

### Create Product
```bash
curl -X POST http://localhost:8000/api/v1/products \
  -H "Content-Type: application/json" \
  -d '{"store_id":1,"name":"Test Product","price":999}'
```

### Test Rate Limiting
```bash
# Send 101 requests (should block on 101st)
for i in {1..101}; do curl http://localhost:8000/api/v1/stores; done
```

---

## 📂 Important Files

### Backend
- `backend/public/api.php` - Main API
- `backend/storage/logs/api.log` - Error logs
- `backend/storage/cache/` - Rate limit cache

### Frontend
- `storefront/src/pages/HomePage.js`
- `storefront/src/pages/StorePage.js`
- `storefront/src/pages/ProductPage.js`

### Documentation
- `CONTINUE_FROM_HERE.md` - Start here
- `PHASE_1_PROGRESS.md` - Progress report
- `COMPLETE_ROADMAP.md` - Full roadmap
- `API_DOCUMENTATION.md` - API docs

---

## 🔒 Security Features

✅ Input Validation  
✅ SQL Injection Protection  
✅ Rate Limiting (100/min)  
✅ Error Logging  
✅ Better Error Messages  
⏳ JWT Authentication (next)  
⏳ Authorization (next)  

**Security Score**: 7/10

---

## 📊 Current Status

**Phase**: 1 (Security & Foundation)  
**Progress**: Day 1 Complete (50%)  
**Backend**: ✅ Running (port 8000)  
**Frontend**: ✅ Running (port 3002)  
**Database**: ✅ Connected (15 stores)  
**Endpoints**: 11 total  

---

## 🎯 Next Steps

1. ⏳ JWT Authentication (Day 2-3)
2. ⏳ Database Constraints (Day 4-5)
3. ⏳ Security Audit (Day 6-7)
4. ⏳ Payment Integration (Week 2)

---

## 🐛 Troubleshooting

### Backend Not Working
```bash
# Check MySQL is running
# Check port 8000 is free
# Check error logs
cat backend/storage/logs/api.log
```

### Frontend Not Working
```bash
# Check backend is running
# Check console for errors
# Clear browser cache
```

### Database Issues
```bash
# Check MySQL service
# Verify database exists
mysql -u root -p
USE linkkart;
SHOW TABLES;
```

---

## 📞 Contact

**Email**: vashynovatechnologies@gmail.com  
**WhatsApp**: +91 8639424962

---

**Last Updated**: May 6, 2026
