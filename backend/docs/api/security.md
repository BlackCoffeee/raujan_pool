# API Security

Panduan lengkap untuk keamanan API dan best practices.

## Authentication & Authorization

### 1. JWT Token Security

#### Token Generation

```php
// app/Services/AuthService.php
public function generateToken(User $user)
{
    $payload = [
        'iss' => config('app.url'),
        'aud' => config('app.url'),
        'iat' => time(),
        'exp' => time() + (60 * 60 * 24), // 24 hours
        'sub' => $user->id,
        'role' => $user->role,
        'permissions' => $user->getAllPermissions()->pluck('name')->toArray()
    ];

    return JWT::encode($payload, config('app.key'), 'HS256');
}
```

#### Token Validation

```php
// app/Http/Middleware/JwtMiddleware.php
public function handle($request, Closure $next)
{
    $token = $request->bearerToken();

    if (!$token) {
        return response()->json([
            'success' => false,
            'message' => 'Token not provided',
            'code' => 'TOKEN_MISSING'
        ], 401);
    }

    try {
        $payload = JWT::decode($token, new Key(config('app.key'), 'HS256'));
        $request->merge(['user_id' => $payload->sub]);
        $request->merge(['user_role' => $payload->role]);
        $request->merge(['user_permissions' => $payload->permissions]);
    } catch (Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Invalid token',
            'code' => 'TOKEN_INVALID'
        ], 401);
    }

    return $next($request);
}
```

### 2. Role-Based Access Control (RBAC)

#### Permission Checking

```php
// app/Http/Middleware/PermissionMiddleware.php
public function handle($request, Closure $next, $permission)
{
    $user = $request->user();

    if (!$user || !$user->hasPermissionTo($permission)) {
        return response()->json([
            'success' => false,
            'message' => 'Permission denied',
            'code' => 'PERMISSION_DENIED'
        ], 403);
    }

    return $next($request);
}
```

#### Route Protection

```php
// routes/api.php
Route::middleware(['auth:sanctum', 'permission:create-booking'])->group(function () {
    Route::post('/bookings', [BookingController::class, 'store']);
});

Route::middleware(['auth:sanctum', 'role:admin'])->group(function () {
    Route::get('/admin/users', [AdminController::class, 'index']);
});
```

### 3. API Key Authentication

#### API Key Generation

```php
// app/Services/ApiKeyService.php
public function generateApiKey(User $user)
{
    $key = Str::random(64);

    $user->apiKeys()->create([
        'key' => hash('sha256', $key),
        'name' => 'Default API Key',
        'expires_at' => now()->addDays(30),
        'last_used_at' => null
    ]);

    return $key; // Return plain key only once
}
```

#### API Key Validation

```php
// app/Http/Middleware/ApiKeyMiddleware.php
public function handle($request, Closure $next)
{
    $apiKey = $request->header('X-API-Key');

    if (!$apiKey) {
        return response()->json([
            'success' => false,
            'message' => 'API key required',
            'code' => 'API_KEY_MISSING'
        ], 401);
    }

    $hashedKey = hash('sha256', $apiKey);
    $keyRecord = ApiKey::where('key', $hashedKey)
        ->where('expires_at', '>', now())
        ->first();

    if (!$keyRecord) {
        return response()->json([
            'success' => false,
            'message' => 'Invalid API key',
            'code' => 'API_KEY_INVALID'
        ], 401);
    }

    $keyRecord->update(['last_used_at' => now()]);
    $request->merge(['user_id' => $keyRecord->user_id]);

    return $next($request);
}
```

## Input Validation & Sanitization

### 1. Request Validation

#### Form Request Validation

```php
// app/Http/Requests/CreateBookingRequest.php
class CreateBookingRequest extends FormRequest
{
    public function rules()
    {
        return [
            'session_id' => 'required|exists:sessions,id',
            'booking_date' => 'required|date|after:today',
            'notes' => 'nullable|string|max:500',
            'guest_name' => 'required_if:user_id,null|string|max:255',
            'guest_phone' => 'required_if:user_id,null|string|max:20',
            'guest_email' => 'required_if:user_id,null|email|max:255'
        ];
    }

    public function messages()
    {
        return [
            'session_id.required' => 'Session is required',
            'booking_date.after' => 'Booking date must be in the future',
            'guest_name.required_if' => 'Guest name is required for guest bookings'
        ];
    }

    public function prepareForValidation()
    {
        $this->merge([
            'notes' => strip_tags($this->notes),
            'guest_name' => trim($this->guest_name),
            'guest_phone' => preg_replace('/[^0-9+]/', '', $this->guest_phone)
        ]);
    }
}
```

#### Custom Validation Rules

```php
// app/Rules/AvailableSessionRule.php
class AvailableSessionRule implements Rule
{
    public function passes($attribute, $value)
    {
        $session = Session::find($value);

        if (!$session) {
            return false;
        }

        $bookingsCount = $session->bookings()
            ->where('booking_date', request('booking_date'))
            ->where('status', '!=', 'cancelled')
            ->count();

        return $bookingsCount < $session->max_capacity;
    }

    public function message()
    {
        return 'The selected session is not available.';
    }
}
```

### 2. Data Sanitization

#### Input Sanitization

```php
// app/Http/Controllers/BaseController.php
protected function sanitizeInput(array $data)
{
    return array_map(function ($value) {
        if (is_string($value)) {
            return strip_tags(trim($value));
        }
        return $value;
    }, $data);
}
```

#### Output Sanitization

```php
// app/Http/Resources/BookingResource.php
class BookingResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'booking_code' => $this->booking_code,
            'notes' => e($this->notes), // Escape HTML
            'guest_name' => e($this->guest_name),
            'created_at' => $this->created_at,
        ];
    }
}
```

## Rate Limiting

### 1. Global Rate Limiting

```php
// app/Http/Kernel.php
protected $middlewareGroups = [
    'api' => [
        'throttle:60,1', // 60 requests per minute
        // ... other middleware
    ],
];
```

### 2. Custom Rate Limiting

```php
// app/Http/Middleware/CustomRateLimitMiddleware.php
class CustomRateLimitMiddleware
{
    public function handle($request, Closure $next, $maxAttempts = 60, $decayMinutes = 1)
    {
        $key = $this->resolveRequestSignature($request);

        if (RateLimiter::tooManyAttempts($key, $maxAttempts)) {
            $retryAfter = RateLimiter::availableIn($key);

            return response()->json([
                'success' => false,
                'message' => 'Too many requests',
                'code' => 'RATE_LIMIT_EXCEEDED',
                'retry_after' => $retryAfter
            ], 429);
        }

        RateLimiter::hit($key, $decayMinutes * 60);

        $response = $next($request);

        $response->headers->set('X-RateLimit-Limit', $maxAttempts);
        $response->headers->set('X-RateLimit-Remaining', RateLimiter::remaining($key, $maxAttempts));
        $response->headers->set('X-RateLimit-Reset', now()->addMinutes($decayMinutes)->timestamp);

        return $response;
    }

    protected function resolveRequestSignature($request)
    {
        return sha1($request->method() . '|' . $request->server('SERVER_NAME') . '|' . $request->ip());
    }
}
```

### 3. User-Specific Rate Limiting

```php
// app/Http/Middleware/UserRateLimitMiddleware.php
class UserRateLimitMiddleware
{
    public function handle($request, Closure $next, $maxAttempts = 100, $decayMinutes = 1)
    {
        $user = $request->user();

        if ($user) {
            $key = 'user:' . $user->id;
        } else {
            $key = 'ip:' . $request->ip();
        }

        if (RateLimiter::tooManyAttempts($key, $maxAttempts)) {
            return response()->json([
                'success' => false,
                'message' => 'Rate limit exceeded',
                'code' => 'RATE_LIMIT_EXCEEDED'
            ], 429);
        }

        RateLimiter::hit($key, $decayMinutes * 60);

        return $next($request);
    }
}
```

## CORS Configuration

### 1. CORS Middleware

```php
// config/cors.php
return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    'allowed_origins' => [
        'http://localhost:3000',
        'https://yourdomain.com',
        'https://www.yourdomain.com'
    ],
    'allowed_origins_patterns' => [
        '/^https:\/\/.*\.yourdomain\.com$/',
    ],
    'allowed_headers' => ['*'],
    'exposed_headers' => ['X-RateLimit-Limit', 'X-RateLimit-Remaining', 'X-RateLimit-Reset'],
    'max_age' => 0,
    'supports_credentials' => true,
];
```

### 2. Custom CORS Headers

```php
// app/Http/Middleware/CorsMiddleware.php
class CorsMiddleware
{
    public function handle($request, Closure $next)
    {
        $response = $next($request);

        $response->headers->set('Access-Control-Allow-Origin', config('cors.allowed_origins')[0]);
        $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
        $response->headers->set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
        $response->headers->set('Access-Control-Allow-Credentials', 'true');
        $response->headers->set('Access-Control-Max-Age', '86400');

        return $response;
    }
}
```

## SQL Injection Prevention

### 1. Eloquent ORM Usage

```php
// Good - Using Eloquent ORM
$bookings = Booking::where('user_id', $userId)
    ->where('status', 'confirmed')
    ->get();

// Good - Using Query Builder with bindings
$bookings = DB::table('bookings')
    ->where('user_id', $userId)
    ->where('status', 'confirmed')
    ->get();

// Bad - Raw queries without bindings
$bookings = DB::select("SELECT * FROM bookings WHERE user_id = $userId");
```

### 2. Parameterized Queries

```php
// Good - Using parameterized queries
$bookings = DB::select(
    'SELECT * FROM bookings WHERE user_id = ? AND status = ?',
    [$userId, 'confirmed']
);

// Good - Using named parameters
$bookings = DB::select(
    'SELECT * FROM bookings WHERE user_id = :user_id AND status = :status',
    ['user_id' => $userId, 'status' => 'confirmed']
);
```

## XSS Prevention

### 1. Input Sanitization

```php
// app/Http/Controllers/BaseController.php
protected function sanitizeInput($input)
{
    if (is_array($input)) {
        return array_map([$this, 'sanitizeInput'], $input);
    }

    if (is_string($input)) {
        return htmlspecialchars(strip_tags($input), ENT_QUOTES, 'UTF-8');
    }

    return $input;
}
```

### 2. Output Escaping

```php
// app/Http/Resources/UserResource.php
class UserResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'name' => e($this->name), // Escape HTML
            'email' => $this->email,
            'bio' => e($this->bio), // Escape HTML
        ];
    }
}
```

## CSRF Protection

### 1. CSRF Token Validation

```php
// app/Http/Middleware/VerifyCsrfToken.php
class VerifyCsrfToken extends Middleware
{
    protected $except = [
        'api/*', // Exclude API routes
    ];

    protected function tokensMatch($request)
    {
        $token = $request->input('_token') ?: $request->header('X-CSRF-TOKEN');

        if (!$token) {
            return false;
        }

        return hash_equals($request->session()->token(), $token);
    }
}
```

### 2. CSRF Token Generation

```php
// app/Http/Controllers/ApiController.php
public function getCsrfToken()
{
    return response()->json([
        'success' => true,
        'data' => [
            'csrf_token' => csrf_token()
        ]
    ]);
}
```

## File Upload Security

### 1. File Validation

```php
// app/Http/Requests/UploadFileRequest.php
class UploadFileRequest extends FormRequest
{
    public function rules()
    {
        return [
            'file' => [
                'required',
                'file',
                'max:10240', // 10MB max
                'mimes:jpg,jpeg,png,pdf,doc,docx',
                'mimetypes:image/jpeg,image/png,application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document'
            ]
        ];
    }

    public function messages()
    {
        return [
            'file.max' => 'File size must not exceed 10MB',
            'file.mimes' => 'File type not allowed',
            'file.mimetypes' => 'File type not allowed'
        ];
    }
}
```

### 2. File Storage Security

```php
// app/Services/FileUploadService.php
class FileUploadService
{
    public function uploadFile($file, $directory = 'uploads')
    {
        // Generate unique filename
        $filename = Str::uuid() . '.' . $file->getClientOriginalExtension();

        // Store file in secure directory
        $path = $file->storeAs($directory, $filename, 'private');

        // Scan file for malware (if available)
        if (class_exists('ClamAV')) {
            $this->scanFile($path);
        }

        return $path;
    }

    private function scanFile($path)
    {
        $clamav = new ClamAV();
        $result = $clamav->scan($path);

        if ($result['infected']) {
            Storage::delete($path);
            throw new Exception('File contains malware');
        }
    }
}
```

## API Security Headers

### 1. Security Headers Middleware

```php
// app/Http/Middleware/SecurityHeadersMiddleware.php
class SecurityHeadersMiddleware
{
    public function handle($request, Closure $next)
    {
        $response = $next($request);

        $response->headers->set('X-Content-Type-Options', 'nosniff');
        $response->headers->set('X-Frame-Options', 'DENY');
        $response->headers->set('X-XSS-Protection', '1; mode=block');
        $response->headers->set('Referrer-Policy', 'strict-origin-when-cross-origin');
        $response->headers->set('Permissions-Policy', 'geolocation=(), microphone=(), camera=()');

        if ($request->isSecure()) {
            $response->headers->set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
        }

        return $response;
    }
}
```

### 2. Content Security Policy

```php
// app/Http/Middleware/CspMiddleware.php
class CspMiddleware
{
    public function handle($request, Closure $next)
    {
        $response = $next($request);

        $csp = "default-src 'self'; " .
               "script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; " .
               "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; " .
               "font-src 'self' https://fonts.gstatic.com; " .
               "img-src 'self' data: https:; " .
               "connect-src 'self' https://api.yourdomain.com;";

        $response->headers->set('Content-Security-Policy', $csp);

        return $response;
    }
}
```

## Logging & Monitoring

### 1. Security Event Logging

```php
// app/Http/Middleware/SecurityLogMiddleware.php
class SecurityLogMiddleware
{
    public function handle($request, Closure $next)
    {
        $response = $next($request);

        // Log security events
        if ($response->getStatusCode() >= 400) {
            Log::warning('Security event', [
                'ip' => $request->ip(),
                'user_agent' => $request->userAgent(),
                'url' => $request->fullUrl(),
                'method' => $request->method(),
                'status' => $response->getStatusCode(),
                'user_id' => $request->user()?->id,
                'timestamp' => now()
            ]);
        }

        return $response;
    }
}
```

### 2. Failed Login Attempts

```php
// app/Http/Controllers/AuthController.php
public function login(Request $request)
{
    $credentials = $request->only('email', 'password');

    if (!Auth::attempt($credentials)) {
        // Log failed login attempt
        Log::warning('Failed login attempt', [
            'email' => $request->email,
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'timestamp' => now()
        ]);

        return response()->json([
            'success' => false,
            'message' => 'Invalid credentials',
            'code' => 'INVALID_CREDENTIALS'
        ], 401);
    }

    // Log successful login
    Log::info('Successful login', [
        'user_id' => Auth::id(),
        'ip' => $request->ip(),
        'timestamp' => now()
    ]);

    return response()->json([
        'success' => true,
        'data' => [
            'user' => Auth::user(),
            'token' => Auth::user()->createToken('auth-token')->plainTextToken
        ]
    ]);
}
```

## Best Practices

### 1. Authentication

-   Use strong, unique passwords
-   Implement two-factor authentication
-   Use JWT tokens with short expiration
-   Implement token refresh mechanism
-   Log all authentication events

### 2. Authorization

-   Implement role-based access control
-   Use principle of least privilege
-   Validate permissions on every request
-   Log authorization failures
-   Regular permission audits

### 3. Input Validation

-   Validate all inputs
-   Sanitize user data
-   Use whitelist validation
-   Implement custom validation rules
-   Log validation failures

### 4. Output Security

-   Escape all outputs
-   Use Content Security Policy
-   Implement proper error handling
-   Don't expose sensitive information
-   Use secure headers

### 5. Data Protection

-   Encrypt sensitive data
-   Use HTTPS in production
-   Implement proper session management
-   Regular security audits
-   Monitor for anomalies

## Security Checklist

-   [ ] Authentication implemented
-   [ ] Authorization configured
-   [ ] Input validation in place
-   [ ] Output sanitization
-   [ ] Rate limiting configured
-   [ ] CORS properly configured
-   [ ] SQL injection prevention
-   [ ] XSS protection
-   [ ] CSRF protection
-   [ ] File upload security
-   [ ] Security headers set
-   [ ] Logging configured
-   [ ] Monitoring in place
-   [ ] Regular security audits
-   [ ] Penetration testing
-   [ ] Security documentation
-   [ ] Incident response plan
-   [ ] Backup and recovery
-   [ ] Access control
-   [ ] Data encryption

## Notes

-   Selalu update dependencies
-   Monitor security advisories
-   Implement security testing
-   Regular security training
-   Document security procedures
-   Test security measures
-   Monitor for vulnerabilities
-   Keep security documentation updated
