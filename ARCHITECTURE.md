# 🏛️ LinkKart - System Architecture

## 📊 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         LinkKart Platform                        │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│  Flutter Mobile  │    │  React Storefront│    │  React Admin     │
│  (Seller App)    │    │  (Customer View) │    │  (Dashboard)     │
│                  │    │                  │    │                  │
│  • Create Store  │    │  • Browse Store  │    │  • Manage Stores │
│  • Add Products  │    │  • View Products │    │  • View Analytics│
│  • View Stats    │    │  • Order via WA  │    │  • Monitor Users │
│  • Share Link    │    │  • Track Events  │    │  • Reports       │
└────────┬─────────┘    └────────┬─────────┘    └────────┬─────────┘
         │                       │                       │
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                                 │ REST API
                                 │
                    ┌────────────▼────────────┐
                    │   Laravel Backend API   │
                    │                         │
                    │  • RESTful Endpoints    │
                    │  • JWT Authentication   │
                    │  • File Upload          │
                    │  • Business Logic       │
                    │  • Data Validation      │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │     MySQL Database      │
                    │                         │
                    │  • stores               │
                    │  • products             │
                    │  • analytics_events     │
                    │  • admins               │
                    └─────────────────────────┘
```

---

## 🔄 Data Flow

### 1. Store Creation Flow

```
┌─────────────┐
│ Seller      │
│ (Mobile App)│
└──────┬──────┘
       │ 1. Enter store details
       │    (name, phone, logo)
       ▼
┌─────────────────┐
│ API Service     │
│ (Flutter)       │
└──────┬──────────┘
       │ 2. POST /api/v1/seller/stores
       │    (multipart/form-data)
       ▼
┌─────────────────┐
│ StoreController │
│ (Laravel)       │
└──────┬──────────┘
       │ 3. Validate input
       │ 4. Upload logo to storage
       │ 5. Generate unique slug
       ▼
┌─────────────────┐
│ Store Model     │
│ (Eloquent)      │
└──────┬──────────┘
       │ 6. Save to database
       ▼
┌─────────────────┐
│ MySQL Database  │
│ stores table    │
└──────┬──────────┘
       │ 7. Return store data
       ▼
┌─────────────────┐
│ JSON Response   │
│ {store_url, id} │
└──────┬──────────┘
       │ 8. Update UI
       ▼
┌─────────────────┐
│ Dashboard       │
│ (Mobile App)    │
└─────────────────┘
```

### 2. Customer Order Flow

```
┌─────────────┐
│ Customer    │
│ (Browser)   │
└──────┬──────┘
       │ 1. Visit store URL
       │    /store/{slug}
       ▼
┌─────────────────┐
│ StorePage       │
│ (React)         │
└──────┬──────────┘
       │ 2. GET /api/v1/stores/{slug}
       ▼
┌─────────────────┐
│ Backend API     │
└──────┬──────────┘
       │ 3. Fetch store + products
       │ 4. Track store_view event
       ▼
┌─────────────────┐
│ Display Products│
│ (Grid Layout)   │
└──────┬──────────┘
       │ 5. Customer clicks
       │    "Order on WhatsApp"
       ▼
┌─────────────────┐
│ Track Event     │
│ whatsapp_click  │
└──────┬──────────┘
       │ 6. Generate WhatsApp URL
       │    with pre-filled message
       ▼
┌─────────────────┐
│ Open WhatsApp   │
│ "Hi, I want to  │
│  order [Product]│
│  - ₹[Price]"    │
└─────────────────┘
```

### 3. Analytics Flow

```
┌─────────────┐
│ Any Action  │
│ (View/Click)│
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│ POST /analytics/track│
│ {                    │
│   store_id,          │
│   product_id,        │
│   event_type,        │
│   metadata           │
│ }                    │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ AnalyticsController │
└──────┬──────────────┘
       │ 1. Validate data
       │ 2. Add IP & User-Agent
       ▼
┌─────────────────────┐
│ AnalyticsEvent Model│
└──────┬──────────────┘
       │ 3. Save to database
       │ 4. Update counters
       ▼
┌─────────────────────┐
│ Update Store/Product│
│ view_count++        │
│ click_count++       │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ Analytics Dashboard │
│ • Charts            │
│ • Graphs            │
│ • Statistics        │
└─────────────────────┘
```

---

## 🗄️ Database Schema

```
┌─────────────────────────────────────────────────────────────┐
│                         stores                               │
├─────────────────────────────────────────────────────────────┤
│ id              BIGINT PRIMARY KEY AUTO_INCREMENT           │
│ name            VARCHAR(255) NOT NULL                       │
│ phone           VARCHAR(20) NOT NULL                        │
│ logo            VARCHAR(255) NULLABLE                       │
│ slug            VARCHAR(255) UNIQUE NOT NULL                │
│ is_active       BOOLEAN DEFAULT TRUE                        │
│ view_count      INTEGER DEFAULT 0                           │
│ created_at      TIMESTAMP                                   │
│ updated_at      TIMESTAMP                                   │
│ deleted_at      TIMESTAMP NULLABLE                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ 1:N
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        products                              │
├─────────────────────────────────────────────────────────────┤
│ id              BIGINT PRIMARY KEY AUTO_INCREMENT           │
│ store_id        BIGINT FOREIGN KEY → stores(id)             │
│ name            VARCHAR(255) NOT NULL                       │
│ price           DECIMAL(10,2) NOT NULL                      │
│ description     TEXT NULLABLE                               │
│ image           VARCHAR(255) NULLABLE                       │
│ is_active       BOOLEAN DEFAULT TRUE                        │
│ click_count     INTEGER DEFAULT 0                           │
│ created_at      TIMESTAMP                                   │
│ updated_at      TIMESTAMP                                   │
│ deleted_at      TIMESTAMP NULLABLE                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ 1:N
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    analytics_events                          │
├─────────────────────────────────────────────────────────────┤
│ id              BIGINT PRIMARY KEY AUTO_INCREMENT           │
│ store_id        BIGINT FOREIGN KEY → stores(id)             │
│ product_id      BIGINT FOREIGN KEY → products(id) NULLABLE  │
│ event_type      ENUM('store_view','product_click',          │
│                      'whatsapp_click')                       │
│ ip_address      VARCHAR(45) NULLABLE                        │
│ user_agent      VARCHAR(255) NULLABLE                       │
│ metadata        JSON NULLABLE                               │
│ created_at      TIMESTAMP                                   │
│ updated_at      TIMESTAMP                                   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                         admins                               │
├─────────────────────────────────────────────────────────────┤
│ id              BIGINT PRIMARY KEY AUTO_INCREMENT           │
│ name            VARCHAR(255) NOT NULL                       │
│ email           VARCHAR(255) UNIQUE NOT NULL                │
│ password        VARCHAR(255) NOT NULL                       │
│ remember_token  VARCHAR(100) NULLABLE                       │
│ created_at      TIMESTAMP                                   │
│ updated_at      TIMESTAMP                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔐 Authentication Flow

```
┌─────────────┐
│ Admin Login │
└──────┬──────┘
       │ POST /api/v1/admin/login
       │ {email, password}
       ▼
┌─────────────────┐
│ AuthController  │
└──────┬──────────┘
       │ 1. Validate credentials
       │ 2. Check against admins table
       ▼
┌─────────────────┐
│ JWT Auth        │
│ (tymon/jwt-auth)│
└──────┬──────────┘
       │ 3. Generate JWT token
       │ 4. Set expiry (60 min)
       ▼
┌─────────────────┐
│ Return Token    │
│ {               │
│   access_token, │
│   token_type,   │
│   expires_in,   │
│   user          │
│ }               │
└──────┬──────────┘
       │ 5. Store in localStorage
       ▼
┌─────────────────┐
│ Protected Routes│
│ Authorization:  │
│ Bearer {token}  │
└─────────────────┘
```

---

## 📁 File Storage Architecture

```
┌─────────────────┐
│ File Upload     │
│ (Image)         │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Validation      │
│ • Max 2MB       │
│ • JPG/PNG/GIF   │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Storage Driver  │
│ (Local/S3)      │
└──────┬──────────┘
       │
       ├─────────────────┐
       │                 │
       ▼                 ▼
┌─────────────┐   ┌─────────────┐
│ Local       │   │ AWS S3      │
│ storage/    │   │ Bucket      │
│ app/public/ │   │             │
│             │   │ • Scalable  │
│ • Dev       │   │ • CDN       │
│ • Testing   │   │ • Production│
└─────────────┘   └─────────────┘
       │                 │
       └────────┬────────┘
                │
                ▼
┌─────────────────────────┐
│ Public URL              │
│ /storage/logos/abc.jpg  │
│ or                      │
│ https://cdn.../abc.jpg  │
└─────────────────────────┘
```

---

## 🔄 State Management (Flutter)

```
┌─────────────────────────────────────────────────────────┐
│                    Provider Pattern                      │
└─────────────────────────────────────────────────────────┘

┌─────────────────┐
│ main.dart       │
│ MultiProvider   │
└──────┬──────────┘
       │
       ├──────────────────┬──────────────────┐
       │                  │                  │
       ▼                  ▼                  ▼
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│StoreProvider│   │ProductProvider│  │ThemeProvider│
│             │   │               │  │             │
│• currentStore│  │• products[]   │  │• isDark     │
│• isLoading  │   │• isLoading    │  │• toggle()   │
│• error      │   │• error        │  │             │
│             │   │               │  │             │
│Methods:     │   │Methods:       │  │             │
│• create()   │   │• load()       │  │             │
│• update()   │   │• add()        │  │             │
│• refresh()  │   │• update()     │  │             │
│• loadStats()│   │• delete()     │  │             │
└──────┬──────┘   └──────┬────────┘  └──────┬──────┘
       │                 │                  │
       └─────────────────┼──────────────────┘
                         │
                         ▼
                  ┌─────────────┐
                  │ UI Widgets  │
                  │ Consumer    │
                  │ Selector    │
                  └─────────────┘
```

---

## 🌐 API Layer Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    API Structure                         │
└─────────────────────────────────────────────────────────┘

Request Flow:
┌─────────────┐
│ HTTP Request│
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ Middleware      │
│ • CORS          │
│ • Throttle      │
│ • Auth (JWT)    │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Router          │
│ routes/api.php  │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Controller      │
│ • Validate      │
│ • Process       │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Model           │
│ • Query DB      │
│ • Relationships │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Response        │
│ JSON Format     │
│ {               │
│   success: bool,│
│   data: {},     │
│   message: ""   │
│ }               │
└─────────────────┘
```

---

## 🎨 Frontend Architecture (React)

```
┌─────────────────────────────────────────────────────────┐
│                  React Component Tree                    │
└─────────────────────────────────────────────────────────┘

                    ┌─────────┐
                    │   App   │
                    └────┬────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
         ▼               ▼               ▼
    ┌─────────┐    ┌─────────┐    ┌─────────┐
    │StorePage│    │NotFound │    │AdminApp │
    └────┬────┘    └─────────┘    └────┬────┘
         │                              │
         │                              │
    ┌────┴────┐                    ┌────┴────┐
    │         │                    │         │
    ▼         ▼                    ▼         ▼
┌────────┐ ┌────────┐        ┌────────┐ ┌────────┐
│Header  │ │Products│        │Sidebar │ │Dashboard│
└────────┘ └───┬────┘        └────────┘ └────────┘
               │
          ┌────┴────┐
          │         │
          ▼         ▼
     ┌────────┐ ┌────────┐
     │Product │ │WhatsApp│
     │Card    │ │Button  │
     └────────┘ └────────┘
```

---

## 🔄 Deployment Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  Production Setup                        │
└─────────────────────────────────────────────────────────┘

                    ┌─────────────┐
                    │   Users     │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │ Cloudflare  │
                    │ CDN + DDoS  │
                    └──────┬──────┘
                           │
         ┌─────────────────┼─────────────────┐
         │                 │                 │
         ▼                 ▼                 ▼
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│  Vercel     │   │  Vercel     │   │   VPS       │
│  Storefront │   │  Admin      │   │   Backend   │
│             │   │  Dashboard  │   │             │
│ React App   │   │  React App  │   │ Laravel API │
└─────────────┘   └─────────────┘   └──────┬──────┘
                                            │
                                            ▼
                                    ┌─────────────┐
                                    │   MySQL     │
                                    │  Database   │
                                    └─────────────┘
                                            │
                                            ▼
                                    ┌─────────────┐
                                    │   AWS S3    │
                                    │File Storage │
                                    └─────────────┘

Mobile Apps:
┌─────────────┐   ┌─────────────┐
│ Play Store  │   │  App Store  │
│  Android    │   │    iOS      │
└─────────────┘   └─────────────┘
```

---

## 📊 Scalability Strategy

```
Current (MVP):
┌──────────┐     ┌──────────┐
│ 1 Server │────▶│ 1 MySQL  │
└──────────┘     └──────────┘

Phase 1 (100+ stores):
┌──────────┐     ┌──────────┐     ┌──────────┐
│ 2 Servers│────▶│ 1 MySQL  │────▶│  Redis   │
│Load Bal. │     │ Master   │     │  Cache   │
└──────────┘     └──────────┘     └──────────┘

Phase 2 (1000+ stores):
┌──────────┐     ┌──────────┐     ┌──────────┐
│ N Servers│────▶│ MySQL    │────▶│  Redis   │
│Load Bal. │     │ Master   │     │ Cluster  │
└──────────┘     └────┬─────┘     └──────────┘
                      │
                      ▼
                 ┌──────────┐
                 │ MySQL    │
                 │ Replicas │
                 └──────────┘

Phase 3 (10000+ stores):
┌──────────┐     ┌──────────┐     ┌──────────┐
│ CDN      │     │ MySQL    │     │  Redis   │
│          │     │ Cluster  │     │ Cluster  │
└────┬─────┘     └──────────┘     └──────────┘
     │
     ▼
┌──────────┐     ┌──────────┐     ┌──────────┐
│ N Servers│     │ Queue    │     │Analytics │
│Auto Scale│     │ Workers  │     │ Service  │
└──────────┘     └──────────┘     └──────────┘
```

---

## 🔒 Security Layers

```
┌─────────────────────────────────────────────────────────┐
│                    Security Stack                        │
└─────────────────────────────────────────────────────────┘

Layer 1: Network
├─ Firewall (UFW)
├─ DDoS Protection (Cloudflare)
└─ SSL/TLS (Let's Encrypt)

Layer 2: Application
├─ CORS Configuration
├─ Rate Limiting
├─ Input Validation
└─ XSS Protection

Layer 3: Authentication
├─ JWT Tokens
├─ Password Hashing (bcrypt)
├─ Token Expiry
└─ Refresh Tokens

Layer 4: Data
├─ SQL Injection Protection (ORM)
├─ Encrypted Connections
├─ Secure File Upload
└─ Data Validation

Layer 5: Monitoring
├─ Error Tracking (Sentry)
├─ Access Logs
├─ Audit Trail
└─ Intrusion Detection
```

---

## 📈 Performance Optimization

```
Backend:
├─ OPcache (PHP)
├─ Query Optimization
├─ Database Indexing
├─ Response Caching
└─ Queue Jobs

Frontend:
├─ Code Splitting
├─ Lazy Loading
├─ Image Optimization
├─ Minification
└─ CDN

Mobile:
├─ Image Caching
├─ API Response Caching
├─ Efficient State Management
└─ Optimized Builds

Database:
├─ Proper Indexing
├─ Query Optimization
├─ Connection Pooling
└─ Regular Maintenance
```

---

This architecture is designed to be:
- ✅ Scalable
- ✅ Maintainable
- ✅ Secure
- ✅ Performant
- ✅ Cost-effective

**Ready for production deployment! 🚀**
