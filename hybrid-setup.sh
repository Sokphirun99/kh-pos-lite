#!/bin/bash

# KH POS Lite Hybrid Setup (Docker for services, local for apps)

set -e

echo "🚀 Setting up KH POS Lite with Docker services and local development..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    if ! docker compose version &> /dev/null; then
        echo -e "${RED}❌ Docker Compose is not available.${NC}"
        exit 1
    fi
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

echo -e "${GREEN}✅ Docker is running${NC}"

# Start Docker services (MySQL, Redis, PhpMyAdmin)
echo -e "${YELLOW}🐳 Starting Docker services...${NC}"
$DOCKER_COMPOSE -f docker-compose.simple.yml up -d

echo -e "${YELLOW}⏳ Waiting for database to be ready...${NC}"
sleep 10

# Setup Flutter App
echo -e "${YELLOW}📱 Setting up Flutter app...${NC}"
cd apps
flutter clean
flutter pub get
cd ..

# Setup Laravel API
echo -e "${YELLOW}🔧 Setting up Laravel API...${NC}"
cd services/api

# Install PHP dependencies if composer.json exists
if [ -f composer.json ]; then
    composer install
fi

# Install Node dependencies if package.json exists
if [ -f package.json ]; then
    npm install
fi

# Update .env for Docker database
if [ -f .env ]; then
    # Update database configuration for Docker
    sed -i '' 's/DB_HOST=.*/DB_HOST=127.0.0.1/' .env
    sed -i '' 's/DB_DATABASE=.*/DB_DATABASE=kh_pos_lite/' .env
    sed -i '' 's/DB_USERNAME=.*/DB_USERNAME=pos_user/' .env
    sed -i '' 's/DB_PASSWORD=.*/DB_PASSWORD=pos_password/' .env
    sed -i '' 's/REDIS_HOST=.*/REDIS_HOST=127.0.0.1/' .env
else
    echo -e "${YELLOW}📝 Creating .env file...${NC}"
    cat > .env << EOF
APP_NAME=KH_POS_API
APP_ENV=local
APP_KEY=$(php artisan key:generate --show)
APP_DEBUG=true
APP_URL=http://localhost:8080

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=kh_pos_lite
DB_USERNAME=pos_user
DB_PASSWORD=pos_password

BROADCAST_DRIVER=log
CACHE_DRIVER=redis
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=redis
SESSION_LIFETIME=120

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
EOF
fi

# Run migrations
php artisan migrate --force

# Build assets if npm is available
if [ -f package.json ]; then
    npm run build
fi

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
echo -e "${GREEN}🌐 Access URLs:${NC}"
echo -e "${GREEN}📱 Flutter Web App:${NC} http://localhost:3000"
echo -e "${GREEN}🔧 Laravel API:${NC} http://localhost:8080"
echo -e "${GREEN}💾 Database (phpMyAdmin):${NC} http://localhost:8081"
echo -e "${GREEN}🔍 MySQL:${NC} localhost:3306 (user: pos_user, password: pos_password)"
echo -e "${GREEN}📊 Redis:${NC} localhost:6379"
echo ""
echo -e "${YELLOW}🛠️  Useful commands:${NC}"
echo "  Stop Docker services: $DOCKER_COMPOSE -f docker-compose.simple.yml down"
echo "  View Docker logs: $DOCKER_COMPOSE -f docker-compose.simple.yml logs -f"
echo "  Access database: mysql -h 127.0.0.1 -u pos_user -p kh_pos_lite"
echo ""
echo -e "${GREEN}✨ Happy coding!${NC}"