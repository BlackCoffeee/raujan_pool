# API Middleware Documentation

## Overview

API menggunakan beberapa middleware untuk mengatur request/response, versioning, rate limiting, dan security.

## Middleware Stack

### 1. ApiResponseMiddleware

Middleware ini memformat semua response API menjadi format konsisten.

**Location:** `app/Http/Middleware/ApiResponseMiddleware.php`

**Function:**

-   Memformat response JSON menjadi struktur standar
-   Menambahkan field `success`, `message`, dan `data`
-   Hanya memproses request yang expect JSON atau route API

**Response Format:**

```json
{
    "success": true|false,
    "message": "Response message",
    "data": {}, // Response data atau null
    "errors": {} // Validation errors (jika ada)
}
```

**Implementation:**

```php
public function handle(Request $request, Closure $next): Response
{
    $response = $next($request);

    // Only process JSON responses
    if ($request->expectsJson() || $request->is('api/*')) {
        $data = $response->getData(true);

        // If response is already formatted, return as is
        if (isset($data['success'])) {
            return $response;
        }

        // Format successful response
        if ($response->getStatusCode() >= 200 && $response->getStatusCode() < 300) {
            $formattedData = [
                'success' => true,
                'message' => 'Request successful',
                'data' => $data
            ];
        } else {
            // Format error response
            $formattedData = [
                'success' => false,
                'message' => $data['message'] ?? 'An error occurred',
                'data' => null,
                'errors' => $data['errors'] ?? null
            ];
        }

        $response->setData($formattedData);
    }

    return $response;
}
```

### 2. ApiVersionMiddleware

Middleware untuk menangani API versioning.

**Location:** `app/Http/Middleware/ApiVersionMiddleware.php`

**Function:**

-   Validasi API version dari header `API-Version`
-   Menambahkan version ke request untuk digunakan di controller
-   Mengembalikan error jika version tidak didukung

**Usage:**

```bash
# Request dengan version
curl -H "API-Version: v1" http://localhost:8000/api/v1/public/health
```

**Supported Versions:**

-   `v1` (default)

**Error Response (400):**

```json
{
    "success": false,
    "message": "Unsupported API version",
    "data": null
}
```

**Implementation:**

```php
public function handle(Request $request, Closure $next): Response
{
    $version = $request->header('API-Version', 'v1');

    // Validate version
    if (!in_array($version, ['v1'])) {
        return response()->json([
            'success' => false,
            'message' => 'Unsupported API version',
            'data' => null
        ], 400);
    }

    // Add version to request
    $request->merge(['api_version' => $version]);

    return $next($request);
}
```

### 3. RateLimitMiddleware

Middleware untuk membatasi jumlah request per IP.

**Location:** `app/Http/Middleware/RateLimitMiddleware.php`

**Function:**

-   Membatasi 100 requests per menit per IP address
-   Menggunakan Laravel RateLimiter
-   Mengembalikan 429 jika melebihi limit

**Rate Limit:**

-   **Limit:** 100 requests
-   **Window:** 60 detik (1 menit)
-   **Key:** `api:{ip_address}`

**Error Response (429):**

```json
{
    "success": false,
    "message": "Too many requests. Please try again later.",
    "data": null
}
```

**Implementation:**

```php
public function handle(Request $request, Closure $next): Response
{
    $key = 'api:' . $request->ip();

    if (RateLimiter::tooManyAttempts($key, 100)) {
        return response()->json([
            'success' => false,
            'message' => 'Too many requests. Please try again later.',
            'data' => null
        ], 429);
    }

    RateLimiter::hit($key, 60); // 100 requests per minute

    return $next($request);
}
```

## Middleware Registration

Middleware didaftarkan di `bootstrap/app.php`:

```php
->withMiddleware(function (Middleware $middleware): void {
    $middleware->api(prepend: [
        \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
    ]);

    $middleware->api(append: [
        \App\Http\Middleware\ApiResponseMiddleware::class,
        \App\Http\Middleware\ApiVersionMiddleware::class,
        \App\Http\Middleware\RateLimitMiddleware::class,
    ]);

    $middleware->alias([
        'verified' => \App\Http\Middleware\EnsureEmailIsVerified::class,
        'role' => \App\Http\Middleware\CheckRole::class,
    ]);
})
```

## Middleware Order

Middleware dijalankan dalam urutan berikut:

1. **EnsureFrontendRequestsAreStateful** (Sanctum)
2. **ThrottleRequests** (Laravel default)
3. **SubstituteBindings** (Laravel default)
4. **ApiResponseMiddleware** (Custom)
5. **ApiVersionMiddleware** (Custom)
6. **RateLimitMiddleware** (Custom)

## Custom Middleware Usage

### Role Middleware

Middleware untuk mengecek role pengguna:

```php
// In routes
Route::middleware(['auth:sanctum', 'role:admin'])->group(function () {
    // Admin only routes
});

Route::middleware(['auth:sanctum', 'role:staff,admin'])->group(function () {
    // Staff and admin routes
});
```

### Verified Middleware

Middleware untuk mengecek email verification:

```php
Route::middleware(['auth:sanctum', 'verified'])->group(function () {
    // Verified users only
});
```

## Testing Middleware

### Test API Response Format

```php
test('api response format', function () {
    $response = $this->getJson('/api/v1/public/health');

    $response->assertStatus(200)
        ->assertJsonStructure([
            'success',
            'message',
            'data'
        ]);

    expect($response->json('success'))->toBeBool();
    expect($response->json('message'))->toBeString();
});
```

### Test API Versioning

```php
test('api versioning', function () {
    // Valid version
    $response = $this->getJson('/api/v1/public/health', [
        'API-Version' => 'v1'
    ]);
    $response->assertStatus(200);

    // Invalid version
    $response = $this->getJson('/api/v1/public/health', [
        'API-Version' => 'v2'
    ]);
    $response->assertStatus(400);
});
```

### Test Rate Limiting

```php
test('rate limiting', function () {
    // Make multiple requests
    for ($i = 0; $i < 5; $i++) {
        $response = $this->getJson('/api/v1/public/health');
        $response->assertStatus(200);
    }
});
```

## Configuration

### Rate Limiting Configuration

Rate limit dapat dikonfigurasi di middleware:

```php
// Change rate limit
if (RateLimiter::tooManyAttempts($key, 50)) { // 50 requests
    // ...
}

RateLimiter::hit($key, 300); // 5 minutes window
```

### CORS Configuration

CORS dikonfigurasi di `config/cors.php`:

```php
return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => [
        'http://localhost:3000',
        'https://raujanpool.com',
    ],
    'allowed_headers' => ['*'],
    'supports_credentials' => true,
];
```

## Best Practices

1. **Consistent Response Format** - Semua response menggunakan format yang sama
2. **Version Control** - Selalu specify API version dalam header
3. **Rate Limiting** - Implement rate limiting untuk mencegah abuse
4. **Error Handling** - Handle error dengan format yang konsisten
5. **Security** - Validasi semua input dan gunakan HTTPS
6. **Logging** - Log semua request untuk monitoring

## Troubleshooting

### Common Issues

1. **CORS Errors**

    - Pastikan origin frontend ada di `allowed_origins`
    - Check `supports_credentials` setting

2. **Rate Limit Exceeded**

    - Implement exponential backoff
    - Consider increasing limit untuk development

3. **Version Not Supported**

    - Pastikan menggunakan header `API-Version: v1`
    - Check middleware registration

4. **Response Format Issues**
    - Pastikan controller tidak mengembalikan response yang sudah diformat
    - Check middleware order


