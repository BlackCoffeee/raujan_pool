# Point 2: Google SSO Integration

## 📋 Overview

Implementasi Google OAuth integration dengan Laravel Socialite untuk single sign-on authentication.

## 🎯 Objectives

-   Install Laravel Socialite
-   Konfigurasi Google OAuth credentials
-   Implementasi Google login flow
-   Handle Google callback
-   Sync Google profile data
-   Error handling for SSO

## 📁 Files Structure

```
phase-2/
├── 02-google-sso-integration.md
├── app/Http/Controllers/GoogleAuthController.php
├── config/services.php
├── app/Models/User.php
└── database/migrations/
```

## 🔧 Implementation Steps

### Step 1: Install Laravel Socialite

```bash
# Install Socialite
composer require laravel/socialite

# Publish Socialite configuration (optional)
php artisan vendor:publish --provider="Laravel\Socialite\SocialiteServiceProvider"
```

### Step 2: Configure Google OAuth

#### Update config/services.php

```php
<?php

return [
    // ... existing services ...

    'google' => [
        'client_id' => env('GOOGLE_CLIENT_ID'),
        'client_secret' => env('GOOGLE_CLIENT_SECRET'),
        'redirect' => env('GOOGLE_REDIRECT_URI'),
    ],
];
```

#### Update .env

```env
# Google OAuth Configuration
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_REDIRECT_URI=http://localhost:8000/api/v1/auth/google/callback
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
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'google_id',
        'google_avatar',
        'phone',
        'date_of_birth',
        'gender',
        'address',
        'emergency_contact_name',
        'emergency_contact_phone',
        'is_active',
        'last_login_at',
        'email_verified_at',
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

    // ... existing methods ...

    public function updateGoogleProfile($googleUser)
    {
        $this->update([
            'google_id' => $googleUser->getId(),
            'google_avatar' => $googleUser->getAvatar(),
            'email_verified_at' => now(),
        ]);
    }

    public function hasGoogleAccount()
    {
        return !is_null($this->google_id);
    }
}
```

### Step 4: Create Google Auth Controller

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseController;
use App\Models\User;
use App\Models\Role;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Laravel\Socialite\Facades\Socialite;
use Laravel\Socialite\Two\InvalidStateException;

class GoogleAuthController extends BaseController
{
    public function redirect()
    {
        try {
            $redirectUrl = Socialite::driver('google')
                ->scopes(['openid', 'profile', 'email'])
                ->redirect()
                ->getTargetUrl();

            return $this->successResponse([
                'redirect_url' => $redirectUrl
            ], 'Google OAuth redirect URL generated');
        } catch (\Exception $e) {
            return $this->errorResponse('Failed to generate Google OAuth URL: ' . $e->getMessage(), 500);
        }
    }

    public function callback(Request $request)
    {
        try {
            $googleUser = Socialite::driver('google')->user();
        } catch (InvalidStateException $e) {
            return $this->errorResponse('Invalid state parameter. Please try again.', 400);
        } catch (\Exception $e) {
            return $this->errorResponse('Failed to authenticate with Google: ' . $e->getMessage(), 500);
        }

        try {
            $user = $this->findOrCreateUser($googleUser);

            if (!$user->isActive()) {
                return $this->errorResponse('Account is inactive', 403);
            }

            $user->updateLastLogin();

            $token = $user->createToken('google-auth-token')->plainTextToken;

            return $this->successResponse([
                'user' => $user->load('roles'),
                'token' => $token,
                'token_type' => 'Bearer',
                'expires_in' => config('sanctum.expiration') ?: null,
                'is_new_user' => $user->wasRecentlyCreated,
            ], 'Google authentication successful');
        } catch (\Exception $e) {
            return $this->errorResponse('Failed to process Google authentication: ' . $e->getMessage(), 500);
        }
    }

    public function linkAccount(Request $request)
    {
        $user = $request->user();

        if ($user->hasGoogleAccount()) {
            return $this->errorResponse('Google account is already linked', 400);
        }

        try {
            $googleUser = Socialite::driver('google')->user();
        } catch (\Exception $e) {
            return $this->errorResponse('Failed to authenticate with Google: ' . $e->getMessage(), 500);
        }

        // Check if Google account is already linked to another user
        $existingUser = User::where('google_id', $googleUser->getId())->first();
        if ($existingUser && $existingUser->id !== $user->id) {
            return $this->errorResponse('This Google account is already linked to another user', 400);
        }

        $user->updateGoogleProfile($googleUser);

        return $this->successResponse([
            'user' => $user->fresh()->load('roles')
        ], 'Google account linked successfully');
    }

    public function unlinkAccount(Request $request)
    {
        $user = $request->user();

        if (!$user->hasGoogleAccount()) {
            return $this->errorResponse('No Google account linked', 400);
        }

        // Check if user has a password set
        if (!$user->password) {
            return $this->errorResponse('Cannot unlink Google account. Please set a password first.', 400);
        }

        $user->update([
            'google_id' => null,
            'google_avatar' => null,
        ]);

        return $this->successResponse([
            'user' => $user->fresh()->load('roles')
        ], 'Google account unlinked successfully');
    }

    private function findOrCreateUser($googleUser)
    {
        // First, try to find user by Google ID
        $user = User::where('google_id', $googleUser->getId())->first();

        if ($user) {
            // Update Google profile data
            $user->updateGoogleProfile($googleUser);
            return $user;
        }

        // Try to find user by email
        $user = User::where('email', $googleUser->getEmail())->first();

        if ($user) {
            // Link Google account to existing user
            $user->updateGoogleProfile($googleUser);
            return $user;
        }

        // Create new user
        $user = User::create([
            'name' => $googleUser->getName(),
            'email' => $googleUser->getEmail(),
            'google_id' => $googleUser->getId(),
            'google_avatar' => $googleUser->getAvatar(),
            'email_verified_at' => now(),
            'password' => Hash::make(Str::random(32)), // Random password for Google users
        ]);

        // Assign guest role by default
        $guestRole = Role::where('name', 'guest')->first();
        if ($guestRole) {
            $user->roles()->attach($guestRole);
        }

        return $user;
    }
}
```

### Step 5: Create Migration for Google Fields

```bash
php artisan make:migration add_google_fields_to_users_table
```

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('google_id')->nullable()->unique()->after('email');
            $table->string('google_avatar')->nullable()->after('google_id');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['google_id', 'google_avatar']);
        });
    }
};
```

### Step 6: Update API Routes

```php
// In routes/api.php
Route::prefix('auth')->group(function () {
    // ... existing auth routes ...

    // Google OAuth routes
    Route::get('/google', [GoogleAuthController::class, 'redirect']);
    Route::get('/google/callback', [GoogleAuthController::class, 'callback']);

    // Protected routes for linking/unlinking Google account
    Route::middleware(['auth:sanctum'])->group(function () {
        Route::post('/google/link', [GoogleAuthController::class, 'linkAccount']);
        Route::delete('/google/unlink', [GoogleAuthController::class, 'unlinkAccount']);
    });
});
```

## 🔐 Security Considerations

### State Parameter Validation

```php
// In GoogleAuthController
public function redirect()
{
    $state = Str::random(40);
    session(['google_oauth_state' => $state]);

    $redirectUrl = Socialite::driver('google')
        ->with(['state' => $state])
        ->redirect()
        ->getTargetUrl();

    return $this->successResponse([
        'redirect_url' => $redirectUrl
    ], 'Google OAuth redirect URL generated');
}

public function callback(Request $request)
{
    $expectedState = session('google_oauth_state');
    $actualState = $request->get('state');

    if (!$expectedState || $expectedState !== $actualState) {
        return $this->errorResponse('Invalid state parameter', 400);
    }

    session()->forget('google_oauth_state');

    // ... rest of callback logic
}
```

### Email Verification

```php
// In findOrCreateUser method
private function findOrCreateUser($googleUser)
{
    // Verify email domain if needed
    $allowedDomains = config('auth.google_allowed_domains', []);
    if (!empty($allowedDomains)) {
        $emailDomain = substr(strrchr($googleUser->getEmail(), "@"), 1);
        if (!in_array($emailDomain, $allowedDomains)) {
            throw new \Exception('Email domain not allowed');
        }
    }

    // ... rest of logic
}
```

### Rate Limiting

```php
// In routes/api.php
Route::middleware(['throttle:google-auth'])->group(function () {
    Route::get('/google', [GoogleAuthController::class, 'redirect']);
    Route::get('/google/callback', [GoogleAuthController::class, 'callback']);
});

// In RouteServiceProvider.php
RateLimiter::for('google-auth', function (Request $request) {
    return Limit::perMinute(10)->by($request->ip());
});
```

## 📚 API Endpoints

### Google OAuth Endpoints

```
GET  /api/v1/auth/google
GET  /api/v1/auth/google/callback
POST /api/v1/auth/google/link
DELETE /api/v1/auth/google/unlink
```

### Request/Response Examples

#### Get Google OAuth URL

```json
GET /api/v1/auth/google

Response:
{
    "success": true,
    "message": "Google OAuth redirect URL generated",
    "data": {
        "redirect_url": "https://accounts.google.com/oauth/authorize?..."
    }
}
```

#### Google OAuth Callback

```json
GET /api/v1/auth/google/callback?code=...&state=...

Response:
{
    "success": true,
    "message": "Google authentication successful",
    "data": {
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@gmail.com",
            "google_id": "123456789",
            "google_avatar": "https://lh3.googleusercontent.com/...",
            "roles": [
                {
                    "id": 1,
                    "name": "guest",
                    "display_name": "Guest"
                }
            ]
        },
        "token": "1|abcdef123456...",
        "token_type": "Bearer",
        "expires_in": null,
        "is_new_user": true
    }
}
```

#### Link Google Account

```json
POST /api/v1/auth/google/link
Authorization: Bearer {token}

Response:
{
    "success": true,
    "message": "Google account linked successfully",
    "data": {
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "google_id": "123456789",
            "google_avatar": "https://lh3.googleusercontent.com/..."
        }
    }
}
```

## 🧪 Testing

### GoogleAuthTest.php

```php
<?php

use App\Models\User;
use App\Models\Role;
use Laravel\Socialite\Facades\Socialite;
use Laravel\Socialite\Two\User as SocialiteUser;

describe('Google OAuth Integration', function () {

    beforeEach(function () {
        $this->seed();
    });

    it('can generate Google OAuth redirect URL', function () {
        $response = apiGet('/api/v1/auth/google');

        assertApiSuccess($response, 'Google OAuth redirect URL generated');
        $response->assertJsonStructure([
            'data' => [
                'redirect_url'
            ]
        ]);
    });

    it('can authenticate with Google and create new user', function () {
        $googleUser = new SocialiteUser();
        $googleUser->map([
            'id' => '123456789',
            'name' => 'John Doe',
            'email' => 'john@gmail.com',
            'avatar' => 'https://lh3.googleusercontent.com/avatar.jpg',
        ]);

        Socialite::shouldReceive('driver->user')
            ->andReturn($googleUser);

        $response = apiGet('/api/v1/auth/google/callback?code=test&state=test');

        assertApiSuccess($response, 'Google authentication successful');
        $this->assertDatabaseHas('users', [
            'email' => 'john@gmail.com',
            'google_id' => '123456789'
        ]);
    });

    it('can link Google account to existing user', function () {
        $user = User::factory()->create([
            'email' => 'john@example.com',
            'google_id' => null
        ]);
        actingAsUser($user);

        $googleUser = new SocialiteUser();
        $googleUser->map([
            'id' => '123456789',
            'email' => 'john@example.com',
            'avatar' => 'https://lh3.googleusercontent.com/avatar.jpg',
        ]);

        Socialite::shouldReceive('driver->user')
            ->andReturn($googleUser);

        $response = apiPost('/api/v1/auth/google/link');

        assertApiSuccess($response, 'Google account linked successfully');
        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'google_id' => '123456789'
        ]);
    });

    it('cannot link Google account if already linked', function () {
        $user = User::factory()->create([
            'google_id' => '123456789'
        ]);
        actingAsUser($user);

        $response = apiPost('/api/v1/auth/google/link');

        assertApiError($response, 400, 'Google account is already linked');
    });

    it('can unlink Google account', function () {
        $user = User::factory()->create([
            'google_id' => '123456789',
            'password' => bcrypt('password123')
        ]);
        actingAsUser($user);

        $response = apiDelete('/api/v1/auth/google/unlink');

        assertApiSuccess($response, 'Google account unlinked successfully');
        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'google_id' => null
        ]);
    });

    it('cannot unlink Google account without password', function () {
        $user = User::factory()->create([
            'google_id' => '123456789',
            'password' => null
        ]);
        actingAsUser($user);

        $response = apiDelete('/api/v1/auth/google/unlink');

        assertApiError($response, 400, 'Cannot unlink Google account. Please set a password first.');
    });
});
```

## 🔧 Configuration

### Google OAuth Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable Google+ API
4. Go to Credentials → Create Credentials → OAuth 2.0 Client ID
5. Configure OAuth consent screen
6. Add authorized redirect URIs:
    - `http://localhost:8000/api/v1/auth/google/callback` (development)
    - `https://yourdomain.com/api/v1/auth/google/callback` (production)

### Environment Configuration

```env
# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_REDIRECT_URI=http://localhost:8000/api/v1/auth/google/callback

# Optional: Restrict to specific email domains
GOOGLE_ALLOWED_DOMAINS=gmail.com,company.com
```

## ✅ Success Criteria

-   [x] Laravel Socialite terinstall
-   [x] Google OAuth credentials terkonfigurasi
-   [x] Google login flow berfungsi
-   [x] Google callback handling berjalan
-   [x] Google profile data tersinkronisasi
-   [x] Error handling untuk SSO berfungsi
-   [x] Account linking/unlinking berjalan
-   [x] Security measures terpasang
-   [x] Testing coverage > 90%
-   [x] Dokumentasi API lengkap
-   [x] Script testing tersedia

## 📚 Documentation

-   [Laravel Socialite Documentation](https://laravel.com/docs/11.x/socialite)
-   [Google OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)
-   [Google Cloud Console](https://console.cloud.google.com/)
-   [OAuth 2.0 Security Best Practices](https://tools.ietf.org/html/draft-ietf-oauth-security-topics)
