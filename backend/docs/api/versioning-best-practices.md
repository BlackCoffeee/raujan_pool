# API Versioning & Best Practices

Panduan lengkap untuk API versioning dan best practices.

## API Versioning Strategy

### 1. URL Versioning

```
Current: /api/v1/endpoint
Future:  /api/v2/endpoint
```

**Advantages:**

-   Clear and explicit
-   Easy to understand
-   Backward compatibility

**Implementation:**

```php
// routes/api.php
Route::prefix('v1')->group(function () {
    Route::get('/bookings', [BookingController::class, 'index']);
    Route::post('/bookings', [BookingController::class, 'store']);
});

Route::prefix('v2')->group(function () {
    Route::get('/bookings', [V2\BookingController::class, 'index']);
    Route::post('/bookings', [V2\BookingController::class, 'store']);
});
```

### 2. Header Versioning

```
Accept: application/vnd.api+json;version=1
Accept: application/vnd.api+json;version=2
```

**Implementation:**

```php
// Middleware for header versioning
class ApiVersionMiddleware
{
    public function handle($request, Closure $next)
    {
        $version = $request->header('Accept');

        if (str_contains($version, 'version=2')) {
            $request->setRouteResolver(function () use ($request) {
                return app('router')->getRoutes()->match($request);
            });
        }

        return $next($request);
    }
}
```

## API Design Principles

### 1. RESTful Design

#### Resource Naming

```http
# Good
GET    /api/v1/bookings
POST   /api/v1/bookings
GET    /api/v1/bookings/{id}
PUT    /api/v1/bookings/{id}
DELETE /api/v1/bookings/{id}

# Bad
GET    /api/v1/getBookings
POST   /api/v1/createBooking
GET    /api/v1/bookingDetails/{id}
POST   /api/v1/updateBooking/{id}
POST   /api/v1/deleteBooking/{id}
```

#### HTTP Methods

| Method | Usage                  | Example                        |
| ------ | ---------------------- | ------------------------------ |
| GET    | Retrieve resource(s)   | `GET /api/v1/bookings`         |
| POST   | Create new resource    | `POST /api/v1/bookings`        |
| PUT    | Update entire resource | `PUT /api/v1/bookings/{id}`    |
| PATCH  | Partial update         | `PATCH /api/v1/bookings/{id}`  |
| DELETE | Remove resource        | `DELETE /api/v1/bookings/{id}` |

### 2. Response Format Consistency

#### Success Response

```json
{
    "success": true,
    "message": "Operation successful",
    "data": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com"
    },
    "meta": {
        "timestamp": "2024-01-15T08:00:00Z",
        "version": "1.0"
    }
}
```

#### Error Response

```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "email": ["The email field is required."]
    },
    "code": "VALIDATION_ERROR",
    "meta": {
        "timestamp": "2024-01-15T08:00:00Z",
        "version": "1.0"
    }
}
```

### 3. Pagination

#### Standard Pagination

```json
{
    "success": true,
    "data": {
        "items": [...],
        "pagination": {
            "current_page": 1,
            "per_page": 15,
            "total": 100,
            "last_page": 7,
            "from": 1,
            "to": 15
        }
    }
}
```

#### Cursor-based Pagination

```json
{
    "success": true,
    "data": {
        "items": [...],
        "pagination": {
            "next_cursor": "eyJpZCI6MTB9",
            "prev_cursor": "eyJpZCI6MX0=",
            "has_next": true,
            "has_prev": false
        }
    }
}
```

## Authentication & Authorization

### 1. Token-based Authentication

```http
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

### 2. Role-based Access Control

```php
// Middleware for role checking
class RoleMiddleware
{
    public function handle($request, Closure $next, $role)
    {
        if (!$request->user() || $request->user()->role !== $role) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied',
                'code' => 'FORBIDDEN'
            ], 403);
        }

        return $next($request);
    }
}
```

### 3. Permission-based Access Control

```php
// Check specific permissions
if (!$request->user()->can('create-booking')) {
    return response()->json([
        'success' => false,
        'message' => 'Permission denied',
        'code' => 'PERMISSION_DENIED'
    ], 403);
}
```

## Rate Limiting

### 1. Global Rate Limiting

```php
// routes/api.php
Route::middleware(['throttle:60,1'])->group(function () {
    Route::get('/bookings', [BookingController::class, 'index']);
});
```

### 2. Per-user Rate Limiting

```php
// Custom rate limiting
Route::middleware(['throttle:user'])->group(function () {
    Route::post('/bookings', [BookingController::class, 'store']);
});
```

### 3. Rate Limit Headers

```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 59
X-RateLimit-Reset: 1642248000
```

## Caching Strategy

### 1. Response Caching

```php
// Cache API responses
public function index(Request $request)
{
    $cacheKey = 'bookings:' . md5(serialize($request->all()));

    return Cache::remember($cacheKey, 300, function () use ($request) {
        return Booking::with('user', 'session')->paginate(15);
    });
}
```

### 2. Cache Invalidation

```php
// Invalidate cache on update
public function update(Request $request, Booking $booking)
{
    $booking->update($request->validated());

    // Invalidate related caches
    Cache::forget('bookings:' . md5(serialize($request->all())));
    Cache::forget('user-bookings:' . $booking->user_id);

    return response()->json([
        'success' => true,
        'message' => 'Booking updated successfully',
        'data' => $booking
    ]);
}
```

## Input Validation

### 1. Request Validation

```php
// Form Request
class CreateBookingRequest extends FormRequest
{
    public function rules()
    {
        return [
            'session_id' => 'required|exists:sessions,id',
            'booking_date' => 'required|date|after:today',
            'notes' => 'nullable|string|max:500'
        ];
    }

    public function messages()
    {
        return [
            'session_id.required' => 'Session is required',
            'booking_date.after' => 'Booking date must be in the future'
        ];
    }
}
```

### 2. Custom Validation Rules

```php
// Custom validation rule
class AvailableSessionRule implements Rule
{
    public function passes($attribute, $value)
    {
        $session = Session::find($value);
        return $session && $session->isAvailable();
    }

    public function message()
    {
        return 'The selected session is not available.';
    }
}
```

## Error Handling

### 1. Global Exception Handler

```php
// app/Exceptions/Handler.php
public function render($request, Throwable $exception)
{
    if ($request->expectsJson()) {
        return $this->handleApiException($request, $exception);
    }

    return parent::render($request, $exception);
}

private function handleApiException($request, Throwable $exception)
{
    if ($exception instanceof ValidationException) {
        return response()->json([
            'success' => false,
            'message' => 'Validation failed',
            'errors' => $exception->errors()
        ], 422);
    }

    if ($exception instanceof ModelNotFoundException) {
        return response()->json([
            'success' => false,
            'message' => 'Resource not found',
            'code' => 'NOT_FOUND'
        ], 404);
    }

    return response()->json([
        'success' => false,
        'message' => 'Internal server error',
        'code' => 'INTERNAL_ERROR'
    ], 500);
}
```

### 2. Custom Exceptions

```php
// Custom exception
class BookingNotAvailableException extends Exception
{
    public function render($request)
    {
        return response()->json([
            'success' => false,
            'message' => 'Booking is not available',
            'code' => 'BOOKING_NOT_AVAILABLE'
        ], 422);
    }
}
```

## API Documentation

### 1. OpenAPI Specification

```yaml
# openapi.yaml
openapi: 3.0.0
info:
    title: Raujan Pool API
    version: 1.0.0
    description: API for Raujan Pool management system

paths:
    /api/v1/bookings:
        get:
            summary: List bookings
            parameters:
                - name: page
                  in: query
                  schema:
                      type: integer
                      default: 1
            responses:
                "200":
                    description: Successful response
                    content:
                        application/json:
                            schema:
                                type: object
                                properties:
                                    success:
                                        type: boolean
                                    data:
                                        type: object
                                        properties:
                                            bookings:
                                                type: array
                                                items:
                                                    $ref: "#/components/schemas/Booking"
```

### 2. API Documentation Generator

```php
// Generate documentation
php artisan l5-swagger:generate
```

## Testing Best Practices

### 1. API Testing

```php
// Feature test
test('user can create booking', function () {
    $user = User::factory()->create();
    $session = Session::factory()->create();

    $response = $this->actingAs($user)
        ->postJson('/api/v1/bookings', [
            'session_id' => $session->id,
            'booking_date' => '2024-01-15'
        ]);

    $response->assertStatus(201)
        ->assertJsonStructure([
            'success',
            'message',
            'data' => [
                'booking' => [
                    'id',
                    'booking_code',
                    'status'
                ]
            ]
        ]);
});
```

### 2. Contract Testing

```php
// Test API contract
test('booking response matches schema', function () {
    $booking = Booking::factory()->create();

    $response = $this->getJson("/api/v1/bookings/{$booking->id}");

    $response->assertJsonSchema([
        'type' => 'object',
        'required' => ['success', 'data'],
        'properties' => [
            'success' => ['type' => 'boolean'],
            'data' => [
                'type' => 'object',
                'required' => ['id', 'booking_code', 'status']
            ]
        ]
    ]);
});
```

## Performance Optimization

### 1. Database Optimization

```php
// Eager loading
$bookings = Booking::with(['user', 'session', 'payments'])
    ->paginate(15);

// Query optimization
$bookings = Booking::select(['id', 'booking_code', 'status', 'user_id'])
    ->with('user:id,name,email')
    ->paginate(15);
```

### 2. Response Optimization

```php
// Response compression
public function index()
{
    $data = Booking::paginate(15);

    return response()->json($data)
        ->header('Content-Encoding', 'gzip');
}
```

## Security Best Practices

### 1. Input Sanitization

```php
// Sanitize input
public function store(Request $request)
{
    $data = $request->only(['session_id', 'booking_date', 'notes']);
    $data['notes'] = strip_tags($data['notes']);

    $booking = Booking::create($data);

    return response()->json([
        'success' => true,
        'data' => $booking
    ]);
}
```

### 2. SQL Injection Prevention

```php
// Use Eloquent ORM
$bookings = Booking::where('user_id', $userId)
    ->where('status', 'confirmed')
    ->get();

// Avoid raw queries
// BAD: DB::select("SELECT * FROM bookings WHERE user_id = $userId");
// GOOD: Booking::where('user_id', $userId)->get();
```

### 3. XSS Prevention

```php
// Escape output
return response()->json([
    'success' => true,
    'data' => [
        'notes' => e($booking->notes)
    ]
]);
```

## Monitoring and Logging

### 1. API Logging

```php
// Log API requests
class ApiLogMiddleware
{
    public function handle($request, Closure $next)
    {
        $start = microtime(true);

        $response = $next($request);

        $duration = microtime(true) - $start;

        Log::info('API Request', [
            'method' => $request->method(),
            'url' => $request->fullUrl(),
            'status' => $response->getStatusCode(),
            'duration' => $duration,
            'user_id' => $request->user()?->id
        ]);

        return $response;
    }
}
```

### 2. Performance Monitoring

```php
// Monitor slow queries
DB::listen(function ($query) {
    if ($query->time > 1000) { // 1 second
        Log::warning('Slow query detected', [
            'sql' => $query->sql,
            'bindings' => $query->bindings,
            'time' => $query->time
        ]);
    }
});
```

## Notes

-   Konsistensi adalah kunci dalam API design
-   Selalu versioning API untuk backward compatibility
-   Implementasikan rate limiting untuk mencegah abuse
-   Gunakan caching untuk meningkatkan performance
-   Test API secara menyeluruh
-   Monitor dan log semua aktivitas API
-   Dokumentasikan API dengan baik
-   Implementasikan security best practices
