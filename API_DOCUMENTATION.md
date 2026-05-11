# 📡 LinkKart API Documentation

Base URL: `http://localhost:8000/api/v1`

## 🔐 Authentication

Admin endpoints require JWT authentication. Include the token in the Authorization header:

```
Authorization: Bearer {token}
```

---

## 📍 Endpoints

### Health Check

#### GET `/health`
Check if the API is running.

**Response:**
```json
{
  "success": true,
  "message": "LinkKart API is running",
  "version": "1.0.0",
  "timestamp": "2024-01-01T00:00:00.000000Z"
}
```

---

## 🏪 Store Endpoints

### Get Store by ID or Slug

#### GET `/stores/{identifier}`
Get store details by ID or slug.

**Parameters:**
- `identifier` (path) - Store ID or slug

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "My Fashion Store",
    "phone": "+919876543210",
    "logo": "/storage/logos/abc123.jpg",
    "slug": "my-fashion-store-abc123",
    "is_active": true,
    "view_count": 150,
    "store_url": "http://localhost:3001/store/my-fashion-store-abc123",
    "product_count": 5,
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z",
    "products": [...]
  }
}
```

### Create Store

#### POST `/seller/stores`
Create a new store.

**Request Body (multipart/form-data):**
- `name` (required) - Store name
- `phone` (required) - WhatsApp number
- `logo` (optional) - Logo image file

**Response:**
```json
{
  "success": true,
  "message": "Store created successfully",
  "data": {
    "id": 1,
    "name": "My Fashion Store",
    "phone": "+919876543210",
    "logo": "/storage/logos/abc123.jpg",
    "slug": "my-fashion-store-abc123",
    "is_active": true,
    "view_count": 0,
    "store_url": "http://localhost:3001/store/my-fashion-store-abc123",
    "product_count": 0,
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

### Update Store

#### PUT `/seller/stores/{id}`
Update store details.

**Request Body (multipart/form-data):**
- `name` (optional) - Store name
- `phone` (optional) - WhatsApp number
- `logo` (optional) - Logo image file
- `is_active` (optional) - Active status

**Response:**
```json
{
  "success": true,
  "message": "Store updated successfully",
  "data": {...}
}
```

### Get Store Statistics

#### GET `/seller/stores/{id}/statistics`
Get detailed statistics for a store.

**Response:**
```json
{
  "success": true,
  "data": {
    "total_products": 10,
    "active_products": 8,
    "total_views": 250,
    "total_clicks": 45,
    "recent_events": [...]
  }
}
```

---

## 📦 Product Endpoints

### Get Products by Store

#### GET `/stores/{storeSlug}/products`
Get all active products for a store.

**Response:**
```json
{
  "success": true,
  "data": {
    "store": {...},
    "products": [
      {
        "id": 1,
        "store_id": 1,
        "name": "Blue T-Shirt",
        "price": "499.00",
        "description": "Comfortable cotton t-shirt",
        "image": "/storage/products/xyz789.jpg",
        "is_active": true,
        "click_count": 15,
        "formatted_price": "₹499.00",
        "whatsapp_url": "https://wa.me/919876543210?text=...",
        "created_at": "2024-01-01T00:00:00.000000Z",
        "updated_at": "2024-01-01T00:00:00.000000Z"
      }
    ]
  }
}
```

### Create Product

#### POST `/seller/products`
Create a new product.

**Request Body (multipart/form-data):**
- `store_id` (required) - Store ID
- `name` (required) - Product name
- `price` (required) - Product price
- `description` (optional) - Product description
- `image` (optional) - Product image file

**Response:**
```json
{
  "success": true,
  "message": "Product created successfully",
  "data": {
    "id": 1,
    "store_id": 1,
    "name": "Blue T-Shirt",
    "price": "499.00",
    "description": "Comfortable cotton t-shirt",
    "image": "/storage/products/xyz789.jpg",
    "is_active": true,
    "click_count": 0,
    "formatted_price": "₹499.00",
    "whatsapp_url": "https://wa.me/919876543210?text=...",
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

### Update Product

#### PUT `/seller/products/{id}`
Update product details.

**Request Body (multipart/form-data):**
- `name` (optional) - Product name
- `price` (optional) - Product price
- `description` (optional) - Product description
- `image` (optional) - Product image file
- `is_active` (optional) - Active status

**Response:**
```json
{
  "success": true,
  "message": "Product updated successfully",
  "data": {...}
}
```

### Delete Product

#### DELETE `/seller/products/{id}`
Delete a product.

**Response:**
```json
{
  "success": true,
  "message": "Product deleted successfully"
}
```

---

## 📊 Analytics Endpoints

### Track Event

#### POST `/analytics/track`
Track an analytics event.

**Request Body (JSON):**
```json
{
  "store_id": 1,
  "product_id": 1,
  "event_type": "product_click",
  "metadata": {}
}
```

**Event Types:**
- `store_view` - Store page viewed
- `product_click` - Product clicked
- `whatsapp_click` - WhatsApp button clicked

**Response:**
```json
{
  "success": true,
  "message": "Event tracked successfully",
  "data": {
    "id": 1,
    "store_id": 1,
    "product_id": 1,
    "event_type": "product_click",
    "ip_address": "192.168.1.1",
    "user_agent": "Mozilla/5.0...",
    "metadata": {},
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

### Get Store Analytics

#### GET `/admin/analytics/stores/{storeId}` 🔐
Get detailed analytics for a specific store.

**Response:**
```json
{
  "success": true,
  "data": {
    "overview": {
      "total_views": 250,
      "total_products": 10,
      "total_clicks": 45,
      "active_products": 8
    },
    "events_by_type": [
      {
        "event_type": "store_view",
        "count": 150
      },
      {
        "event_type": "product_click",
        "count": 75
      },
      {
        "event_type": "whatsapp_click",
        "count": 25
      }
    ],
    "daily_views": [
      {
        "date": "2024-01-01",
        "count": 10
      }
    ],
    "top_products": [...],
    "recent_events": [...]
  }
}
```

### Get Global Analytics

#### GET `/admin/analytics/global` 🔐
Get platform-wide analytics.

**Response:**
```json
{
  "success": true,
  "data": {
    "overview": {
      "total_stores": 100,
      "active_stores": 85,
      "total_products": 500,
      "total_views": 10000,
      "total_clicks": 2000
    },
    "stores_by_date": [...],
    "products_by_date": [...],
    "top_stores": [...],
    "recent_stores": [...]
  }
}
```

---

## 🔐 Admin Authentication Endpoints

### Admin Login

#### POST `/admin/login`
Authenticate admin user.

**Request Body (JSON):**
```json
{
  "email": "admin@linkkart.com",
  "password": "password"
}
```

**Response:**
```json
{
  "success": true,
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "bearer",
  "expires_in": 3600,
  "user": {
    "id": 1,
    "name": "Admin",
    "email": "admin@linkkart.com",
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

### Admin Register

#### POST `/admin/register`
Register a new admin user.

**Request Body (JSON):**
```json
{
  "name": "Admin Name",
  "email": "admin@example.com",
  "password": "password",
  "password_confirmation": "password"
}
```

**Response:**
```json
{
  "success": true,
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "bearer",
  "expires_in": 3600,
  "user": {...}
}
```

### Get Current Admin

#### GET `/admin/me` 🔐
Get authenticated admin details.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Admin",
    "email": "admin@linkkart.com",
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

### Admin Logout

#### POST `/admin/logout` 🔐
Logout admin user.

**Response:**
```json
{
  "success": true,
  "message": "Successfully logged out"
}
```

### Refresh Token

#### POST `/admin/refresh` 🔐
Refresh JWT token.

**Response:**
```json
{
  "success": true,
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "bearer",
  "expires_in": 3600,
  "user": {...}
}
```

---

## 🛠️ Admin Store Management

### List All Stores

#### GET `/admin/stores` 🔐
Get paginated list of all stores.

**Query Parameters:**
- `per_page` (optional) - Items per page (default: 15)

**Response:**
```json
{
  "success": true,
  "data": {
    "current_page": 1,
    "data": [...],
    "first_page_url": "...",
    "from": 1,
    "last_page": 5,
    "last_page_url": "...",
    "next_page_url": "...",
    "path": "...",
    "per_page": 15,
    "prev_page_url": null,
    "to": 15,
    "total": 75
  }
}
```

### Delete Store

#### DELETE `/admin/stores/{id}` 🔐
Delete a store (soft delete).

**Response:**
```json
{
  "success": true,
  "message": "Store deleted successfully"
}
```

---

## ❌ Error Responses

### Validation Error (422)
```json
{
  "success": false,
  "errors": {
    "name": ["The name field is required."],
    "phone": ["The phone field is required."]
  }
}
```

### Unauthorized (401)
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

### Not Found (404)
```json
{
  "success": false,
  "message": "Resource not found"
}
```

### Server Error (500)
```json
{
  "success": false,
  "message": "Internal server error"
}
```

---

## 📝 Notes

1. All timestamps are in ISO 8601 format
2. File uploads must be sent as `multipart/form-data`
3. Maximum file size: 2MB
4. Supported image formats: JPG, JPEG, PNG, GIF
5. Phone numbers should include country code
6. Prices are stored with 2 decimal places
7. JWT tokens expire after 60 minutes
8. Refresh tokens expire after 2 weeks

---

## 🧪 Testing with cURL

### Create a Store
```bash
curl -X POST http://localhost:8000/api/v1/seller/stores \
  -F "name=My Test Store" \
  -F "phone=+919876543210" \
  -F "logo=@/path/to/logo.jpg"
```

### Get Store
```bash
curl http://localhost:8000/api/v1/stores/my-test-store-abc123
```

### Create Product
```bash
curl -X POST http://localhost:8000/api/v1/seller/products \
  -F "store_id=1" \
  -F "name=Test Product" \
  -F "price=999" \
  -F "description=Test description" \
  -F "image=@/path/to/product.jpg"
```

### Admin Login
```bash
curl -X POST http://localhost:8000/api/v1/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@linkkart.com","password":"password"}'
```

### Get Analytics (with auth)
```bash
curl http://localhost:8000/api/v1/admin/analytics/global \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 📚 Additional Resources

- [Postman Collection](./postman_collection.json)
- [Setup Guide](./SETUP_GUIDE.md)
- [Project Structure](./PROJECT_STRUCTURE.md)

---

**API Version:** 1.0.0  
**Last Updated:** 2024-01-01
