# Point 1: Laravel 12 Setup

## 📋 Overview

Setup Laravel 12 project dengan konfigurasi dasar dan dependencies yang diperlukan.

## 🎯 Objectives

-   Install Laravel 12 dengan Composer
-   Konfigurasi environment variables
-   Setup database connection (MySQL)
-   Konfigurasi Redis untuk cache
-   Setup Laravel Reverb untuk WebSocket
-   Install dan konfigurasi Laravel Sanctum

## 📁 Files Structure

```
phase-1/
├── 01-laravel-setup.md
├── composer.json
├── .env.example
├── config/database.php
└── config/broadcasting.php
```

## 📋 File Hierarchy Rules

Implementasi mengikuti urutan: **Database → Model → Service → Controller**

1. **Database**: Migrations dan database schema
2. **Model**: Eloquent models dengan relationships
3. **Service**: Business logic dan complex operations
4. **Controller**: HTTP request handling dan response

## 🔧 Implementation Steps

### Step 1: Install Laravel 12

```bash
# Install Laravel 12
composer create-project laravel/laravel:^11.0 raujan-pool-backend

# Navigate to project directory
cd raujan-pool-backend
```

### Step 2: Install Required Packages

```bash
# Install Laravel Sanctum
composer require laravel/sanctum

# Install Laravel Socialite for Google OAuth
composer require laravel/socialite

# Install Laravel Reverb for WebSocket
composer require laravel/reverb

# Install Redis client
composer require predis/predis

# Install testing framework
composer require pestphp/pest --dev

# Install development tools
composer require laravel/telescope --dev
composer require laravel/horizon --dev
```

### Step 3: Environment Configuration

```bash
# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate
```

### Step 4: Database Configuration

Update `.env` file:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=raujan_pool
DB_USERNAME=root
DB_PASSWORD=

# Redis Configuration
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

# Broadcasting Configuration
BROADCAST_CONNECTION=reverb
REVERB_APP_ID=raujan-pool
REVERB_APP_KEY=base64:your-app-key
REVERB_APP_SECRET=your-app-secret
REVERB_HOST="localhost"
REVERB_PORT=443
REVERB_SCHEME=https
```

### Step 5: Publish Sanctum Configuration

```bash
# Publish Sanctum configuration
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

### Step 6: Publish Reverb Configuration

```bash
# Publish Reverb configuration
php artisan reverb:install
```

## 📊 Dependencies

```json
{
    "require": {
        "laravel/framework": "^11.0",
        "laravel/sanctum": "^4.0",
        "laravel/socialite": "^6.0",
        "laravel/reverb": "^1.0",
        "predis/predis": "^2.0"
    },
    "require-dev": {
        "pestphp/pest": "^2.0",
        "laravel/telescope": "^5.0",
        "laravel/horizon": "^6.0"
    }
}
```

## 🔧 Configuration Files

### composer.json

```json
{
    "name": "raujan-pool/backend",
    "type": "project",
    "description": "Raujan Pool Syariah Backend API",
    "keywords": ["laravel", "framework", "pool", "swimming"],
    "license": "MIT",
    "require": {
        "php": "^8.2",
        "laravel/framework": "^11.0",
        "laravel/sanctum": "^4.0",
        "laravel/socialite": "^6.0",
        "laravel/reverb": "^1.0",
        "predis/predis": "^2.0"
    },
    "require-dev": {
        "pestphp/pest": "^2.0",
        "laravel/telescope": "^5.0",
        "laravel/horizon": "^6.0"
    },
    "autoload": {
        "psr-4": {
            "App\\": "app/",
            "Database\\Factories\\": "database/factories/",
            "Database\\Seeders\\": "database/seeders/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "Tests\\": "tests/"
        }
    },
    "scripts": {
        "post-autoload-dump": [
            "Illuminate\\Foundation\\ComposerScripts::postAutoloadDump",
            "@php artisan package:discover --ansi"
        ],
        "post-update-cmd": [
            "@php artisan vendor:publish --tag=laravel-assets --ansi --force"
        ],
        "post-root-package-install": [
            "@php -r \"file_exists('.env') || copy('.env.example', '.env');\""
        ],
        "post-create-project-cmd": ["@php artisan key:generate --ansi"]
    },
    "extra": {
        "laravel": {
            "dont-discover": []
        }
    },
    "config": {
        "optimize-autoloader": true,
        "preferred-install": "dist",
        "sort-packages": true,
        "allow-plugins": {
            "pestphp/pest-plugin": true,
            "php-http/discovery": true
        }
    },
    "minimum-stability": "stable",
    "prefer-stable": true
}
```

### config/database.php

```php
<?php

return [
    'default' => env('DB_CONNECTION', 'mysql'),
    'connections' => [
        'mysql' => [
            'driver' => 'mysql',
            'url' => env('DB_URL'),
            'host' => env('DB_HOST', '127.0.0.1'),
            'port' => env('DB_PORT', '3306'),
            'database' => env('DB_DATABASE', 'raujan_pool'),
            'username' => env('DB_USERNAME', 'root'),
            'password' => env('DB_PASSWORD', ''),
            'unix_socket' => env('DB_SOCKET', ''),
            'charset' => 'utf8mb4',
            'collation' => 'utf8mb4_unicode_ci',
            'prefix' => '',
            'prefix_indexes' => true,
            'strict' => true,
            'engine' => null,
            'options' => extension_loaded('pdo_mysql') ? array_filter([
                PDO::MYSQL_ATTR_SSL_CA => env('MYSQL_ATTR_SSL_CA'),
            ]) : [],
        ],
    ],
    'migrations' => 'migrations',
    'redis' => [
        'client' => env('REDIS_CLIENT', 'phpredis'),
        'options' => [
            'cluster' => env('REDIS_CLUSTER', 'redis'),
            'prefix' => env('REDIS_PREFIX', Str::slug(env('APP_NAME', 'laravel'), '_').'_database_'),
        ],
        'default' => [
            'url' => env('REDIS_URL'),
            'host' => env('REDIS_HOST', '127.0.0.1'),
            'username' => env('REDIS_USERNAME'),
            'password' => env('REDIS_PASSWORD'),
            'port' => env('REDIS_PORT', '6379'),
            'database' => env('REDIS_DB', '0'),
        ],
        'cache' => [
            'url' => env('REDIS_URL'),
            'host' => env('REDIS_HOST', '127.0.0.1'),
            'username' => env('REDIS_USERNAME'),
            'password' => env('REDIS_PASSWORD'),
            'port' => env('REDIS_PORT', '6379'),
            'database' => env('REDIS_CACHE_DB', '1'),
        ],
    ],
];
```

### config/broadcasting.php

```php
<?php

return [
    'default' => env('BROADCAST_CONNECTION', 'reverb'),
    'connections' => [
        'reverb' => [
            'driver' => 'reverb',
            'key' => env('REVERB_APP_KEY'),
            'secret' => env('REVERB_APP_SECRET'),
            'app_id' => env('REVERB_APP_ID'),
            'options' => [
                'host' => env('REVERB_HOST', '127.0.0.1'),
                'port' => env('REVERB_PORT', 443),
                'scheme' => env('REVERB_SCHEME', 'https'),
                'useTLS' => env('REVERB_SCHEME', 'https') === 'https',
            ],
            'client_options' => [
                // Guzzle client options: https://docs.guzzlephp.org/en/stable/request-options.html
            ],
        ],
        'pusher' => [
            'driver' => 'pusher',
            'key' => env('PUSHER_APP_KEY'),
            'secret' => env('PUSHER_APP_SECRET'),
            'app_id' => env('PUSHER_APP_ID'),
            'options' => [
                'cluster' => env('PUSHER_APP_CLUSTER'),
                'host' => env('PUSHER_HOST') ?: 'api-'.env('PUSHER_APP_CLUSTER', 'mt1').'.pusherapp.com',
                'port' => env('PUSHER_PORT', 443),
                'scheme' => env('PUSHER_SCHEME', 'https'),
                'encrypted' => true,
                'useTLS' => env('PUSHER_SCHEME', 'https') === 'https',
            ],
            'client_options' => [
                // Guzzle client options: https://docs.guzzlephp.org/en/stable/request-options.html
            ],
        ],
    ],
];
```

## 🚀 Getting Started

1. Clone repository
2. Run `composer install`
3. Copy `.env.example` to `.env`
4. Configure database settings
5. Run `php artisan migrate`
6. Run `php artisan key:generate`
7. Start development server: `php artisan serve`

## ✅ Success Criteria

-   [x] Laravel 12 berhasil terinstall
-   [x] Dependencies terinstall dengan benar
-   [x] Environment configuration berfungsi
-   [x] Database connection dapat terkoneksi
-   [x] Redis connection berfungsi
-   [x] Laravel Sanctum terkonfigurasi
-   [x] Laravel Reverb terkonfigurasi
-   [x] Development server dapat dijalankan

## 📚 Documentation

-   [Laravel 12 Documentation](https://laravel.com/docs/11.x)
-   [Laravel Sanctum Documentation](https://laravel.com/docs/11.x/sanctum)
-   [Laravel Reverb Documentation](https://laravel.com/docs/11.x/reverb)
-   [Laravel Socialite Documentation](https://laravel.com/docs/11.x/socialite)
