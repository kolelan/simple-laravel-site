
# Создание проекта
composer create-project laravel/laravel


# Запуск сервера разработки
php artisan serve

# Или для production
php artisan config:cache
php artisan route:cache

php artisan make:model Contact -m


# Разработка
docker-compose up -d
./docker/develop/scripts/init.sh

# Продакшен
docker-compose -f docker-compose-prod.yml up -d --build

# Остановка разработки
docker-compose down

# Остановка продакшена
docker-compose -f docker-compose-prod.yml down

# Просмотр логов
docker-compose logs -f app

# Даем права на выполнение
chmod +x docker/develop/scripts/clean.sh
chmod +x docker/prod/scripts/deploy.sh

# Полная очистка (осторожно!)
./docker/develop/scripts/clean.sh

# Только остановка контейнеров
docker-compose down

# Остановка с удалением volumes
docker-compose down -v

# Перед первым деплоем настройте .env и SSL сертификаты
cp .env.example .env
# отредактируйте .env для production

# Запуск деплоя
./docker/prod/scripts/deploy.sh

# Или вручную
docker-compose -f docker-compose-prod.yml up -d --build