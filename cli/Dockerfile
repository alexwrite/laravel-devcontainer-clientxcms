# From official php image with Alpine (légère et rapide)
FROM php:8.3-cli-alpine

# Create a user group and account under id 1000
RUN addgroup -g 1000 -S user && adduser -u 1000 -D user -G user

# Install quality-of-life packages including openssh-client for SSH agent forwarding
# zsh-vcs provides vcs_info functions needed by Oh My Zsh themes like agnoster
RUN apk add --no-cache bash curl git vim zsh zsh-vcs shadow openssh-client

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

# Install composer for php deps
RUN apk add --no-cache composer

# Composer uses its php binary, but we want it to use the container's one
RUN rm -f /usr/bin/php83 && ln -s /usr/local/bin/php /usr/bin/php83

# Install redis driver
RUN mkdir -p /usr/src/php/ext/redis && \
    curl -fsSL --ipv4 https://github.com/phpredis/phpredis/archive/6.0.2.tar.gz | tar xvz -C "/usr/src/php/ext/redis" --strip 1 && \
    docker-php-ext-install redis

# Install nodejs and npm for frontend
RUN apk add --no-cache nodejs npm

# Install Claude CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Install oh-my-zsh for user
USER user
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Create directories for persistent volumes
RUN mkdir -p /home/user/.claude /home/user/.ssh

# Configure SSH for agent forwarding
RUN echo "Host *\n\
    AddKeysToAgent yes\n\
    ForwardAgent yes\n\
    StrictHostKeyChecking accept-new" > /home/user/.ssh/config && \
    chmod 600 /home/user/.ssh/config

# Configure zsh as default shell for user
USER root
RUN sed -i 's|user:x:1000:1000:Linux User,,,:/home/user:/bin/sh|user:x:1000:1000:Linux User,,,:/home/user:/bin/zsh|' /etc/passwd
COPY .zshrc /home/user/.zshrc
COPY *.keys /home/user/.ssh/
RUN chmod 600 /home/user/.ssh/* && \
    chown -R user:user /home/user/.oh-my-zsh /home/user/.zshrc /home/user/.ssh
USER user

# Prevent container from exiting early
CMD ["sleep", "infinity"]
