# Utilise la même base que le container CLI
FROM php:8.3-cli-alpine

# Installer les dépendances
RUN apk add --no-cache \
    libpng-dev \
    libzip-dev \
    icu-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    oniguruma-dev \
    libxml2-dev \
    libxslt-dev \
    postgresql-dev \
    supervisor \
    $PHPIZE_DEPS

# Installer les extensions PHP nécessaires
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) \
    gd \
    intl \
    zip \
    bcmath \
    pdo_mysql \
    pdo_pgsql \
    exif \
    pcntl

# Installer Redis pour Laravel Queue
RUN mkdir -p /usr/src/php/ext/redis; \
    curl -fsSL --ipv4 https://github.com/phpredis/phpredis/archive/6.0.2.tar.gz | tar xvz -C "/usr/src/php/ext/redis" --strip 1; \
    docker-php-ext-install redis

# Création du répertoire pour les logs Supervisor
RUN mkdir -p /var/log/supervisor

# Copier la configuration Supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Définir le point d'entrée
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
