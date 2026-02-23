#!/bin/bash
set -e

cd /workspaces/laravel

# Create Laravel storage directories and fix ownership (volumes may be owned by root)
mkdir -p storage/framework/{cache/data,sessions,views,testing}
mkdir -p storage/logs
mkdir -p bootstrap/cache
sudo chown -R user:user storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

if [ ! -f .env ]; then
    cp .env.example .env
fi

if [ ! -d "vendor" ]; then
    composer install --no-interaction --no-dev --prefer-dist --optimize-autoloader
fi

if [ ! -d "node_modules" ]; then
    npm install
fi

if ! grep -q "^APP_KEY=base64:" .env; then
    php artisan key:generate
fi

# Run migrations if the database has no tables
TABLE_COUNT=$(mysql -h mariadb -u clientxcms -pclientxcms clientxcms -sNe "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'clientxcms';" 2>/dev/null || echo "0")
if [ "$TABLE_COUNT" -eq 0 ]; then
    php artisan migrate --force --seed
fi
