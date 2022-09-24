
## Step 2 — Creating the Docker Compose File

```sh
vi ./laravel-app/docker-compose.yml
```

```
version: "3"
services:
  #PHP Service
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: digitalocean.com/php
    container_name: app
    restart: unless-stopped
    tty: true
    environment:
      SERVICE_NAME: app
      SERVICE_TAGS: dev
    working_dir: /var/www
    volumes:
      - ./:/var/www
      - ./php/local.ini:/usr/local/etc/php/conf.d/local.ini
    networks:
      - app-network

  #Nginx Service
  webserver:
    image: nginx:alpine
    container_name: webserver
    restart: unless-stopped
    tty: true
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./:/var/www
      - ./nginx/conf.d/:/etc/nginx/conf.d/
    networks:
      - app-network

  #MySQL Service
  db:
    image: mysql:5.7.31
    #image: mysql:5.7.22
    #для mysql:8
    #command: --default-authentication-plugin=mysql_native_password
    container_name: db
    restart: unless-stopped
    tty: true
    ports:
      - "3306:3306"
    environment:
      MYSQL_DATABASE: laravel
      MYSQL_ROOT_PASSWORD: r00t
      SERVICE_TAGS: dev
      SERVICE_NAME: mysql
    volumes:
      - ./db_data:/var/lib/mysql
      - ./mysql/my.cnf:/etc/mysql/my.cnf
    networks:
      - app-network

  # phpmyadmin
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: phpmyadmin
    restart: unless-stopped
    ports:
      - "8080:80"
    environment:
      PMA_HOST: db
      MYSQL_ROOT_PASSWORD: r00t
    depends_on:
      - db
    networks:
      - app-network

#Docker Networks
networks:
  app-network:
    driver: bridge

```

## Step 3 — Persisting Data

## Step 4 — Creating the Dockerfile

```sh
vi ./laravel-app/Dockerfile
```

```
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
RUN docker-php-ext-install pdo_mysql intl zip exif pcntl opcache
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

```

## Step 5 — Configuring PHP

```sh
mkdir ./laravel-app/php
vi ./laravel-app/php/local.ini
```

```
upload_max_filesize=40M
post_max_size=40M
```

## Step 6 — Configuring Nginx

```sh
mkdir -p ./laravel-app/nginx/conf.d
vi ./laravel-app/nginx/conf.d/app.conf
```

```
server {
    listen 80;
    index index.php index.html;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /var/www/public;
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass app:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
    location / {
        try_files $uri $uri/ /index.php?$query_string;
        gzip_static on;
    }
}
```

## Step 7 — Configuring MySQL

```sh
mkdir ./laravel-app/mysql && \
mkdir ./laravel-app/dbdata && \
vi ./laravel-app/mysql/my.cnf

```

```
[mysqld]
character-set-server = utf8
collation-server = utf8_general_ci
general_log = 1
general_log_file = /var/lib/mysql/general.log
[client]
default-character-set = utf8
```

## Step 8 — Modifying Environment Settings and Running the Containers

```sh
cp ./laravel-app/.env.example ./laravel-app/.env
vi ./laravel-app/.env
```

```
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laraveluser
DB_PASSWORD=laraveluser_password
```
