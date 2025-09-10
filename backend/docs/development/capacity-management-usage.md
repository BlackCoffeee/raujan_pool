# Capacity Management Usage Guide

## Overview

Capacity Management System adalah fitur yang memungkinkan pengelolaan kapasitas kolam renang secara dinamis, termasuk sistem antrian, monitoring real-time, dan analytics. Sistem ini dirancang untuk mengoptimalkan penggunaan kapasitas dan memberikan pengalaman yang lebih baik kepada pengguna.

## Features

### 1. Dynamic Capacity Management

-   Penyesuaian kapasitas session secara real-time
-   Monitoring utilization dan performance
-   Alerts untuk kondisi kapasitas

### 2. Queue System

-   Antrian otomatis ketika kapasitas penuh
-   Prioritas berdasarkan tipe booking
-   Estimasi waktu tunggu
-   Notifikasi real-time

### 3. Analytics & Monitoring

-   Utilization statistics
-   Peak usage analysis
-   Capacity recommendations
-   Performance metrics

## Architecture

### Models

#### CapacityQueue

Model untuk mengelola antrian kapasitas.

```php
// Create queue entry
$queueEntry = CapacityQueue::create([
    'session_id' => 1,
    'date' => '2025-09-01',
    'requested_slots' => 2,
    'user_id' => 1,
    'booking_type' => 'regular',
    'priority' => 1,
    'status' => 'pending'
]);
```

#### Session

Model session dengan kapasitas dinamis.

```php
// Adjust capacity
$session = Session::find(1);
$session->update(['max_capacity' => 15]);
```

### Services

#### CapacityService

Service utama untuk mengelola kapasitas dan antrian.

```php
use App\Services\CapacityService;

$capacityService = app(CapacityService::class);

// Check capacity
$availability = $capacityService->checkCapacity(1, '2025-09-01', 2);

// Add to queue
$queueEntry = $capacityService->addToQueue(1, '2025-09-01', 2, 1, null, 'regular');

// Process queue
$capacityService->processQueue(1, '2025-09-01');
```

### Jobs

#### ProcessCapacityQueue

Job untuk memproses antrian secara asynchronous.

```php
use App\Jobs\ProcessCapacityQueue;

// Dispatch job
ProcessCapacityQueue::dispatch($sessionId, $date);
```

### Events

#### CapacityUpdated

Event untuk notifikasi real-time.

```php
use App\Events\CapacityUpdated;

// Broadcast event
broadcast(new CapacityUpdated($sessionId, $date, $capacityData, $queueData));
```

## Usage Examples

### 1. Basic Capacity Check

```php
use App\Services\CapacityService;

$capacityService = app(CapacityService::class);

// Check if capacity is available
$result = $capacityService->checkCapacity(
    sessionId: 1,
    date: '2025-09-01',
    requestedSlots: 2
);

if ($result['available']) {
    // Create booking directly
    $booking = BookingService::createBooking($bookingData);
} else {
    // Add to queue
    $queueEntry = $capacityService->addToQueue(
        sessionId: 1,
        date: '2025-09-01',
        requestedSlots: 2,
        userId: 1,
        guestUserId: null,
        bookingType: 'regular'
    );
}
```

### 2. Queue Management

```php
// Get queue status
$queueStatus = $capacityService->getQueueStatus(1, '2025-09-01');

echo "Total in queue: " . $queueStatus['total_in_queue'];
echo "Average wait time: " . $queueStatus['average_wait_time'] . " minutes";

// Process queue entries
$capacityService->processQueue(1, '2025-09-01');

// Remove from queue
$capacityService->removeFromQueue($queueId, 'user_cancelled');
```

### 3. Capacity Adjustment

```php
// Adjust capacity based on demand
$currentCapacity = $session->max_capacity;
$newCapacity = $currentCapacity + 5;

$capacityService->adjustCapacity(1, $newCapacity, 'demand_increase');
```

### 4. Analytics and Monitoring

```php
// Get capacity analytics
$analytics = $capacityService->getCapacityAnalytics(1, '2025-08-01', '2025-09-01');

echo "Average utilization: " . $analytics['capacity_stats']['average_utilization'] . "%";
echo "Peak utilization: " . $analytics['capacity_stats']['peak_utilization'] . "%";

// Get alerts
$alerts = $capacityService->getCapacityAlerts(1);

foreach ($alerts as $alert) {
    if ($alert['type'] === 'high_utilization') {
        // Send notification to admin
        Notification::send($admin, new HighUtilizationAlert($alert));
    }
}
```

### 5. Real-time Updates

```javascript
// Frontend - Listen for capacity updates
Echo.channel("capacity-updates.1").listen("capacity.updated", (e) => {
    console.log("Capacity updated:", e);

    // Update UI
    updateCapacityDisplay(e.capacity);
    updateQueueDisplay(e.queue);
});
```

```php
// Backend - Broadcast capacity update
broadcast(new CapacityUpdated(
    sessionId: 1,
    date: '2025-09-01',
    capacityData: $capacityData,
    queueData: $queueData
));
```

## Configuration

### Environment Variables

```env
# Queue configuration
QUEUE_CONNECTION=redis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

# Broadcasting configuration
BROADCAST_DRIVER=pusher
PUSHER_APP_ID=your_app_id
PUSHER_APP_KEY=your_app_key
PUSHER_APP_SECRET=your_app_secret
PUSHER_APP_CLUSTER=mt1
```

### Queue Configuration

```php
// config/queue.php
'connections' => [
    'redis' => [
        'driver' => 'redis',
        'connection' => 'default',
        'queue' => env('REDIS_QUEUE', 'default'),
        'retry_after' => 90,
        'block_for' => null,
    ],
],
```

### Broadcasting Configuration

```php
// config/broadcasting.php
'connections' => [
    'pusher' => [
        'driver' => 'pusher',
        'key' => env('PUSHER_APP_KEY'),
        'secret' => env('PUSHER_APP_SECRET'),
        'app_id' => env('PUSHER_APP_ID'),
        'options' => [
            'cluster' => env('PUSHER_APP_CLUSTER'),
            'useTLS' => true,
        ],
    ],
],
```

## Testing

### Unit Tests

```php
// tests/Unit/CapacityServiceTest.php
use App\Services\CapacityService;

it('can check capacity availability', function () {
    $capacityService = app(CapacityService::class);

    $result = $capacityService->checkCapacity(1, '2025-09-01', 2);

    expect($result)->toHaveKey('available');
    expect($result['available'])->toBeBool();
});
```

### Feature Tests

```php
// tests/Feature/CapacityManagementTest.php
it('can add to capacity queue', function () {
    $session = Session::factory()->create(['max_capacity' => 5]);
    $user = User::factory()->create();

    $queueEntry = $this->capacityService->addToQueue(
        $session->id,
        '2025-09-01',
        2,
        $user->id,
        null,
        'regular'
    );

    expect($queueEntry)->toBeInstanceOf(CapacityQueue::class);
    expect($queueEntry->status)->toBe('pending');
});
```

## Performance Optimization

### 1. Database Indexing

```php
// Migration - Add indexes for performance
Schema::table('capacity_queues', function (Blueprint $table) {
    $table->index(['session_id', 'date', 'status']);
    $table->index(['user_id', 'status']);
    $table->index(['status', 'priority', 'created_at']);
});
```

### 2. Caching

```php
// Cache capacity data
$cacheKey = "capacity:{$sessionId}:{$date}";
$capacity = Cache::remember($cacheKey, 300, function () use ($sessionId, $date) {
    return $this->getCurrentAvailability($sessionId, $date);
});
```

### 3. Queue Optimization

```php
// Process queue in batches
$queueEntries = CapacityQueue::pending()
    ->where('session_id', $sessionId)
    ->whereDate('date', $date)
    ->chunk(10, function ($entries) {
        foreach ($entries as $entry) {
            $this->processQueueEntry($entry);
        }
    });
```

## Monitoring and Logging

### 1. Logging

```php
// Log capacity events
Log::info('Capacity adjusted', [
    'session_id' => $sessionId,
    'old_capacity' => $oldCapacity,
    'new_capacity' => $newCapacity,
    'reason' => $reason
]);
```

### 2. Metrics

```php
// Track capacity metrics
$metrics = [
    'utilization_percentage' => $utilization,
    'queue_length' => $queueLength,
    'average_wait_time' => $averageWaitTime,
    'capacity_adjustments' => $adjustmentCount
];

// Send to monitoring service
Metrics::gauge('capacity.utilization', $utilization, ['session_id' => $sessionId]);
```

## Troubleshooting

### Common Issues

#### 1. Queue Not Processing

```php
// Check queue worker status
php artisan queue:work --queue=capacity

// Check failed jobs
php artisan queue:failed
```

#### 2. Real-time Updates Not Working

```php
// Check broadcasting configuration
php artisan config:cache
php artisan queue:restart

// Test broadcasting
php artisan tinker
broadcast(new CapacityUpdated(1, '2025-09-01', [], []));
```

#### 3. Performance Issues

```php
// Optimize database queries
DB::enableQueryLog();
$capacity = $capacityService->getCapacityAnalytics(1);
$queries = DB::getQueryLog();

// Add missing indexes
php artisan migrate
```

### Debug Commands

```bash
# Check queue status
php artisan queue:monitor

# Clear cache
php artisan cache:clear

# Restart workers
php artisan queue:restart

# Check broadcasting
php artisan config:show broadcasting
```

## Security Considerations

### 1. Input Validation

```php
// Validate all inputs
$request->validate([
    'session_id' => 'required|exists:sessions,id',
    'date' => 'required|date|after:today',
    'requested_slots' => 'required|integer|min:1|max:10'
]);
```

### 2. Authorization

```php
// Check user permissions
if (!$user->can('manage_capacity')) {
    abort(403, 'Unauthorized');
}
```

### 3. Rate Limiting

```php
// Apply rate limiting
Route::middleware(['throttle:capacity'])->group(function () {
    Route::post('/capacity/queue', [CapacityController::class, 'addToQueue']);
});
```

## Best Practices

1. **Always validate input** before processing
2. **Use transactions** for critical operations
3. **Implement proper error handling** and logging
4. **Cache frequently accessed data** for performance
5. **Use queues** for heavy operations
6. **Monitor performance** and set up alerts
7. **Test thoroughly** with various scenarios
8. **Document changes** and maintain versioning
9. **Use real-time updates** for better UX
10. **Implement proper security** measures
