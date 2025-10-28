# Laravel Project Landing

Одностраничный лендинг с параллакс-эффектом на Laravel с Docker-окружением.

## 🚀 Быстрый старт

### Требования

- Docker
- Docker Compose

### Запуск проекта

```bash
# Клонируйте репозиторий (если нужно)
git clone git@github.com:kolelan/simple-laravel-site.git 
# или 
git clone git@gitverse.ru:2222/Kolelan/simple-laravel-site.git

# Запустите инициализацию (автоматически настроит всё необходимое)
./docker/develop/scripts/init.sh
```

После успешного выполнения скрипта приложение будет доступно по адресу:  
**http://localhost:8000**

## 📁 Структура проекта

```
Project-landing/
├── laravel/                 # Все файлы Laravel приложения
│   ├── app/                 # Модели, контроллеры, middleware
│   ├── bootstrap/           # Файлы инициализации
│   ├── config/              # Конфигурации приложения
│   ├── database/            # Миграции, сидеры
│   ├── public/              # Публичная директория
│   ├── resources/           # Шаблоны, стили, скрипты
│   ├── routes/              # Маршруты
│   ├── storage/             # Логи, кэш, загружаемые файлы
│   └── tests/               # Тесты
├── docker/                  # Docker конфигурации
│   ├── develop/             # Конфиги для разработки
│   └── prod/                # Конфиги для продакшена
├── docker-compose.yml       # Docker Compose для разработки
└── docker-compose-prod.yml  # Docker Compose для продакшена
```

## 🛠 Сервисы в Docker

При запуске создаются следующие сервисы:

- **🌐 Nginx** - Веб-сервер на порту 8000
- **🐘 PHP-FPM** - Обработчик PHP с Laravel
- **🗄 PostgreSQL** - База данных на порту 5432
- **📊 pgAdmin** - Веб-интерфейс для БД на порту 8080
- **🔴 Redis** - Кэш и сессии на порту 6379

### Доступ к сервисам

- **Приложение**: http://localhost:8000
- **pgAdmin**: http://localhost:8080
    - Email: `admin@localhost.com`
    - Пароль: `admin`
- **PostgreSQL**: `localhost:5432`
- **Redis**: `localhost:6379`

## 🎯 Особенности проекта

### Фронтенд
- Одностраничный лендинг с параллакс-эффектом
- Адаптивный дизайн
- Современный CSS с переменными
- Плавные анимации и переходы

### Бэкенд
- Laravel 10
- PostgreSQL для базы данных
- Redis для кэширования
- Docker-окружение

### Параллакс эффект
Простой JavaScript для создания параллакс-эффекта при скролле:

```javascript
window.addEventListener('scroll', function() {
  const scrolled = window.pageYOffset;
  const parallaxElements = document.querySelectorAll('.parallax-section');

  parallaxElements.forEach(function(element) {
    const speed = 0.5;
    element.style.transform = `translateY(${scrolled * speed}px)`;
  });
});
```

## 🛠 Команды для разработки

### Основные команды

```bash
# Запуск окружения
./docker/develop/scripts/init.sh

# Остановка контейнеров
docker-compose down

# Полная очистка (удаляет ВСЕ данные включая БД)
./docker/develop/scripts/clean.sh

# Просмотр логов
docker-compose logs -f app
docker-compose logs -f nginx
```

### Работа внутри контейнеров

```bash
# Войти в контейнер с приложением
docker-compose exec app bash

# Выполнить Artisan команды
docker-compose exec app php artisan migrate
docker-compose exec app php artisan make:controller NewController

# Установить зависимости Composer
docker-compose exec app composer install
docker-compose exec app composer require package-name

# Очистить кэш
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan cache:clear
```

### Работа с базой данных

```bash
# Подключиться к PostgreSQL
docker-compose exec postgres psql -U laravel_user -d laravel_landing_dev

# Создать миграцию
docker-compose exec app php artisan make:migration create_table_name

# Запустить миграции
docker-compose exec app php artisan migrate

# Запустить сидеры
docker-compose exec app php artisan db:seed
```

## 🔧 Настройка окружения

### Файл .env

Основные настройки в `laravel/.env`:

```env
APP_NAME="Project Landing"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=laravel_landing_dev
DB_USERNAME=laravel_user
DB_PASSWORD=password

REDIS_HOST=redis
```

### Конфигурация Docker

- **PHP 8.2** с расширениями для Laravel и PostgreSQL
- **XDebug** для отладки
- **Nginx** с оптимизированной конфигурацией
- **PostgreSQL 15** с предварительной настройкой

## 🚀 Деплой в продакшен

Для деплоя в продакшен используйте:

```bash
# Настройте .env для production
cp laravel/.env.example laravel/.env
# Отредактируйте laravel/.env для production

# Запустите деплой
./docker/prod/scripts/deploy.sh
```

## 🐛 Отладка

### XDebug

XDebug предустановлен в контейнере разработки. Для использования:

1. Настройте ваш IDE для удаенной отладки
2. Установите точку останова
3. Откройте приложение в браузере

### Логи

```bash
# Просмотр логов приложения
docker-compose logs app

# Просмотр логов Nginx
docker-compose logs webserver

# Просмотр логов базы данных
docker-compose logs postgres

# Просмотр всех логов в реальном времени
docker-compose logs -f
```

## 📝 Полезные ссылки

- [Laravel Documentation](https://laravel.com/docs)
- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Nginx Documentation](https://nginx.org/en/docs/)

## 🤝 Разработка

### Добавление нового функционала

1. Создайте ветку для новой функциональности
2. Внесите изменения в код
3. Протестируйте локально с помощью Docker
4. Создайте Pull Request

### Структура лендинга

Основные секции лендинга находятся в `laravel/resources/views/landing.blade.php`:

- Герой-секция с параллаксом
- О компании
- Услуги
- Контактная форма

## 📄 Лицензия

Этот проект является открытым и распространяется под лицензией MIT.

---

**Примечание**: Для работы проекта убедитесь, что порты 8000, 8080, 5432 и 6379 свободны на вашей системе.