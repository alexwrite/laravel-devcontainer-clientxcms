#!/bin/bash
set -e

cd /workspaces/laravel

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
