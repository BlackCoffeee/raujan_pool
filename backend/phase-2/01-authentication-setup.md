# Point 1: Laravel Sanctum Authentication

## 📋 Overview

Setup Laravel Sanctum untuk API authentication dengan login/logout endpoints dan token management.

## 🎯 Objectives

- Install dan konfigurasi Laravel Sanctum
- Setup API token authentication
- Implementasi login/logout endpoints
- Token refresh mechanism
- Token revocation
- Security middleware

## 📁 Files Structure

```
phase-2/
├── 01-authentication-setup.md
├── database/migrations/
│   └── 2024_01_01_000001_create_users_table.php
├── app/Models/
│   └── User.php
├── app/Services/
│   └── AuthService.php
├── app/Http/Controllers/
│   └── AuthController.php
├── app/Http/Middleware/
│   └── Authenticate.php
├── routes/api.php
└── config/jwt.php
```

## 📋 File Hierarchy Rules

Implementasi mengikuti urutan: **Database → Model → Service → Controller**

1. **Database**: Migrations untuk users table
2. **Model**: User model dengan JWT traits
3. **Service**: AuthService untuk authentication logic
4. **Controller**: AuthController untuk HTTP handling

## 🔧 Implementation Steps

### Step 1: Install Laravel Sanctum

```bash
# Install Laravel Sanctum
composer require laravel/sanctum

# Publish Sanctum configuration
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"

# Run migrations
php artisan migrate
```

### Step 2: Configure Sanctum

Update `config/sanctum.php`:

```php
<?php

use Laravel\Sanctum\Sanctum;

return [

    /*
    |--------------------------------------------------------------------------
    | Stateful Domains
    |--------------------------------------------------------------------------
    |
    | Requests from the following domains / hosts will receive stateful API
    | authentication cookies. Typically, these should include your local
    | and production domains which access your API via a frontend SPA.
    |
    */

    'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', sprintf(
        '%s%s%s',
        'localhost,localhost:3000,localhost:3001,127.0.0.1,127.0.0.1:8000,::1',
        Sanctum::currentApplicationUrlWithPort(),
        env('FRONTEND_URL') ? ','.parse_url(env('FRONTEND_URL'), PHP_URL_HOST) : ''
    ))),

    /*
    |--------------------------------------------------------------------------
    | Sanctum Guards
    |--------------------------------------------------------------------------
    |
    | This array contains the authentication guards that will be checked when
    | Sanctum is trying to authenticate a request. If none of these guards
    | are able to authenticate the request, Sanctum will use the bearer
    | token that's present on an incoming request for authentication.
    |
    */

    'guard' => ['web'],

    /*
    |--------------------------------------------------------------------------
    | Expiration Minutes
    |--------------------------------------------------------------------------
    |
    | This value controls the number of minutes until an issued token will be
    | considered expired. This will override any values set in the token's
    | "expires_at" attribute, but first-party sessions are not affected.
    |
    */

    'expiration' => env('SANCTUM_EXPIRATION', 60 * 24 * 7), // 7 days

    /*
    |--------------------------------------------------------------------------
    | Token Prefix
    |--------------------------------------------------------------------------
    |
    | Sanctum can prefix new tokens in order to take advantage of numerous
    | security scanning initiatives maintained by open source platforms
    | that notify developers if they commit tokens into repositories.
    |
    */

    'token_prefix' => env('SANCTUM_TOKEN_PREFIX', ''),

    /*
    |--------------------------------------------------------------------------
    | Sanctum Middleware
    |--------------------------------------------------------------------------
    |
    | When authenticating your first-party SPA with Sanctum you may need to
    | customize some of the middleware Sanctum uses while processing the
    | request. You may change the middleware listed below as required.
    |
    */

    'middleware' => [
        'authenticate_session' => Laravel\Sanctum\Http\Middleware\AuthenticateSession::class,
        'encrypt_cookies' => Illuminate\Cookie\Middleware\EncryptCookies::class,
        'validate_csrf_token' => Illuminate\Foundation\Http\Middleware\ValidateCsrfToken::class,
    ],

];
```

### Step 3: Update User Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasFactory, Notifiable, HasApiTokens;

    protected $fillable = [
        'name',
        'email',
        'password',
        'google_id',
        'phone',
        'date_of_birth',
        'gender',
        'address',
        'emergency_contact_name',
        'emergency_contact_phone',
        'is_active',
        'last_login_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'date_of_birth' => 'date',
        'last_login_at' => 'datetime',
        'is_active' => 'boolean',
    ];

    public function roles()
    {
        return $this->belongsToMany(Role::class);
    }

    public function hasRole($role)
    {
        return $this->roles()->where('name', $role)->exists();
    }

    public function hasAnyRole($roles)
    {
        return $this->roles()->whereIn('name', $roles)->exists();
    }

    public function hasPermission($permission)
    {
        return $this->roles()->whereHas('permissions', function ($query) use ($permission) {
            $query->where('name', $permission);
        })->exists();
    }

    public function isActive()
    {
        return $this->is_active;
    }

    public function updateLastLogin()
    {
        $this->update(['last_login_at' => now()]);
    }
}
```

### Step 4: Create Auth Controller

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseController;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends BaseController
{
    public function login(LoginRequest $request)
    {
        $credentials = $request->only('email', 'password');

        if (!Auth::attempt($credentials)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $user = Auth::user();

        if (!$user->isActive()) {
            return $this->errorResponse('Account is inactive', 403);
        }

        $user->updateLastLogin();

        $token = $user->createToken('auth-token')->plainTextToken;

        return $this->successResponse([
            'user' => $user->load('roles'),
            'token' => $token,
            'token_type' => 'Bearer',
            'expires_in' => config('sanctum.expiration') ?: null,
        ], 'Login successful');
    }

    public function register(RegisterRequest $request)
    {
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'phone' => $request->phone,
            'date_of_birth' => $request->date_of_birth,
            'gender' => $request->gender,
            'address' => $request->address,
            'emergency_contact_name' => $request->emergency_contact_name,
            'emergency_contact_phone' => $request->emergency_contact_phone,
        ]);

        // Assign guest role by default
        $guestRole = \App\Models\Role::where('name', 'guest')->first();
        if ($guestRole) {
            $user->roles()->attach($guestRole);
        }

        $token = $user->createToken('auth-token')->plainTextToken;

        return $this->successResponse([
            'user' => $user->load('roles'),
            'token' => $token,
            'token_type' => 'Bearer',
            'expires_in' => config('sanctum.expiration') ?: null,
        ], 'Registration successful', 201);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return $this->successResponse(null, 'Logout successful');
    }

    public function refresh(Request $request)
    {
        $user = $request->user();

        // Delete current token
        $request->user()->currentAccessToken()->delete();

        // Create new token
        $token = $user->createToken('auth-token')->plainTextToken;

        return $this->successResponse([
            'token' => $token,
            'token_type' => 'Bearer',
            'expires_in' => config('sanctum.expiration') ?: null,
        ], 'Token refreshed successfully');
    }

    public function user(Request $request)
    {
        $user = $request->user()->load('roles');

        return $this->successResponse($user, 'User data retrieved successfully');
    }

    public function revokeAllTokens(Request $request)
    {
        $request->user()->tokens()->delete();

        return $this->successResponse(null, 'All tokens revoked successfully');
    }
}
```

### Step 5: Create Request Classes

#### LoginRequest

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'email' => ['required', 'email'],
            'password' => ['required', 'string', 'min:6'],
        ];
    }

    public function messages()
    {
        return [
            'email.required' => 'Email is required',
            'email.email' => 'Please provide a valid email address',
            'password.required' => 'Password is required',
            'password.min' => 'Password must be at least 6 characters',
        ];
    }
}
```

#### RegisterRequest

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
            'phone' => ['nullable', 'string', 'max:20'],
            'date_of_birth' => ['nullable', 'date', 'before:today'],
            'gender' => ['nullable', 'in:male,female'],
            'address' => ['nullable', 'string', 'max:500'],
            'emergency_contact_name' => ['nullable', 'string', 'max:255'],
            'emergency_contact_phone' => ['nullable', 'string', 'max:20'],
        ];
    }

    public function messages()
    {
        return [
            'name.required' => 'Name is required',
            'email.required' => 'Email is required',
            'email.email' => 'Please provide a valid email address',
            'email.unique' => 'This email is already registered',
            'password.required' => 'Password is required',
            'password.min' => 'Password must be at least 6 characters',
            'password.confirmed' => 'Password confirmation does not match',
            'date_of_birth.before' => 'Date of birth must be before today',
            'gender.in' => 'Gender must be either male or female',
        ];
    }
}
```

### Step 6: Create Custom Middleware

#### CheckRole Middleware

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckRole
{
    public function handle(Request $request, Closure $next, ...$roles): Response
    {
        if (!$request->user()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated',
                'data' => null
            ], 401);
        }

        if (!$request->user()->hasAnyRole($roles)) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied. Insufficient permissions.',
                'data' => null
            ], 403);
        }

        return $next($request);
    }
}
```

#### CheckPermission Middleware

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckPermission
{
    public function handle(Request $request, Closure $next, $permission): Response
    {
        if (!$request->user()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated',
                'data' => null
            ], 401);
        }

        if (!$request->user()->hasPermission($permission)) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied. Insufficient permissions.',
                'data' => null
            ], 403);
        }

        return $next($request);
    }
}
```

### Step 7: Update Kernel.php

```php
<?php

namespace App\Http;

use Illuminate\Foundation\Http\Kernel as HttpKernel;

class Kernel extends HttpKernel
{
    // ... existing code ...

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
        'permission' => \App\Http\Middleware\CheckPermission::class,
    ];
}
```

## 🔐 Security Features

### Token Management

```php
// Create token with specific abilities
$token = $user->createToken('auth-token', ['read', 'write']);

// Create token with expiration
$token = $user->createToken('auth-token', ['*'], now()->addDays(7));

// Check token abilities
if ($request->user()->tokenCan('read')) {
    // User can read
}

// Revoke specific token
$request->user()->currentAccessToken()->delete();

// Revoke all tokens
$request->user()->tokens()->delete();
```

### Rate Limiting

```php
// In routes/api.php
Route::middleware(['throttle:auth'])->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/register', [AuthController::class, 'register']);
});

// In RouteServiceProvider.php
protected function configureRateLimiting()
{
    RateLimiter::for('auth', function (Request $request) {
        return Limit::perMinute(5)->by($request->ip());
    });
}
```

### CSRF Protection

```php
// In routes/api.php
Route::middleware(['web', 'auth:sanctum'])->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
});
```

## 📚 API Endpoints

### Authentication Endpoints

```
POST /api/v1/auth/login
POST /api/v1/auth/register
POST /api/v1/auth/logout
POST /api/v1/auth/refresh
GET  /api/v1/auth/user
POST /api/v1/auth/revoke-all-tokens
```

### Request/Response Examples

#### Login Request

```json
POST /api/v1/auth/login
{
    "email": "user@example.com",
    "password": "password123"
}
```

#### Login Response

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "user@example.com",
      "roles": [
        {
          "id": 1,
          "name": "member",
          "display_name": "Member"
        }
      ]
    },
    "token": "1|abcdef123456...",
    "token_type": "Bearer",
    "expires_in": null
  }
}
```

#### Register Request

```json
POST /api/v1/auth/register
{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "phone": "081234567890",
    "date_of_birth": "1990-01-01",
    "gender": "male"
}
```

## 🧪 Testing

### AuthTest.php

```php
<?php

use App\Models\User;
use App\Models\Role;

describe('Authentication', function () {

    beforeEach(function () {
        $this->seed();
    });

    it('can login with valid credentials', function () {
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => bcrypt('password123')
        ]);

        $response = apiPost('/api/v1/auth/login', [
            'email' => 'test@example.com',
            'password' => 'password123'
        ]);

        assertApiSuccess($response, 'Login successful');
        $response->assertJsonStructure([
            'data' => [
                'user',
                'token',
                'token_type',
                'expires_in'
            ]
        ]);
    });

    it('cannot login with invalid credentials', function () {
        $response = apiPost('/api/v1/auth/login', [
            'email' => 'test@example.com',
            'password' => 'wrongpassword'
        ]);

        assertApiError($response, 422, 'The provided credentials are incorrect.');
    });

    it('can register a new user', function () {
        $userData = [
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'phone' => '081234567890'
        ];

        $response = apiPost('/api/v1/auth/register', $userData);

        assertApiSuccess($response, 'Registration successful');
        $this->assertDatabaseHas('users', [
            'email' => 'john@example.com'
        ]);
    });

    it('can logout authenticated user', function () {
        $user = User::factory()->create();
        $token = $user->createToken('test-token')->plainTextToken;

        $response = apiPost('/api/v1/auth/logout', [], [
            'Authorization' => 'Bearer ' . $token
        ]);

        assertApiSuccess($response, 'Logout successful');
    });

    it('can get authenticated user data', function () {
        $user = User::factory()->create();
        actingAsUser($user);

        $response = apiGet('/api/v1/auth/user');

        assertApiSuccess($response, 'User data retrieved successfully');
        $response->assertJson([
            'data' => [
                'id' => $user->id,
                'email' => $user->email
            ]
        ]);
    });
});
```

## ✅ Success Criteria

- [ ] Laravel Sanctum terinstall dan terkonfigurasi
- [ ] API token authentication berfungsi
- [ ] Login/logout endpoints berjalan
- [ ] Token refresh mechanism berfungsi
- [ ] Session management terimplementasi
- [ ] Security middleware berfungsi
- [ ] Role-based access control berjalan
- [ ] Rate limiting terpasang
- [ ] Testing coverage > 90%

## 📚 Documentation

- [Laravel Sanctum Documentation](https://laravel.com/docs/11.x/sanctum)
- [API Authentication Guide](https://laravel.com/docs/11.x/sanctum#api-token-authentication)
- [Token Abilities Documentation](https://laravel.com/docs/11.x/sanctum#token-abilities)
- [SPA Authentication Guide](https://laravel.com/docs/11.x/sanctum#spa-authentication)
