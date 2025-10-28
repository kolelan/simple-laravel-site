FROM php:8.2-fpm

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libpq-dev \
    postgresql-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Установка PHP расширений
RUN docker-php-ext-install pdo_pgsql pgsql mbstring exif pcntl bcmath gd zip

# Установка XDebug для разработки
RUN pecl install xdebug && docker-php-ext-enable xdebug

# Установка Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Создание рабочей директории
WORKDIR /var/www

# Копирование файлов Laravel
COPY laravel/ .

# Создание необходимых папок если их нет
RUN mkdir -p storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    bootstrap/cache

# Установка прав
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 storage bootstrap/cache

# Создание пользователя для разработки
RUN useradd -G www-data,root -u 1000 -d /home/devuser devuser \
    && mkdir -p /home/devuser \
    && chown -R devuser:devuser /home/devuser

USER devuser

EXPOSE 9000
CMD ["php-fpm"]