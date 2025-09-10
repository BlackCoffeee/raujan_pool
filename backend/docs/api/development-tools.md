# Development Tools API Documentation

## Overview

Dokumentasi ini menjelaskan API endpoints untuk development tools yang telah diimplementasikan dalam Phase 1.5.

## Base URL

```
http://localhost:8000/api/v1
```

## Development Tools Endpoints

### Telescope

Telescope adalah debugging tool untuk Laravel yang memungkinkan monitoring aplikasi secara real-time.

#### Access Telescope Dashboard

```http
GET /telescope
```

**Description:** Mengakses dashboard Telescope untuk debugging dan monitoring.

**Response:**
- **200 OK:** Dashboard Telescope berhasil diakses
- **403 Forbidden:** Akses ditolak (hanya untuk development environment)

**Example:**
```bash
curl -X GET http://localhost:8000/telescope
```

### Horizon

Horizon adalah dashboard untuk monitoring dan mengelola queue jobs Laravel.

#### Access Horizon Dashboard

```http
GET /horizon
```

**Description:** Mengakses dashboard Horizon untuk monitoring queue jobs.

**Response:**
- **200 OK:** Dashboard Horizon berhasil diakses
- **403 Forbidden:** Akses ditolak (hanya untuk development environment)

**Example:**
```bash
curl -X GET http://localhost:8000/horizon
```

## Configuration

### Telescope Configuration

Telescope dikonfigurasi melalui environment variables:

```env
TELESCOPE_ENABLED=true
TELESCOPE_PATH=telescope
TELESCOPE_DRIVER=database
```

### Horizon Configuration

Horizon dikonfigurasi melalui environment variables:

```env
HORIZON_PREFIX=horizon
HORIZON_DOMAIN=null
```

## Development Commands

### Telescope Commands

```bash
# Clear Telescope data
php artisan telescope:clear

# Prune old Telescope entries
php artisan telescope:prune

# Install Telescope
php artisan telescope:install
```

### Horizon Commands

```bash
# Start Horizon
php artisan horizon

# Stop Horizon
php artisan horizon:terminate

# Pause Horizon
php artisan horizon:pause

# Continue Horizon
php artisan horizon:continue

# Clear failed jobs
php artisan horizon:clear
```

### Code Quality Commands

```bash
# Run PHPStan analysis
./vendor/bin/phpstan analyse

# Run Laravel Pint (Code Style Fixer)
./vendor/bin/pint

# Generate IDE Helper files
php artisan ide-helper:generate
php artisan ide-helper:models
php artisan ide-helper:meta
```

## Security Notes

- Telescope dan Horizon hanya boleh diakses dalam development environment
- Pastikan environment variables `APP_ENV=local` untuk development
- Jangan expose tools ini ke production environment
- Gunakan authentication middleware jika diperlukan

## Troubleshooting

### Telescope tidak bisa diakses

1. Pastikan `TELESCOPE_ENABLED=true` di environment
2. Jalankan `php artisan telescope:install`
3. Pastikan database connection berfungsi
4. Check log untuk error messages

### Horizon tidak bisa diakses

1. Pastikan Redis connection berfungsi
2. Jalankan `php artisan horizon:install`
3. Start Horizon dengan `php artisan horizon`
4. Check queue configuration

### Code Quality Tools Error

1. Pastikan semua dependencies terinstall: `composer install`
2. Check PHPStan configuration di `phpstan.neon`
3. Check Pint configuration di `pint.json`
4. Pastikan file permissions executable untuk scripts
