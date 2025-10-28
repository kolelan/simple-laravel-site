#!/bin/bash

set -e

echo "Moving Laravel files to laravel/ directory..."

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}ℹ️  $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Создаем папку laravel если ее нет
mkdir -p laravel

# Список папок и файлов для перемещения
folders=("app" "bootstrap" "config" "database" "public" "resources" "routes" "storage" "tests" "vendor")
files=("artisan" "composer.json" "composer.lock" ".env" ".env.example" "phpunit.xml" "vite.config.js" "package.json")

# Функция для безопасного перемещения
safe_move() {
    local source=$1
    local destination=$2

    if [ -e "$source" ]; then
        if [ -e "$destination" ]; then
            log_warning "$destination already exists, merging contents..."
            if [ -d "$source" ] && [ -d "$destination" ]; then
                cp -r "$source"/* "$destination"/ 2>/dev/null || true
                rm -rf "$source"
            elif [ -f "$source" ] && [ -f "$destination" ]; then
                log_warning "Both $source and $destination are files. Keeping both."
                mv "$source" "${source}.backup"
            fi
        else
            log_info "Moving $source to $destination"
            mv "$source" "$destination"
        fi
    fi
}

# Перемещаем папки
for folder in "${folders[@]}"; do
    if [ -d "$folder" ] && [ "$folder" != "laravel" ] && [ "$folder" != "docker" ]; then
        safe_move "$folder" "laravel/$folder"
    fi
done

# Перемещаем файлы
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        safe_move "$file" "laravel/$file"
    fi
done

# Создаем необходимые папки если их нет
mkdir -p laravel/storage/app/public \
         laravel/storage/framework/cache \
         laravel/storage/framework/sessions \
         laravel/storage/framework/views \
         laravel/storage/logs \
         laravel/bootstrap/cache

log_info "✅ Laravel files reorganization completed!"
log_info "📁 Project structure is now ready for Docker setup"

# Показываем итоговую структуру
echo
log_info "Final project structure:"
find laravel -type f -name "*.php" | head -20 | sort
echo
log_info "Total files in laravel/: $(find laravel -type f | wc -l)"