# From official php image.
FROM php:8.3-cli-alpine
# # Create a user group and account under id 1000.
RUN addgroup -g 1000 -S user && adduser -u 1000 -D user -G user
# Install quality-of-life packages.
RUN apk add --no-cache bash curl git vim
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
    pcntl
# Install composer for php deps.
RUN apk add --no-cache composer
# Composer uses its php binary, but we want it to use the container's one
RUN rm -f /usr/bin/php83
RUN ln -s /usr/local/bin/php /usr/bin/php83
# Install postgres pdo driver.
RUN apk add --no-cache postgresql-dev && docker-php-ext-install pdo_pgsql
# Install redis driver.
RUN mkdir -p /usr/src/php/ext/redis; \
    curl -fsSL --ipv4 https://github.com/phpredis/phpredis/archive/6.0.2.tar.gz | tar xvz -C "/usr/src/php/ext/redis" --strip 1; \
    docker-php-ext-install redis
# Install nodejs and npm for frontend.
RUN apk add --no-cache nodejs npm
# Prevent container from exiting early.
CMD ["sleep", "infinity"]
