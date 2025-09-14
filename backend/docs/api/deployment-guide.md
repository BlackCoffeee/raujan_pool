# Deployment Guide

Panduan lengkap untuk deployment aplikasi ke production.

## Prerequisites

### 1. Server Requirements

-   PHP 8.2 atau lebih tinggi
-   Composer
-   MySQL 8.0 atau PostgreSQL 13
-   Redis (untuk cache dan queue)
-   Nginx atau Apache
-   SSL Certificate
-   Domain name

### 2. PHP Extensions

```bash
php -m | grep -E "(bcmath|ctype|fileinfo|json|mbstring|openssl|pdo|tokenizer|xml|zip|gd|curl|intl)"
```

## Environment Configuration

### 1. Production Environment

```env
# .env.production
APP_NAME="Raujan Pool Backend"
APP_ENV=production
APP_KEY=base64:your_production_key_here
APP_DEBUG=false
APP_URL=https://yourdomain.com

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=raujan_pool
DB_USERNAME=raujan_pool_user
DB_PASSWORD=your_secure_password

BROADCAST_DRIVER=pusher
CACHE_DRIVER=redis
FILESYSTEM_DISK=local

# File Storage Configuration
# Laravel Storage (Local) - No additional configuration needed
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis
SESSION_LIFETIME=120

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

PUSHER_APP_ID=your_pusher_app_id
PUSHER_APP_KEY=your_pusher_app_key
PUSHER_APP_SECRET=your_pusher_app_secret
PUSHER_HOST=your_pusher_host
PUSHER_PORT=443
PUSHER_SCHEME=https
PUSHER_APP_CLUSTER=your_pusher_cluster

MAIL_MAILER=smtp
MAIL_HOST=your_smtp_host
MAIL_PORT=587
MAIL_USERNAME=your_smtp_username
MAIL_PASSWORD=your_smtp_password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@yourdomain.com
MAIL_FROM_NAME="${APP_NAME}"
```

### 2. Security Configuration

```env
# Security settings
SESSION_SECURE_COOKIE=true
SESSION_HTTP_ONLY=true
SESSION_SAME_SITE=strict

SANCTUM_STATEFUL_DOMAINS=yourdomain.com,www.yourdomain.com
```

## Database Setup

### 1. Create Database

```sql
CREATE DATABASE raujan_pool CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'raujan_pool_user'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON raujan_pool.* TO 'raujan_pool_user'@'localhost';
FLUSH PRIVILEGES;
```

### 2. Run Migrations

```bash
php artisan migrate --force
php artisan db:seed --force
```

## Server Configuration

### 1. Nginx Configuration

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name yourdomain.com www.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;
    root /var/www/raujan-pool-backend/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    # SSL Configuration
    ssl_certificate /path/to/your/certificate.crt;
    ssl_certificate_key /path/to/your/private.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

### 2. PHP-FPM Configuration

```ini
; /etc/php/8.2/fpm/pool.d/raujan-pool.conf
[raujan-pool]
user = www-data
group = www-data
listen = /var/run/php/php8.2-fpm-raujan-pool.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660

pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 1000

php_admin_value[error_log] = /var/log/php8.2-fpm-raujan-pool.log
php_admin_flag[log_errors] = on
php_admin_value[memory_limit] = 256M
php_admin_value[max_execution_time] = 300
```

## Deployment Scripts

### 1. Deployment Script

```bash
#!/bin/bash
# deploy.sh

set -e

echo "Starting deployment..."

# Backup current version
if [ -d "/var/www/raujan-pool-backend" ]; then
    echo "Backing up current version..."
    cp -r /var/www/raujan-pool-backend /var/www/raujan-pool-backend.backup.$(date +%Y%m%d_%H%M%S)
fi

# Pull latest code
echo "Pulling latest code..."
cd /var/www/raujan-pool-backend
git pull origin main

# Install dependencies
echo "Installing dependencies..."
composer install --no-dev --optimize-autoloader

# Clear and cache configuration
echo "Optimizing application..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

# Run migrations
echo "Running migrations..."
php artisan migrate --force

# Clear caches
echo "Clearing caches..."
php artisan cache:clear
php artisan queue:restart

# Set permissions
echo "Setting permissions..."
chown -R www-data:www-data /var/www/raujan-pool-backend
chmod -R 755 /var/www/raujan-pool-backend
chmod -R 775 /var/www/raujan-pool-backend/storage
chmod -R 775 /var/www/raujan-pool-backend/bootstrap/cache

echo "Deployment completed successfully!"
```

### 2. Rollback Script

```bash
#!/bin/bash
# rollback.sh

set -e

echo "Starting rollback..."

# Find latest backup
LATEST_BACKUP=$(ls -t /var/www/raujan-pool-backend.backup.* | head -n1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "No backup found!"
    exit 1
fi

echo "Rolling back to: $LATEST_BACKUP"

# Stop services
systemctl stop php8.2-fpm
systemctl stop nginx

# Restore backup
rm -rf /var/www/raujan-pool-backend
mv "$LATEST_BACKUP" /var/www/raujan-pool-backend

# Restart services
systemctl start php8.2-fpm
systemctl start nginx

echo "Rollback completed successfully!"
```

## Queue Configuration

### 1. Supervisor Configuration

```ini
; /etc/supervisor/conf.d/raujan-pool-worker.conf
[program:raujan-pool-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/raujan-pool-backend/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=4
redirect_stderr=true
stdout_logfile=/var/www/raujan-pool-backend/storage/logs/worker.log
stopwaitsecs=3600
```

### 2. Start Supervisor

```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start raujan-pool-worker:*
```

## Monitoring and Logging

### 1. Log Rotation

```bash
# /etc/logrotate.d/raujan-pool
/var/www/raujan-pool-backend/storage/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    notifempty
    create 644 www-data www-data
    postrotate
        systemctl reload php8.2-fpm
    endscript
}
```

### 2. Health Check Script

```bash
#!/bin/bash
# health-check.sh

URL="https://yourdomain.com/api/v1/health"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

if [ "$RESPONSE" -eq 200 ]; then
    echo "Health check passed"
    exit 0
else
    echo "Health check failed with status: $RESPONSE"
    exit 1
fi
```

### 3. Cron Job for Health Check

```bash
# Add to crontab
*/5 * * * * /path/to/health-check.sh
```

## SSL Certificate

### 1. Let's Encrypt with Certbot

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## Performance Optimization

### 1. Redis Configuration

```conf
# /etc/redis/redis.conf
maxmemory 256mb
maxmemory-policy allkeys-lru
save 900 1
save 300 10
save 60 10000
```

### 2. MySQL Optimization

```ini
# /etc/mysql/mysql.conf.d/mysqld.cnf
[mysqld]
innodb_buffer_pool_size = 1G
innodb_log_file_size = 256M
innodb_flush_log_at_trx_commit = 2
query_cache_size = 64M
query_cache_type = 1
```

## Backup Strategy

### 1. Database Backup Script

```bash
#!/bin/bash
# backup-db.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/raujan-pool"
DB_NAME="raujan_pool"
DB_USER="raujan_pool_user"
DB_PASS="your_secure_password"

mkdir -p "$BACKUP_DIR"

mysqldump -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" | gzip > "$BACKUP_DIR/db_backup_$DATE.sql.gz"

# Keep only last 7 days
find "$BACKUP_DIR" -name "db_backup_*.sql.gz" -mtime +7 -delete

echo "Database backup completed: db_backup_$DATE.sql.gz"
```

### 2. File Backup Script

```bash
#!/bin/bash
# backup-files.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/raujan-pool"
SOURCE_DIR="/var/www/raujan-pool-backend"

mkdir -p "$BACKUP_DIR"

tar -czf "$BACKUP_DIR/files_backup_$DATE.tar.gz" -C "$SOURCE_DIR" .

# Keep only last 7 days
find "$BACKUP_DIR" -name "files_backup_*.tar.gz" -mtime +7 -delete

echo "Files backup completed: files_backup_$DATE.tar.gz"
```

## Security Checklist

-   [ ] SSL certificate installed and configured
-   [ ] Firewall configured (only ports 80, 443, 22)
-   [ ] Database credentials secured
-   [ ] Environment variables protected
-   [ ] File permissions set correctly
-   [ ] Log files secured
-   [ ] Regular security updates
-   [ ] Backup strategy implemented
-   [ ] Monitoring and alerting configured
-   [ ] Rate limiting configured

## Troubleshooting

### 1. Common Issues

```bash
# Check PHP-FPM status
sudo systemctl status php8.2-fpm

# Check Nginx status
sudo systemctl status nginx

# Check queue workers
sudo supervisorctl status

# Check logs
tail -f /var/www/raujan-pool-backend/storage/logs/laravel.log
tail -f /var/log/nginx/error.log
```

### 2. Performance Issues

```bash
# Check memory usage
free -h

# Check disk usage
df -h

# Check CPU usage
top

# Check database connections
mysql -u root -p -e "SHOW PROCESSLIST;"
```

## Notes

-   Selalu backup sebelum deployment
-   Test di staging environment terlebih dahulu
-   Monitor logs dan performance setelah deployment
-   Update dependencies secara berkala
-   Implementasikan monitoring dan alerting
-   Backup database dan files secara rutin
