# API Performance & Optimization

Panduan lengkap untuk optimasi performa API dan best practices.

## Performance Metrics

### 1. Key Performance Indicators (KPIs)

#### Response Time

-   **Target**: < 200ms average
-   **Acceptable**: < 500ms
-   **Critical**: > 1000ms

#### Throughput

-   **Target**: 1000+ requests/second
-   **Acceptable**: 500+ requests/second
-   **Critical**: < 100 requests/second

#### Error Rate

-   **Target**: < 0.1%
-   **Acceptable**: < 1%
-   **Critical**: > 5%

#### Uptime

-   **Target**: 99.9%
-   **Acceptable**: 99.5%
-   **Critical**: < 99%

### 2. Performance Monitoring

```php
// app/Http/Middleware/PerformanceMiddleware.php
class PerformanceMiddleware
{
    public function handle($request, Closure $next)
    {
        $start = microtime(true);
        $startMemory = memory_get_usage();

        $response = $next($request);

        $end = microtime(true);
        $endMemory = memory_get_usage();

        $duration = ($end - $start) * 1000; // Convert to milliseconds
        $memoryUsage = $endMemory - $startMemory;

        // Log performance metrics
        Log::info('API Performance', [
            'url' => $request->fullUrl(),
            'method' => $request->method(),
            'duration_ms' => round($duration, 2),
            'memory_usage' => $memoryUsage,
            'status_code' => $response->getStatusCode(),
            'user_id' => $request->user()?->id
        ]);

        // Add performance headers
        $response->headers->set('X-Response-Time', $duration . 'ms');
        $response->headers->set('X-Memory-Usage', $memoryUsage . ' bytes');

        return $response;
    }
}
```

## Database Optimization

### 1. Query Optimization

#### Eager Loading

```php
// Bad - N+1 query problem
$bookings = Booking::all();
foreach ($bookings as $booking) {
    echo $booking->user->name; // N+1 queries
}

// Good - Eager loading
$bookings = Booking::with(['user', 'session', 'payments'])->get();
foreach ($bookings as $booking) {
    echo $booking->user->name; // No additional queries
}
```

#### Query Optimization

```php
// Bad - Inefficient query
$bookings = Booking::where('status', 'confirmed')
    ->where('created_at', '>', now()->subDays(30))
    ->get();

// Good - Optimized query
$bookings = Booking::select(['id', 'booking_code', 'status', 'user_id', 'created_at'])
    ->where('status', 'confirmed')
    ->where('created_at', '>', now()->subDays(30))
    ->with(['user:id,name,email'])
    ->get();
```

#### Database Indexing

```php
// Migration for database indexes
Schema::table('bookings', function (Blueprint $table) {
    $table->index(['user_id', 'status']);
    $table->index(['booking_date', 'status']);
    $table->index(['created_at']);
    $table->index(['payment_status']);
});

Schema::table('users', function (Blueprint $table) {
    $table->index(['email']);
    $table->index(['role']);
    $table->index(['status']);
});
```

### 2. Database Connection Optimization

```php
// config/database.php
'mysql' => [
    'driver' => 'mysql',
    'host' => env('DB_HOST', '127.0.0.1'),
    'port' => env('DB_PORT', '3306'),
    'database' => env('DB_DATABASE', 'forge'),
    'username' => env('DB_USERNAME', 'forge'),
    'password' => env('DB_PASSWORD', ''),
    'charset' => 'utf8mb4',
    'collation' => 'utf8mb4_unicode_ci',
    'prefix' => '',
    'strict' => true,
    'engine' => null,
    'options' => [
        PDO::ATTR_PERSISTENT => true,
        PDO::ATTR_EMULATE_PREPARES => false,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ],
    'pool' => [
        'min_connections' => 5,
        'max_connections' => 20,
        'connect_timeout' => 10.0,
        'wait_timeout' => 3.0,
        'heartbeat' => -1,
        'max_idle_time' => 60.0,
    ],
],
```

## Caching Strategy

### 1. Response Caching

```php
// app/Http/Controllers/BookingController.php
class BookingController extends Controller
{
    public function index(Request $request)
    {
        $cacheKey = 'bookings:' . md5(serialize($request->all()));

        return Cache::remember($cacheKey, 300, function () use ($request) {
            return Booking::with(['user', 'session'])
                ->when($request->status, function ($query, $status) {
                    return $query->where('status', $status);
                })
                ->when($request->date_from, function ($query, $date) {
                    return $query->where('booking_date', '>=', $date);
                })
                ->paginate(15);
        });
    }

    public function show(Booking $booking)
    {
        $cacheKey = "booking:{$booking->id}";

        return Cache::remember($cacheKey, 600, function () use ($booking) {
            return $booking->load(['user', 'session', 'payments']);
        });
    }
}
```

### 2. Query Result Caching

```php
// app/Services/BookingService.php
class BookingService
{
    public function getAvailableSessions($date)
    {
        $cacheKey = "available_sessions:{$date}";

        return Cache::remember($cacheKey, 300, function () use ($date) {
            return Session::where('is_active', true)
                ->whereDoesntHave('bookings', function ($query) use ($date) {
                    $query->where('booking_date', $date)
                        ->where('status', '!=', 'cancelled');
                })
                ->get();
        });
    }

    public function getBookingStatistics()
    {
        $cacheKey = 'booking_statistics:' . now()->format('Y-m-d');

        return Cache::remember($cacheKey, 3600, function () {
            return [
                'total_bookings' => Booking::count(),
                'confirmed_bookings' => Booking::where('status', 'confirmed')->count(),
                'cancelled_bookings' => Booking::where('status', 'cancelled')->count(),
                'pending_bookings' => Booking::where('status', 'pending')->count(),
            ];
        });
    }
}
```

### 3. Cache Invalidation

```php
// app/Http/Controllers/BookingController.php
public function store(CreateBookingRequest $request)
{
    $booking = Booking::create($request->validated());

    // Invalidate related caches
    Cache::forget('bookings:' . md5(serialize($request->all())));
    Cache::forget("available_sessions:{$booking->booking_date}");
    Cache::forget('booking_statistics:' . now()->format('Y-m-d'));

    return response()->json([
        'success' => true,
        'data' => $booking
    ]);
}
```

## API Response Optimization

### 1. Response Compression

```php
// app/Http/Middleware/CompressionMiddleware.php
class CompressionMiddleware
{
    public function handle($request, Closure $next)
    {
        $response = $next($request);

        if ($request->header('Accept-Encoding') && strpos($request->header('Accept-Encoding'), 'gzip') !== false) {
            $content = $response->getContent();
            $compressed = gzencode($content, 6);

            if ($compressed !== false && strlen($compressed) < strlen($content)) {
                $response->setContent($compressed);
                $response->headers->set('Content-Encoding', 'gzip');
                $response->headers->set('Content-Length', strlen($compressed));
            }
        }

        return $response;
    }
}
```

### 2. Response Pagination

```php
// app/Http/Controllers/BookingController.php
public function index(Request $request)
{
    $perPage = min($request->get('per_page', 15), 100); // Max 100 items per page

    $bookings = Booking::with(['user:id,name,email', 'session:id,name'])
        ->when($request->status, function ($query, $status) {
            return $query->where('status', $status);
        })
        ->paginate($perPage);

    return response()->json([
        'success' => true,
        'data' => [
            'bookings' => $bookings->items(),
            'pagination' => [
                'current_page' => $bookings->currentPage(),
                'per_page' => $bookings->perPage(),
                'total' => $bookings->total(),
                'last_page' => $bookings->lastPage(),
                'from' => $bookings->firstItem(),
                'to' => $bookings->lastItem(),
            ]
        ]
    ]);
}
```

### 3. Field Selection

```php
// app/Http/Controllers/UserController.php
public function index(Request $request)
{
    $fields = $request->get('fields', 'id,name,email,role');
    $fieldArray = explode(',', $fields);

    $users = User::select($fieldArray)
        ->when($request->role, function ($query, $role) {
            return $query->where('role', $role);
        })
        ->paginate(15);

    return response()->json([
        'success' => true,
        'data' => $users
    ]);
}
```

## Memory Optimization

### 1. Memory Usage Monitoring

```php
// app/Http/Middleware/MemoryMiddleware.php
class MemoryMiddleware
{
    public function handle($request, Closure $next)
    {
        $startMemory = memory_get_usage();

        $response = $next($request);

        $endMemory = memory_get_usage();
        $memoryUsage = $endMemory - $startMemory;

        // Log memory usage
        if ($memoryUsage > 1024 * 1024) { // More than 1MB
            Log::warning('High memory usage', [
                'url' => $request->fullUrl(),
                'memory_usage' => $memoryUsage,
                'peak_memory' => memory_get_peak_usage()
            ]);
        }

        return $response;
    }
}
```

### 2. Chunked Processing

```php
// app/Http/Controllers/ExportController.php
public function exportBookings()
{
    $response = response()->stream(function () {
        $handle = fopen('php://output', 'w');

        // Write CSV header
        fputcsv($handle, ['ID', 'Booking Code', 'User Name', 'Session Name', 'Date', 'Status']);

        // Process in chunks
        Booking::with(['user', 'session'])
            ->chunk(1000, function ($bookings) use ($handle) {
                foreach ($bookings as $booking) {
                    fputcsv($handle, [
                        $booking->id,
                        $booking->booking_code,
                        $booking->user->name,
                        $booking->session->name,
                        $booking->booking_date,
                        $booking->status
                    ]);
                }
            });

        fclose($handle);
    });

    $response->headers->set('Content-Type', 'text/csv');
    $response->headers->set('Content-Disposition', 'attachment; filename="bookings.csv"');

    return $response;
}
```

## Queue Optimization

### 1. Job Optimization

```php
// app/Jobs/SendNotificationJob.php
class SendNotificationJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $timeout = 30;
    public $tries = 3;
    public $maxExceptions = 2;

    public function handle()
    {
        // Process notification
        $this->sendNotification();
    }

    public function failed(Throwable $exception)
    {
        Log::error('Notification job failed', [
            'exception' => $exception->getMessage(),
            'job' => get_class($this)
        ]);
    }
}
```

### 2. Queue Configuration

```php
// config/queue.php
'redis' => [
    'driver' => 'redis',
    'connection' => 'default',
    'queue' => env('REDIS_QUEUE', 'default'),
    'retry_after' => 90,
    'block_for' => null,
    'after_commit' => false,
],

'horizon' => [
    'environments' => [
        'production' => [
            'supervisor-1' => [
                'connection' => 'redis',
                'queue' => ['default', 'notifications', 'emails'],
                'balance' => 'simple',
                'processes' => 10,
                'tries' => 3,
                'timeout' => 60,
                'memory' => 512,
            ],
        ],
    ],
],
```

## CDN and Static Assets

### 1. CDN Configuration

```php
// config/filesystems.php
'cdn' => [
    'driver' => 's3',
    'key' => env('AWS_ACCESS_KEY_ID'),
    'secret' => env('AWS_SECRET_ACCESS_KEY'),
    'region' => env('AWS_DEFAULT_REGION'),
    'bucket' => env('AWS_BUCKET'),
    'url' => env('AWS_URL'),
    'endpoint' => env('AWS_ENDPOINT'),
    'use_path_style_endpoint' => env('AWS_USE_PATH_STYLE_ENDPOINT', false),
    'throw' => false,
],
```

### 2. Asset Optimization

```php
// app/Http/Controllers/AssetController.php
class AssetController extends Controller
{
    public function serve($path)
    {
        $file = Storage::disk('cdn')->get($path);

        $response = response($file);
        $response->headers->set('Cache-Control', 'public, max-age=31536000');
        $response->headers->set('ETag', md5($file));

        return $response;
    }
}
```

## Performance Testing

### 1. Load Testing

```bash
# Using Apache Bench
ab -n 1000 -c 10 http://localhost:8000/api/v1/bookings

# Using Artillery
artillery run load-test.yml
```

### 2. Performance Test Configuration

```yaml
# load-test.yml
config:
    target: "http://localhost:8000"
    phases:
        - duration: 60
          arrivalRate: 10
    defaults:
        headers:
            Authorization: "Bearer {{token}}"

scenarios:
    - name: "API Load Test"
      flow:
          - get:
                url: "/api/v1/bookings"
          - post:
                url: "/api/v1/bookings"
                json:
                    session_id: 1
                    booking_date: "2024-01-15"
```

### 3. Performance Monitoring

```php
// app/Http/Middleware/PerformanceMonitoringMiddleware.php
class PerformanceMonitoringMiddleware
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

        // Send to monitoring service
        $this->sendMetrics([
            'endpoint' => $request->path(),
            'method' => $request->method(),
            'duration' => $duration,
            'memory' => $memoryUsage,
            'status' => $response->getStatusCode(),
            'timestamp' => now()
        ]);

        return $response;
    }

    private function sendMetrics($metrics)
    {
        // Send to monitoring service (e.g., DataDog, New Relic)
        if (config('monitoring.enabled')) {
            // Implementation depends on monitoring service
        }
    }
}
```

## Best Practices

### 1. Database

-   Use database indexes
-   Optimize queries
-   Use eager loading
-   Implement query caching
-   Monitor slow queries

### 2. Caching

-   Cache frequently accessed data
-   Use appropriate cache TTL
-   Implement cache invalidation
-   Monitor cache hit rates
-   Use distributed caching

### 3. API Design

-   Implement pagination
-   Use field selection
-   Compress responses
-   Optimize payload size
-   Use appropriate HTTP methods

### 4. Memory Management

-   Monitor memory usage
-   Use chunked processing
-   Implement garbage collection
-   Optimize data structures
-   Use streaming for large data

### 5. Queue Processing

-   Optimize job processing
-   Use appropriate queue drivers
-   Implement job retry logic
-   Monitor queue performance
-   Use job batching

## Performance Checklist

-   [ ] Database queries optimized
-   [ ] Indexes created
-   [ ] Caching implemented
-   [ ] Response compression enabled
-   [ ] Pagination implemented
-   [ ] Memory usage monitored
-   [ ] Queue processing optimized
-   [ ] CDN configured
-   [ ] Performance testing done
-   [ ] Monitoring implemented
-   [ ] Load balancing configured
-   [ ] Database connection pooling
-   [ ] Query result caching
-   [ ] Response optimization
-   [ ] Memory optimization
-   [ ] Queue optimization
-   [ ] Asset optimization
-   [ ] Performance monitoring
-   [ ] Load testing
-   [ ] Performance documentation

## Notes

-   Monitor performance metrics regularly
-   Implement performance testing
-   Use profiling tools
-   Optimize based on real usage
-   Document performance requirements
-   Set up performance alerts
-   Regular performance reviews
-   Keep dependencies updated
