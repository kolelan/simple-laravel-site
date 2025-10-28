#!/bin/bash

# Скрипт полной очистки development окружения

set -e

echo "🧹 Starting full cleanup of development environment..."

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

# Функция для подтверждения действия
confirm_cleanup() {
    echo -e "${YELLOW}⚠️  WARNING: This will remove ALL data including databases!${NC}"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Cleanup cancelled."
        exit 1
    fi
}

# Функция проверки запущенных контейнеров
check_containers() {
    if [ "$(docker ps -q -f name=laravel_)" ]; then
        log_info "Stopping running containers..."
        docker-compose down
    fi
}

# Функция удаления контейнеров
remove_containers() {
    log_info "Removing containers..."
    docker-compose down -v --rmi all --remove-orphans
}

# Функция удаления volumes
remove_volumes() {
    log_info "Removing volumes..."
    docker volume ls -q | grep parallax-landing | while read volume; do
        docker volume rm "$volume" 2>/dev/null || true
    done
}

# Функция очистки локальных файлов
clean_local_files() {
    log_info "Cleaning local files..."

    # Очищаем кэш Laravel
    if [ -d "laravel" ]; then
        if [ -f "laravel/bootstrap/cache/packages.php" ]; then
            rm laravel/bootstrap/cache/*.php 2>/dev/null || true
        fi

        # Удаляем логи
        if [ -f "laravel/storage/logs/laravel.log" ]; then
            rm laravel/storage/logs/laravel.log 2>/dev/null || true
        fi
    fi
}

# Основная функция
main() {
    echo "=========================================="
    echo "🧼 PARALLAX LANDING - CLEANUP SCRIPT"
    echo "=========================================="
    echo

    confirm_cleanup

    log_info "Starting cleanup process..."

    # Останавливаем контейнеры
    check_containers

    # Удаляем контейнеры, images и volumes
    remove_containers

    # Дополнительная очистка volumes
    remove_volumes

    # Очистка локальных файлов
    clean_local_files

    echo
    log_info "✅ Cleanup completed successfully!"
    echo
    log_info "📝 To start fresh, run:"
    echo "   ./docker/develop/scripts/init.sh"
    echo
}

# Запуск основной функции
main "$@"