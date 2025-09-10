# API Monitoring & Logging

Panduan lengkap untuk monitoring dan logging API.

## Logging Strategy

### 1. Log Levels

#### Log Level Configuration

```php
// config/logging.php
'channels' => [
    'stack' => [
        'driver' => 'stack',
        'channels' => ['single', 'slack'],
        'ignore_exceptions' => false,
    ],

    'single' => [
        'driver' => 'single',
        'path' => storage_path('logs/laravel.log'),
        'level' => env('LOG_LEVEL', 'debug'),
    ],

    'api' => [
        'driver' => 'single',
        'path' => storage_path('logs/api.log'),
        'level' => 'info',
    ],

    'security' => [
        'driver' => 'single',
        'path' => storage_path('logs/security.log'),
        'level' => 'warning',
    ],

    'performance' => [
        'driver' => 'single',
        'path' => storage_path('logs/performance.log'),
        'level' => 'info',
    ],

    'slack' => [
        'driver' => 'slack',
        'url' => env('LOG_SLACK_WEBHOOK_URL'),
        'username' => 'Laravel Log',
        'emoji' => ':boom:',
        'level' => 'critical',
    ],
],
```

### 2. API Request Logging

```php
// app/Http/Middleware/ApiLogMiddleware.php
class ApiLogMiddleware
{
    public function handle($request, Closure $next)
    {
        $start = microtime(true);
        $startMemory = memory_get_usage();

        // Log request
        Log::channel('api')->info('API Request', [
            'method' => $request->method(),
            'url' => $request->fullUrl(),
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'user_id' => $request->user()?->id,
            'request_id' => $request->header('X-Request-ID', Str::uuid()),
            'timestamp' => now()->toISOString(),
            'headers' => $this->sanitizeHeaders($request->headers->all()),
            'body' => $this->sanitizeBody($request->all()),
        ]);

        $response = $next($request);

        $end = microtime(true);
        $endMemory = memory_get_usage();

        // Log response
        Log::channel('api')->info('API Response', [
            'method' => $request->method(),
            'url' => $request->fullUrl(),
            'status_code' => $response->getStatusCode(),
            'response_time' => round(($end - $start) * 1000, 2),
            'memory_usage' => $endMemory - $startMemory,
            'user_id' => $request->user()?->id,
            'request_id' => $request->header('X-Request-ID'),
            'timestamp' => now()->toISOString(),
        ]);

        return $response;
    }

    private function sanitizeHeaders(array $headers)
    {
        $sensitiveHeaders = ['authorization', 'cookie', 'x-api-key'];

        foreach ($sensitiveHeaders as $header) {
            if (isset($headers[$header])) {
                $headers[$header] = ['***'];
            }
        }

        return $headers;
    }

    private function sanitizeBody(array $body)
    {
        $sensitiveFields = ['password', 'token', 'api_key', 'secret'];

        foreach ($sensitiveFields as $field) {
            if (isset($body[$field])) {
                $body[$field] = '***';
            }
        }

        return $body;
    }
}
```

### 3. Security Event Logging

```php
// app/Http/Middleware/SecurityLogMiddleware.php
class SecurityLogMiddleware
{
    public function handle($request, Closure $next)
    {
        $response = $next($request);

        // Log security events
        if ($response->getStatusCode() >= 400) {
            Log::channel('security')->warning('Security Event', [
                'ip' => $request->ip(),
                'user_agent' => $request->userAgent(),
                'url' => $request->fullUrl(),
                'method' => $request->method(),
                'status_code' => $response->getStatusCode(),
                'user_id' => $request->user()?->id,
                'timestamp' => now()->toISOString(),
                'request_body' => $this->sanitizeBody($request->all()),
            ]);
        }

        return $response;
    }

    private function sanitizeBody(array $body)
    {
        $sensitiveFields = ['password', 'token', 'api_key', 'secret'];

        foreach ($sensitiveFields as $field) {
            if (isset($body[$field])) {
                $body[$field] = '***';
            }
        }

        return $body;
    }
}
```

### 4. Performance Logging

```php
// app/Http/Middleware/PerformanceLogMiddleware.php
class PerformanceLogMiddleware
{
    public function handle($request, Closure $next)
    {
        $start = microtime(true);
        $startMemory = memory_get_usage();

        $response = $next($request);

        $end = microtime(true);
        $endMemory = memory_get_usage();

        $duration = ($end - $start) * 1000;
        $memoryUsage = $endMemory - $startMemory;

        // Log performance metrics
        Log::channel('performance')->info('Performance Metrics', [
            'url' => $request->fullUrl(),
            'method' => $request->method(),
            'duration_ms' => round($duration, 2),
            'memory_usage' => $memoryUsage,
            'peak_memory' => memory_get_peak_usage(),
            'status_code' => $response->getStatusCode(),
            'user_id' => $request->user()?->id,
            'timestamp' => now()->toISOString(),
        ]);

        // Log slow requests
        if ($duration > 1000) { // More than 1 second
            Log::channel('performance')->warning('Slow Request', [
                'url' => $request->fullUrl(),
                'method' => $request->method(),
                'duration_ms' => round($duration, 2),
                'memory_usage' => $memoryUsage,
                'user_id' => $request->user()?->id,
                'timestamp' => now()->toISOString(),
            ]);
        }

        return $response;
    }
}
```

## Error Logging

### 1. Exception Logging

```php
// app/Exceptions/Handler.php
class Handler extends ExceptionHandler
{
    public function register()
    {
        $this->reportable(function (Throwable $e) {
            $this->logException($e);
        });
    }

    private function logException(Throwable $e)
    {
        Log::channel('api')->error('Exception Occurred', [
            'exception' => get_class($e),
            'message' => $e->getMessage(),
            'file' => $e->getFile(),
            'line' => $e->getLine(),
            'trace' => $e->getTraceAsString(),
            'url' => request()->fullUrl(),
            'method' => request()->method(),
            'user_id' => request()->user()?->id,
            'ip' => request()->ip(),
            'user_agent' => request()->userAgent(),
            'timestamp' => now()->toISOString(),
        ]);
    }
}
```

### 2. Custom Error Logging

```php
// app/Services/ErrorLogService.php
class ErrorLogService
{
    public function logError(Throwable $e, array $context = [])
    {
        Log::channel('api')->error('Custom Error', [
            'exception' => get_class($e),
            'message' => $e->getMessage(),
            'file' => $e->getFile(),
            'line' => $e->getLine(),
            'context' => $context,
            'user_id' => auth()->id(),
            'ip' => request()->ip(),
            'timestamp' => now()->toISOString(),
        ]);
    }

    public function logValidationError(array $errors, array $input = [])
    {
        Log::channel('api')->warning('Validation Error', [
            'errors' => $errors,
            'input' => $this->sanitizeInput($input),
            'user_id' => auth()->id(),
            'ip' => request()->ip(),
            'timestamp' => now()->toISOString(),
        ]);
    }

    private function sanitizeInput(array $input)
    {
        $sensitiveFields = ['password', 'token', 'api_key', 'secret'];

        foreach ($sensitiveFields as $field) {
            if (isset($input[$field])) {
                $input[$field] = '***';
            }
        }

        return $input;
    }
}
```

## Monitoring Metrics

### 1. Application Metrics

```php
// app/Services/MetricsService.php
class MetricsService
{
    public function collectMetrics()
    {
        return [
            'system' => $this->getSystemMetrics(),
            'application' => $this->getApplicationMetrics(),
            'database' => $this->getDatabaseMetrics(),
            'cache' => $this->getCacheMetrics(),
        ];
    }

    private function getSystemMetrics()
    {
        return [
            'memory_usage' => memory_get_usage(true),
            'peak_memory' => memory_get_peak_usage(true),
            'cpu_usage' => sys_getloadavg()[0],
            'disk_usage' => disk_free_space('/'),
            'uptime' => time() - $_SERVER['REQUEST_TIME_FLOAT'],
        ];
    }

    private function getApplicationMetrics()
    {
        return [
            'active_users' => User::where('last_activity_at', '>', now()->subMinutes(5))->count(),
            'total_bookings' => Booking::count(),
            'pending_bookings' => Booking::where('status', 'pending')->count(),
            'queue_jobs' => DB::table('jobs')->count(),
            'failed_jobs' => DB::table('failed_jobs')->count(),
        ];
    }

    private function getDatabaseMetrics()
    {
        return [
            'connections' => DB::getConnections(),
            'slow_queries' => $this->getSlowQueries(),
            'table_sizes' => $this->getTableSizes(),
        ];
    }

    private function getCacheMetrics()
    {
        return [
            'cache_hits' => Cache::get('cache_hits', 0),
            'cache_misses' => Cache::get('cache_misses', 0),
            'cache_size' => $this->getCacheSize(),
        ];
    }
}
```

### 2. Health Check Endpoint

```php
// app/Http/Controllers/HealthController.php
class HealthController extends Controller
{
    public function check()
    {
        $checks = [
            'database' => $this->checkDatabase(),
            'cache' => $this->checkCache(),
            'queue' => $this->checkQueue(),
            'storage' => $this->checkStorage(),
        ];

        $allHealthy = collect($checks)->every(fn($check) => $check['status'] === 'healthy');

        return response()->json([
            'status' => $allHealthy ? 'healthy' : 'unhealthy',
            'checks' => $checks,
            'timestamp' => now()->toISOString(),
        ], $allHealthy ? 200 : 503);
    }

    private function checkDatabase()
    {
        try {
            DB::connection()->getPdo();
            return ['status' => 'healthy', 'message' => 'Database connection successful'];
        } catch (Exception $e) {
            return ['status' => 'unhealthy', 'message' => $e->getMessage()];
        }
    }

    private function checkCache()
    {
        try {
            Cache::put('health_check', 'ok', 10);
            $value = Cache::get('health_check');
            return ['status' => 'healthy', 'message' => 'Cache is working'];
        } catch (Exception $e) {
            return ['status' => 'unhealthy', 'message' => $e->getMessage()];
        }
    }

    private function checkQueue()
    {
        try {
            // Check if queue is processing
            $jobs = DB::table('jobs')->count();
            return ['status' => 'healthy', 'message' => "Queue has {$jobs} jobs"];
        } catch (Exception $e) {
            return ['status' => 'unhealthy', 'message' => $e->getMessage()];
        }
    }

    private function checkStorage()
    {
        try {
            Storage::put('health_check.txt', 'ok');
            $content = Storage::get('health_check.txt');
            Storage::delete('health_check.txt');
            return ['status' => 'healthy', 'message' => 'Storage is working'];
        } catch (Exception $e) {
            return ['status' => 'unhealthy', 'message' => $e->getMessage()];
        }
    }
}
```

## Real-time Monitoring

### 1. WebSocket Monitoring

```php
// app/Http/Controllers/MonitoringController.php
class MonitoringController extends Controller
{
    public function metrics()
    {
        $metrics = [
            'timestamp' => now()->toISOString(),
            'system' => [
                'memory_usage' => memory_get_usage(true),
                'peak_memory' => memory_get_peak_usage(true),
                'cpu_usage' => sys_getloadavg()[0],
            ],
            'application' => [
                'active_users' => User::where('last_activity_at', '>', now()->subMinutes(5))->count(),
                'total_bookings' => Booking::count(),
                'pending_bookings' => Booking::where('status', 'pending')->count(),
            ],
            'database' => [
                'connections' => DB::getConnections(),
                'slow_queries' => $this->getSlowQueries(),
            ],
            'cache' => [
                'cache_hits' => Cache::get('cache_hits', 0),
                'cache_misses' => Cache::get('cache_misses', 0),
            ],
        ];

        return response()->json($metrics);
    }

    private function getSlowQueries()
    {
        // Implementation depends on database driver
        return [];
    }
}
```

### 2. Monitoring Dashboard

```php
// app/Http/Controllers/Admin/MonitoringController.php
class MonitoringController extends Controller
{
    public function dashboard()
    {
        $metrics = [
            'users' => [
                'total' => User::count(),
                'active' => User::where('last_activity_at', '>', now()->subMinutes(5))->count(),
                'new_today' => User::whereDate('created_at', today())->count(),
            ],
            'bookings' => [
                'total' => Booking::count(),
                'today' => Booking::whereDate('created_at', today())->count(),
                'pending' => Booking::where('status', 'pending')->count(),
                'confirmed' => Booking::where('status', 'confirmed')->count(),
            ],
            'payments' => [
                'total' => Payment::count(),
                'pending' => Payment::where('status', 'pending')->count(),
                'verified' => Payment::where('status', 'verified')->count(),
                'rejected' => Payment::where('status', 'rejected')->count(),
            ],
            'system' => [
                'memory_usage' => memory_get_usage(true),
                'peak_memory' => memory_get_peak_usage(true),
                'uptime' => time() - $_SERVER['REQUEST_TIME_FLOAT'],
            ],
        ];

        return response()->json($metrics);
    }
}
```

## Log Rotation

### 1. Log Rotation Configuration

```bash
# /etc/logrotate.d/laravel
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

### 2. Custom Log Rotation

```php
// app/Console/Commands/RotateLogs.php
class RotateLogs extends Command
{
    protected $signature = 'logs:rotate';
    protected $description = 'Rotate application logs';

    public function handle()
    {
        $logPath = storage_path('logs');
        $files = glob($logPath . '/*.log');

        foreach ($files as $file) {
            $this->rotateLog($file);
        }

        $this->info('Logs rotated successfully');
    }

    private function rotateLog($file)
    {
        $backupFile = $file . '.' . date('Y-m-d');

        if (file_exists($file)) {
            rename($file, $backupFile);
            touch($file);
            chmod($file, 0644);
        }
    }
}
```

## Alerting

### 1. Alert Configuration

```php
// config/alerts.php
return [
    'channels' => [
        'slack' => [
            'webhook_url' => env('SLACK_WEBHOOK_URL'),
            'channel' => '#alerts',
        ],
        'email' => [
            'to' => env('ALERT_EMAIL'),
            'from' => env('MAIL_FROM_ADDRESS'),
        ],
    ],

    'rules' => [
        'high_error_rate' => [
            'condition' => 'error_rate > 5%',
            'channels' => ['slack', 'email'],
        ],
        'slow_response' => [
            'condition' => 'response_time > 1000ms',
            'channels' => ['slack'],
        ],
        'high_memory_usage' => [
            'condition' => 'memory_usage > 80%',
            'channels' => ['slack', 'email'],
        ],
    ],
];
```

### 2. Alert Service

```php
// app/Services/AlertService.php
class AlertService
{
    public function sendAlert(string $type, array $data)
    {
        $channels = config("alerts.rules.{$type}.channels", []);

        foreach ($channels as $channel) {
            $this->sendToChannel($channel, $type, $data);
        }
    }

    private function sendToChannel(string $channel, string $type, array $data)
    {
        switch ($channel) {
            case 'slack':
                $this->sendSlackAlert($type, $data);
                break;
            case 'email':
                $this->sendEmailAlert($type, $data);
                break;
        }
    }

    private function sendSlackAlert(string $type, array $data)
    {
        $webhookUrl = config('alerts.channels.slack.webhook_url');

        $payload = [
            'text' => "Alert: {$type}",
            'attachments' => [
                [
                    'color' => 'danger',
                    'fields' => [
                        [
                            'title' => 'Type',
                            'value' => $type,
                            'short' => true,
                        ],
                        [
                            'title' => 'Data',
                            'value' => json_encode($data),
                            'short' => false,
                        ],
                    ],
                ],
            ],
        ];

        Http::post($webhookUrl, $payload);
    }

    private function sendEmailAlert(string $type, array $data)
    {
        $to = config('alerts.channels.email.to');

        Mail::to($to)->send(new AlertMail($type, $data));
    }
}
```

## Best Practices

### 1. Logging

-   Use appropriate log levels
-   Include relevant context
-   Sanitize sensitive data
-   Implement log rotation
-   Monitor log file sizes

### 2. Monitoring

-   Set up health checks
-   Monitor key metrics
-   Implement alerting
-   Use real-time monitoring
-   Regular performance reviews

### 3. Error Handling

-   Log all exceptions
-   Include stack traces
-   Add context information
-   Monitor error rates
-   Set up error alerts

### 4. Performance

-   Monitor response times
-   Track memory usage
-   Monitor database performance
-   Set up performance alerts
-   Regular performance reviews

## Monitoring Checklist

-   [ ] Logging configured
-   [ ] Error logging implemented
-   [ ] Performance monitoring
-   [ ] Health checks implemented
-   [ ] Metrics collection
-   [ ] Real-time monitoring
-   [ ] Log rotation configured
-   [ ] Alerting set up
-   [ ] Dashboard created
-   [ ] Monitoring documentation
-   [ ] Performance baselines
-   [ ] Error tracking
-   [ ] System monitoring
-   [ ] Application monitoring
-   [ ] Database monitoring
-   [ ] Cache monitoring
-   [ ] Queue monitoring
-   [ ] Storage monitoring
-   [ ] Network monitoring
-   [ ] Security monitoring

## Notes

-   Monitor all critical systems
-   Set up appropriate alerts
-   Regular monitoring reviews
-   Keep monitoring tools updated
-   Document monitoring procedures
-   Test monitoring systems
-   Review and update metrics
-   Monitor monitoring systems
