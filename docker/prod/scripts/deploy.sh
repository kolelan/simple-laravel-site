#!/bin/bash

# Скрипт деплоя production окружения
# ВНИМАНИЕ: Для использования требуется настройка SSL и домена

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Конфигурация
COMPOSE_FILE="docker-compose-prod.yml"
DOMAIN="${DOMAIN:-your-domain.com}"
BACKUP_DIR="./backups"

# Функции логирования
log_info() {
    echo -e "${GREEN}ℹ️  $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Функция проверки зависимостей
check_dependencies() {
    log_info "Checking dependencies..."

    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed!"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose is not installed!"
        exit 1
    fi
}

# Функция проверки SSL сертификатов
check_ssl_certificates() {
    log_info "Checking SSL certificates..."

    if [ ! -d "./ssl" ]; then
        log_warning "SSL directory not found. Creating..."
        mkdir -p ssl
    fi

    if [ ! -f "./ssl/cert.pem" ] || [ ! -f "./ssl/key.pem" ]; then
        log_warning "SSL certificates not found in ./ssl/"
        log_warning "Please place your certificates:"
        log_warning "  - ./ssl/cert.pem"
        log_warning "  - ./ssl/key.pem"
        log_warning "Or update nginx config to use HTTP only."
        read -p "Continue without SSL? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Функция создания бэкапа
create_backup() {
    log_info "Creating database backup..."

    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$BACKUP_DIR/backup_$timestamp"

    mkdir -p "$BACKUP_DIR"
    mkdir -p "$backup_path"

    # Бэкап PostgreSQL
    if docker ps -q -f name=laravel_postgres_prod > /dev/null; then
        log_info "Backing up PostgreSQL..."
        docker-compose -f $COMPOSE_FILE exec -T postgres pg_dump -U laravel_user laravel_landing_prod > "$backup_path/database.sql" 2>/dev/null || {
            log_warning "Could not create database backup. Continuing..."
        }
    fi

    # Бэкап Redis (если нужен)
    if docker ps -q -f name=laravel_redis_prod > /dev/null; then
        log_info "Backing up Redis..."
        docker-compose -f $COMPOSE_FILE exec -T redis redis-cli SAVE > /dev/null 2>&1 || true
        docker cp laravel_redis_prod:/data/dump.rdb "$backup_path/redis_dump.rdb" 2>/dev/null || {
            log_warning "Could not create Redis backup. Continuing..."
        }
    fi

    # Бэкап storage
    if docker ps -q -f name=laravel_app_prod > /dev/null; then
        log_info "Backing up storage..."
        docker cp laravel_app_prod:/var/www/storage/app "$backup_path/storage" 2>/dev/null || {
            log_warning "Could not create storage backup. Continuing..."
        }
    fi

    # Создание архива бэкапа
    tar -czf "$backup_path.tar.gz" -C "$BACKUP_DIR" "backup_$timestamp" 2>/dev/null && {
        rm -rf "$backup_path"
        log_info "Backup created: $backup_path.tar.gz"
    } || {
        log_warning "Could not create backup archive"
    }
}

# Функция проверки окружения
check_environment() {
    log_info "Checking environment configuration..."

    if [ ! -f ".env" ]; then
        log_error ".env file not found!"
        log_info "Please create .env file from .env.example and configure production values."
        exit 1
    fi

    # Проверка критических переменных
    if grep -q "APP_KEY=base64:" .env 2>/dev/null; then
        log_info "App key found ✓"
    else
        log_error "App key not set! Run: php artisan key:generate"
        exit 1
    fi

    if grep -q "APP_ENV=production" .env; then
        log_info "App environment: production ✓"
    else
        log_warning "APP_ENV is not set to production"
    fi

    if grep -q "APP_DEBUG=false" .env; then
        log_info "Debug mode: disabled ✓"
    else
        log_warning "APP_DEBUG is not set to false"
    fi
}

# Функция деплоя
deploy_application() {
    log_info "Starting deployment..."

    # Остановка текущих контейнеров
    log_info "Stopping existing containers..."
    docker-compose -f $COMPOSE_FILE down

    # Пулл последних образов (если используются)
    log_info "Pulling latest images..."
    docker-compose -f $COMPOSE_FILE pull --ignore-pull-failures

    # Билд и запуск контейнеров
    log_info "Building and starting containers..."
    docker-compose -f $COMPOSE_FILE up -d --build

    # Ожидание запуска сервисов
    log_info "Waiting for services to start..."
    sleep 30

    # Запуск миграций
    log_info "Running database migrations..."
    docker-compose -f $COMPOSE_FILE exec -T app php artisan migrate --force

    # Очистка кэша
    log_info "Optimizing application..."
    docker-compose -f $COMPOSE_FILE exec -T app php artisan config:cache
    docker-compose -f $COMPOSE_FILE exec -T app php artisan route:cache
    docker-compose -f $COMPOSE_FILE exec -T app php artisan view:cache

    # Установка прав
    log_info "Setting permissions..."
    docker-compose -f $COMPOSE_FILE exec -T app chown -R www-data:www-data /var/www/storage
    docker-compose -f $COMPOSE_FILE exec -T app chmod -R 775 /var/www/storage
}

# Функция проверки здоровья
health_check() {
    log_info "Performing health check..."

    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if curl -f -s http://localhost > /dev/null 2>&1 || curl -f -s https://localhost > /dev/null 2>&1; then
            log_info "✅ Application is healthy and responding"
            return 0
        fi

        log_info "⏳ Waiting for application to start... (attempt $attempt/$max_attempts)"
        sleep 10
        ((attempt++))
    done

    log_error "Application health check failed!"
    return 1
}

# Функция очистки старых образов
cleanup_old_images() {
    log_info "Cleaning up old Docker images..."
    docker image prune -f
}

# Функция показа статуса
show_status() {
    log_info "Deployment completed!"
    echo
    echo "📊 Deployment Status:"
    echo "===================="
    docker-compose -f $COMPOSE_FILE ps
    echo
    echo "📝 Logs can be viewed with:"
    echo "   docker-compose -f $COMPOSE_FILE logs -f"
    echo
    echo "🌐 Application should be available at:"
    echo "   https://$DOMAIN (or http if SSL not configured)"
}

# Основная функция
main() {
    echo "=========================================="
    echo "🚀 PARALLAX LANDING - PRODUCTION DEPLOY"
    echo "=========================================="
    echo

    check_dependencies
    check_environment
    check_ssl_certificates

    log_warning "This will deploy to PRODUCTION environment!"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Deployment cancelled."
        exit 0
    fi

    # Создание бэкапа
    create_backup

    # Деплой
    deploy_application

    # Проверка здоровья
    health_check

    # Очистка
    cleanup_old_images

    # Статус
    show_status
}

# Обработка ошибок
trap 'log_error "Deployment failed!"; exit 1' ERR

# Запуск основной функции
main "$@"