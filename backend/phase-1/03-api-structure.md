# Point 3: API Structure Setup

## 📋 Overview

Setup struktur API dengan routes, middleware, versioning, CORS, dan dokumentasi.

## 🎯 Objectives

-   Setup API routes structure
-   Konfigurasi API middleware
-   Setup API versioning
-   Konfigurasi CORS
-   Setup API documentation (Postman ready)

## 📁 Files Structure

```
phase-1/
├── 03-api-structure.md
├── routes/
│   └── api.php
├── app/Http/
│   ├── Middleware/
│   └── Controllers/
└── config/cors.php
```

## 🔧 Implementation Steps

### Step 1: API Routes Structure

```bash
# Create API controller
php artisan make:controller Api/BaseController

# Create API middleware
php artisan make:middleware ApiResponseMiddleware
php artisan make:middleware ApiVersionMiddleware
php artisan make:middleware RateLimitMiddleware
```

### Step 2: Configure CORS

```bash
# Install CORS package
composer require fruitcake/laravel-cors
```

### Step 3: Setup API Documentation

```bash
# API documentation akan menggunakan Postman collection
# Dokumentasi tersedia di folder docs/api/
```

## 📊 API Routes Structure

### routes/api.php

```php
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\BaseController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// API Version 1
Route::prefix('v1')->group(function () {

    // Public routes (no authentication required)
    Route::prefix('public')->group(function () {
        Route::get('/health', [BaseController::class, 'health']);
        Route::get('/info', [BaseController::class, 'info']);
    });

    // Authentication routes
    Route::prefix('auth')->group(function () {
        Route::post('/login', [App\Http\Controllers\Api\V1\AuthController::class, 'login']);
        Route::post('/register', [App\Http\Controllers\Api\V1\AuthController::class, 'register']);
        Route::post('/logout', [App\Http\Controllers\Api\V1\AuthController::class, 'logout']);
        Route::post('/refresh', [App\Http\Controllers\Api\V1\AuthController::class, 'refresh']);
        Route::get('/user', [App\Http\Controllers\Api\V1\AuthController::class, 'user']);

        // Google OAuth routes
        Route::get('/google', [App\Http\Controllers\Api\V1\GoogleAuthController::class, 'redirect']);
        Route::get('/google/callback', [App\Http\Controllers\Api\V1\GoogleAuthController::class, 'callback']);
    });

    // Protected routes (authentication required)
    Route::middleware(['auth:sanctum'])->group(function () {

        // User routes
        Route::prefix('users')->group(function () {
            Route::get('/', [App\Http\Controllers\Api\V1\UserController::class, 'index']);
            Route::get('/{id}', [App\Http\Controllers\Api\V1\UserController::class, 'show']);
            Route::put('/{id}', [App\Http\Controllers\Api\V1\UserController::class, 'update']);
            Route::delete('/{id}', [App\Http\Controllers\Api\V1\UserController::class, 'destroy']);
        });

        // Profile routes
        Route::prefix('profile')->group(function () {
            Route::get('/', [App\Http\Controllers\Api\V1\ProfileController::class, 'show']);
            Route::put('/', [App\Http\Controllers\Api\V1\ProfileController::class, 'update']);
            Route::post('/avatar', [App\Http\Controllers\Api\V1\ProfileController::class, 'uploadAvatar']);
            Route::delete('/avatar', [App\Http\Controllers\Api\V1\ProfileController::class, 'deleteAvatar']);
        });

        // Booking routes
        Route::prefix('bookings')->group(function () {
            Route::get('/', [App\Http\Controllers\Api\V1\BookingController::class, 'index']);
            Route::post('/', [App\Http\Controllers\Api\V1\BookingController::class, 'store']);
            Route::get('/{id}', [App\Http\Controllers\Api\V1\BookingController::class, 'show']);
            Route::put('/{id}', [App\Http\Controllers\Api\V1\BookingController::class, 'update']);
            Route::delete('/{id}', [App\Http\Controllers\Api\V1\BookingController::class, 'destroy']);
            Route::post('/{id}/confirm', [App\Http\Controllers\Api\V1\BookingController::class, 'confirm']);
            Route::post('/{id}/cancel', [App\Http\Controllers\Api\V1\BookingController::class, 'cancel']);
        });

        // Calendar routes
        Route::prefix('calendar')->group(function () {
            Route::get('/availability', [App\Http\Controllers\Api\V1\CalendarController::class, 'availability']);
            Route::get('/sessions', [App\Http\Controllers\Api\V1\CalendarController::class, 'sessions']);
            Route::get('/dates/{date}', [App\Http\Controllers\Api\V1\CalendarController::class, 'getDateInfo']);
        });

        // Payment routes
        Route::prefix('payments')->group(function () {
            Route::get('/', [App\Http\Controllers\Api\V1\PaymentController::class, 'index']);
            Route::post('/', [App\Http\Controllers\Api\V1\PaymentController::class, 'store']);
            Route::get('/{id}', [App\Http\Controllers\Api\V1\PaymentController::class, 'show']);
            Route::put('/{id}', [App\Http\Controllers\Api\V1\PaymentController::class, 'update']);
            Route::post('/{id}/upload-proof', [App\Http\Controllers\Api\V1\PaymentController::class, 'uploadProof']);
            Route::get('/{id}/status', [App\Http\Controllers\Api\V1\PaymentController::class, 'getStatus']);
        });

        // Member routes
        Route::prefix('members')->group(function () {
            Route::get('/profile', [App\Http\Controllers\Api\V1\MemberController::class, 'profile']);
            Route::put('/profile', [App\Http\Controllers\Api\V1\MemberController::class, 'updateProfile']);
            Route::get('/quota', [App\Http\Controllers\Api\V1\MemberController::class, 'getQuota']);
            Route::get('/usage', [App\Http\Controllers\Api\V1\MemberController::class, 'getUsage']);
            Route::post('/register', [App\Http\Controllers\Api\V1\MemberController::class, 'register']);
        });

        // Cafe routes
        Route::prefix('cafe')->group(function () {
            Route::get('/menu', [App\Http\Controllers\Api\V1\CafeController::class, 'getMenu']);
            Route::get('/menu/{id}', [App\Http\Controllers\Api\V1\CafeController::class, 'getMenuItem']);
            Route::post('/orders', [App\Http\Controllers\Api\V1\CafeController::class, 'createOrder']);
            Route::get('/orders', [App\Http\Controllers\Api\V1\CafeController::class, 'getOrders']);
            Route::get('/orders/{id}', [App\Http\Controllers\Api\V1\CafeController::class, 'getOrder']);
            Route::post('/orders/{id}/feedback', [App\Http\Controllers\Api\V1\CafeController::class, 'submitFeedback']);
        });
    });

    // Admin routes (admin role required)
    Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {

        // User management
        Route::prefix('users')->group(function () {
            Route::get('/', [App\Http\Controllers\Api\V1\Admin\UserController::class, 'index']);
            Route::post('/', [App\Http\Controllers\Api\V1\Admin\UserController::class, 'store']);
            Route::get('/{id}', [App\Http\Controllers\Api\V1\Admin\UserController::class, 'show']);
            Route::put('/{id}', [App\Http\Controllers\Api\V1\Admin\UserController::class, 'update']);
            Route::delete('/{id}', [App\Http\Controllers\Api\V1\Admin\UserController::class, 'destroy']);
            Route::put('/{id}/suspend', [App\Http\Controllers\Api\V1\Admin\UserController::class, 'suspend']);
            Route::put('/{id}/activate', [App\Http\Controllers\Api\V1\Admin\UserController::class, 'activate']);
        });

        // Booking management
        Route::prefix('bookings')->group(function () {
            Route::get('/', [App\Http\Controllers\Api\V1\Admin\BookingController::class, 'index']);
            Route::get('/{id}', [App\Http\Controllers\Api\V1\Admin\BookingController::class, 'show']);
            Route::put('/{id}/status', [App\Http\Controllers\Api\V1\Admin\BookingController::class, 'updateStatus']);
            Route::get('/analytics', [App\Http\Controllers\Api\V1\Admin\BookingController::class, 'getAnalytics']);
        });

        // Payment management
        Route::prefix('payments')->group(function () {
            Route::get('/', [App\Http\Controllers\Api\V1\Admin\PaymentController::class, 'index']);
            Route::get('/{id}', [App\Http\Controllers\Api\V1\Admin\PaymentController::class, 'show']);
            Route::put('/{id}/verify', [App\Http\Controllers\Api\V1\Admin\PaymentController::class, 'verify']);
            Route::put('/{id}/reject', [App\Http\Controllers\Api\V1\Admin\PaymentController::class, 'reject']);
            Route::get('/analytics', [App\Http\Controllers\Api\V1\Admin\PaymentController::class, 'getAnalytics']);
        });

        // Member management
        Route::prefix('members')->group(function () {
            Route::get('/', [App\Http\Controllers\Api\V1\Admin\MemberController::class, 'index']);
            Route::post('/', [App\Http\Controllers\Api\V1\Admin\MemberController::class, 'store']);
            Route::get('/{id}', [App\Http\Controllers\Api\V1\Admin\MemberController::class, 'show']);
            Route::put('/{id}', [App\Http\Controllers\Api\V1\Admin\MemberController::class, 'update']);
            Route::delete('/{id}', [App\Http\Controllers\Api\V1\Admin\MemberController::class, 'destroy']);
            Route::get('/analytics', [App\Http\Controllers\Api\V1\Admin\MemberController::class, 'getAnalytics']);
        });

        // Cafe management
        Route::prefix('cafe')->group(function () {
            Route::prefix('menu')->group(function () {
                Route::get('/', [App\Http\Controllers\Api\V1\Admin\CafeController::class, 'getMenu']);
                Route::post('/', [App\Http\Controllers\Api\V1\Admin\CafeController::class, 'createMenuItem']);
                Route::get('/{id}', [App\Http\Controllers\Api\V1\Admin\CafeController::class, 'getMenuItem']);
                Route::put('/{id}', [App\Http\Controllers\Api\V1\Admin\CafeController::class, 'updateMenuItem']);
                Route::delete('/{id}', [App\Http\Controllers\Api\V1\Admin\CafeController::class, 'deleteMenuItem']);
            });

            Route::prefix('orders')->group(function () {
                Route::get('/', [App\Http\Controllers\Api\V1\Admin\CafeController::class, 'getOrders']);
                Route::get('/{id}', [App\Http\Controllers\Api\V1\Admin\CafeController::class, 'getOrder']);
                Route::put('/{id}/status', [App\Http\Controllers\Api\V1\Admin\CafeController::class, 'updateOrderStatus']);
                Route::get('/analytics', [App\Http\Controllers\Api\V1\Admin\CafeController::class, 'getOrderAnalytics']);
            });

            Route::prefix('inventory')->group(function () {
                Route::get('/', [App\Http\Controllers\Api\V1\Admin\CafeController::class, 'getInventory']);
                Route::post('/{id}/restock', [App\Http\Controllers\Api\V1\Admin\CafeController::class, 'restock']);
                Route::get('/alerts', [App\Http\Controllers\Api\V1\Admin\CafeController::class, 'getLowStockAlerts']);
            });
        });

        // Analytics routes
        Route::prefix('analytics')->group(function () {
            Route::get('/dashboard', [App\Http\Controllers\Api\V1\Admin\AnalyticsController::class, 'getDashboard']);
            Route::get('/revenue', [App\Http\Controllers\Api\V1\Admin\AnalyticsController::class, 'getRevenue']);
            Route::get('/users', [App\Http\Controllers\Api\V1\Admin\AnalyticsController::class, 'getUserAnalytics']);
            Route::get('/bookings', [App\Http\Controllers\Api\V1\Admin\AnalyticsController::class, 'getBookingAnalytics']);
            Route::get('/payments', [App\Http\Controllers\Api\V1\Admin\AnalyticsController::class, 'getPaymentAnalytics']);
            Route::get('/members', [App\Http\Controllers\Api\V1\Admin\AnalyticsController::class, 'getMemberAnalytics']);
            Route::get('/cafe', [App\Http\Controllers\Api\V1\Admin\AnalyticsController::class, 'getCafeAnalytics']);
        });
    });

    // Staff routes (staff role required)
    Route::middleware(['auth:sanctum', 'role:staff,admin'])->prefix('staff')->group(function () {

        // Front desk operations
        Route::prefix('front-desk')->group(function () {
            Route::get('/dashboard', [App\Http\Controllers\Api\V1\Staff\FrontDeskController::class, 'getDashboard']);
            Route::get('/bookings', [App\Http\Controllers\Api\V1\Staff\FrontDeskController::class, 'getBookings']);
            Route::put('/bookings/{id}/check-in', [App\Http\Controllers\Api\V1\Staff\FrontDeskController::class, 'checkIn']);
            Route::put('/bookings/{id}/check-out', [App\Http\Controllers\Api\V1\Staff\FrontDeskController::class, 'checkOut']);
        });

        // Payment verification
        Route::prefix('payments')->group(function () {
            Route::get('/pending', [App\Http\Controllers\Api\V1\Staff\PaymentController::class, 'getPendingPayments']);
            Route::put('/{id}/verify', [App\Http\Controllers\Api\V1\Staff\PaymentController::class, 'verifyPayment']);
            Route::put('/{id}/reject', [App\Http\Controllers\Api\V1\Staff\PaymentController::class, 'rejectPayment']);
        });
    });
});

// Fallback route for undefined API endpoints
Route::fallback(function () {
    return response()->json([
        'success' => false,
        'message' => 'API endpoint not found',
        'data' => null
    ], 404);
});
```

## 🛡️ API Middleware

### ApiResponseMiddleware

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class ApiResponseMiddleware
{
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
}
```

### ApiVersionMiddleware

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class ApiVersionMiddleware
{
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
}
```

### RateLimitMiddleware

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Symfony\Component\HttpFoundation\Response;

class RateLimitMiddleware
{
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
}
```

## 🎯 Base Controller

### BaseController

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class BaseController extends Controller
{
    /**
     * API Health Check
     */
    public function health()
    {
        return response()->json([
            'success' => true,
            'message' => 'API is healthy',
            'data' => [
                'status' => 'ok',
                'timestamp' => now()->toISOString(),
                'version' => '1.0.0'
            ]
        ]);
    }

    /**
     * API Information
     */
    public function info()
    {
        return response()->json([
            'success' => true,
            'message' => 'API information',
            'data' => [
                'name' => 'Raujan Pool Syariah API',
                'version' => '1.0.0',
                'description' => 'API for Raujan Pool Syariah management system',
                'author' => 'Raujan Pool Development Team',
                'endpoints' => [
                    'authentication' => '/api/v1/auth',
                    'users' => '/api/v1/users',
                    'bookings' => '/api/v1/bookings',
                    'payments' => '/api/v1/payments',
                    'members' => '/api/v1/members',
                    'cafe' => '/api/v1/cafe',
                    'admin' => '/api/v1/admin',
                    'staff' => '/api/v1/staff'
                ]
            ]
        ]);
    }

    /**
     * Success response helper
     */
    protected function successResponse($data = null, $message = 'Success', $code = 200)
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data
        ], $code);
    }

    /**
     * Error response helper
     */
    protected function errorResponse($message = 'Error', $code = 400, $errors = null)
    {
        return response()->json([
            'success' => false,
            'message' => $message,
            'data' => null,
            'errors' => $errors
        ], $code);
    }

    /**
     * Validation error response helper
     */
    protected function validationErrorResponse($errors, $message = 'Validation failed')
    {
        return response()->json([
            'success' => false,
            'message' => $message,
            'data' => null,
            'errors' => $errors
        ], 422);
    }
}
```

## 🌐 CORS Configuration

### config/cors.php

```php
<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => [
        'http://localhost:3000',
        'http://localhost:3001',
        'https://raujanpool.com',
        'https://www.raujanpool.com',
        'https://admin.raujanpool.com',
    ],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
```

## 📚 API Documentation Setup

### Documentation Structure

API documentation menggunakan format markdown dan siap untuk Postman collection:

```
docs/api/
├── README.md           # Overview dan daftar endpoints
├── authentication.md   # Panduan autentikasi
└── middleware.md       # Dokumentasi middleware
```

### Postman Collection

Collection Postman akan disediakan di folder `docs/postman/` untuk testing API endpoints.

## 🔧 Middleware Registration

### app/Http/Kernel.php

```php
<?php

namespace App\Http;

use Illuminate\Foundation\Http\Kernel as HttpKernel;

class Kernel extends HttpKernel
{
    protected $middleware = [
        // \App\Http\Middleware\TrustHosts::class,
        \App\Http\Middleware\TrustProxies::class,
        \Illuminate\Http\Middleware\HandleCors::class,
        \App\Http\Middleware\PreventRequestsDuringMaintenance::class,
        \Illuminate\Foundation\Http\Middleware\ValidatePostSize::class,
        \App\Http\Middleware\TrimStrings::class,
        \Illuminate\Foundation\Http\Middleware\ConvertEmptyStringsToNull::class,
    ];

    protected $middlewareGroups = [
        'web' => [
            \App\Http\Middleware\EncryptCookies::class,
            \Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse::class,
            \Illuminate\Session\Middleware\StartSession::class,
            \Illuminate\View\Middleware\ShareErrorsFromSession::class,
            \App\Http\Middleware\VerifyCsrfToken::class,
            \Illuminate\Routing\Middleware\SubstituteBindings::class,
        ],

        'api' => [
            \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
            \Illuminate\Routing\Middleware\ThrottleRequests::class.':api',
            \Illuminate\Routing\Middleware\SubstituteBindings::class,
            \App\Http\Middleware\ApiResponseMiddleware::class,
            \App\Http\Middleware\ApiVersionMiddleware::class,
            \App\Http\Middleware\RateLimitMiddleware::class,
        ],
    ];

    protected $middlewareAliases = [
        'auth' => \App\Http\Middleware\Authenticate::class,
        'auth.basic' => \Illuminate\Auth\Middleware\AuthenticateWithBasicAuth::class,
        'auth.session' => \Illuminate\Session\Middleware\AuthenticateSession::class,
        'cache.headers' => \Illuminate\Http\Middleware\SetCacheHeaders::class,
        'can' => \Illuminate\Auth\Middleware\Authorize::class,
        'guest' => \App\Http\Middleware\RedirectIfAuthenticated::class,
        'password.confirm' => \Illuminate\Auth\Middleware\RequirePassword::class,
        'precognitive' => \Illuminate\Foundation\Http\Middleware\HandlePrecognitiveRequests::class,
        'signed' => \App\Http\Middleware\ValidateSignature::class,
        'throttle' => \Illuminate\Routing\Middleware\ThrottleRequests::class,
        'verified' => \Illuminate\Auth\Middleware\EnsureEmailIsVerified::class,
        'role' => \App\Http\Middleware\CheckRole::class,
    ];
}
```

## ✅ Success Criteria

-   [x] API routes structure terkonfigurasi
-   [x] API middleware berfungsi
-   [x] API versioning terimplementasi
-   [x] CORS configuration berfungsi
-   [x] API documentation siap untuk Postman
-   [x] Base controller terimplementasi
-   [x] Rate limiting berfungsi
-   [x] API response format konsisten

## 📚 Documentation

-   [Laravel API Documentation](https://laravel.com/docs/11.x/routing#api-routes)
-   [Laravel Middleware Documentation](https://laravel.com/docs/11.x/middleware)
-   [Laravel CORS Documentation](https://laravel.com/docs/11.x/cors)
-   [Postman Documentation](https://learning.postman.com/docs/getting-started/introduction/)
