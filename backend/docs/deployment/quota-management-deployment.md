# Quota Management Deployment Guide

## Overview

Dokumentasi ini menjelaskan cara melakukan deployment sistem Quota Management ke production environment.

## Pre-Deployment Checklist

### 1. Code Review

-   [ ] Semua test berhasil (coverage > 90%)
-   [ ] Code review selesai
-   [ ] Security review selesai
-   [ ] Performance review selesai

### 2. Environment Preparation

-   [ ] Production database backup
-   [ ] Environment variables configured
-   [ ] SSL certificates ready
-   [ ] Monitoring tools configured

### 3. Dependencies

-   [ ] Composer dependencies updated
-   [ ] Node.js dependencies updated (if applicable)
-   [ ] System packages updated

## Deployment Steps

### Step 1: Database Migration

```bash
# Backup production database
mysqldump -u username -p database_name > backup_$(date +%Y%m%d_%H%M%S).sql

# Run migrations
php artisan migrate --force

# Verify migration status
php artisan migrate:status
```

### Step 2: Code Deployment

```bash
# Pull latest code
git pull origin main

# Install dependencies
composer install --optimize-autoloader --no-dev

# Clear caches
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Optimize for production
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### Step 3: Environment Configuration

```bash
# Update environment variables
cp .env.example .env
php artisan key:generate

# Configure database
DB_CONNECTION=mysql
DB_HOST=production_host
DB_PORT=3306
DB_DATABASE=production_db
DB_USERNAME=production_user
DB_PASSWORD=production_password

# Configure app
APP_ENV=production
APP_DEBUG=false
APP_URL=https://yourdomain.com

# Configure logging
LOG_CHANNEL=stack
LOG_LEVEL=error
```

### Step 4: File Permissions

```bash
# Set proper permissions
chmod -R 755 storage/
chmod -R 755 bootstrap/cache/
chown -R www-data:www-data storage/
chown -R www-data:www-data bootstrap/cache/
```

### Step 5: Queue Configuration (if applicable)

```bash
# Configure queue workers
php artisan queue:work --daemon

# Or use supervisor
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start laravel-worker:*
```

## Post-Deployment Verification

### 1. Health Checks

```bash
# Check application status
curl -I https://yourdomain.com/api/v1/health

# Check database connection
php artisan tinker
>>> DB::connection()->getPdo()
```

### 2. API Endpoint Testing

```bash
# Test quota endpoints
curl -X GET https://yourdomain.com/api/v1/admin/quota/configs \
  -H "Authorization: Bearer YOUR_TOKEN"

curl -X POST https://yourdomain.com/api/v1/admin/quota/configs \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"membership_type":"regular","max_quota":50}'
```

### 3. Database Verification

```bash
# Check tables exist
php artisan tinker
>>> Schema::hasTable('member_quota_config')
>>> Schema::hasTable('member_quota_history')

# Check data integrity
>>> App\Models\MemberQuotaConfig::count()
>>> App\Models\MemberQuotaHistory::count()
```

## Monitoring & Maintenance

### 1. Log Monitoring

```bash
# Monitor application logs
tail -f storage/logs/laravel.log

# Monitor error logs
tail -f storage/logs/laravel-error.log

# Monitor access logs (if using web server)
tail -f /var/log/nginx/access.log
```

### 2. Performance Monitoring

```bash
# Check database performance
php artisan tinker
>>> DB::select('SHOW STATUS LIKE "Slow_queries"')

# Check memory usage
php artisan tinker
>>> memory_get_usage(true)
>>> memory_get_peak_usage(true)
```

### 3. Health Check Endpoints

```php
// Add to routes/api.php
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now(),
        'database' => DB::connection()->getPdo() ? 'connected' : 'disconnected',
        'quota_system' => 'operational'
    ]);
});
```

## Rollback Plan

### 1. Code Rollback

```bash
# Revert to previous commit
git reset --hard HEAD~1

# Clear caches
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
```

### 2. Database Rollback

```bash
# Rollback migrations
php artisan migrate:rollback --step=1

# Restore from backup
mysql -u username -p database_name < backup_file.sql
```

### 3. Environment Rollback

```bash
# Restore previous environment
cp .env.backup .env

# Clear caches
php artisan config:clear
php artisan cache:clear
```

## Security Considerations

### 1. Authentication & Authorization

-   [ ] JWT tokens properly configured
-   [ ] Role-based access control implemented
-   [ ] API rate limiting enabled
-   [ ] CORS properly configured

### 2. Data Protection

-   [ ] Sensitive data encrypted
-   [ ] Database connections secured
-   [ ] Input validation implemented
-   [ ] SQL injection protection

### 3. Monitoring & Alerting

-   [ ] Failed login attempts monitored
-   [ ] Unusual quota usage patterns detected
-   [ ] System resource usage monitored
-   [ ] Error rate monitoring

## Performance Optimization

### 1. Database Optimization

```sql
-- Add indexes for better performance
CREATE INDEX idx_member_quota_config_membership_type ON member_quota_config(membership_type);
CREATE INDEX idx_member_quota_config_is_active ON member_quota_config(is_active);
CREATE INDEX idx_member_quota_history_member_id ON member_quota_history(member_id);
CREATE INDEX idx_member_quota_history_reason ON member_quota_history(reason);
CREATE INDEX idx_member_quota_history_created_at ON member_quota_history(created_at);
```

### 2. Caching Strategy

```php
// Cache frequently accessed data
public function getQuotaStats($filters = [])
{
    $cacheKey = 'quota_stats_' . md5(serialize($filters));

    return Cache::remember($cacheKey, 300, function () use ($filters) {
        // Original logic here
    });
}
```

### 3. Queue Processing

```php
// Move heavy operations to queue
public function bulkAdjustQuota($memberIds, $newQuota, $reason = 'bulk_adjustment')
{
    // Dispatch job to queue
    BulkQuotaAdjustmentJob::dispatch($memberIds, $newQuota, $reason);

    return ['message' => 'Bulk adjustment queued for processing'];
}
```

## Troubleshooting

### Common Deployment Issues

1. **Migration Failures**

    ```bash
    # Check migration status
    php artisan migrate:status

    # Fix migration issues
    php artisan migrate:rollback --step=1
    php artisan migrate
    ```

2. **Permission Issues**

    ```bash
    # Fix storage permissions
    chmod -R 775 storage/
    chown -R www-data:www-data storage/
    ```

3. **Cache Issues**

    ```bash
    # Clear all caches
    php artisan optimize:clear
    ```

4. **Database Connection Issues**

    ```bash
    # Test database connection
    php artisan tinker
    >>> DB::connection()->getPdo()

    # Check environment variables
    php artisan config:show database
    ```

### Emergency Procedures

1. **System Down**

    - Check error logs
    - Verify database connectivity
    - Check server resources
    - Rollback if necessary

2. **Data Corruption**

    - Stop all write operations
    - Restore from backup
    - Verify data integrity
    - Resume operations

3. **Performance Issues**
    - Check database performance
    - Monitor resource usage
    - Optimize queries
    - Scale resources if needed

## Maintenance Schedule

### Daily

-   [ ] Monitor error logs
-   [ ] Check system health
-   [ ] Monitor quota usage patterns

### Weekly

-   [ ] Review performance metrics
-   [ ] Check database performance
-   [ ] Update security patches

### Monthly

-   [ ] Full system backup
-   [ ] Performance optimization
-   [ ] Security audit

### Quarterly

-   [ ] Capacity planning
-   [ ] Disaster recovery testing
-   [ ] System updates

## Support Contacts

### Development Team

-   **Lead Developer**: [Name] - [Email]
-   **Backend Developer**: [Name] - [Email]
-   **DevOps Engineer**: [Name] - [Email]

### Operations Team

-   **System Administrator**: [Name] - [Email]
-   **Database Administrator**: [Name] - [Email]
-   **Network Engineer**: [Name] - [Email]

### Emergency Contacts

-   **On-Call Engineer**: [Phone]
-   **System Manager**: [Phone]
-   **Project Manager**: [Phone]

## Documentation Updates

-   [ ] API documentation updated
-   [ ] User manual updated
-   [ ] System architecture updated
-   [ ] Troubleshooting guide updated
-   [ ] Deployment checklist updated

## Sign-off

-   [ ] **Developer**: [Name] - [Date]
-   [ ] **QA Engineer**: [Name] - [Date]
-   [ ] **DevOps Engineer**: [Name] - [Date]
-   [ ] **Project Manager**: [Name] - [Date]
-   [ ] **System Administrator**: [Name] - [Date]
