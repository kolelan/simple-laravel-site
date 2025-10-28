FROM php:8.2-fpm-alpine

# Установка системных зависимостей
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libzip-dev \
    postgresql-dev \
    oniguruma-dev \
    freetype-dev \
    jpeg-dev \
    libjpeg-turbo-dev \
    libwebp-dev

# Установка PHP расширений
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install pdo_pgsql pgsql mbstring exif pcntl bcmath gd zip opcache

# Установка Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Настройка OPcache для продакшена
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=60'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Создание рабочей директории
WORKDIR /var/www

# Копирование только необходимых файлов
COPY . .
COPY --chown=www-data:www-data . /var/www/

# Установка зависимостей и оптимизация
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress

# Установка прав
RUN chmod -R 775 storage bootstrap/cache

# Создание симлинка для storage
RUN php artisan storage:link

# Оптимизация Laravel
RUN php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

USER www-data

EXPOSE 9000
CMD ["php-fpm"]