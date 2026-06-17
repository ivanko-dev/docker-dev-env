FROM php:8.3-fpm-bookworm

ARG APP_ID=1000

# --- www-data uid/gid match host user ---
RUN groupmod -g "$APP_ID" www-data \
  && usermod -g "$APP_ID" -u "$APP_ID" -d /var/www -s /bin/bash www-data

# --- php-fpm listen + php.ini ---
RUN sed -i -e 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/' /usr/local/etc/php-fpm.d/www.conf \
  && sed 's/memory_limit = 128M/memory_limit = 2G/' /usr/local/etc/php/php.ini-development > /usr/local/etc/php/php.ini

# --- base dirs/permissions ---
RUN mkdir -p /etc/nginx/html /var/www /sock \
  && chown -R www-data:www-data /etc/nginx /var/www /usr/local/etc/php/conf.d /sock

# --- OS deps ---
RUN apt-get update && apt-get install -y \
    sudo \
    cron \
    default-mysql-client \
    git \
    gnupg \
    gzip \
    libbz2-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmagickwand-dev \
    libonig-dev \
    libpng-dev \
    libsodium-dev \
    libssh2-1-dev \
    libwebp-dev \
    libxslt1-dev \
    libzip-dev \
    lsof \
    mailutils \
    msmtp \
    nodejs \
    procps \
    nano \
    zip \
  && rm -rf /var/lib/apt/lists/*

# sudo for www-data (dev convenience)
RUN usermod -aG sudo www-data \
  && echo "www-data ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# --- PECL extensions ---
RUN pecl channel-update pecl.php.net \
  && pecl install \
    imagick \
    ssh2-1.3.1 \
    xdebug \
  && pecl clear-cache \
  && rm -rf /tmp/pear

# --- PHP extensions ---
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
  && docker-php-ext-install \
    bcmath \
    bz2 \
    calendar \
    exif \
    gd \
    gettext \
    intl \
    mbstring \
    mysqli \
    opcache \
    pcntl \
    pdo_mysql \
    soap \
    sockets \
    sodium \
    sysvmsg \
    sysvsem \
    sysvshm \
    xsl \
    zip \
    ftp \
  && docker-php-ext-enable \
    imagick \
    ssh2 \
    ftp \
    xdebug

# --- OPcache: disable JIT for stability ---
RUN set -eux; \
  cat > /usr/local/etc/php/conf.d/98-opcache-safe.ini <<'EOF'
opcache.jit=0
opcache.jit_buffer_size=0
EOF

# --- Xdebug: universal + stable defaults (NO IDE hardcoding) ---
# Trigger-based debugging: enabled only when you send XDEBUG_SESSION / XDEBUG_SESSION_START / XDEBUG_TRIGGER
RUN set -eux; \
  cat > /usr/local/etc/php/conf.d/99-xdebug.ini <<'EOF'
; Safe defaults: do not start debugging automatically
xdebug.start_with_request=trigger

; Keep modes lightweight (no coverage!)
xdebug.mode=develop,debug

; Where IDE runs (host machine)
xdebug.client_host=host.docker.internal
xdebug.client_port=9003

; Optional tweaks
xdebug.max_nesting_level=-1
xdebug.log_level=0
EOF

# --- Composer ---
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

USER www-data:www-data
VOLUME /var/www
WORKDIR /var/www
