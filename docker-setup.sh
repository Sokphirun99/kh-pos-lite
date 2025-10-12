#!/bin/bash

# KH POS Lite Docker Setup and Run Script

set -e

echo "🚀 Setting up KH POS Lite with Docker..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Create .env file for Laravel if it doesn't exist
if [ ! -f services/api/.env ]; then
    echo -e "${YELLOW}📝 Creating Laravel .env file...${NC}"
    cp services/api/.env.example services/api/.env 2>/dev/null || echo "
APP_NAME=KH_POS_API
APP_ENV=production
APP_KEY=base64:$(openssl rand -base64 32)
APP_DEBUG=false
APP_URL=http://localhost:8080

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=db
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

REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS=\"hello@example.com\"
MAIL_FROM_NAME=\"\${APP_NAME}\"
" > services/api/.env
fi

echo -e "${YELLOW}🔧 Fixing Flutter dependencies...${NC}"
cd apps
flutter pub get
cd ..

echo -e "${YELLOW}🐳 Building and starting containers...${NC}"
$DOCKER_COMPOSE up --build -d

echo -e "${YELLOW}⏳ Waiting for services to be ready...${NC}"
sleep 10

echo -e "${YELLOW}🔧 Running Laravel setup...${NC}"
$DOCKER_COMPOSE exec api php artisan key:generate --force
$DOCKER_COMPOSE exec api php artisan migrate --force
$DOCKER_COMPOSE exec api php artisan config:cache
$DOCKER_COMPOSE exec api php artisan route:cache

echo -e "${GREEN}🎉 Setup complete!${NC}"
echo ""
echo -e "${GREEN}📱 Flutter Web App:${NC} http://localhost:3000"
echo -e "${GREEN}🔧 Laravel API:${NC} http://localhost:8080"
echo -e "${GREEN}💾 MySQL Database:${NC} localhost:3306"
echo -e "${GREEN}📊 Redis:${NC} localhost:6379"
echo ""
echo -e "${YELLOW}🛠️  Useful commands:${NC}"
echo "  View logs: $DOCKER_COMPOSE logs -f"
echo "  Stop services: $DOCKER_COMPOSE down"
echo "  Restart services: $DOCKER_COMPOSE restart"
echo "  Enter API container: $DOCKER_COMPOSE exec api bash"
echo ""
echo -e "${GREEN}✨ Happy coding!${NC}"