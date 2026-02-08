FROM dunglas/frankenphp:php8.3

# semua extensi yg akan di install oleh docker
RUN apt-get update && apt-get install -y \
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

# container akan dijalankan di app
WORKDIR /app

# . itu artinya disini di file ini masuk ke folder app
COPY . /app

# jika error hapus kode dibawah ini| jika error lagi tambahkan kode ini lagi, terus lakukan "docker compose down" | "docker compose down --v" dan "docker compose up -d" | "docker compose up --build"
COPY --from=composer:latest usr/bin/composer usr/bin/composer
# RUN cd /app && composer install --optimize-autoloader --no-dev
# RUN composer install

# --workers=20 (20 itu adalah jumah workernya)
ENTRYPOINT [ "php", "artisan", "octane:frankenphp", "--workers=20"]

#cara menjalankannya docker compose up --build
#ctrl + c lalu enter untuk exit

#cara setupnya install laravel "laravel new nama projek"
#lalu install "composer require laravel/octane"
#setelah itu janlankan "php artisan octane:install" lalu pilih (0 frankenphp) dan pilih no untuk membatalkan imstall konfigurasi frankenphp
#setelah itu jalankan "php artisan install:api" dan "php artisan migrate"
#lalu buat seperti ini di Dockerfile dan docker-compose.yaml
#atur file .env sesuai dengan host, nama_database, username, password, port | di sini kita pakai mysql xampp karena mysql docker selalu error
#setelah itu jalankan "docker compose up -d" | "docker compose up --build"
#jika error perhatikan "COPY" di atas
#setelah berhasil buat route untuk phpinfo() dan lihat apakah sudah menggunakn frankenphp dan worker