# Real-time Availability System Setup Guide

## 📋 Overview

Panduan setup dan konfigurasi untuk sistem real-time availability dengan WebSocket integration.

## 🔧 Prerequisites

### Required Packages

Pastikan package berikut sudah terinstall:

```bash
# Laravel Reverb untuk WebSocket
composer require laravel/reverb

# Redis untuk caching dan broadcasting
composer require predis/predis
```

### Environment Configuration

Tambahkan konfigurasi berikut ke `.env`:

```env
# Broadcasting Configuration
BROADCAST_CONNECTION=reverb

# Reverb Configuration
REVERB_APP_ID=your-app-id
REVERB_APP_KEY=your-app-key
REVERB_APP_SECRET=your-app-secret
REVERB_HOST="localhost"
REVERB_PORT=8080
REVERB_SCHEME=http

# Redis Configuration
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

# Cache Configuration
CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
```

## 🚀 Installation Steps

### 1. Install Laravel Reverb

```bash
# Install Reverb
composer require laravel/reverb

# Publish Reverb configuration
php artisan reverb:install

# Start Reverb server
php artisan reverb:start
```

### 2. Configure Broadcasting

Pastikan `config/broadcasting.php` sudah dikonfigurasi dengan benar:

```php
'default' => env('BROADCAST_CONNECTION', 'reverb'),

'connections' => [
    'reverb' => [
        'key' => env('REVERB_APP_KEY'),
        'secret' => env('REVERB_APP_SECRET'),
        'app_id' => env('REVERB_APP_ID'),
        'options' => [
            'host' => env('REVERB_HOST'),
            'port' => env('REVERB_PORT', 443),
            'scheme' => env('REVERB_SCHEME', 'https'),
            'useTLS' => env('REVERB_SCHEME', 'https') === 'https',
        ],
    ],
],
```

### 3. Configure Channels

Pastikan `routes/channels.php` sudah dikonfigurasi:

```php
<?php

use Illuminate\Support\Facades\Broadcast;

// Public channels
Broadcast::channel('availability', function () {
    return true;
});

Broadcast::channel('availability.{date}', function () {
    return true;
});

Broadcast::channel('availability.session.{sessionId}', function () {
    return true;
});

// Private channels
Broadcast::channel('availability.user.{userId}', function ($user, $userId) {
    return (int) $user->id === (int) $userId;
});
```

### 4. Add API Routes

Tambahkan routes ke `routes/api.php`:

```php
use App\Http\Controllers\Api\V1\WebSocketController;

Route::middleware(['auth:sanctum'])->group(function () {
    // Real-time Availability Routes
    Route::prefix('websocket')->group(function () {
        Route::get('availability', [WebSocketController::class, 'getAvailability']);
        Route::get('availability/date-range', [WebSocketController::class, 'getAvailabilityForDateRange']);
        Route::get('availability/session', [WebSocketController::class, 'getAvailabilityForSession']);
        Route::get('availability/stats', [WebSocketController::class, 'getAvailabilityStats']);
        Route::get('availability/trends', [WebSocketController::class, 'getAvailabilityTrends']);
        Route::get('availability/peak-hours', [WebSocketController::class, 'getPeakHours']);
        Route::get('availability/alerts', [WebSocketController::class, 'getAvailabilityAlerts']);
        Route::post('availability/refresh', [WebSocketController::class, 'refreshAvailability']);
        Route::post('availability/subscribe', [WebSocketController::class, 'subscribeToAvailability']);
    });
});
```

## 🔄 Integration with Existing Services

### 1. Update BookingService

Integrasikan dengan `BookingService` untuk broadcast update:

```php
// app/Services/BookingService.php

use App\Services\RealTimeAvailabilityService;

class BookingService
{
    protected $realTimeAvailabilityService;

    public function __construct(RealTimeAvailabilityService $realTimeAvailabilityService)
    {
        $this->realTimeAvailabilityService = $realTimeAvailabilityService;
    }

    public function createBooking($data)
    {
        // ... existing code ...

        // Update availability and broadcast
        $this->realTimeAvailabilityService->updateAvailability(
            $data['booking_date'],
            $data['session_id'],
            $data['adult_count'] + $data['child_count']
        );

        // ... rest of the code ...
    }

    public function cancelBooking($bookingId, $reason = null)
    {
        // ... existing code ...

        // Update availability and broadcast
        $this->realTimeAvailabilityService->updateAvailability(
            $booking->booking_date,
            $booking->session_id,
            -($booking->adult_count + $booking->child_count)
        );

        // ... rest of the code ...
    }
}
```

### 2. Update CalendarService

Integrasikan dengan `CalendarService`:

```php
// app/Services/CalendarService.php

use App\Services\RealTimeAvailabilityService;

class CalendarService
{
    protected $realTimeAvailabilityService;

    public function __construct(RealTimeAvailabilityService $realTimeAvailabilityService)
    {
        $this->realTimeAvailabilityService = $realTimeAvailabilityService;
    }

    public function bookSlots($date, $sessionId, $slots = 1)
    {
        // ... existing code ...

        // Broadcast availability update
        $this->realTimeAvailabilityService->broadcastAvailabilityUpdate($date, $sessionId);

        return $availability;
    }
}
```

## 🧪 Testing

### 1. Run Tests

```bash
# Run all tests
php artisan test

# Run specific test
php artisan test --filter=RealTimeAvailabilityTest

# Run with coverage
php artisan test --coverage
```

### 2. Test WebSocket Connection

```bash
# Start Reverb server
php artisan reverb:start

# Test WebSocket connection
php artisan test --filter=WebSocketControllerTest
```

## 🚀 Deployment

### 1. Production Configuration

```env
# Production Environment
BROADCAST_CONNECTION=reverb
REVERB_SCHEME=https
REVERB_HOST=your-domain.com
REVERB_PORT=443

# Redis Configuration
REDIS_HOST=your-redis-host
REDIS_PASSWORD=your-redis-password
REDIS_PORT=6379
```

### 2. Supervisor Configuration

Buat file supervisor untuk Reverb server:

```ini
# /etc/supervisor/conf.d/reverb.conf

[program:reverb]
process_name=%(program_name)s_%(process_num)02d
command=php /path/to/your/project/artisan reverb:start --host=0.0.0.0 --port=8080
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=1
redirect_stderr=true
stdout_logfile=/path/to/your/project/storage/logs/reverb.log
stopwaitsecs=3600
```

### 3. Nginx Configuration

```nginx
# /etc/nginx/sites-available/your-site

upstream reverb {
    server 127.0.0.1:8080;
}

server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://reverb;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## 🔍 Monitoring

### 1. Log Monitoring

```bash
# Monitor Reverb logs
tail -f storage/logs/reverb.log

# Monitor Laravel logs
tail -f storage/logs/laravel.log
```

### 2. Redis Monitoring

```bash
# Monitor Redis connections
redis-cli monitor

# Check Redis memory usage
redis-cli info memory
```

### 3. Performance Monitoring

```bash
# Monitor WebSocket connections
php artisan reverb:status

# Check queue status
php artisan queue:monitor
```

## 🛠️ Troubleshooting

### Common Issues

1. **WebSocket Connection Failed**

    - Check Reverb server status
    - Verify firewall settings
    - Check SSL certificate (for HTTPS)

2. **Broadcasting Not Working**

    - Verify Redis connection
    - Check broadcasting configuration
    - Ensure events implement ShouldBroadcast

3. **Cache Issues**
    - Clear application cache
    - Restart Redis server
    - Check cache configuration

### Debug Commands

```bash
# Clear all caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear

# Restart services
php artisan reverb:restart
php artisan queue:restart

# Check configuration
php artisan config:show broadcasting
php artisan config:show cache
```

## 📚 Additional Resources

-   [Laravel Broadcasting Documentation](https://laravel.com/docs/11.x/broadcasting)
-   [Laravel Reverb Documentation](https://laravel.com/docs/11.x/reverb)
-   [Redis Documentation](https://redis.io/documentation)
-   [WebSocket API Documentation](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket)
