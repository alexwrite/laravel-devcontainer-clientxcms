# From official PHP FPM image
FROM php:8.3-fpm-alpine

# Install dependencies for PHP extensions
RUN apk add --no-cache \
    libpng-dev \
    libzip-dev \
    icu-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    oniguruma-dev \
    libxml2-dev \
    libxslt-dev \
    $PHPIZE_DEPS

# Install required PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) \
    gd \
    intl \
    zip \
    bcmath \
    pdo_mysql \
    exif \
    pcntl \
    opcache

# Install postgres pdo driver
RUN apk add --no-cache postgresql-dev && docker-php-ext-install pdo_pgsql

# Install redis driver
RUN mkdir -p /usr/src/php/ext/redis; \
    curl -fsSL --ipv4 https://github.com/phpredis/phpredis/archive/6.0.2.tar.gz | tar xvz -C "/usr/src/php/ext/redis" --strip 1; \
    docker-php-ext-install redis

# Configure PHP-FPM
RUN echo "pm = dynamic" >> /usr/local/etc/php-fpm.d/www.conf && \
    echo "pm.max_children = 50" >> /usr/local/etc/php-fpm.d/www.conf && \
    echo "pm.start_servers = 5" >> /usr/local/etc/php-fpm.d/www.conf && \
    echo "pm.min_spare_servers = 5" >> /usr/local/etc/php-fpm.d/www.conf && \
    echo "pm.max_spare_servers = 10" >> /usr/local/etc/php-fpm.d/www.conf

# Configure PHP opcache
RUN echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.interned_strings_buffer=8" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.max_accelerated_files=10000" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.revalidate_freq=2" >> /usr/local/etc/php/conf.d/opcache.ini

# Set working directory
WORKDIR /workspaces/laravel

# Expose port 9000 for PHP-FPM
EXPOSE 9000

CMD ["php-fpm"]
