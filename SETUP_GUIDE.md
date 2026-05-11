# 🚀 LinkKart - Complete Setup Guide

This guide will help you set up all four systems of the LinkKart platform.

## 📋 Prerequisites

### Required Software
- **PHP** >= 8.1
- **Composer** >= 2.0
- **MySQL** >= 8.0
- **Node.js** >= 18.0
- **npm** or **yarn**
- **Flutter** >= 3.0
- **Git**

### Optional
- **Docker** (for containerized setup)
- **Postman** (for API testing)

---

## 🔧 1. Backend Setup (Laravel)

### Step 1: Install Dependencies
```bash
cd backend
composer install
```

### Step 2: Environment Configuration
```bash
cp .env.example .env
```

Edit `.env` file:
```env
DB_DATABASE=linkkart
DB_USERNAME=your_mysql_username
DB_PASSWORD=your_mysql_password

JWT_SECRET=your_jwt_secret_here
FRONTEND_URL=http://localhost:3000
STOREFRONT_URL=http://localhost:3001
```

### Step 3: Generate Application Key
```bash
php artisan key:generate
php artisan jwt:secret
```

### Step 4: Create Database
```bash
mysql -u root -p
CREATE DATABASE linkkart;
exit;
```

### Step 5: Run Migrations
```bash
php artisan migrate
php artisan db:seed
```

### Step 6: Create Storage Link
```bash
php artisan storage:link
```

### Step 7: Start Server
```bash
php artisan serve
```

Backend will run on: `http://localhost:8000`

**Default Admin Credentials:**
- Email: `admin@linkkart.com`
- Password: `password`

---

## 📱 2. Mobile App Setup (Flutter)

### Step 1: Navigate to Mobile App
```bash
cd mobile-app
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Update API Configuration
Edit `lib/utils/constants.dart`:
```dart
// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

// For iOS Simulator
// static const String baseUrl = 'http://localhost:8000/api/v1';

// For Physical Device (use your computer's IP)
// static const String baseUrl = 'http://192.168.1.100:8000/api/v1';
```

### Step 4: Run the App
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For specific device
flutter devices
flutter run -d <device_id>
```

---

## 🌐 3. Customer Storefront Setup (React)

### Step 1: Navigate to Storefront
```bash
cd storefront
```

### Step 2: Install Dependencies
```bash
npm install
# or
yarn install
```

### Step 3: Create Environment File
Create `.env` file:
```env
REACT_APP_API_URL=http://localhost:8000/api/v1
REACT_APP_BACKEND_URL=http://localhost:8000
```

### Step 4: Start Development Server
```bash
npm start
# or
yarn start
```

Storefront will run on: `http://localhost:3001`

---

## 🛠️ 4. Admin Dashboard Setup (React)

### Step 1: Navigate to Admin Dashboard
```bash
cd admin-dashboard
```

### Step 2: Install Dependencies
```bash
npm install
# or
yarn install
```

### Step 3: Create Environment File
Create `.env` file:
```env
REACT_APP_API_URL=http://localhost:8000/api/v1
```

### Step 4: Start Development Server
```bash
npm start
# or
yarn start
```

Admin Dashboard will run on: `http://localhost:3000`

---

## 🧪 Testing the Complete System

### 1. Test Backend API
```bash
curl http://localhost:8000/api/health
```

Expected response:
```json
{
  "success": true,
  "message": "LinkKart API is running",
  "version": "1.0.0"
}
```

### 2. Test Mobile App Flow
1. Open the Flutter app
2. Complete onboarding
3. Create a store with name and phone
4. Add a product with image
5. View the store link
6. Share via WhatsApp

### 3. Test Storefront
1. Open browser: `http://localhost:3001/store/{store-slug}`
2. View products
3. Click "Order on WhatsApp"
4. Verify WhatsApp opens with pre-filled message

### 4. Test Admin Dashboard
1. Open browser: `http://localhost:3000`
2. Login with admin credentials
3. View stores and products
4. Check analytics

---

## 🐳 Docker Setup (Alternative)

### Create docker-compose.yml
```yaml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: linkkart
      MYSQL_ROOT_PASSWORD: root
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql

  backend:
    build: ./backend
    ports:
      - "8000:8000"
    depends_on:
      - mysql
    environment:
      DB_HOST: mysql
      DB_DATABASE: linkkart
      DB_USERNAME: root
      DB_PASSWORD: root

  storefront:
    build: ./storefront
    ports:
      - "3001:3000"
    environment:
      REACT_APP_API_URL: http://localhost:8000/api/v1

  admin:
    build: ./admin-dashboard
    ports:
      - "3000:3000"
    environment:
      REACT_APP_API_URL: http://localhost:8000/api/v1

volumes:
  mysql_data:
```

### Run with Docker
```bash
docker-compose up -d
```

---

## 🔍 Troubleshooting

### Backend Issues

**Issue: Migration fails**
```bash
php artisan migrate:fresh --seed
```

**Issue: Storage permission denied**
```bash
chmod -R 775 storage bootstrap/cache
```

**Issue: JWT secret not set**
```bash
php artisan jwt:secret
```

### Mobile App Issues

**Issue: Network error on Android**
- Use `10.0.2.2` instead of `localhost`
- Check if backend is running

**Issue: Image picker not working**
```bash
flutter clean
flutter pub get
```

### Frontend Issues

**Issue: CORS error**
- Check backend `config/cors.php`
- Ensure `allowed_origins` includes frontend URL

**Issue: API connection failed**
- Verify `.env` file has correct API URL
- Check if backend is running

---

## 📊 Database Schema

### Stores Table
- id, name, phone, logo, slug, is_active, view_count, timestamps

### Products Table
- id, store_id, name, price, description, image, is_active, click_count, timestamps

### Analytics Events Table
- id, store_id, product_id, event_type, ip_address, user_agent, metadata, timestamps

### Admins Table
- id, name, email, password, timestamps

---

## 🚀 Deployment

### Backend (Laravel Forge / AWS)
1. Push code to Git repository
2. Configure server with PHP 8.1+
3. Set up MySQL database
4. Configure environment variables
5. Run migrations
6. Set up SSL certificate

### Frontend (Vercel / Netlify)
1. Connect Git repository
2. Set build command: `npm run build`
3. Set publish directory: `build`
4. Add environment variables
5. Deploy

### Mobile App
1. **Android**: Build APK/AAB and upload to Play Store
2. **iOS**: Build IPA and upload to App Store

---

## 📞 Support

For issues or questions:
- Email: support@linkkart.com
- Documentation: https://docs.linkkart.com
- GitHub Issues: https://github.com/linkkart/linkkart/issues

---

## 🎉 Success!

If all systems are running:
- ✅ Backend API: http://localhost:8000
- ✅ Admin Dashboard: http://localhost:3000
- ✅ Storefront: http://localhost:3001
- ✅ Mobile App: Running on emulator/device

You're ready to start using LinkKart! 🛍️
