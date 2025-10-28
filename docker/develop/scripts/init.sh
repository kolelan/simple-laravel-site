#!/bin/bash

set -e

echo "🚀 Initializing Laravel Parallax Landing Development Environment..."

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Функция для проверки зависимостей
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

# Функция для подготовки проекта
prepare_project() {
    log_info "Preparing project structure..."



    # Создаем папку laravel если ее нет
    if [ ! -d "laravel" ]; then
        log_warning "laravel/ directory not found. Creating structure..."
        mkdir -p laravel

        # Если есть файлы в корне, перемещаем их в laravel/
        if [ "$(ls -A | grep -v '^laravel$' | grep -v '^docker' | grep -v '^docker-compose' | grep -v '^README' | grep -v '^\.')" ]; then
            log_info "Moving existing files to laravel/ directory..."
            mv app bootstrap config database public resources routes storage tests vendor artisan composer.* .env* laravel/ 2>/dev/null || true
        fi
    fi

    # Создаем необходимые папки внутри laravel
    mkdir -p laravel/storage/app/public \
             laravel/storage/framework/cache \
             laravel/storage/framework/sessions \
             laravel/storage/framework/views \
             laravel/storage/logs \
             laravel/bootstrap/cache

    # Проверяем наличие composer.json
    if [ ! -f "laravel/composer.json" ]; then
        log_error "laravel/composer.json not found!"
        log_info "Current structure:"
        ls -la
        log_info "Files in laravel/:"
        ls -la laravel/ 2>/dev/null || log_error "laravel/ directory doesn't exist"
        exit 1
    fi
}

# Функция для настройки env файла
setup_env() {
    if [ ! -f "laravel/.env" ]; then
        log_info "Creating .env file..."
        if [ -f "laravel/.env.example" ]; then
            cp laravel/.env.example laravel/.env
        else
            log_error "laravel/.env.example not found!"
            exit 1
        fi
    else
        log_info ".env file already exists"
    fi
}

# Функция для запуска контейнеров
start_containers() {
    log_info "Starting Docker containers..."

    # Останавливаем существующие контейнеры
    docker-compose down 2>/dev/null || true

    # Запускаем контейнеры
    if docker-compose up -d --build; then
        log_info "Containers started successfully"
    else
        log_error "Failed to start containers"
        docker-compose logs
        exit 1
    fi

    # Ждем запуска контейнеров
    sleep 10
}

# Функция для проверки работы контейнеров
check_containers() {
    log_info "Checking containers status..."

    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if docker-compose ps | grep -q "Up"; then
            log_info "✅ All containers are running"
            return 0
        fi
        log_info "⏳ Waiting for containers to start... (attempt $attempt/$max_attempts)"
        sleep 5
        ((attempt++))
    done

    log_error "Some containers failed to start"
    docker-compose ps
    docker-compose logs
    exit 1
}

# Функция для установки Laravel зависимостей
setup_laravel() {
    log_info "Setting up Laravel application..."

    # Ждем пока контейнер app будет готов
    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if docker-compose exec -T app php --version > /dev/null 2>&1; then
            break
        fi
        log_info "⏳ Waiting for app container to be ready... (attempt $attempt/$max_attempts)"
        sleep 5
        ((attempt++))
    done

    if [ $attempt -gt $max_attempts ]; then
        log_error "App container is not responding"
        exit 1
    fi

    # Устанавливаем зависимости внутри контейнера
    log_info "Installing Composer dependencies..."
    docker-compose exec -T app composer install --no-interaction --no-progress

    # Генерируем ключ приложения
    log_info "Generating application key..."
    docker-compose exec -T app php artisan key:generate

    # Очищаем кэш
    docker-compose exec -T app php artisan config:clear
    docker-compose exec -T app php artisan cache:clear
}

# Функция для настройки базы данных
setup_database() {
    log_info "Setting up database..."

    # Ждем пока PostgreSQL будет готов
    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if docker-compose exec -T postgres pg_isready -U laravel_user > /dev/null 2>&1; then
            break
        fi
        log_info "⏳ Waiting for PostgreSQL to be ready... (attempt $attempt/$max_attempts)"
        sleep 5
        ((attempt++))
    done

    if [ $attempt -gt $max_attempts ]; then
        log_error "PostgreSQL is not ready"
        exit 1
    fi

    # Запускаем миграции
    log_info "Running database migrations..."
    docker-compose exec -T app php artisan migrate --force

    # Запускаем сидеры если есть
    if docker-compose exec -T app test -f database/seeders/DatabaseSeeder.php; then
        log_info "Running database seeders..."
        docker-compose exec -T app php artisan db:seed --force
    fi
}

# Функция для настройки прав
setup_permissions() {
    log_info "Setting up permissions..."
    docker-compose exec -T app chmod -R 775 storage bootstrap/cache
}

# Функция для настройки storage link
setup_storage() {
    log_info "Setting up storage link..."
    docker-compose exec -T app php artisan storage:link
}

# Функция для проверки приложения
check_application() {
    log_info "Testing application..."

    local max_attempts=20
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if curl -f -s http://localhost:8000 > /dev/null 2>&1; then
            log_info "✅ Application is accessible at http://localhost:8000"
            return 0
        fi
        log_info "⏳ Waiting for application to respond... (attempt $attempt/$max_attempts)"
        sleep 3
        ((attempt++))
    done

    log_warning "Application is not accessible yet. It might need more time to start."
}

# Основная функция
main() {
    echo "=========================================="
    echo "🚀 LARAVEL PARALLAX LANDING - INIT"
    echo "=========================================="
    echo

    check_dependencies
    prepare_project
    setup_env
    start_containers
    check_containers
    setup_laravel
    setup_database
    setup_permissions
    setup_storage
    check_application

    echo
    echo "🎉 Development environment is ready!"
    echo
    echo "📱 Access your application: http://localhost:8000"
    echo "🗄️  PGAdmin: http://localhost:8080"
    echo "   - Email: admin@localhost.com"
    echo "   - Password: admin"
    echo "📊 PostgreSQL: localhost:5432"
    echo "🔴 Redis: localhost:6379"
    echo
    echo "🛠️  Useful commands:"
    echo "   docker-compose logs -f app      # View app logs"
    echo "   docker-compose exec app bash    # Enter app container"
    echo "   docker-compose down             # Stop containers"
    echo "   ./docker/develop/scripts/clean.sh # Full cleanup"
    echo
}

# Обработка ошибок
trap 'log_error "Init failed!"; exit 1' ERR

# Запуск
main "$@"