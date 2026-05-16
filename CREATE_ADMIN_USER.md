# 🔐 Admin Credentials for LinkKart

## Default Admin Credentials

Based on the database setup, here are the default admin credentials:

### Admin Dashboard Login

**Email:** `admin@linkkart.com`  
**Password:** `password`

**Login URL (Local):** http://localhost:3000  
**Login URL (Production):** https://admin.linkkart.shop

---

## ⚠️ IMPORTANT: Change Password After First Login!

For security reasons, you should change the default password immediately after your first login.

---

## 🔧 How to Create Additional Admin Users

### Method 1: Using PHP Script (Recommended)

Create a file `backend/create_admin.php`:

```php
<?php
require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Admin;
use Illuminate\Support\Facades\Hash;

// Create new admin
$admin = Admin::create([
    'name' => 'Your Name',
    'email' => 'your@email.com',
    'password' => Hash::make('your_password'),
]);

echo "Admin created successfully!\n";
echo "Email: " . $admin->email . "\n";
echo "Password: your_password\n";
```

**Run it:**
```bash
cd backend
php create_admin.php
```

---

### Method 2: Using MySQL Command

```sql
-- Connect to MySQL
mysql -u root -p

-- Use linkkart database
USE linkkart;

-- Create admin user
-- Password hash for 'password' is: $2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi

INSERT INTO admins (name, email, password, created_at, updated_at) 
VALUES (
    'Your Name',
    'your@email.com',
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    NOW(),
    NOW()
);

-- Verify admin was created
SELECT * FROM admins;
```

**Note:** The password hash above is for the password `password`. You should change it after login.

---

### Method 3: Using Laravel Artisan Command

Create a file `backend/app/Console/Commands/CreateAdmin.php`:

```php
<?php

namespace App\Console\Commands;

use App\Models\Admin;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;

class CreateAdmin extends Command
{
    protected $signature = 'admin:create {name} {email} {password}';
    protected $description = 'Create a new admin user';

    public function handle()
    {
        $admin = Admin::create([
            'name' => $this->argument('name'),
            'email' => $this->argument('email'),
            'password' => Hash::make($this->argument('password')),
        ]);

        $this->info('Admin created successfully!');
        $this->info('Email: ' . $admin->email);
        
        return 0;
    }
}
```

**Run it:**
```bash
cd backend
php artisan admin:create "Your Name" "your@email.com" "your_password"
```

---

### Method 4: Using API Registration Endpoint

**Endpoint:** `POST /api/v1/admin/register`

**Request:**
```json
{
    "name": "Your Name",
    "email": "your@email.com",
    "password": "your_password",
    "password_confirmation": "your_password"
}
```

**Using curl:**
```bash
curl -X POST http://localhost:8000/api/v1/admin/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Your Name",
    "email": "your@email.com",
    "password": "your_password",
    "password_confirmation": "your_password"
  }'
```

---

## 🔐 Generate Password Hash

If you need to generate a password hash manually:

### Using PHP:
```php
<?php
echo password_hash('your_password', PASSWORD_BCRYPT);
```

### Using Laravel Tinker:
```bash
cd backend
php artisan tinker
```

Then in tinker:
```php
Hash::make('your_password')
```

---

## 📝 Admin API Endpoints

### Login
```
POST /api/v1/admin/login
Content-Type: application/json

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
    "expires_in": 86400,
    "user": {
        "id": 1,
        "name": "Admin",
        "email": "admin@linkkart.com"
    }
}
```

### Get Current Admin
```
GET /api/v1/admin/me
Authorization: Bearer YOUR_TOKEN
```

### Logout
```
POST /api/v1/admin/logout
Authorization: Bearer YOUR_TOKEN
```

### Refresh Token
```
POST /api/v1/admin/refresh
Authorization: Bearer YOUR_TOKEN
```

---

## 🧪 Test Admin Login

### Using curl:
```bash
curl -X POST http://localhost:8000/api/v1/admin/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@linkkart.com",
    "password": "password"
  }'
```

### Using Postman:
1. Create new POST request
2. URL: `http://localhost:8000/api/v1/admin/login`
3. Headers: `Content-Type: application/json`
4. Body (raw JSON):
```json
{
    "email": "admin@linkkart.com",
    "password": "password"
}
```

---

## 🔒 Security Best Practices

### 1. Change Default Password
```sql
-- Update admin password
UPDATE admins 
SET password = '$2y$10$YOUR_NEW_PASSWORD_HASH' 
WHERE email = 'admin@linkkart.com';
```

### 2. Use Strong Passwords
- Minimum 12 characters
- Mix of uppercase, lowercase, numbers, symbols
- Don't use common words

### 3. Enable Two-Factor Authentication (Future Enhancement)
Consider adding 2FA for additional security.

### 4. Limit Login Attempts
Implement rate limiting on login endpoint.

### 5. Use HTTPS in Production
Always use HTTPS for admin panel in production.

---

## 📊 Check Existing Admins

### Using MySQL:
```sql
SELECT id, name, email, created_at FROM admins;
```

### Using Laravel Tinker:
```bash
cd backend
php artisan tinker
```

Then:
```php
Admin::all();
```

---

## 🆘 Troubleshooting

### "Invalid credentials" error
- Check email is correct
- Check password is correct
- Verify admin exists in database
- Check password hash is valid

### "Admin table doesn't exist"
Run the database setup:
```bash
mysql -u root -p linkkart < database_setup.sql
```

### "JWT token error"
Generate JWT secret:
```bash
cd backend
php artisan jwt:secret
```

### Can't login to admin dashboard
1. Check backend API is running
2. Verify API URL in admin dashboard config
3. Check browser console for errors
4. Test API endpoint directly with curl

---

## 📋 Quick Reference

**Default Credentials:**
- Email: `admin@linkkart.com`
- Password: `password`

**Login URLs:**
- Local: `http://localhost:3000`
- Production: `https://admin.linkkart.shop`

**API Endpoint:**
- `POST /api/v1/admin/login`

**Database Table:**
- Table: `admins`
- Fields: `id`, `name`, `email`, `password`, `created_at`, `updated_at`

---

## 🎯 After First Login

1. **Change Password** - Use a strong, unique password
2. **Update Email** - Use your actual email address
3. **Create Additional Admins** - If needed for your team
4. **Test All Features** - Ensure everything works
5. **Set Up Backups** - Regular database backups
6. **Monitor Access** - Keep track of admin logins

---

**Remember: Always change default credentials in production! 🔒**
