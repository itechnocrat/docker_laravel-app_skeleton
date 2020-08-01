FROM php:7.4-fpm

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    build-essential \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libjpeg-dev \
    locales \
    zip \
    jpegoptim \
    optipng \
    pngquant \
    gifsicle \
    unzip \
    curl \
    libonig-dev \
    libzip-dev \
    libmcrypt-dev \
    zlib1g-dev \
    libxml2-dev \
    graphviz \
    libcurl4-openssl-dev \
    pkg-config \
    libpq-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql mysqli intl zip exif pcntl opcache
# RUN mbstring
RUN docker-php-source delete
# RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) gd
RUN docker-php-source delete
# изменение UID пользователя `www-data`, (если нужно)
# RUN usermod -u 33 www-data

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY . /var/www

# Copy existing application directory permissions
COPY --chown=www:www . /var/www

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
