# 🛍️ LinkKart - WhatsApp-First Mini Store Builder

A complete production-ready SaaS platform that enables small businesses to create stores and receive orders via WhatsApp.

---

## 🚀 **[START HERE →](./START_HERE.md)**

**New to LinkKart?** Read the [START_HERE.md](./START_HERE.md) guide for a quick introduction and setup instructions.

**Complete Documentation:** See [INDEX.md](./INDEX.md) for all documentation.

---

## 🌟 Features

- **2-Minute Store Creation**: Quick and easy store setup
- **WhatsApp Integration**: Direct order placement via WhatsApp
- **Multi-Platform**: Flutter mobile app, React storefront, and admin dashboard
- **Premium UI/UX**: Shopify-level design with modern aesthetics

## 🏗️ Architecture

```
linkkart/
├── mobile-app/          # Flutter Seller App
├── storefront/          # React Customer Storefront
├── admin-dashboard/     # React Admin Panel
├── backend/             # Laravel API
└── docs/                # Documentation
```

## 🎨 Design System

- **Primary Color**: #5B6CFF (Modern Indigo)
- **Secondary Color**: #00C2A8 (Teal Accent)
- **Dark Background**: #0F172A
- **Light Background**: #F8FAFC
- **Font**: Inter / Poppins
- **Design Philosophy**: Premium, minimal, modern SaaS

## 🚀 Quick Start

### Backend (Laravel)
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

### Mobile App (Flutter)
```bash
cd mobile-app
flutter pub get
flutter run
```

### Storefront (React)
```bash
cd storefront
npm install
npm start
```

### Admin Dashboard (React)
```bash
cd admin-dashboard
npm install
npm start
```

## 📱 System Components

### 1. Flutter Mobile App (Seller)
- Store creation and management
- Product management with image upload
- WhatsApp integration
- Real-time analytics

### 2. React Storefront (Customer)
- Mobile-first design
- Product browsing
- WhatsApp order placement
- Fast loading and responsive

### 3. React Admin Dashboard
- Store management
- Product monitoring
- Analytics and insights
- User management

### 4. Laravel Backend
- RESTful API
- JWT authentication
- MySQL database
- Cloud storage integration

## 🔐 Security

- Input validation
- JWT authentication
- Secure API endpoints
- CORS configuration

## 📊 Database Schema

- **Stores**: Store information and settings
- **Products**: Product catalog with images
- **Analytics**: Event tracking and metrics

## 🌐 Deployment

- Backend: Laravel Forge / AWS / DigitalOcean
- Frontend: Vercel / Netlify
- Mobile: Play Store / App Store
- Database: MySQL 8.0+

## 📄 License

Proprietary - All rights reserved

## 👥 Support

For support, email support@linkkart.com
