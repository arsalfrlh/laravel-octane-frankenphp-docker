#jika error hapus dulu ininya "rm public/storage"
FROM dunglas/frankenphp:php8.3

RUN apt-get update && apt-get install -y \
    ffmpeg \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    libzip-dev \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libonig-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

#ini yg akan digunakan volume, bahwa filesystem akan masuk ke mana| "app atau /var/www"
WORKDIR /app

COPY . /app

COPY php.ini /usr/local/etc/php/php.ini

COPY --from=composer:latest usr/bin/composer usr/bin/composer

ENTRYPOINT [ "php", "artisan", "octane:frankenphp", "--workers=4"]
# ENTRYPOINT ["php", "artisan", "octane:frankenphp", "--host=0.0.0.0", "--port=8000", "--workers=4"]