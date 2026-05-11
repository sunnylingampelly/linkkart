# Design Document: LinkKart Mobile App Redesign

## Overview

LinkKart Mobile App Redesign transforms the existing basic Flutter app into a modern, Shopify-level seller application for WhatsApp-first store management. The redesign introduces complete authentication flow using Firebase Phone Authentication, comprehensive order management system, enhanced UI/UX with smooth animations and gradients, customer database, analytics dashboard, and marketing tools. The app targets small business owners who want to create and manage online stores with orders received via WhatsApp, providing a professional, native app experience with touch-optimized interactions and micro-animations.

**Key Improvements:**
- Firebase Phone Authentication (phone + OTP verification)
- Complete order management and tracking system
- Modern design system with Inter font, gradient colors, and smooth animations
- Customer database and analytics
- Enhanced user journey from onboarding to daily operations
- Professional UI matching Shopify's quality standards

## Architecture

```mermaid
graph TB
    subgraph "Mobile App (Flutter)"
        UI[UI Layer<br/>Screens & Widgets]
        Providers[State Management<br/>Provider Pattern]
        Services[Services Layer<br/>API & Firebase]
        Models[Data Models<br/>Store, Product, Order, User]
    end
    
    subgraph "Authentication"
        Firebase[Firebase Auth<br/>Phone + OTP]
    end
    
    subgraph "Backend (Laravel)"
        API[REST API<br/>Laravel Controllers]
        DB[(MySQL Database)]
    end
    
    subgraph "External Services"
        WhatsApp[WhatsApp<br/>Order Notifications]
        SMS[SMS Gateway<br/>Firebase SMS]
    end
    
    UI --> Providers
    Providers --> Services
    Services --> Models
    Services --> Firebase
    Services --> API
    API --> DB
    Services --> WhatsApp
    Firebase --> SMS
    
    style UI fill:#5B6CFF,color:#fff
    style Providers fill:#00C2A8,color:#fff
    style Firebase fill:#FF6B6B,color:#fff
    style API fill:#5B6CFF,color:#fff


## User Journey Flow

```mermaid
sequenceDiagram
    participant User
    participant App
    participant Firebase
    participant Backend
    participant WhatsApp
    
    User->>App: Open App
    App->>App: Show Splash (2s)
    App->>App: Show Welcome Screen
    User->>App: Tap "Create Free Store"
    App->>App: Show Phone Entry
    User->>App: Enter Phone Number
    App->>Firebase: Request OTP
    Firebase->>User: Send SMS with OTP
    User->>App: Enter OTP
    App->>Firebase: Verify OTP
    Firebase-->>App: Token
    
    alt New User
        App->>App: Show Store Setup
        User->>App: Enter Store Details
        App->>Backend: Create Store
        Backend-->>App: Store Created
        App->>App: Show Onboarding Tutorial
        User->>App: Complete Tutorial
    else Existing User
        App->>Backend: Fetch Store Data
        Backend-->>App: Store Data
    end
    
    App->>App: Show Dashboard
    User->>App: Add Product
    App->>Backend: Save Product
    User->>App: Share Store Link
    App->>WhatsApp: Open WhatsApp Share
    
    Note over User,WhatsApp: Customer places order via WhatsApp
    
    User->>App: View Orders
    App->>Backend: Fetch Orders
    Backend-->>App: Order List
    User->>App: Update Order Status
    App->>Backend: Update Status
    App->>WhatsApp: Notify Customer


## Design System

### Color Palette

```dart
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF5B6CFF);        // Trust, Professional
  static const Color secondary = Color(0xFF00C2A8);      // Growth, Success
  static const Color whatsapp = Color(0xFF25D366);       // Action, WhatsApp Brand
  static const Color accent = Color(0xFFFF6B6B);         // Urgency, Alerts
  
  // Background Colors
  static const Color background = Color(0xFFF8FAFC);     // Clean, Light
  static const Color cardBackground = Color(0xFFFFFFFF); // White Cards
  static const Color inputBackground = Color(0xFFF1F5F9);// Input Fields
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);    // Dark Text
  static const Color textSecondary = Color(0xFF64748B);  // Secondary Text
  static const Color textTertiary = Color(0xFF94A3B8);   // Tertiary Text
  
  // Status Colors
  static const Color success = Color(0xFF10B981);        // Success States
  static const Color warning = Color(0xFFF59E0B);        // Warning States
  static const Color error = Color(0xFFEF4444);          // Error States
  static const Color info = Color(0xFF3B82F6);           // Info States
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5B6CFF), Color(0xFF4F5FE6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00C2A8), Color(0xFF00A890)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF5B6CFF), Color(0xFF00C2A8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
```

### Typography

```dart
class AppTypography {
  // Font Family: Inter (Google Fonts)
  static const String fontFamily = 'Inter';
  
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,  // Bold
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,  // SemiBold
    height: 1.4,
    letterSpacing: -0.2,
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,  // Regular
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  // Special
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    color: AppColors.textTertiary,
  );
  
  // Numbers (for stats, prices)
  static const TextStyle numberLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  static const TextStyle numberMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
}
```

### Spacing System

```dart
class AppSpacing {
  // Base: 4px grid system
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  // Specific Use Cases
  static const double cardPadding = 16.0;
  static const double screenPadding = 20.0;
  static const double sectionSpacing = 24.0;
  static const double itemSpacing = 12.0;
}
```

### Border Radius

```dart
class AppRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xlarge = 24.0;
  static const double circular = 999.0;
  
  // Specific Components
  static const double button = 12.0;
  static const double card = 16.0;
  static const double input = 12.0;
  static const double bottomSheet = 24.0;
}
```

### Shadows

```dart
class AppShadows {
  static const BoxShadow small = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );
  
  static const BoxShadow medium = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );
  
  static const BoxShadow large = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  );
  
  static const BoxShadow card = BoxShadow(
    color: Color(0x08000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  );
}
```


## Components and Interfaces

### Core Data Models

#### User Model

```dart
class User {
  final String id;
  final String phoneNumber;
  final String? email;
  final String? displayName;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isVerified;
  
  User({
    required this.id,
    required this.phoneNumber,
    this.email,
    this.displayName,
    required this.createdAt,
    required this.lastLoginAt,
    required this.isVerified,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      displayName: json['display_name'],
      createdAt: DateTime.parse(json['created_at']),
      lastLoginAt: DateTime.parse(json['last_login_at']),
      isVerified: json['is_verified'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'email': email,
      'display_name': displayName,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt.toIso8601String(),
      'is_verified': isVerified,
    };
  }
}
```

#### Enhanced Store Model

```dart
class Store {
  final int id;
  final String userId;
  final String name;
  final String phone;
  final String? logo;
  final String slug;
  final String? category;
  final String? description;
  final bool isActive;
  final int viewCount;
  final String storeUrl;
  final int productCount;
  final Map<String, String>? socialLinks;
  final StoreTimings? timings;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Store({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    this.logo,
    required this.slug,
    this.category,
    this.description,
    required this.isActive,
    required this.viewCount,
    required this.storeUrl,
    required this.productCount,
    this.socialLinks,
    this.timings,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      phone: json['phone'],
      logo: json['logo'],
      slug: json['slug'],
      category: json['category'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
      viewCount: json['view_count'] ?? 0,
      storeUrl: json['store_url'] ?? '',
      productCount: json['product_count'] ?? 0,
      socialLinks: json['social_links'] != null 
          ? Map<String, String>.from(json['social_links']) 
          : null,
      timings: json['timings'] != null 
          ? StoreTimings.fromJson(json['timings']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class StoreTimings {
  final String openTime;
  final String closeTime;
  final List<String> workingDays;
  
  StoreTimings({
    required this.openTime,
    required this.closeTime,
    required this.workingDays,
  });
  
  factory StoreTimings.fromJson(Map<String, dynamic> json) {
    return StoreTimings(
      openTime: json['open_time'],
      closeTime: json['close_time'],
      workingDays: List<String>.from(json['working_days']),
    );
  }
}
```

#### Order Model

```dart
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled
}

enum PaymentMethod {
  cod,
  online,
  upi
}

class Order {
  final int id;
  final int storeId;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String? deliveryAddress;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryCharge;
  final double total;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final bool isPaid;
  final String? notes;
  final List<OrderTimeline> timeline;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Order({
    required this.id,
    required this.storeId,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    this.deliveryAddress,
    required this.items,
    required this.subtotal,
    required this.deliveryCharge,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.isPaid,
    this.notes,
    required this.timeline,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      storeId: json['store_id'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      customerEmail: json['customer_email'],
      deliveryAddress: json['delivery_address'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      subtotal: double.parse(json['subtotal'].toString()),
      deliveryCharge: double.parse(json['delivery_charge'].toString()),
      total: double.parse(json['total'].toString()),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['payment_method'],
        orElse: () => PaymentMethod.cod,
      ),
      isPaid: json['is_paid'] ?? false,
      notes: json['notes'],
      timeline: (json['timeline'] as List)
          .map((t) => OrderTimeline.fromJson(t))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  String get formattedTotal => '₹${total.toStringAsFixed(2)}';
  String get statusLabel => status.name.toUpperCase();
  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
      case OrderStatus.processing:
        return AppColors.info;
      case OrderStatus.shipped:
        return AppColors.secondary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }
}

class OrderItem {
  final int productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;
  final double total;
  
  OrderItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
    required this.total,
  });
  
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'],
      productName: json['product_name'],
      productImage: json['product_image'],
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
      total: double.parse(json['total'].toString()),
    );
  }
}

class OrderTimeline {
  final OrderStatus status;
  final String description;
  final DateTime timestamp;
  
  OrderTimeline({
    required this.status,
    required this.description,
    required this.timestamp,
  });
  
  factory OrderTimeline.fromJson(Map<String, dynamic> json) {
    return OrderTimeline(
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
```

#### Customer Model

```dart
class Customer {
  final int id;
  final int storeId;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final int totalOrders;
  final double totalSpent;
  final DateTime? lastOrderDate;
  final DateTime createdAt;
  
  Customer({
    required this.id,
    required this.storeId,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    required this.totalOrders,
    required this.totalSpent,
    this.lastOrderDate,
    required this.createdAt,
  });
  
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      storeId: json['store_id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      totalOrders: json['total_orders'] ?? 0,
      totalSpent: double.parse(json['total_spent']?.toString() ?? '0'),
      lastOrderDate: json['last_order_date'] != null
          ? DateTime.parse(json['last_order_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  String get formattedTotalSpent => '₹${totalSpent.toStringAsFixed(2)}';
}
```

#### Analytics Model

```dart
class Analytics {
  final int storeId;
  final AnalyticsPeriod period;
  final RevenueData revenue;
  final OrdersData orders;
  final ProductsData products;
  final TrafficData traffic;
  final List<TopProduct> topProducts;
  final List<CustomerInsight> customerInsights;
  
  Analytics({
    required this.storeId,
    required this.period,
    required this.revenue,
    required this.orders,
    required this.products,
    required this.traffic,
    required this.topProducts,
    required this.customerInsights,
  });
  
  factory Analytics.fromJson(Map<String, dynamic> json) {
    return Analytics(
      storeId: json['store_id'],
      period: AnalyticsPeriod.values.firstWhere(
        (e) => e.name == json['period'],
      ),
      revenue: RevenueData.fromJson(json['revenue']),
      orders: OrdersData.fromJson(json['orders']),
      products: ProductsData.fromJson(json['products']),
      traffic: TrafficData.fromJson(json['traffic']),
      topProducts: (json['top_products'] as List)
          .map((p) => TopProduct.fromJson(p))
          .toList(),
      customerInsights: (json['customer_insights'] as List)
          .map((c) => CustomerInsight.fromJson(c))
          .toList(),
    );
  }
}

enum AnalyticsPeriod {
  today,
  week,
  month,
  year,
  custom
}

class RevenueData {
  final double total;
  final double average;
  final double growth;
  final List<DataPoint> chartData;
  
  RevenueData({
    required this.total,
    required this.average,
    required this.growth,
    required this.chartData,
  });
  
  factory RevenueData.fromJson(Map<String, dynamic> json) {
    return RevenueData(
      total: double.parse(json['total'].toString()),
      average: double.parse(json['average'].toString()),
      growth: double.parse(json['growth'].toString()),
      chartData: (json['chart_data'] as List)
          .map((d) => DataPoint.fromJson(d))
          .toList(),
    );
  }
}

class OrdersData {
  final int total;
  final int pending;
  final int completed;
  final double completionRate;
  
  OrdersData({
    required this.total,
    required this.pending,
    required this.completed,
    required this.completionRate,
  });
  
  factory OrdersData.fromJson(Map<String, dynamic> json) {
    return OrdersData(
      total: json['total'],
      pending: json['pending'],
      completed: json['completed'],
      completionRate: double.parse(json['completion_rate'].toString()),
    );
  }
}

class ProductsData {
  final int total;
  final int active;
  final int outOfStock;
  
  ProductsData({
    required this.total,
    required this.active,
    required this.outOfStock,
  });
  
  factory ProductsData.fromJson(Map<String, dynamic> json) {
    return ProductsData(
      total: json['total'],
      active: json['active'],
      outOfStock: json['out_of_stock'],
    );
  }
}

class TrafficData {
  final int totalViews;
  final int uniqueVisitors;
  final Map<String, int> sources;
  
  TrafficData({
    required this.totalViews,
    required this.uniqueVisitors,
    required this.sources,
  });
  
  factory TrafficData.fromJson(Map<String, dynamic> json) {
    return TrafficData(
      totalViews: json['total_views'],
      uniqueVisitors: json['unique_visitors'],
      sources: Map<String, int>.from(json['sources']),
    );
  }
}

class DataPoint {
  final String label;
  final double value;
  
  DataPoint({required this.label, required this.value});
  
  factory DataPoint.fromJson(Map<String, dynamic> json) {
    return DataPoint(
      label: json['label'],
      value: double.parse(json['value'].toString()),
    );
  }
}

class TopProduct {
  final int productId;
  final String name;
  final int sales;
  final double revenue;
  
  TopProduct({
    required this.productId,
    required this.name,
    required this.sales,
    required this.revenue,
  });
  
  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productId: json['product_id'],
      name: json['name'],
      sales: json['sales'],
      revenue: double.parse(json['revenue'].toString()),
    );
  }
}

class CustomerInsight {
  final String metric;
  final String value;
  final String trend;
  
  CustomerInsight({
    required this.metric,
    required this.value,
    required this.trend,
  });
  
  factory CustomerInsight.fromJson(Map<String, dynamic> json) {
    return CustomerInsight(
      metric: json['metric'],
      value: json['value'],
      trend: json['trend'],
    );
  }
}
```


### State Management Providers

#### AuthProvider

```dart
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  String? _verificationId;
  bool _isLoading = false;
  String? _error;
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  
  // Send OTP to phone number
  Future<bool> sendOTP(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _error = e.message;
          _isLoading = false;
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _isLoading = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Verify OTP code
  Future<bool> verifyOTP(String otp) async {
    if (_verificationId == null) {
      _error = 'Verification ID not found';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      
      await _signInWithCredential(credential);
      return true;
    } catch (e) {
      _error = 'Invalid OTP';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Sign in with credential
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential = 
          await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Create or update user in backend
      final response = await ApiService.post('/auth/verify-otp', {
        'firebase_uid': userCredential.user!.uid,
        'phone_number': userCredential.user!.phoneNumber,
      });
      
      _currentUser = User.fromJson(response['user']);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }
  
  // Logout
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _currentUser = null;
    _verificationId = null;
    notifyListeners();
  }
  
  // Check if user has store
  Future<bool> hasStore() async {
    if (_currentUser == null) return false;
    
    try {
      final response = await ApiService.get('/stores/user/${_currentUser!.id}');
      return response['has_store'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
```

#### StoreProvider

```dart
class StoreProvider extends ChangeNotifier {
  Store? _currentStore;
  bool _isLoading = false;
  String? _error;
  
  Store? get currentStore => _currentStore;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Create new store
  Future<bool> createStore({
    required String name,
    required String phone,
    required String category,
    String? description,
    File? logoFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Upload logo if provided
      String? logoUrl;
      if (logoFile != null) {
        logoUrl = await ApiService.uploadImage(logoFile);
      }
      
      final response = await ApiService.post('/stores', {
        'name': name,
        'phone': phone,
        'category': category,
        'description': description,
        'logo': logoUrl,
      });
      
      _currentStore = Store.fromJson(response['store']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Fetch store data
  Future<void> fetchStore(int storeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await ApiService.get('/stores/$storeId');
      _currentStore = Store.fromJson(response['store']);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update store
  Future<bool> updateStore({
    String? name,
    String? phone,
    String? category,
    String? description,
    File? logoFile,
    Map<String, String>? socialLinks,
    StoreTimings? timings,
  }) async {
    if (_currentStore == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      String? logoUrl;
      if (logoFile != null) {
        logoUrl = await ApiService.uploadImage(logoFile);
      }
      
      final response = await ApiService.put('/stores/${_currentStore!.id}', {
        'name': name ?? _currentStore!.name,
        'phone': phone ?? _currentStore!.phone,
        'category': category ?? _currentStore!.category,
        'description': description ?? _currentStore!.description,
        'logo': logoUrl ?? _currentStore!.logo,
        'social_links': socialLinks ?? _currentStore!.socialLinks,
        'timings': timings?.toJson() ?? _currentStore!.timings?.toJson(),
      });
      
      _currentStore = Store.fromJson(response['store']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Get store link
  String getStoreLink() {
    return _currentStore?.storeUrl ?? '';
  }
  
  // Share store link
  Future<void> shareStoreLink() async {
    if (_currentStore == null) return;
    
    final String message = '''
Check out my store on LinkKart!
${_currentStore!.name}

${_currentStore!.storeUrl}

Shop now and order via WhatsApp!
''';
    
    await Share.share(message);
  }
}
```

#### ProductProvider

```dart
class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  String? _searchQuery;
  String? _categoryFilter;
  
  List<Product> get products {
    var filtered = _products;
    
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(_searchQuery!.toLowerCase())
      ).toList();
    }
    
    if (_categoryFilter != null) {
      // Filter by category if implemented
    }
    
    return filtered;
  }
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Fetch products for store
  Future<void> fetchProducts(int storeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await ApiService.get('/products/store/$storeId');
      _products = (response['products'] as List)
          .map((p) => Product.fromJson(p))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Add product
  Future<bool> addProduct({
    required int storeId,
    required String name,
    required double price,
    String? description,
    File? imageFile,
    bool isActive = true,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await ApiService.uploadImage(imageFile);
      }
      
      final response = await ApiService.post('/products', {
        'store_id': storeId,
        'name': name,
        'price': price,
        'description': description,
        'image': imageUrl,
        'is_active': isActive,
      });
      
      _products.add(Product.fromJson(response['product']));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Update product
  Future<bool> updateProduct({
    required int productId,
    String? name,
    double? price,
    String? description,
    File? imageFile,
    bool? isActive,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await ApiService.uploadImage(imageFile);
      }
      
      final response = await ApiService.put('/products/$productId', {
        'name': name,
        'price': price,
        'description': description,
        'image': imageUrl,
        'is_active': isActive,
      });
      
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = Product.fromJson(response['product']);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Delete product
  Future<bool> deleteProduct(int productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await ApiService.delete('/products/$productId');
      _products.removeWhere((p) => p.id == productId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Search products
  void searchProducts(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  // Filter by category
  void filterByCategory(String? category) {
    _categoryFilter = category;
    notifyListeners();
  }
}
```

#### OrderProvider

```dart
class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  OrderStatus? _statusFilter;
  
  List<Order> get orders {
    if (_statusFilter == null) {
      return _orders;
    }
    return _orders.where((o) => o.status == _statusFilter).toList();
  }
  
  List<Order> get pendingOrders => 
      _orders.where((o) => o.status == OrderStatus.pending).toList();
  
  List<Order> get confirmedOrders => 
      _orders.where((o) => o.status == OrderStatus.confirmed).toList();
  
  List<Order> get deliveredOrders => 
      _orders.where((o) => o.status == OrderStatus.delivered).toList();
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Fetch orders for store
  Future<void> fetchOrders(int storeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await ApiService.get('/orders/store/$storeId');
      _orders = (response['orders'] as List)
          .map((o) => Order.fromJson(o))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Create order (manual entry)
  Future<bool> createOrder({
    required int storeId,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    String? deliveryAddress,
    required List<OrderItem> items,
    required PaymentMethod paymentMethod,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await ApiService.post('/orders', {
        'store_id': storeId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'customer_email': customerEmail,
        'delivery_address': deliveryAddress,
        'items': items.map((i) => i.toJson()).toList(),
        'payment_method': paymentMethod.name,
        'notes': notes,
      });
      
      _orders.insert(0, Order.fromJson(response['order']));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Update order status
  Future<bool> updateOrderStatus(int orderId, OrderStatus newStatus) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await ApiService.put('/orders/$orderId/status', {
        'status': newStatus.name,
      });
      
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = Order.fromJson(response['order']);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Filter by status
  void filterByStatus(OrderStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }
  
  // Contact customer via WhatsApp
  Future<void> contactCustomerWhatsApp(Order order) async {
    final message = Uri.encodeComponent(
      'Hi ${order.customerName}, regarding your order #${order.id}'
    );
    final phone = order.customerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final url = 'https://wa.me/$phone?text=$message';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
  
  // Call customer
  Future<void> callCustomer(Order order) async {
    final url = 'tel:${order.customerPhone}';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
```

#### AnalyticsProvider

```dart
class AnalyticsProvider extends ChangeNotifier {
  Analytics? _analytics;
  bool _isLoading = false;
  String? _error;
  AnalyticsPeriod _currentPeriod = AnalyticsPeriod.week;
  
  Analytics? get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AnalyticsPeriod get currentPeriod => _currentPeriod;
  
  // Fetch analytics
  Future<void> fetchAnalytics(int storeId, {AnalyticsPeriod? period}) async {
    _isLoading = true;
    _error = null;
    if (period != null) {
      _currentPeriod = period;
    }
    notifyListeners();
    
    try {
      final response = await ApiService.get(
        '/analytics/$storeId',
        queryParams: {'period': _currentPeriod.name},
      );
      
      _analytics = Analytics.fromJson(response['analytics']);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Change period
  void changePeriod(AnalyticsPeriod period, int storeId) {
    _currentPeriod = period;
    fetchAnalytics(storeId, period: period);
  }
  
  // Export report
  Future<void> exportReport(int storeId) async {
    try {
      final response = await ApiService.get(
        '/analytics/$storeId/export',
        queryParams: {'period': _currentPeriod.name},
      );
      
      // Handle PDF/CSV download
      // Implementation depends on platform
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
```


### Service Interfaces

#### API Service

```dart
class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  static String? _authToken;
  
  // Set auth token
  static void setAuthToken(String token) {
    _authToken = token;
  }
  
  // Clear auth token
  static void clearAuthToken() {
    _authToken = null;
  }
  
  // GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(
        uri,
        headers: _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }
  
  // POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: json.encode(body),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }
  
  // PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: json.encode(body),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }
  
  // DELETE request
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }
  
  // Upload image
  static Future<String> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload'),
      );
      
      request.headers.addAll(_getHeaders());
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      final data = _handleResponse(response);
      return data['url'];
    } catch (e) {
      throw ApiException('Image upload failed: $e');
    }
  }
  
  // Get headers
  static Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  // Handle response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw ApiException('Unauthorized');
    } else if (response.statusCode == 404) {
      throw ApiException('Not found');
    } else if (response.statusCode == 422) {
      final data = json.decode(response.body);
      throw ApiException(data['message'] ?? 'Validation error');
    } else {
      throw ApiException('Server error: ${response.statusCode}');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}
```

#### Firebase Service

```dart
class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }
  
  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
  
  // Get ID token
  static Future<String?> getIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }
  
  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Listen to auth state changes
  static Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
```

#### Storage Service (Local Persistence)

```dart
class StorageService {
  static late SharedPreferences _prefs;
  
  // Initialize
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Save user data
  static Future<void> saveUser(User user) async {
    await _prefs.setString('user', json.encode(user.toJson()));
  }
  
  // Get user data
  static User? getUser() {
    final userJson = _prefs.getString('user');
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }
  
  // Save store data
  static Future<void> saveStore(Store store) async {
    await _prefs.setString('store', json.encode(store.toJson()));
  }
  
  // Get store data
  static Store? getStore() {
    final storeJson = _prefs.getString('store');
    if (storeJson != null) {
      return Store.fromJson(json.decode(storeJson));
    }
    return null;
  }
  
  // Save onboarding status
  static Future<void> setOnboardingComplete(bool complete) async {
    await _prefs.setBool('onboarding_complete', complete);
  }
  
  // Check onboarding status
  static bool isOnboardingComplete() {
    return _prefs.getBool('onboarding_complete') ?? false;
  }
  
  // Clear all data
  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}
```

#### Analytics Service

```dart
class AnalyticsService {
  // Track screen view
  static Future<void> trackScreenView(String screenName) async {
    await FirebaseAnalytics.instance.logScreenView(
      screenName: screenName,
    );
  }
  
  // Track event
  static Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }
  
  // Track product view
  static Future<void> trackProductView(Product product) async {
    await trackEvent('product_view', parameters: {
      'product_id': product.id,
      'product_name': product.name,
      'product_price': product.price,
    });
  }
  
  // Track order created
  static Future<void> trackOrderCreated(Order order) async {
    await trackEvent('order_created', parameters: {
      'order_id': order.id,
      'order_total': order.total,
      'items_count': order.items.length,
    });
  }
  
  // Track store created
  static Future<void> trackStoreCreated(Store store) async {
    await trackEvent('store_created', parameters: {
      'store_id': store.id,
      'store_name': store.name,
      'store_category': store.category,
    });
  }
}
```


## Screen Designs and User Flows

### 1. Splash Screen

**Purpose**: Brand introduction and app initialization

**Duration**: 2 seconds

**UI Elements**:
- Animated LinkKart logo with gradient
- Brand colors fade-in animation
- Loading indicator (optional)

**Implementation**:

```dart
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
    _controller.forward();
    
    _navigateToNext();
  }
  
  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final authProvider = context.read<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;
    
    if (isAuthenticated) {
      final hasStore = await authProvider.hasStore();
      if (hasStore) {
        final isOnboardingComplete = StorageService.isOnboardingComplete();
        if (isOnboardingComplete) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => DashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => OnboardingScreen()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => StoreSetupScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WelcomeScreen()),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [AppShadows.large],
                    ),
                    child: Center(
                      child: Text(
                        'LK',
                        style: AppTypography.h1.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'LinkKart',
                    style: AppTypography.h2.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your WhatsApp Store',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

### 2. Welcome/Landing Screen

**Purpose**: Introduce app value proposition and guide user to authentication

**UI Elements**:
- Hero illustration (store + phone + heart)
- Headline: "Create Your WhatsApp Store in 2 Minutes"
- 3 value propositions with checkmarks:
  - ✓ Create store in minutes
  - ✓ Receive orders on WhatsApp
  - ✓ Manage everything in one app
- Primary CTA: "Create Free Store" (gradient button)
- Secondary CTA: "I already have a store" (text button)
- Modern gradient background

**Implementation**:

```dart
class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              children: [
                Spacer(),
                
                // Hero Illustration
                Container(
                  height: 250,
                  child: Image.asset(
                    'assets/images/welcome_hero.png',
                    fit: BoxFit.contain,
                  ),
                ),
                
                SizedBox(height: AppSpacing.xl),
                
                // Headline
                Text(
                  'Create Your WhatsApp\nStore in 2 Minutes',
                  style: AppTypography.h1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: AppSpacing.lg),
                
                // Value Props
                _buildValueProp('Create store in minutes'),
                SizedBox(height: AppSpacing.md),
                _buildValueProp('Receive orders on WhatsApp'),
                SizedBox(height: AppSpacing.md),
                _buildValueProp('Manage everything in one app'),
                
                Spacer(),
                
                // Primary CTA
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    boxShadow: [AppShadows.medium],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PhoneEntryScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                    ),
                    child: Text(
                      'Create Free Store',
                      style: AppTypography.button.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: AppSpacing.md),
                
                // Secondary CTA
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhoneEntryScreen(isReturningUser: true),
                      ),
                    );
                  },
                  child: Text(
                    'I already have a store',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildValueProp(String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 16,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Text(
          text,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
```

---

### 3. Phone Number Entry Screen

**Purpose**: Collect user's phone number for OTP authentication

**UI Elements**:
- Back button
- Title: "Enter Your Phone Number"
- Subtitle: "We'll send you an OTP to verify"
- Country code selector (default: +91 India)
- Phone number input field (10 digits)
- Large "Continue" button (disabled until valid)
- Terms & Privacy links at bottom

**Validation**:
- Phone number must be 10 digits
- Only numeric input allowed
- Real-time validation feedback

**Implementation**:

```dart
class PhoneEntryScreen extends StatefulWidget {
  final bool isReturningUser;
  
  const PhoneEntryScreen({this.isReturningUser = false});
  
  @override
  _PhoneEntryScreenState createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _phoneController = TextEditingController();
  String _countryCode = '+91';
  bool _isValid = false;
  
  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
  }
  
  void _validatePhone() {
    setState(() {
      _isValid = _phoneController.text.length == 10;
    });
  }
  
  Future<void> _sendOTP() async {
    if (!_isValid) return;
    
    final authProvider = context.read<AuthProvider>();
    final phoneNumber = '$_countryCode${_phoneController.text}';
    
    final success = await authProvider.sendOTP(phoneNumber);
    
    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OTPVerificationScreen(
            phoneNumber: phoneNumber,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Failed to send OTP')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.lg),
              
              // Title
              Text(
                'Enter Your Phone Number',
                style: AppTypography.h2,
              ),
              
              SizedBox(height: AppSpacing.sm),
              
              // Subtitle
              Text(
                'We\'ll send you an OTP to verify',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              SizedBox(height: AppSpacing.xl),
              
              // Phone Input
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country Code Selector
                  Container(
                    width: 80,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Text(
                        _countryCode,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: AppSpacing.md),
                  
                  // Phone Number Input
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        hintText: '9876543210',
                        counterText: '',
                        prefixIcon: Icon(Icons.phone_outlined),
                        suffixIcon: _isValid
                            ? Icon(Icons.check_circle, color: AppColors.success)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              
              Spacer(),
              
              // Continue Button
              Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isValid && !authProvider.isLoading
                      ? _sendOTP
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: authProvider.isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Continue', style: AppTypography.button),
                ),
              ),
              
              SizedBox(height: AppSpacing.md),
              
              // Terms & Privacy
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'By continuing, you agree to our ',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    children: [
                      TextSpan(
                        text: 'Terms',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
```

---

### 4. OTP Verification Screen

**Purpose**: Verify user's phone number with OTP code

**UI Elements**:
- Back button
- Title: "Enter Verification Code"
- Subtitle: "Sent to +91 9876543210"
- 6-digit OTP input (auto-focus, auto-detect from SMS)
- Resend timer (60 seconds countdown)
- "Didn't receive?" link
- Large "Verify" button
- Loading state during verification

**Features**:
- Auto-read OTP from SMS (Android)
- Auto-submit when 6 digits entered
- Resend OTP after 60 seconds
- Error handling for invalid OTP

**Implementation**:

```dart
class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  
  const OTPVerificationScreen({required this.phoneNumber});
  
  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = 
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = 
      List.generate(6, (_) => FocusNode());
  
  int _resendTimer = 60;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _startTimer();
    _focusNodes[0].requestFocus();
  }
  
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }
  
  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();
    
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter complete OTP')),
      );
      return;
    }
    
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOTP(otp);
    
    if (success) {
      // Check if user has store
      final hasStore = await authProvider.hasStore();
      
      if (hasStore) {
        // Existing user - go to dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => DashboardScreen()),
          (route) => false,
        );
      } else {
        // New user - go to store setup
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => StoreSetupScreen()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Invalid OTP')),
      );
    }
  }
  
  Future<void> _resendOTP() async {
    if (_resendTimer > 0) return;
    
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendOTP(widget.phoneNumber);
    
    if (success) {
      setState(() {
        _resendTimer = 60;
      });
      _startTimer();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent successfully')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.lg),
              
              // Title
              Text(
                'Enter Verification Code',
                style: AppTypography.h2,
              ),
              
              SizedBox(height: AppSpacing.sm),
              
              // Subtitle
              Text(
                'Sent to ${widget.phoneNumber}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              SizedBox(height: AppSpacing.xl),
              
              // OTP Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return Container(
                    width: 50,
                    height: 60,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: AppTypography.h3,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        }
                        
                        if (index == 5 && value.isNotEmpty) {
                          _verifyOTP();
                        }
                      },
                      onTap: () {
                        _otpControllers[index].selection = TextSelection.fromPosition(
                          TextPosition(offset: _otpControllers[index].text.length),
                        );
                      },
                    ),
                  );
                }),
              ),
              
              SizedBox(height: AppSpacing.lg),
              
              // Resend OTP
              Center(
                child: _resendTimer > 0
                    ? Text(
                        'Resend OTP in $_resendTimer seconds',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      )
                    : TextButton(
                        onPressed: _resendOTP,
                        child: Text(
                          'Didn\'t receive? Resend OTP',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
              
              Spacer(),
              
              // Verify Button
              Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _verifyOTP,
                  child: authProvider.isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Verify', style: AppTypography.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
```


---

### 5. Store Setup Screen (New Users Only)

**Purpose**: Collect store information from new users

**UI Elements**:
- Progress indicator: "Step 1 of 3"
- Title: "Create Your Store"
- Store Name input (required)
- Store Category dropdown (Fashion, Electronics, Food, Beauty, Home & Garden, Services, Other)
- WhatsApp Number input (pre-filled with auth phone, editable)
- Store Logo upload (optional, camera + gallery)
- "Create Store" button
- Skip button (creates store with minimal info)

**Validation**:
- Store name: 3-50 characters
- WhatsApp number: valid phone format
- Category: must select one

**Implementation**:

```dart
class StoreSetupScreen extends StatefulWidget {
  @override
  _StoreSetupScreenState createState() => _StoreSetupScreenState();
}

class _StoreSetupScreenState extends State<StoreSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String? _selectedCategory;
  File? _logoFile;
  
  final List<String> _categories = [
    'Fashion',
    'Electronics',
    'Food & Beverages',
    'Beauty & Personal Care',
    'Home & Garden',
    'Services',
    'Other',
  ];
  
  @override
  void initState() {
    super.initState();
    // Pre-fill phone number from auth
    final authProvider = context.read<AuthProvider>();
    _phoneController.text = authProvider.currentUser?.phoneNumber ?? '';
  }
  
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null) {
      setState(() {
        _logoFile = File(pickedFile.path);
      });
    }
  }
  
  Future<void> _createStore() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    
    final storeProvider = context.read<StoreProvider>();
    
    final success = await storeProvider.createStore(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      category: _selectedCategory!,
      logoFile: _logoFile,
    );
    
    if (success) {
      // Track analytics
      AnalyticsService.trackStoreCreated(storeProvider.currentStore!);
      
      // Navigate to onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(storeProvider.error ?? 'Failed to create store')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Your Store'),
        actions: [
          TextButton(
            onPressed: () {
              // Skip with minimal info
              _createStore();
            },
            child: Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Indicator
                LinearProgressIndicator(
                  value: 0.33,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
                
                SizedBox(height: AppSpacing.lg),
                
                Text(
                  'Step 1 of 3',
                  style: AppTypography.caption,
                ),
                
                SizedBox(height: AppSpacing.sm),
                
                Text(
                  'Tell us about your store',
                  style: AppTypography.h2,
                ),
                
                SizedBox(height: AppSpacing.xl),
                
                // Logo Upload
                Center(
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.camera_alt),
                                title: Text('Take Photo'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.camera);
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.photo_library),
                                title: Text('Choose from Gallery'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.gallery);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(AppRadius.large),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: _logoFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.large),
                              child: Image.file(_logoFile!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 40,
                                  color: AppColors.textTertiary,
                                ),
                                SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Add Logo',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                
                SizedBox(height: AppSpacing.xl),
                
                // Store Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Store Name *',
                    hintText: 'e.g., Fashion Hub',
                    prefixIcon: Icon(Icons.store_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Store name is required';
                    }
                    if (value.trim().length < 3) {
                      return 'Store name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: AppSpacing.md),
                
                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category *',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: AppSpacing.md),
                
                // WhatsApp Number
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'WhatsApp Number *',
                    hintText: '+91 9876543210',
                    prefixIcon: Icon(Icons.whatsapp),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'WhatsApp number is required';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: AppSpacing.xl),
                
                // Create Button
                Container(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: storeProvider.isLoading ? null : _createStore,
                    child: storeProvider.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Create Store', style: AppTypography.button),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
```

---

### 6. Onboarding Tutorial (First Time Only)

**Purpose**: Guide new users through key features

**UI Elements**:
- 3 swipeable cards with illustrations:
  1. "Add Your Products" - Show product management
  2. "Share Your Store Link" - Show sharing feature
  3. "Receive Orders on WhatsApp" - Show order flow
- Page indicators (dots)
- "Skip" button (top right)
- "Next" button (cards 1-2)
- "Get Started" button (card 3)

**Implementation**:

```dart
class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: 'assets/images/onboarding_1.png',
      title: 'Add Your Products',
      description: 'Easily add products with photos, prices, and descriptions',
    ),
    OnboardingPage(
      image: 'assets/images/onboarding_2.png',
      title: 'Share Your Store Link',
      description: 'Share your store link on WhatsApp, Instagram, and more',
    ),
    OnboardingPage(
      image: 'assets/images/onboarding_3.png',
      title: 'Receive Orders on WhatsApp',
      description: 'Get orders directly on WhatsApp and manage them in the app',
    ),
  ];
  
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }
  
  void _skip() {
    StorageService.setOnboardingComplete(true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DashboardScreen()),
    );
  }
  
  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _skip();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skip,
                child: Text('Skip'),
              ),
            ),
            
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            
            SizedBox(height: AppSpacing.xl),
            
            // Next/Get Started Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              child: Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: AppTypography.button,
                  ),
                ),
              ),
            ),
            
            SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            height: 300,
            child: Image.asset(
              page.image,
              fit: BoxFit.contain,
            ),
          ),
          
          SizedBox(height: AppSpacing.xl),
          
          // Title
          Text(
            page.title,
            style: AppTypography.h2,
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: AppSpacing.md),
          
          // Description
          Text(
            page.description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String image;
  final String title;
  final String description;
  
  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });
}
```


---

### 7. Dashboard Screen (Home)

**Purpose**: Main hub showing store overview and quick actions

**UI Layout**:
- **Header**: Greeting, store name, notification bell
- **Stats Cards** (2x2 grid): Total Orders, Revenue, Products, Views
- **Quick Actions**: Add Product, View Orders, Share Link, Analytics
- **Recent Orders** section (last 5 orders)
- **Bottom Navigation**: Home, Products, Orders, More

**Implementation Summary**:

```dart
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    HomeTab(),
    ProductsTab(),
    OrdersTab(),
    MoreTab(),
  ];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final storeProvider = context.read<StoreProvider>();
    final productProvider = context.read<ProductProvider>();
    final orderProvider = context.read<OrderProvider>();
    
    if (storeProvider.currentStore != null) {
      await Future.wait([
        productProvider.fetchProducts(storeProvider.currentStore!.id),
        orderProvider.fetchOrders(storeProvider.currentStore!.id),
      ]);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            activeIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

// Home Tab Widget
class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    final productProvider = context.watch<ProductProvider>();
    final orderProvider = context.watch<OrderProvider>();
    
    final store = storeProvider.currentStore;
    
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          // Refresh data
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '👋 Hi, ${store?.name ?? "There"}!',
                        style: AppTypography.h3,
                      ),
                      SizedBox(height: 4),
                      Text(
                        store?.name ?? '',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications_outlined),
                    onPressed: () {
                      // Navigate to notifications
                    },
                  ),
                ],
              ),
              
              SizedBox(height: AppSpacing.lg),
              
              // Stats Cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    icon: Icons.shopping_bag,
                    label: 'Total Orders',
                    value: '${orderProvider.orders.length}',
                    color: AppColors.primary,
                  ),
                  _buildStatCard(
                    icon: Icons.currency_rupee,
                    label: 'Revenue',
                    value: '₹${_calculateRevenue(orderProvider.orders)}',
                    color: AppColors.success,
                  ),
                  _buildStatCard(
                    icon: Icons.inventory_2,
                    label: 'Products',
                    value: '${productProvider.products.length}',
                    color: AppColors.secondary,
                  ),
                  _buildStatCard(
                    icon: Icons.visibility,
                    label: 'Store Views',
                    value: '${store?.viewCount ?? 0}',
                    color: AppColors.info,
                  ),
                ],
              ),
              
              SizedBox(height: AppSpacing.lg),
              
              // Quick Actions
              Text(
                'Quick Actions',
                style: AppTypography.h4,
              ),
              
              SizedBox(height: AppSpacing.md),
              
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.add,
                      label: 'Add Product',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddProductScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.share,
                      label: 'Share Link',
                      onTap: () {
                        storeProvider.shareStoreLink();
                      },
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: AppSpacing.lg),
              
              // Recent Orders
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Orders',
                    style: AppTypography.h4,
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to orders tab
                    },
                    child: Text('View All'),
                  ),
                ],
              ),
              
              SizedBox(height: AppSpacing.md),
              
              // Order List
              if (orderProvider.orders.isEmpty)
                _buildEmptyState('No orders yet')
              else
                ...orderProvider.orders.take(5).map((order) {
                  return _buildOrderCard(order);
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [AppShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.numberMedium,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary),
            SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderCard(Order order) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [AppShadows.card],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: order.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.shopping_bag,
              color: order.statusColor,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  order.formattedTotal,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: order.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              order.statusLabel,
              style: AppTypography.bodySmall.copyWith(
                color: order.statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(String message) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _calculateRevenue(List<Order> orders) {
    final total = orders
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0.0, (sum, order) => sum + order.total);
    return total.toStringAsFixed(0);
  }
}
```

---

### 8. Orders Management Screen

**Purpose**: View and manage all orders with filtering and actions

**UI Elements**:
- **Tabs**: All, Pending, Confirmed, Delivered
- **Order Cards** with:
  - Customer name + phone
  - Order items summary
  - Total amount
  - Order date/time
  - Status badge
  - Action buttons (WhatsApp, Call, Update Status)
- **Order Details Modal**: Full order information
- **Empty State**: "No orders yet" with illustration

**Key Features**:
- Filter by status
- Update order status
- Contact customer (WhatsApp/Call)
- View order timeline
- Search orders

**Implementation Summary**:

```dart
class OrdersTab extends StatefulWidget {
  @override
  _OrdersTabState createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Delivered'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(orderProvider.orders),
          _buildOrderList(orderProvider.pendingOrders),
          _buildOrderList(orderProvider.confirmedOrders),
          _buildOrderList(orderProvider.deliveredOrders),
        ],
      ),
    );
  }
  
  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No orders found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index]);
      },
    );
  }
  
  Widget _buildOrderCard(Order order) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          _showOrderDetails(order);
        },
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: order.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.statusLabel,
                      style: AppTypography.bodySmall.copyWith(
                        color: order.statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: AppSpacing.md),
              
              // Customer Info
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(order.customerName),
                  SizedBox(width: 16),
                  Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(order.customerPhone),
                ],
              ),
              
              SizedBox(height: AppSpacing.sm),
              
              // Items Summary
              Text(
                '${order.items.length} items • ${order.formattedTotal}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              SizedBox(height: AppSpacing.md),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<OrderProvider>().contactCustomerWhatsApp(order);
                      },
                      icon: Icon(Icons.whatsapp, size: 18),
                      label: Text('WhatsApp'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.whatsapp,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<OrderProvider>().callCustomer(order);
                      },
                      icon: Icon(Icons.call, size: 18),
                      label: Text('Call'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsSheet(order: order),
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
```


## Animations and Interactions

### Page Transitions

```dart
class AppPageRoute {
  // Slide from right (forward navigation)
  static Route slideFromRight(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 300),
    );
  }
  
  // Fade transition
  static Route fadeIn(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 200),
    );
  }
  
  // Scale transition (for modals)
  static Route scaleUp(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.8;
        const end = 1.0;
        const curve = Curves.easeOutBack;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return ScaleTransition(
          scale: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 300),
    );
  }
}
```

### Button Interactions

```dart
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  
  const AnimatedButton({
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.padding,
  });
  
  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: widget.padding ?? EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: widget.child,
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Loading States

```dart
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  
  const ShimmerLoading({
    required this.width,
    required this.height,
    this.borderRadius,
  });
  
  @override
  _ShimmerLoadingState createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(-1.0 - _controller.value * 2, 0.0),
              end: Alignment(1.0 - _controller.value * 2, 0.0),
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
            ),
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Success Animations

```dart
class SuccessAnimation extends StatefulWidget {
  final VoidCallback? onComplete;
  
  const SuccessAnimation({this.onComplete});
  
  @override
  _SuccessAnimationState createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        Future.delayed(Duration(milliseconds: 500), widget.onComplete);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: CustomPaint(
              painter: CheckmarkPainter(_checkAnimation.value),
            ),
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CheckmarkPainter extends CustomPainter {
  final double progress;
  
  CheckmarkPainter(this.progress);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.5);
    path.lineTo(size.width * 0.4, size.height * 0.65);
    path.lineTo(size.width * 0.75, size.height * 0.35);
    
    final metric = path.computeMetrics().first;
    final extractPath = metric.extractPath(0.0, metric.length * progress);
    
    canvas.drawPath(extractPath, paint);
  }
  
  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
```

## Error Handling

### Error Types and Responses

```dart
enum ErrorType {
  network,
  authentication,
  validation,
  server,
  unknown
}

class AppError {
  final ErrorType type;
  final String message;
  final String? details;
  
  AppError({
    required this.type,
    required this.message,
    this.details,
  });
  
  factory AppError.fromException(dynamic exception) {
    if (exception is ApiException) {
      if (exception.message.contains('Unauthorized')) {
        return AppError(
          type: ErrorType.authentication,
          message: 'Please login again',
          details: exception.message,
        );
      } else if (exception.message.contains('Network')) {
        return AppError(
          type: ErrorType.network,
          message: 'No internet connection',
          details: exception.message,
        );
      } else {
        return AppError(
          type: ErrorType.server,
          message: 'Something went wrong',
          details: exception.message,
        );
      }
    }
    
    return AppError(
      type: ErrorType.unknown,
      message: 'An unexpected error occurred',
      details: exception.toString(),
    );
  }
  
  void show(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        action: details != null
            ? SnackBarAction(
                label: 'Details',
                textColor: Colors.white,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error Details'),
                      content: Text(details!),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }
}
```

### Retry Logic

```dart
class RetryHelper {
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    
    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        
        if (attempts >= maxAttempts) {
          rethrow;
        }
        
        await Future.delayed(delay * attempts);
      }
    }
    
    throw Exception('Max retry attempts reached');
  }
}
```

## Testing Strategy

### Unit Testing

**Test Coverage Goals**: 80% minimum

**Key Areas**:
- Data models (serialization/deserialization)
- Business logic in providers
- Utility functions
- Validation logic

**Example Test**:

```dart
void main() {
  group('User Model Tests', () {
    test('User.fromJson creates valid User object', () {
      final json = {
        'id': '123',
        'phone_number': '+919876543210',
        'email': 'test@example.com',
        'display_name': 'Test User',
        'created_at': '2024-01-01T00:00:00Z',
        'last_login_at': '2024-01-01T00:00:00Z',
        'is_verified': true,
      };
      
      final user = User.fromJson(json);
      
      expect(user.id, '123');
      expect(user.phoneNumber, '+919876543210');
      expect(user.email, 'test@example.com');
      expect(user.isVerified, true);
    });
    
    test('User.toJson creates valid JSON', () {
      final user = User(
        id: '123',
        phoneNumber: '+919876543210',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        lastLoginAt: DateTime.parse('2024-01-01T00:00:00Z'),
        isVerified: true,
      );
      
      final json = user.toJson();
      
      expect(json['id'], '123');
      expect(json['phone_number'], '+919876543210');
      expect(json['is_verified'], true);
    });
  });
  
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;
    
    setUp(() {
      authProvider = AuthProvider();
    });
    
    test('Initial state is not authenticated', () {
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.currentUser, null);
    });
    
    test('sendOTP updates loading state', () async {
      expect(authProvider.isLoading, false);
      
      // Mock Firebase call
      authProvider.sendOTP('+919876543210');
      
      expect(authProvider.isLoading, true);
    });
  });
}
```

### Widget Testing

**Test Coverage**: All custom widgets and screens

**Example Test**:

```dart
void main() {
  testWidgets('WelcomeScreen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WelcomeScreen(),
      ),
    );
    
    // Verify headline
    expect(
      find.text('Create Your WhatsApp\nStore in 2 Minutes'),
      findsOneWidget,
    );
    
    // Verify CTAs
    expect(find.text('Create Free Store'), findsOneWidget);
    expect(find.text('I already have a store'), findsOneWidget);
    
    // Verify value props
    expect(find.text('Create store in minutes'), findsOneWidget);
    expect(find.text('Receive orders on WhatsApp'), findsOneWidget);
    expect(find.text('Manage everything in one app'), findsOneWidget);
  });
  
  testWidgets('Tapping Create Free Store navigates to PhoneEntryScreen', 
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WelcomeScreen(),
      ),
    );
    
    await tester.tap(find.text('Create Free Store'));
    await tester.pumpAndSettle();
    
    expect(find.byType(PhoneEntryScreen), findsOneWidget);
  });
}
```

### Integration Testing

**Test Scenarios**:
1. Complete authentication flow (phone → OTP → store setup)
2. Product CRUD operations
3. Order management workflow
4. Store settings update
5. Analytics data fetching

**Example Test**:

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Complete authentication and store setup flow', 
      (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    // 1. Splash screen
    expect(find.text('LinkKart'), findsOneWidget);
    await tester.pumpAndSettle(Duration(seconds: 2));
    
    // 2. Welcome screen
    expect(find.text('Create Free Store'), findsOneWidget);
    await tester.tap(find.text('Create Free Store'));
    await tester.pumpAndSettle();
    
    // 3. Phone entry
    expect(find.byType(PhoneEntryScreen), findsOneWidget);
    await tester.enterText(
      find.byType(TextField),
      '9876543210',
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    
    // 4. OTP verification (mock)
    expect(find.byType(OTPVerificationScreen), findsOneWidget);
    // Enter OTP
    for (int i = 0; i < 6; i++) {
      await tester.enterText(
        find.byType(TextField).at(i),
        '1',
      );
    }
    await tester.pumpAndSettle();
    
    // 5. Store setup
    expect(find.byType(StoreSetupScreen), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Store Name *'),
      'Test Store',
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fashion').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create Store'));
    await tester.pumpAndSettle();
    
    // 6. Onboarding
    expect(find.byType(OnboardingScreen), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    
    // 7. Dashboard
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Test Store'), findsOneWidget);
  });
}
```

## Performance Considerations

### Image Optimization

```dart
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  
  const OptimizedImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });
  
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => ShimmerLoading(
        width: width ?? 100,
        height: height ?? 100,
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: Icon(Icons.error_outline, color: Colors.grey),
      ),
      memCacheWidth: width != null ? (width! * 2).toInt() : null,
      memCacheHeight: height != null ? (height! * 2).toInt() : null,
    );
  }
}
```

### List Optimization

```dart
class OptimizedListView extends StatelessWidget {
  final List<Widget> children;
  final ScrollController? controller;
  
  const OptimizedListView({
    required this.children,
    this.controller,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      itemCount: children.length,
      cacheExtent: 500, // Cache 500 pixels ahead
      itemBuilder: (context, index) {
        return children[index];
      },
    );
  }
}
```

### Pagination

```dart
class PaginatedList<T> extends StatefulWidget {
  final Future<List<T>> Function(int page) fetchData;
  final Widget Function(T item) itemBuilder;
  
  const PaginatedList({
    required this.fetchData,
    required this.itemBuilder,
  });
  
  @override
  _PaginatedListState<T> createState() => _PaginatedListState<T>();
}

class _PaginatedListState<T> extends State<PaginatedList<T>> {
  final List<T> _items = [];
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  
  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }
  
  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final newItems = await widget.fetchData(_currentPage);
      
      setState(() {
        _items.addAll(newItems);
        _currentPage++;
        _hasMore = newItems.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        return widget.itemBuilder(_items[index]);
      },
    );
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

### Offline Support

```dart
class OfflineManager {
  static final _storage = GetStorage();
  
  // Cache data
  static Future<void> cacheData(String key, dynamic data) async {
    await _storage.write(key, json.encode(data));
  }
  
  // Get cached data
  static dynamic getCachedData(String key) {
    final cached = _storage.read(key);
    if (cached != null) {
      return json.decode(cached);
    }
    return null;
  }
  
  // Check connectivity
  static Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
  
  // Fetch with offline fallback
  static Future<T> fetchWithFallback<T>({
    required String cacheKey,
    required Future<T> Function() fetchFunction,
    required T Function(dynamic) fromCache,
  }) async {
    final isOnline = await isConnected();
    
    if (isOnline) {
      try {
        final data = await fetchFunction();
        await cacheData(cacheKey, data);
        return data;
      } catch (e) {
        // Fallback to cache on error
        final cached = getCachedData(cacheKey);
        if (cached != null) {
          return fromCache(cached);
        }
        rethrow;
      }
    } else {
      // Offline - use cache
      final cached = getCachedData(cacheKey);
      if (cached != null) {
        return fromCache(cached);
      }
      throw Exception('No internet connection and no cached data');
    }
  }
}
```


## Security Considerations

### Authentication Security

**Firebase Phone Authentication**:
- Automatic reCAPTCHA verification
- SMS rate limiting (Firebase handles)
- Token-based session management
- Automatic token refresh

**Best Practices**:
```dart
class SecurityHelper {
  // Secure token storage
  static Future<void> saveAuthToken(String token) async {
    final storage = FlutterSecureStorage();
    await storage.write(key: 'auth_token', value: token);
  }
  
  static Future<String?> getAuthToken() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'auth_token');
  }
  
  static Future<void> clearAuthToken() async {
    final storage = FlutterSecureStorage();
    await storage.delete(key: 'auth_token');
  }
  
  // Validate phone number format
  static bool isValidPhoneNumber(String phone) {
    final regex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return regex.hasMatch(phone);
  }
  
  // Sanitize user input
  static String sanitizeInput(String input) {
    return input.trim().replaceAll(RegExp(r'[<>]'), '');
  }
}
```

### Data Protection

**Sensitive Data Handling**:
- Use `flutter_secure_storage` for tokens
- Never log sensitive information
- Encrypt local database if storing sensitive data
- Clear sensitive data on logout

**API Security**:
- HTTPS only
- JWT token authentication
- Request timeout (30 seconds)
- Certificate pinning (production)

```dart
class SecureApiService extends ApiService {
  static const Duration timeout = Duration(seconds: 30);
  
  static Future<Map<String, dynamic>> secureGet(String endpoint) async {
    try {
      final token = await SecurityHelper.getAuthToken();
      
      if (token == null) {
        throw ApiException('Not authenticated');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(timeout);
      
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Request timeout');
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }
}
```

### Input Validation

```dart
class Validators {
  static String? validateStoreName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Store name is required';
    }
    if (value.trim().length < 3) {
      return 'Store name must be at least 3 characters';
    }
    if (value.trim().length > 50) {
      return 'Store name must be less than 50 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9\s&\-]+$').hasMatch(value)) {
      return 'Store name contains invalid characters';
    }
    return null;
  }
  
  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Invalid price format';
    }
    if (price <= 0) {
      return 'Price must be greater than 0';
    }
    if (price > 1000000) {
      return 'Price is too high';
    }
    return null;
  }
  
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length != 10) {
      return 'Phone number must be 10 digits';
    }
    return null;
  }
}
```

## Dependencies

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  firebase_analytics: ^10.7.4
  
  # Networking
  http: ^1.1.2
  dio: ^5.4.0  # Alternative to http with better features
  
  # Local Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # Image Handling
  image_picker: ^1.0.7
  cached_network_image: ^3.3.1
  
  # UI Components
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  shimmer: ^3.0.0
  
  # Utilities
  intl: ^0.18.1  # Date formatting
  url_launcher: ^6.2.2  # Open URLs, WhatsApp, Phone
  share_plus: ^7.2.1  # Share functionality
  connectivity_plus: ^5.0.2  # Network connectivity
  
  # QR Code
  qr_flutter: ^4.1.0
  
  # Charts (for analytics)
  fl_chart: ^0.65.0
  
  # Permissions
  permission_handler: ^11.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  integration_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.7
```

### Platform-Specific Configuration

**Android (android/app/build.gradle)**:
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.linkkart.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
        multiDexEnabled true
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}

dependencies {
    implementation 'com.google.firebase:firebase-auth:22.3.0'
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
}
```

**iOS (ios/Podfile)**:
```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  pod 'Firebase/Auth'
  pod 'Firebase/Analytics'
end
```

## Database Schema Updates

### New Tables Required

```sql
-- Users table
CREATE TABLE users (
    id VARCHAR(255) PRIMARY KEY,
    firebase_uid VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255),
    display_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_verified BOOLEAN DEFAULT FALSE,
    INDEX idx_phone (phone_number),
    INDEX idx_firebase_uid (firebase_uid)
);

-- Update stores table
ALTER TABLE stores 
ADD COLUMN user_id VARCHAR(255) AFTER id,
ADD COLUMN category VARCHAR(50),
ADD COLUMN description TEXT,
ADD COLUMN logo_url VARCHAR(500),
ADD COLUMN social_links JSON,
ADD COLUMN timings JSON,
ADD FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Orders table
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    store_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    customer_email VARCHAR(255),
    delivery_address TEXT,
    items JSON NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    delivery_charge DECIMAL(10, 2) DEFAULT 0,
    total DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    payment_method ENUM('cod', 'online', 'upi') DEFAULT 'cod',
    is_paid BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
    INDEX idx_store (store_id),
    INDEX idx_status (status),
    INDEX idx_created (created_at)
);

-- Order timeline table
CREATE TABLE order_timeline (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_order (order_id)
);

-- Customers table
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    store_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    address TEXT,
    total_orders INT DEFAULT 0,
    total_spent DECIMAL(10, 2) DEFAULT 0,
    last_order_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
    UNIQUE KEY unique_customer (store_id, phone),
    INDEX idx_store (store_id),
    INDEX idx_phone (phone)
);

-- Update products table
ALTER TABLE products
ADD COLUMN category VARCHAR(50),
ADD COLUMN stock_quantity INT DEFAULT 0,
ADD COLUMN is_in_stock BOOLEAN DEFAULT TRUE;
```

## API Endpoints Required

### Authentication Endpoints

```
POST   /api/auth/send-otp
       Body: { phone_number: string }
       Response: { success: boolean, message: string }

POST   /api/auth/verify-otp
       Body: { firebase_uid: string, phone_number: string }
       Response: { success: boolean, user: User, token: string }

POST   /api/auth/logout
       Headers: Authorization: Bearer {token}
       Response: { success: boolean }

GET    /api/auth/me
       Headers: Authorization: Bearer {token}
       Response: { user: User }
```

### Store Endpoints

```
POST   /api/stores
       Body: { name, phone, category, description?, logo? }
       Response: { store: Store }

GET    /api/stores/user/:userId
       Response: { has_store: boolean, store?: Store }

PUT    /api/stores/:id
       Body: { name?, phone?, category?, description?, logo?, social_links?, timings? }
       Response: { store: Store }
```

### Order Endpoints

```
GET    /api/orders/store/:storeId
       Query: ?status=pending&page=1&limit=20
       Response: { orders: Order[], pagination: {...} }

POST   /api/orders
       Body: { store_id, customer_name, customer_phone, items, payment_method, notes? }
       Response: { order: Order }

PUT    /api/orders/:id/status
       Body: { status: OrderStatus }
       Response: { order: Order }

GET    /api/orders/:id
       Response: { order: Order }
```

### Analytics Endpoints

```
GET    /api/analytics/:storeId
       Query: ?period=week&start_date=&end_date=
       Response: { analytics: Analytics }

GET    /api/analytics/:storeId/export
       Query: ?period=week&format=pdf
       Response: PDF/CSV file
```

### Customer Endpoints

```
GET    /api/customers/store/:storeId
       Query: ?search=&page=1&limit=20
       Response: { customers: Customer[], pagination: {...} }

GET    /api/customers/:id
       Response: { customer: Customer }
```

## Implementation Roadmap

### Phase 1: Foundation (Week 1-2)

**Tasks**:
1. ✅ Set up project structure
2. ✅ Configure Firebase (Auth, Analytics)
3. ✅ Implement design system (colors, typography, spacing)
4. ✅ Create base components (buttons, cards, inputs)
5. ✅ Set up state management (Provider)
6. ✅ Implement API service layer
7. ✅ Create data models

**Deliverables**:
- Project scaffolding complete
- Design system implemented
- Firebase configured
- Base architecture ready

### Phase 2: Authentication (Week 3)

**Tasks**:
1. Implement Splash Screen
2. Implement Welcome Screen
3. Implement Phone Entry Screen
4. Implement OTP Verification Screen
5. Integrate Firebase Phone Auth
6. Implement AuthProvider
7. Add error handling and loading states

**Deliverables**:
- Complete authentication flow
- Firebase integration working
- User can sign up/login

### Phase 3: Onboarding & Store Setup (Week 4)

**Tasks**:
1. Implement Store Setup Screen
2. Implement Onboarding Tutorial
3. Add image picker for logo
4. Integrate store creation API
5. Implement StoreProvider
6. Add form validation

**Deliverables**:
- New users can create stores
- Onboarding tutorial complete
- Store data persisted

### Phase 4: Dashboard & Products (Week 5-6)

**Tasks**:
1. Implement Dashboard Screen
2. Implement Products List Screen
3. Implement Add/Edit Product Screen
4. Implement ProductProvider
5. Add product CRUD operations
6. Implement search and filters
7. Add empty states

**Deliverables**:
- Dashboard with stats
- Product management complete
- Users can add/edit/delete products

### Phase 5: Orders Management (Week 7-8)

**Tasks**:
1. Implement Orders Screen with tabs
2. Implement Order Details Modal
3. Implement OrderProvider
4. Add order status updates
5. Integrate WhatsApp/Call actions
6. Add order timeline
7. Implement order creation (manual)

**Deliverables**:
- Complete order management
- Status updates working
- Customer contact features

### Phase 6: Analytics & Settings (Week 9)

**Tasks**:
1. Implement Analytics Screen
2. Add charts (fl_chart)
3. Implement AnalyticsProvider
4. Implement Settings Screen
5. Add store settings update
6. Add logout functionality
7. Implement QR code generation

**Deliverables**:
- Analytics dashboard
- Settings management
- Store customization

### Phase 7: Polish & Optimization (Week 10)

**Tasks**:
1. Add animations and transitions
2. Implement shimmer loading states
3. Add offline support
4. Optimize images (caching)
5. Implement pagination
6. Add haptic feedback
7. Performance optimization

**Deliverables**:
- Smooth animations
- Fast loading
- Offline capability
- Professional polish

### Phase 8: Testing & Bug Fixes (Week 11)

**Tasks**:
1. Write unit tests
2. Write widget tests
3. Write integration tests
4. Fix bugs
5. Test on multiple devices
6. Performance testing
7. Security audit

**Deliverables**:
- 80%+ test coverage
- All critical bugs fixed
- App tested on iOS/Android

### Phase 9: Deployment (Week 12)

**Tasks**:
1. Prepare app icons and splash screens
2. Configure app signing (Android/iOS)
3. Prepare store listings
4. Create screenshots
5. Submit to Play Store
6. Submit to App Store
7. Set up crash reporting (Firebase Crashlytics)

**Deliverables**:
- App published on stores
- Monitoring in place
- Ready for users

## Success Metrics

### Key Performance Indicators (KPIs)

**User Acquisition**:
- Signup completion rate > 80%
- Time to first product < 3 minutes
- Onboarding completion rate > 70%

**Engagement**:
- Daily Active Users (DAU)
- Products added per store (avg > 5)
- Orders tracked per store (avg > 10/month)
- Store link shares per user (avg > 3/week)

**Technical**:
- App crash rate < 1%
- API response time < 500ms (p95)
- App load time < 2 seconds
- App rating > 4.5 stars

**Business**:
- User retention (Day 7) > 40%
- User retention (Day 30) > 20%
- Monthly active stores > 1000
- Average revenue per store

### Monitoring & Analytics

**Firebase Analytics Events**:
- `app_open`
- `signup_started`
- `signup_completed`
- `store_created`
- `product_added`
- `product_edited`
- `product_deleted`
- `order_created`
- `order_status_updated`
- `store_link_shared`
- `analytics_viewed`

**Crashlytics**:
- Monitor crash-free users
- Track non-fatal errors
- Performance monitoring

## Future Enhancements (Phase 2)

### Planned Features

1. **WhatsApp Business API Integration**
   - Automated order confirmations
   - Order status updates via WhatsApp
   - Catalog sync

2. **Payment Gateway (Razorpay)**
   - Online payments
   - Payment links
   - Subscription plans

3. **Inventory Management**
   - Stock tracking
   - Low stock alerts
   - Automatic stock updates

4. **Customer Segmentation**
   - Customer groups
   - Targeted messaging
   - Loyalty programs

5. **Marketing Campaigns**
   - Bulk WhatsApp messages
   - Discount codes
   - Promotional banners

6. **Multi-Language Support**
   - Hindi, Tamil, Telugu, Bengali
   - RTL support for regional languages

7. **Dark Mode**
   - System-based theme switching
   - Manual theme selection

8. **Desktop Web App**
   - Responsive web version
   - Same features as mobile
   - Shared backend

9. **Advanced Analytics**
   - Customer lifetime value
   - Product performance
   - Sales forecasting

10. **Team Management**
    - Multiple users per store
    - Role-based permissions
    - Activity logs

## Conclusion

This design document provides a comprehensive blueprint for the LinkKart Mobile App Redesign. The redesign transforms the basic Flutter app into a modern, professional seller application with complete authentication, order management, analytics, and a delightful user experience matching Shopify's quality standards.

**Key Achievements**:
- ✅ Modern design system with Inter font and gradient colors
- ✅ Complete Firebase Phone Authentication flow
- ✅ Comprehensive order management system
- ✅ Customer database and analytics
- ✅ Professional UI with smooth animations
- ✅ Offline support and performance optimization
- ✅ Comprehensive testing strategy
- ✅ Clear implementation roadmap

**Next Steps**:
1. Review and approve design document
2. Set up development environment
3. Begin Phase 1 implementation
4. Regular progress reviews
5. User testing and feedback
6. Launch and iterate

The app is designed to empower small business owners to manage their WhatsApp-first stores efficiently, providing them with professional tools to grow their business.
