# Point 1: JWT Authentication

## 📋 Overview

Setup JWT (JSON Web Token) untuk API authentication dengan login/logout endpoints dan token management.

## 🎯 Objectives

- Install dan konfigurasi JWT package (tymon/jwt-auth)
- Setup JWT token authentication
- Implementasi login/logout endpoints
- Token refresh mechanism
- Token blacklisting
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

### Step 1: Install JWT Package

```bash
# Install JWT Auth
composer require tymon/jwt-auth

# Publish JWT configuration
php artisan vendor:publish --provider="Tymon\JWTAuth\Providers\LaravelServiceProvider"

# Generate JWT secret key
php artisan jwt:secret

# Run migrations
php artisan migrate
```

### Step 2: Configure JWT

Update `config/jwt.php`:

```php
<?php

return [
    /*
    |--------------------------------------------------------------------------
    | JWT Authentication Secret
    |--------------------------------------------------------------------------
    |
    | Don't forget to set this in your .env file, as it will be used to sign
    | your tokens. A helper command is provided for this:
    | `php artisan jwt:secret`
    |
    | Note: This will be used for Symmetric algorithms only (HMAC),
    | since RSA and ECDSA use a private/public key combo (See below).
    |
    */

    'secret' => env('JWT_SECRET'),

    /*
    |--------------------------------------------------------------------------
    | JWT Authentication Keys
    |--------------------------------------------------------------------------
    |
    | The algorithm you are using, will determine whether your tokens are
    | signed with a random string (defined in `JWT_SECRET`) or using the
    | following public & private keys.
    |
    | Symmetric Algorithms:
    | HS256, HS384 & HS512 will use `JWT_SECRET`.
    |
    | Asymmetric Algorithms:
    | RS256, RS384 & RS512 / ES256, ES384 & ES512 will use the keys below.
    |
    */

    'keys' => [

        /*
        |--------------------------------------------------------------------------
        | Public Key
        |--------------------------------------------------------------------------
        |
        | A path or resource to your public key.
        |
        */

        'public' => env('JWT_PUBLIC_KEY'),

        /*
        |--------------------------------------------------------------------------
        | Private Key
        |--------------------------------------------------------------------------
        |
        | A path or resource to your private key.
        |
        */

        'private' => env('JWT_PRIVATE_KEY'),

        /*
        |--------------------------------------------------------------------------
        | Passphrase
        |--------------------------------------------------------------------------
        |
        | The passphrase for your private key. Can be null if none set.
        |
        */

        'passphrase' => env('JWT_PASSPHRASE'),

    ],

    /*
    |--------------------------------------------------------------------------
    | JWT time to live
    |--------------------------------------------------------------------------
    |
    | Specify the length of time (in minutes) that the token will be valid for.
    | Defaults to 1 hour.
    |
    | You can also set this to null, to yield a never expiring token.
    | Some people may want this behaviour for e.g. a mobile app.
    | This is not particularly recommended, so make sure you have appropriate
    | systems in place to revoke the token if necessary.
    |
    */

    'ttl' => env('JWT_TTL', 60),

    /*
    |--------------------------------------------------------------------------
    | Refresh time to live
    |--------------------------------------------------------------------------
    |
    | Specify the length of time (in minutes) that the token can be refreshed
    | within. I.E. The user can refresh their token within a 2 week window of
    | the original token being created until they must re-authenticate.
    | Defaults to 2 weeks.
    |
    | You can also set this to null, to yield a never expiring refresh token.
    | Some may want this behaviour for e.g. a mobile app.
    | This is not particularly recommended, so make sure you have appropriate
    | systems in place to revoke the token if necessary.
    |
    */

    'refresh_ttl' => env('JWT_REFRESH_TTL', 20160),

    /*
    |--------------------------------------------------------------------------
    | JWT hashing algorithm
    |--------------------------------------------------------------------------
    |
    | Specify the hashing algorithm that will be used to sign the token.
    |
    | See here: https://github.com/namshi/jose/tree/master/src/Namshi/JOSE/Signer/OpenSSL
    | for possible values.
    |
    */

    'algo' => env('JWT_ALGO', 'HS256'),

    /*
    |--------------------------------------------------------------------------
    | Required Claims
    |--------------------------------------------------------------------------
    |
    | Specify the required claims that must exist in any token.
    | A TokenInvalidException will be thrown if any of these claims are not
    | present in the payload.
    |
    */

    'required_claims' => [
        'iss',
        'iat',
        'exp',
        'nbf',
        'sub',
        'jti',
    ],

    /*
    |--------------------------------------------------------------------------
    | Persistent Claims
    |--------------------------------------------------------------------------
    |
    | Specify the claim keys to be persisted when refreshing a token.
    | `sub` and `iat` will automatically be persisted, in
    | addition to the these claims.
    |
    | Note: If a claim does not exist then it will be ignored.
    |
    */

    'persistent_claims' => [
        // 'foo',
        // 'bar',
    ],

    /*
    |--------------------------------------------------------------------------
    | Lock Subject
    |--------------------------------------------------------------------------
    |
    | This will determine whether a `prv` claim is automatically added to
    | the token. The purpose of this is to ensure that if you have multiple
    | authentication models e.g. `App\User` & `App\OtherPerson`, then we
    | should prevent one authentication request from impersonating another,
    | if 2 tokens happen to have the same id across the 2 different models.
    |
    | Under specific circumstances, you may want to disable this behaviour
    | e.g. if you only have one authentication model, then you would save
    | a little on token size.
    |
    */

    'lock_subject' => true,

    /*
    |--------------------------------------------------------------------------
    | Leeway
    |--------------------------------------------------------------------------
    |
    | This property gives the jwt timestamp claims some "leeway".
    | Meaning that if you have any unavoidable slight clock skew on
    | any of your servers then this will afford you some level of cushioning.
    |
    | This applies to the claims `iat`, `nbf` and `exp`.
    |
    | Specify in seconds - only if you know you need it.
    |
    */

    'leeway' => env('JWT_LEEWAY', 0),

    /*
    |--------------------------------------------------------------------------
    | Blacklist Enabled
    |--------------------------------------------------------------------------
    |
    | In order to invalidate tokens, you must have the blacklist enabled.
    | If you do not want or need this functionality, then set this to false.
    |
    */

    'blacklist_enabled' => env('JWT_BLACKLIST_ENABLED', true),

    /*
    | -------------------------------------------------------------------------
    | Blacklist Grace Period
    | -------------------------------------------------------------------------
    |
    | When multiple concurrent requests are made with the same JWT,
    | it is possible that some of them fail, due to token regeneration
    | on every request.
    |
    | Set grace period in seconds to prevent parallel request failure.
    |
    */

    'blacklist_grace_period' => env('JWT_BLACKLIST_GRACE_PERIOD', 0),

    /*
    |--------------------------------------------------------------------------
    | Cookies encryption
    |--------------------------------------------------------------------------
    |
    | By default Laravel encrypt cookies for security reason.
    | If you decide to not decrypt cookies, you will have to configure Laravel
    | to not encrypt your cookie token by adding its name into the $except
    | array available in the middleware "EncryptCookies" provided by Laravel.
    | see https://laravel.com/docs/master/responses#cookies-and-encryption
    | for details.
    |
    | Set it to true if you want to decrypt cookies.
    |
    */

    'decrypt_cookies' => false,

    /*
    |--------------------------------------------------------------------------
    | Providers
    |--------------------------------------------------------------------------
    |
    | Specify the various providers used throughout the package.
    |
    */

    'providers' => [

        /*
        |--------------------------------------------------------------------------
        | JWT Provider
        |--------------------------------------------------------------------------
        |
        | Specify the provider that is used to create and decode the tokens.
        |
        */

        'jwt' => Tymon\JWTAuth\Providers\JWT\Lcobucci::class,

        /*
        |--------------------------------------------------------------------------
        | Authentication Provider
        |--------------------------------------------------------------------------
        |
        | Specify the provider that is used to authenticate users.
        |
        */

        'auth' => Tymon\JWTAuth\Providers\Auth\Illuminate::class,

        /*
        |--------------------------------------------------------------------------
        | Storage Provider
        |--------------------------------------------------------------------------
        |
        | Specify the provider that is used to store tokens in the blacklist.
        |
        */

        'storage' => Tymon\JWTAuth\Providers\Storage\Illuminate::class,

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
use Tymon\JWTAuth\Contracts\JWTSubject;

class User extends Authenticatable implements JWTSubject
{
    use HasFactory, Notifiable;

    /**
     * Get the identifier that will be stored in the subject claim of the JWT.
     *
     * @return mixed
     */
    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    /**
     * Return a key value array, containing any custom claims to be added to the JWT.
     *
     * @return array
     */
    public function getJWTCustomClaims()
    {
        return [];
    }

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
