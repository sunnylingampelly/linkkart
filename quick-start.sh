#!/bin/bash

# LinkKart Quick Start Script
# This script helps you set up the entire LinkKart platform

echo "🛍️  LinkKart - Quick Start Setup"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check prerequisites
echo "Checking prerequisites..."
echo ""

# Check PHP
if command -v php &> /dev/null; then
    PHP_VERSION=$(php -v | head -n 1 | cut -d " " -f 2 | cut -d "." -f 1,2)
    print_success "PHP $PHP_VERSION installed"
else
    print_error "PHP is not installed. Please install PHP 8.1 or higher."
    exit 1
fi

# Check Composer
if command -v composer &> /dev/null; then
    print_success "Composer installed"
else
    print_error "Composer is not installed. Please install Composer."
    exit 1
fi

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v)
    print_success "Node.js $NODE_VERSION installed"
else
    print_error "Node.js is not installed. Please install Node.js 18 or higher."
    exit 1
fi

# Check MySQL
if command -v mysql &> /dev/null; then
    print_success "MySQL installed"
else
    print_error "MySQL is not installed. Please install MySQL 8.0 or higher."
    exit 1
fi

# Check Flutter
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    print_success "Flutter installed"
else
    print_info "Flutter is not installed. Mobile app setup will be skipped."
fi

echo ""
echo "=================================="
echo "Setting up Backend (Laravel)..."
echo "=================================="
echo ""

cd backend

# Install dependencies
print_info "Installing PHP dependencies..."
composer install --no-interaction

# Copy environment file
if [ ! -f .env ]; then
    print_info "Creating .env file..."
    cp .env.example .env
    print_success ".env file created"
fi

# Generate application key
print_info "Generating application key..."
php artisan key:generate

# Create database
print_info "Please enter your MySQL credentials:"
read -p "MySQL Username (default: root): " MYSQL_USER
MYSQL_USER=${MYSQL_USER:-root}

read -sp "MySQL Password: " MYSQL_PASS
echo ""

# Update .env file
sed -i "s/DB_USERNAME=.*/DB_USERNAME=$MYSQL_USER/" .env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$MYSQL_PASS/" .env

# Create database
print_info "Creating database..."
mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" -e "CREATE DATABASE IF NOT EXISTS linkkart;"

if [ $? -eq 0 ]; then
    print_success "Database created"
else
    print_error "Failed to create database"
fi

# Run migrations
print_info "Running migrations..."
php artisan migrate --force

# Seed database
print_info "Seeding database..."
php artisan db:seed --force

# Create storage link
print_info "Creating storage link..."
php artisan storage:link

print_success "Backend setup complete!"
echo ""
print_info "Default admin credentials:"
echo "  Email: admin@linkkart.com"
echo "  Password: password"
echo ""

cd ..

echo "=================================="
echo "Setting up Storefront (React)..."
echo "=================================="
echo ""

cd storefront

# Install dependencies
print_info "Installing npm dependencies..."
npm install

# Create .env file
if [ ! -f .env ]; then
    print_info "Creating .env file..."
    echo "REACT_APP_API_URL=http://localhost:8000/api/v1" > .env
    echo "REACT_APP_BACKEND_URL=http://localhost:8000" >> .env
    print_success ".env file created"
fi

print_success "Storefront setup complete!"
echo ""

cd ..

echo "=================================="
echo "Setting up Admin Dashboard (React)..."
echo "=================================="
echo ""

cd admin-dashboard

# Install dependencies
print_info "Installing npm dependencies..."
npm install

# Create .env file
if [ ! -f .env ]; then
    print_info "Creating .env file..."
    echo "REACT_APP_API_URL=http://localhost:8000/api/v1" > .env
    print_success ".env file created"
fi

print_success "Admin Dashboard setup complete!"
echo ""

cd ..

# Flutter setup (if available)
if command -v flutter &> /dev/null; then
    echo "=================================="
    echo "Setting up Mobile App (Flutter)..."
    echo "=================================="
    echo ""

    cd mobile-app

    print_info "Getting Flutter dependencies..."
    flutter pub get

    print_success "Mobile App setup complete!"
    echo ""

    cd ..
fi

echo ""
echo "🎉 Setup Complete!"
echo "=================================="
echo ""
echo "To start the application:"
echo ""
echo "1. Backend (Terminal 1):"
echo "   cd backend"
echo "   php artisan serve"
echo ""
echo "2. Storefront (Terminal 2):"
echo "   cd storefront"
echo "   npm start"
echo ""
echo "3. Admin Dashboard (Terminal 3):"
echo "   cd admin-dashboard"
echo "   npm start"
echo ""

if command -v flutter &> /dev/null; then
    echo "4. Mobile App (Terminal 4):"
    echo "   cd mobile-app"
    echo "   flutter run"
    echo ""
fi

echo "Access URLs:"
echo "  Backend API: http://localhost:8000"
echo "  Admin Dashboard: http://localhost:3000"
echo "  Storefront: http://localhost:3001"
echo ""
echo "For detailed setup instructions, see SETUP_GUIDE.md"
echo ""
