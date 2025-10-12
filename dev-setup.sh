#!/bin/bash

# KH POS Lite Development Setup (Without Docker)

set -e

echo "🚀 Setting up KH POS Lite for local development..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if required tools are installed
echo -e "${BLUE}🔍 Checking required tools...${NC}"

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed. Please install Flutter first.${NC}"
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check PHP
if ! command -v php &> /dev/null; then
    echo -e "${RED}❌ PHP is not installed. Please install PHP 8.2 or higher.${NC}"
    exit 1
fi

# Check Composer
if ! command -v composer &> /dev/null; then
    echo -e "${RED}❌ Composer is not installed. Please install Composer first.${NC}"
    echo "Visit: https://getcomposer.org/download/"
    exit 1
fi

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js first.${NC}"
    echo "Visit: https://nodejs.org/"
    exit 1
fi

echo -e "${GREEN}✅ All required tools are available${NC}"

# Setup Flutter App
echo -e "${YELLOW}📱 Setting up Flutter app...${NC}"
cd apps
flutter clean
flutter pub get
cd ..

# Setup Laravel API
echo -e "${YELLOW}🔧 Setting up Laravel API...${NC}"
cd services/api

# Install PHP dependencies
composer install

# Install Node dependencies
npm install

# Create .env if it doesn't exist
if [ ! -f .env ]; then
    cp .env.example .env
    php artisan key:generate
fi

# Build assets
npm run build

cd ../..

echo -e "${GREEN}🎉 Setup complete!${NC}"
echo ""
echo -e "${YELLOW}🚀 To run the application:${NC}"
echo ""
echo -e "${BLUE}📱 Flutter Web (Terminal 1):${NC}"
echo "  cd apps"
echo "  flutter run -d web-server --web-port 3000"
echo ""
echo -e "${BLUE}🔧 Laravel API (Terminal 2):${NC}"
echo "  cd services/api"
echo "  php artisan serve --port=8080"
echo ""
echo -e "${BLUE}💾 Database (if using SQLite):${NC}"
echo "  cd services/api"
echo "  php artisan migrate"
echo "  php artisan db:seed"
echo ""
echo -e "${GREEN}📱 Flutter Web App:${NC} http://localhost:3000"
echo -e "${GREEN}🔧 Laravel API:${NC} http://localhost:8080"
echo ""
echo -e "${YELLOW}📝 Note: Make sure to configure your database in services/api/.env${NC}"