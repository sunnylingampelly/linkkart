# 🚀 Getting Started with LinkKart

Welcome to LinkKart! This guide will help you get started quickly.

---

## 🎯 What is LinkKart?

LinkKart is a **WhatsApp-first mini store builder** that allows small businesses to:
- ✅ Create a store in under 2 minutes
- ✅ Add products with images and pricing
- ✅ Share a store link
- ✅ Receive orders via WhatsApp

---

## 🏗️ System Architecture

LinkKart consists of 4 integrated systems:

1. **Flutter Mobile App** - For sellers to manage their stores
2. **React Storefront** - Customer-facing product catalog
3. **React Admin Dashboard** - Platform administration
4. **Laravel Backend API** - Powers everything

---

## ⚡ Quick Start (5 Minutes)

### Prerequisites
Make sure you have installed:
- PHP 8.1+
- Composer
- MySQL 8.0+
- Node.js 18+
- Flutter 3.0+ (optional, for mobile app)

### Automated Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/linkkart.git
cd linkkart

# Run the quick start script
chmod +x quick-start.sh
./quick-start.sh
```

The script will:
1. Install all dependencies
2. Set up the database
3. Configure environment files
4. Create default admin account

### Manual Setup

If you prefer manual setup, follow the [SETUP_GUIDE.md](./SETUP_GUIDE.md).

---

## 🎮 Using the Platform

### For Sellers (Mobile App)

1. **Download the App**
   - Android: Google Play Store
   - iOS: App Store

2. **Create Your Store**
   - Open the app
   - Complete onboarding
   - Enter store name and WhatsApp number
   - Upload logo (optional)

3. **Add Products**
   - Tap "Add Product"
   - Upload product image
   - Enter name, price, and description
   - Save

4. **Share Your Store**
   - Copy store link
   - Share on WhatsApp, Facebook, Instagram
   - Customers can browse and order

### For Customers (Web Storefront)

1. **Visit Store**
   - Click on store link shared by seller
   - Browse products

2. **Place Order**
   - Click "Order on WhatsApp" on any product
   - WhatsApp opens with pre-filled message
   - Send message to seller

### For Admins (Dashboard)

1. **Login**
   - Visit: `http://localhost:3000`
   - Email: `admin@linkkart.com`
   - Password: `password`

2. **Manage Platform**
   - View all stores and products
   - Monitor analytics
   - Manage users
   - View reports

---

## 📱 Testing the Complete Flow

### 1. Create a Test Store

**Using Mobile App:**
```
1. Open Flutter app
2. Complete onboarding
3. Create store:
   - Name: "Test Fashion Store"
   - Phone: "+919876543210"
4. Note the store URL
```

**Using API (cURL):**
```bash
curl -X POST http://localhost:8000/api/v1/seller/stores \
  -F "name=Test Fashion Store" \
  -F "phone=+919876543210"
```

### 2. Add a Test Product

**Using Mobile App:**
```
1. Tap "Add Product"
2. Upload image
3. Enter details:
   - Name: "Blue T-Shirt"
   - Price: 499
   - Description: "Comfortable cotton t-shirt"
4. Save
```

**Using API:**
```bash
curl -X POST http://localhost:8000/api/v1/seller/products \
  -F "store_id=1" \
  -F "name=Blue T-Shirt" \
  -F "price=499" \
  -F "description=Comfortable cotton t-shirt"
```

### 3. View Storefront

```
1. Open browser
2. Go to: http://localhost:3001/store/test-fashion-store-abc123
3. View products
4. Click "Order on WhatsApp"
5. Verify WhatsApp opens with message
```

### 4. Check Admin Dashboard

```
1. Login to admin dashboard
2. View stores list
3. Check analytics
4. Monitor activity
```

---

## 🎨 Customization

### Branding

**Colors** (in `mobile-app/lib/utils/theme.dart`):
```dart
static const Color primaryColor = Color(0xFF5B6CFF);
static const Color secondaryColor = Color(0xFF00C2A8);
```

**Logo:**
- Replace `mobile-app/assets/icons/app_icon.png`
- Run: `flutter pub run flutter_launcher_icons:main`

### Features

**Add Custom Fields:**
1. Create migration for new field
2. Update model
3. Update API controller
4. Update mobile app UI

**Example - Add Store Description:**

```php
// Backend migration
Schema::table('stores', function (Blueprint $table) {
    $table->text('description')->nullable();
});

// Model
protected $fillable = [..., 'description'];

// Mobile app
TextFormField(
  controller: _descriptionController,
  decoration: InputDecoration(labelText: 'Description'),
)
```

---

## 📊 Understanding Analytics

### Tracked Events

1. **Store View** - When someone visits a store page
2. **Product Click** - When someone clicks on a product
3. **WhatsApp Click** - When someone clicks "Order on WhatsApp"

### Viewing Analytics

**Mobile App:**
- Dashboard shows basic stats
- View count and product count

**Admin Dashboard:**
- Detailed analytics
- Charts and graphs
- Top performing stores
- Daily trends

**API:**
```bash
curl http://localhost:8000/api/v1/admin/analytics/global \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 🔧 Configuration

### Environment Variables

**Backend (.env):**
```env
APP_URL=http://localhost:8000
DB_DATABASE=linkkart
DB_USERNAME=root
DB_PASSWORD=
FRONTEND_URL=http://localhost:3000
STOREFRONT_URL=http://localhost:3001
```

**Storefront (.env):**
```env
REACT_APP_API_URL=http://localhost:8000/api/v1
REACT_APP_BACKEND_URL=http://localhost:8000
```

**Admin Dashboard (.env):**
```env
REACT_APP_API_URL=http://localhost:8000/api/v1
```

**Mobile App (constants.dart):**
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
```

---

## 🐛 Troubleshooting

### Backend Issues

**Problem: Migration fails**
```bash
php artisan migrate:fresh --seed
```

**Problem: Storage link not working**
```bash
php artisan storage:link
chmod -R 775 storage
```

**Problem: CORS error**
- Check `config/cors.php`
- Ensure frontend URL is allowed

### Frontend Issues

**Problem: API connection failed**
- Verify backend is running
- Check .env file has correct API URL
- Check browser console for errors

**Problem: Images not loading**
- Check REACT_APP_BACKEND_URL in .env
- Verify images exist in backend storage

### Mobile App Issues

**Problem: Network error**
- Android emulator: Use `10.0.2.2` instead of `localhost`
- iOS simulator: Use `localhost`
- Physical device: Use computer's IP address

**Problem: Build fails**
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📚 Learning Resources

### Documentation
- [Setup Guide](./SETUP_GUIDE.md) - Detailed setup instructions
- [API Documentation](./API_DOCUMENTATION.md) - Complete API reference
- [Project Structure](./PROJECT_STRUCTURE.md) - Architecture overview
- [Deployment Guide](./DEPLOYMENT_GUIDE.md) - Production deployment

### Code Examples

**Create Store (JavaScript):**
```javascript
const formData = new FormData();
formData.append('name', 'My Store');
formData.append('phone', '+919876543210');

const response = await fetch('http://localhost:8000/api/v1/seller/stores', {
  method: 'POST',
  body: formData
});

const data = await response.json();
console.log(data);
```

**Get Store Products (Flutter):**
```dart
final response = await http.get(
  Uri.parse('$baseUrl/stores/$storeId/products'),
);

if (response.statusCode == 200) {
  final data = json.decode(response.body);
  final products = data['data']['products'];
}
```

---

## 🎯 Next Steps

### For Development

1. **Explore the Code**
   - Backend: `backend/app/`
   - Mobile: `mobile-app/lib/`
   - Storefront: `storefront/src/`
   - Admin: `admin-dashboard/src/`

2. **Add Features**
   - Product categories
   - Search functionality
   - Order management
   - Payment integration

3. **Improve UI**
   - Custom themes
   - Animations
   - Better layouts

### For Production

1. **Prepare for Launch**
   - Review security settings
   - Set up monitoring
   - Configure backups
   - Test thoroughly

2. **Deploy**
   - Follow [Deployment Guide](./DEPLOYMENT_GUIDE.md)
   - Set up domains
   - Configure SSL
   - Launch!

3. **Market**
   - Create landing page
   - Social media presence
   - Content marketing
   - User onboarding

---

## 💡 Tips & Best Practices

### Performance
- Optimize images before upload
- Use lazy loading
- Implement caching
- Monitor API response times

### Security
- Use strong passwords
- Enable HTTPS in production
- Validate all inputs
- Keep dependencies updated

### User Experience
- Keep store creation simple
- Provide clear instructions
- Show loading states
- Handle errors gracefully

### Scaling
- Use CDN for static assets
- Implement database indexing
- Use queue for heavy tasks
- Monitor server resources

---

## 🤝 Contributing

We welcome contributions! Here's how:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write tests
5. Submit a pull request

### Code Style
- Follow PSR-12 for PHP
- Use ESLint for JavaScript
- Follow Flutter style guide
- Write meaningful commit messages

---

## 📞 Support

### Get Help
- **Documentation**: Check all .md files in the project
- **Issues**: Open a GitHub issue
- **Email**: support@linkkart.com
- **Community**: Join our Discord/Slack

### Report Bugs
When reporting bugs, include:
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots (if applicable)
- Environment details

---

## 🎉 Success Stories

> "LinkKart helped me start my online business in just 2 minutes. I'm now receiving orders daily via WhatsApp!" - *Sarah, Fashion Store Owner*

> "The platform is so simple to use. My customers love the easy ordering process." - *Raj, Electronics Seller*

> "Perfect for small businesses. No technical knowledge required!" - *Maria, Handicrafts Store*

---

## 🌟 Features Roadmap

### Coming Soon
- [ ] Payment gateway integration
- [ ] Order management system
- [ ] Inventory tracking
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Push notifications
- [ ] Email notifications
- [ ] Advanced analytics
- [ ] Custom domains
- [ ] Product categories

### Future Plans
- [ ] Multi-vendor marketplace
- [ ] Subscription plans
- [ ] Mobile app for customers
- [ ] Social media integration
- [ ] Marketing tools
- [ ] Customer reviews
- [ ] Discount codes
- [ ] Shipping integration

---

## 📄 License

LinkKart is proprietary software. All rights reserved.

For licensing inquiries, contact: licensing@linkkart.com

---

## 🙏 Acknowledgments

Built with:
- Laravel - Backend framework
- Flutter - Mobile development
- React - Frontend framework
- MySQL - Database
- And many other amazing open-source projects

---

**Ready to build something amazing? Let's get started! 🚀**

For detailed setup instructions, proceed to [SETUP_GUIDE.md](./SETUP_GUIDE.md)
