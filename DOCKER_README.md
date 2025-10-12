# KH POS Lite - Docker Setup

This guide will help you run the KH POS Lite application using Docker.

## 🏗️ Architecture

The application consists of:
- **Flutter Web App** (Frontend) - Port 3000
- **Laravel API** (Backend) - Port 8080
- **MySQL Database** - Port 3306
- **Redis Cache** - Port 6379

## 🚀 Quick Start

### Prerequisites
- Docker Desktop installed and running
- Git (to clone the repository)

### 1. Fix Flutter Dependencies
First, resolve the dependency conflict by running:
```bash
cd apps
flutter pub get
```

### 2. Run with Docker
Choose one of the following methods:

#### Option A: Automated Setup (Recommended)
```bash
./docker-setup.sh
```

#### Option B: Manual Setup
```bash
# Build and start all services
docker-compose up --build -d

# Run Laravel setup
docker-compose exec api php artisan key:generate --force
docker-compose exec api php artisan migrate --force
```

#### Option C: Development Mode
For development with hot reload and debugging:
```bash
docker-compose -f docker-compose.dev.yml up --build -d
```

### 3. Access the Application
- **Flutter Web App**: http://localhost:3000
- **Laravel API**: http://localhost:8080
- **API Documentation**: http://localhost:8080/api/documentation (if available)

## 🛠️ Development Commands

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f api
docker-compose logs -f app
```

### Access Containers
```bash
# Laravel API container
docker-compose exec api bash

# Flutter app container
docker-compose exec app sh
```

### Database Access
```bash
# Connect to MySQL
docker-compose exec db mysql -u pos_user -p kh_pos_lite
# Password: pos_password
```

### Laravel Artisan Commands
```bash
# Run migrations
docker-compose exec api php artisan migrate

# Seed database
docker-compose exec api php artisan db:seed

# Clear cache
docker-compose exec api php artisan cache:clear
docker-compose exec api php artisan config:clear
docker-compose exec api php artisan route:clear
```

### Flutter Commands
```bash
# For development, you might want to run Flutter outside Docker
cd apps
flutter run -d web-server --web-port 3000
```

## 🔧 Configuration

### Environment Variables
Create/modify `services/api/.env` for Laravel configuration:
```env
APP_NAME=KH_POS_API
APP_ENV=production
APP_DEBUG=false
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=kh_pos_lite
DB_USERNAME=pos_user
DB_PASSWORD=pos_password
REDIS_HOST=redis
```

### Database Configuration
Default credentials:
- Database: `kh_pos_lite`
- Username: `pos_user`
- Password: `pos_password`
- Root Password: `root_password`

## 📁 Docker Files Overview

- `docker-compose.yml` - Production setup
- `docker-compose.dev.yml` - Development setup
- `apps/Dockerfile` - Flutter web app build
- `services/api/Dockerfile` - Laravel API build
- `docker/nginx.conf` - Nginx configuration for Flutter
- `docker/api-nginx.conf` - Nginx configuration for Laravel

## 🚨 Troubleshooting

### Flutter Dependency Issues
If you encounter dependency conflicts:
```bash
cd apps
flutter clean
flutter pub get
```

### Database Connection Issues
```bash
# Restart database
docker-compose restart db

# Check database logs
docker-compose logs db
```

### Port Conflicts
If ports are already in use, modify the ports in `docker-compose.yml`:
```yaml
ports:
  - "3001:80"  # Change from 3000 to 3001
```

### Container Issues
```bash
# Stop all containers
docker-compose down

# Remove all containers and volumes
docker-compose down -v

# Rebuild everything
docker-compose up --build -d
```

## 🔄 Updating the Application

### Update Code
```bash
# Pull latest changes
git pull origin main

# Rebuild containers
docker-compose up --build -d
```

### Update Dependencies
```bash
# Flutter dependencies
cd apps
flutter pub upgrade

# Laravel dependencies
docker-compose exec api composer update
```

## 📊 Monitoring

### Health Checks
```bash
# Check container status
docker-compose ps

# Check resource usage
docker stats
```

### Backup Database
```bash
docker-compose exec db mysqldump -u root -p kh_pos_lite > backup.sql
```

## 🚀 Production Deployment

For production deployment:
1. Use `docker-compose.yml` (not the dev version)
2. Set strong passwords in environment variables
3. Configure proper SSL certificates
4. Set up proper logging and monitoring
5. Configure backup strategies

## 📝 Notes

- The Flutter app is built for web and served via Nginx
- Laravel API uses PHP-FPM with Nginx reverse proxy
- MySQL data is persisted in Docker volumes
- Redis is configured for session storage and caching

For issues or questions, please check the logs first using `docker-compose logs -f`.