# LinkKart - Multi-Vendor E-Commerce Platform

A complete multi-vendor e-commerce solution with mobile app, backend API, admin dashboard, and customer storefront.

## 🚀 Features

### Mobile App (Flutter)
- 📱 Store creation and management
- 🛍️ Product management (add, edit, delete)
- 📸 Image upload with camera/gallery support
- 📊 Analytics dashboard
- 💳 Payment integration (Razorpay)
- 🔐 Firebase phone authentication
- 🎨 Modern purple theme UI

### Backend API (PHP)
- 🔌 RESTful API with MySQL database
- 🏪 Store management endpoints
- 📦 Product CRUD operations
- 📈 Analytics tracking
- 💰 Payment processing
- 🔒 JWT authentication
- 📝 Rate limiting

### Admin Dashboard (React)
- 👥 Store management
- 📊 Analytics and insights
- 💳 Subscription plans
- 📈 Revenue tracking
- 🎯 User management

### Customer Storefront (React)
- 🛒 Browse stores and products
- 🔍 Search functionality
- 📱 WhatsApp integration for orders
- 📊 Product analytics
- 🎨 Responsive design

## 📁 Project Structure

```
linkkart/
├── mobile-app/          # Flutter mobile application
│   ├── lib/
│   │   ├── models/      # Data models
│   │   ├── providers/   # State management
│   │   ├── screens/     # UI screens
│   │   ├── services/    # API services
│   │   └── utils/       # Utilities
│   └── android/         # Android configuration
│
├── backend/             # PHP backend API
│   ├── public/          # Public files
│   │   └── api.php      # Main API router
│   ├── lib/             # Libraries (JWT, Razorpay)
│   ├── database/        # Migrations and seeders
│   └── storage/         # File storage
│
├── admin-dashboard/     # React admin panel
│   └── src/
│       ├── components/  # React components
│       └── pages/       # Admin pages
│
└── storefront/          # React customer storefront
    └── src/
        ├── components/  # React components
        └── pages/       # Store pages
```

## 🛠️ Tech Stack

### Mobile App
- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Authentication**: Firebase Auth
- **Payment**: Razorpay
- **HTTP Client**: http package
- **Image Handling**: image_picker

### Backend
- **Language**: PHP 8.3
- **Database**: MySQL 8.0
- **Authentication**: JWT
- **Payment**: Razorpay API
- **Server**: PHP Built-in / Apache

### Frontend
- **Framework**: React 18
- **Styling**: CSS3
- **HTTP Client**: Axios
- **Routing**: React Router

## 📋 Prerequisites

- Flutter SDK 3.0+
- PHP 8.3+
- MySQL 8.0+
- Node.js 16+
- Android Studio (for mobile development)
- Git

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/sunnylingampelly/linkkart.git
cd linkkart
```

### 2. Setup Database

```bash
# Create database
mysql -u root -p
CREATE DATABASE linkkart;
exit;

# Import schema
mysql -u root -p linkkart < database_setup.sql
```

### 3. Start Backend

```bash
# Start PHP server
cd backend/public
php -S 192.168.1.25:8000 api.php
```

Or use the provided script:
```bash
start-backend-correct.bat
```

### 4. Setup Mobile App

```bash
cd mobile-app

# Install dependencies
flutter pub get

# Update IP address in lib/utils/constants.dart
# Change baseUrl to your computer's IP

# Run on device/emulator
flutter run

# Or build APK
flutter build apk --release
```

Or use the build script:
```bash
build-apk-fixed.bat
```

### 5. Setup Admin Dashboard

```bash
cd admin-dashboard

# Install dependencies
npm install

# Start development server
npm start
```

### 6. Setup Storefront

```bash
cd storefront

# Install dependencies
npm install

# Start development server
npm start
```

## 🔧 Configuration

### Backend Configuration

Edit `backend/public/api.php`:
```php
$host = 'localhost';
$dbname = 'linkkart';
$username = 'root';
$password = '';
```

### Mobile App Configuration

Edit `mobile-app/lib/utils/constants.dart`:
```dart
static const List<String> baseUrls = [
  'http://YOUR_IP:8000',  // Change to your IP
];
```

### Firebase Setup

1. Create Firebase project
2. Add Android app
3. Download `google-services.json`
4. Place in `mobile-app/android/app/`
5. Add SHA-1 fingerprint for phone auth

### Razorpay Setup

1. Get API keys from Razorpay dashboard
2. Update in backend and mobile app

## 📱 Building APK

```bash
cd mobile-app

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release
```

APK location: `mobile-app/build/app/outputs/flutter-apk/app-release.apk`

## 🌐 API Endpoints

### Stores
- `GET /api/v1/stores` - Get all stores
- `POST /api/v1/stores` - Create store
- `GET /api/v1/stores/{id}` - Get store by ID
- `PUT /api/v1/stores/{id}` - Update store
- `DELETE /api/v1/stores/{id}` - Delete store

### Products
- `GET /api/v1/stores/{id}/products` - Get store products
- `POST /api/v1/products` - Create product
- `PUT /api/v1/products/{id}` - Update product
- `DELETE /api/v1/products/{id}` - Delete product

### Analytics
- `POST /api/v1/analytics/track` - Track event

### Health
- `GET /api/health` - Health check

## 📊 Database Schema

### Tables
- `stores` - Store information
- `products` - Product catalog
- `users` - User accounts
- `analytics_events` - Analytics data
- `subscriptions` - Subscription plans
- `payments` - Payment records

## 🎨 Design System

### Colors
- **Primary**: #5B6CFF (Purple)
- **Secondary**: #9B59B6 (Purple Accent)
- **Success**: #4CAF50 (Green)
- **Error**: #F44336 (Red)
- **Background**: #F5F5F5 (Light Gray)

### Typography
- **Font**: Google Fonts Inter
- **Heading Weight**: 700
- **Body Weight**: 400

## 📝 Documentation

- [API Documentation](API_DOCUMENTATION.md)
- [Complete Business Model](COMPLETE_BUSINESS_MODEL_AND_FLOW.md)
- [Architecture](ARCHITECTURE.md)
- [Build Guide](BUILD_APK_GUIDE.md)

## 🐛 Troubleshooting

### Backend Issues
- Check PHP version: `php -v`
- Verify MySQL connection
- Check port 8000 is not in use
- Review logs in `backend/storage/logs/`

### Mobile App Issues
- Run `flutter doctor`
- Clear build: `flutter clean`
- Check IP address in constants.dart
- Verify backend is running

### Network Issues
- Use computer's actual IP (not localhost)
- Check firewall settings
- Ensure phone and computer on same network
- Test API with: `curl http://YOUR_IP:8000/api/health`

## 🔐 Security

- JWT authentication for API
- Rate limiting enabled
- Input validation
- SQL injection prevention
- XSS protection
- CORS configured

## 📈 Performance

- Image optimization
- Lazy loading
- Caching strategies
- Database indexing
- API response compression

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👥 Contact

**Vashynova Technologies**
- Email: vashynovatechnologies@gmail.com
- WhatsApp: +91 8639424962

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- React community for excellent libraries
- PHP community for robust backend tools
- All contributors and testers

## 📸 Screenshots

### Mobile App
- Store Dashboard
- Product Management
- Analytics
- Payment Integration

### Admin Dashboard
- Store Management
- Analytics Dashboard
- Subscription Plans

### Storefront
- Store Listing
- Product Catalog
- Store Details

## 🗺️ Roadmap

- [ ] Multi-language support
- [ ] Dark mode
- [ ] Advanced analytics
- [ ] Push notifications
- [ ] Social media integration
- [ ] Advanced search filters
- [ ] Inventory management
- [ ] Order tracking
- [ ] Customer reviews
- [ ] Wishlist feature

## 📊 Project Status

✅ **Completed Features:**
- Mobile app with store & product management
- Backend API with all endpoints
- Admin dashboard
- Customer storefront
- Payment integration
- Firebase authentication
- Image upload
- Analytics tracking

🚧 **In Progress:**
- Advanced analytics
- Push notifications
- Order management

## 💡 Tips

1. **Development**: Use `flutter run` for hot reload
2. **Testing**: Test on real device for best results
3. **Debugging**: Check console logs for API errors
4. **Performance**: Use release builds for production
5. **Security**: Never commit `.env` files

---

**Made with ❤️ by Vashynova Technologies**
