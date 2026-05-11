# 🚀 Quick Run Guide - LinkKart

## Prerequisites Check

Before running, make sure you have:
- ✅ PHP 8.1+ installed
- ✅ Composer installed
- ✅ MySQL 8.0+ installed and running
- ✅ Node.js 18+ installed
- ✅ npm installed

---

## 🔧 Backend Setup & Run

### Option 1: Fresh Laravel Installation (Recommended)

Since the backend needs a complete Laravel installation, let's set it up properly:

```bash
# 1. Navigate to project root
cd linkkart

# 2. Remove the incomplete backend folder
rm -rf backend

# 3. Create a fresh Laravel project
composer create-project laravel/laravel backend

# 4. Navigate to backend
cd backend

# 5. Install additional dependencies
composer require tymon/jwt-auth
composer require intervention/image

# 6. Copy our configuration files
# (Copy the files from the original backend folder we created)

# 7. Set up environment
cp .env.example .env

# 8. Generate application key
php artisan key:generate

# 9. Configure database in .env
# Edit .env file and set:
DB_DATABASE=linkkart
DB_USERNAME=root
DB_PASSWORD=your_password

# 10. Create database
mysql -u root -p
CREATE DATABASE linkkart;
exit;

# 11. Run migrations
php artisan migrate

# 12. Seed database
php artisan db:seed

# 13. Create storage link
php artisan storage:link

# 14. Start the server
php artisan serve
```

### Option 2: Use Existing Backend (Quick Fix)

If you want to use the backend structure we created:

```bash
# 1. Navigate to backend
cd backend

# 2. Create missing Laravel files
# We need to create a complete Laravel structure

# 3. For now, let's use a simple PHP server
php -S localhost:8000 -t public
```

---

## 🌐 Storefront Setup & Run

The storefront is ready to run:

```bash
# 1. Open a new terminal

# 2. Navigate to storefront
cd linkkart/storefront

# 3. Install dependencies
npm install

# 4. Create .env file
echo "REACT_APP_API_URL=http://localhost:8000/api/v1" > .env
echo "REACT_APP_BACKEND_URL=http://localhost:8000" >> .env

# 5. Start the development server
npm start
```

The storefront will open at: **http://localhost:3001**

---

## 🎯 Simplified Quick Start (Recommended)

Since setting up a complete Laravel backend requires many steps, here's the **fastest way** to get started:

### Step 1: Install Laravel Backend Properly

```bash
# Create a fresh Laravel project
composer create-project laravel/laravel linkkart-backend

# Navigate to it
cd linkkart-backend

# Install JWT
composer require tymon/jwt-auth

# Copy our migrations and models
# (You'll need to copy the files we created)

# Set up and run
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

### Step 2: Run Storefront

```bash
# In a new terminal
cd linkkart/storefront
npm install
npm start
```

---

## 🐛 Troubleshooting

### Backend Issues

**Issue: "Could not open input file: artisan"**
- Solution: You need a complete Laravel installation
- Run: `composer create-project laravel/laravel backend`

**Issue: "Database connection failed"**
- Check MySQL is running
- Verify credentials in `.env`
- Create database: `CREATE DATABASE linkkart;`

**Issue: "Class not found"**
- Run: `composer dump-autoload`
- Run: `php artisan config:clear`

### Storefront Issues

**Issue: "npm: command not found"**
- Install Node.js from: https://nodejs.org/

**Issue: "Port 3001 already in use"**
- Kill the process: `npx kill-port 3001`
- Or change port: `PORT=3002 npm start`

**Issue: "API connection failed"**
- Verify backend is running on port 8000
- Check `.env` file has correct API URL

---

## ✅ Verification

Once both are running:

1. **Backend**: Visit http://localhost:8000/api/health
   - Should return: `{"success":true,"message":"LinkKart API is running"}`

2. **Storefront**: Visit http://localhost:3001
   - Should show the LinkKart storefront

---

## 🎯 Alternative: Docker Setup (Easiest)

If you have Docker installed, this is the easiest way:

```bash
# Create docker-compose.yml in project root
# Then run:
docker-compose up -d
```

---

## 📞 Need Help?

If you encounter issues:

1. **Check Prerequisites**: Ensure all required software is installed
2. **Check Logs**: Look at terminal output for error messages
3. **Check Ports**: Make sure ports 8000 and 3001 are available
4. **Check Documentation**: See SETUP_GUIDE.md for detailed instructions

---

## 🚀 Next Steps

Once both systems are running:

1. Test the API: `curl http://localhost:8000/api/health`
2. Open storefront: http://localhost:3001
3. Create a test store using the mobile app or API
4. View the store on the storefront

---

**For complete setup instructions, see: [SETUP_GUIDE.md](./SETUP_GUIDE.md)**
