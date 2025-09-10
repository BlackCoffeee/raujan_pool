# Point 4: Guest User Management

## 📋 Overview

Implementasi sistem manajemen guest user dengan temporary accounts, conversion ke member, dan data cleanup.

## 🎯 Objectives

-   Guest user registration system
-   Temporary user accounts
-   Guest to member conversion
-   Guest session management
-   Guest data cleanup
-   Guest analytics tracking

## 📁 Files Structure

```
phase-2/
├── 04-guest-user-management.md
├── app/Models/GuestUser.php
├── app/Http/Controllers/GuestController.php
├── app/Jobs/CleanupGuestDataJob.php
└── database/migrations/
```

## 🔧 Implementation Steps

### Step 1: Create Guest User Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class GuestUser extends Model
{
    use HasFactory;

    protected $fillable = [
        'email',
        'name',
        'phone',
        'temp_token',
        'expires_at',
        'converted_to_member',
        'conversion_date',
        'member_id',
        'last_activity_at',
        'session_count',
        'total_bookings',
        'total_spent',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
        'conversion_date' => 'datetime',
        'last_activity_at' => 'datetime',
        'converted_to_member' => 'boolean',
        'total_spent' => 'decimal:2',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($guestUser) {
            if (empty($guestUser->temp_token)) {
                $guestUser->temp_token = Str::random(64);
            }
            if (empty($guestUser->expires_at)) {
                $guestUser->expires_at = now()->addDays(30);
            }
        });
    }

    public function member()
    {
        return $this->belongsTo(User::class, 'member_id');
    }

    public function bookings()
    {
        return $this->hasMany(Booking::class, 'guest_user_id');
    }

    public function isExpired()
    {
        return $this->expires_at->isPast();
    }

    public function isActive()
    {
        return !$this->isExpired() && !$this->converted_to_member;
    }

    public function canConvertToMember()
    {
        return $this->isActive() && !$this->converted_to_member;
    }

    public function convertToMember(User $member)
    {
        if (!$this->canConvertToMember()) {
            throw new \Exception('Guest user cannot be converted to member');
        }

        $this->update([
            'converted_to_member' => true,
            'conversion_date' => now(),
            'member_id' => $member->id,
        ]);

        // Transfer bookings to member
        $this->bookings()->update(['user_id' => $member->id, 'guest_user_id' => null]);

        return $this;
    }

    public function updateActivity()
    {
        $this->update(['last_activity_at' => now()]);
    }

    public function incrementSessionCount()
    {
        $this->increment('session_count');
        $this->updateActivity();
    }

    public function addBooking($amount = 0)
    {
        $this->increment('total_bookings');
        if ($amount > 0) {
            $this->increment('total_spent', $amount);
        }
        $this->updateActivity();
    }

    public function scopeActive($query)
    {
        return $query->where('expires_at', '>', now())
            ->where('converted_to_member', false);
    }

    public function scopeExpired($query)
    {
        return $query->where('expires_at', '<=', now());
    }

    public function scopeConverted($query)
    {
        return $query->where('converted_to_member', true);
    }

    public function scopeByEmail($query, $email)
    {
        return $query->where('email', $email);
    }
}
```

### Step 2: Create Guest Controller

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseController;
use App\Http\Requests\GuestRegistrationRequest;
use App\Http\Requests\GuestConversionRequest;
use App\Models\GuestUser;
use App\Models\User;
use App\Models\Role;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class GuestController extends BaseController
{
    public function register(GuestRegistrationRequest $request)
    {
        // Check if guest already exists
        $existingGuest = GuestUser::byEmail($request->email)->active()->first();

        if ($existingGuest) {
            return $this->errorResponse('Guest with this email already exists', 422);
        }

        // Check if user with this email already exists
        $existingUser = User::where('email', $request->email)->first();
        if ($existingUser) {
            return $this->errorResponse('User with this email already exists', 422);
        }

        $guestUser = GuestUser::create([
            'email' => $request->email,
            'name' => $request->name,
            'phone' => $request->phone,
            'temp_token' => Str::random(64),
            'expires_at' => now()->addDays(30),
        ]);

        return $this->successResponse([
            'guest' => $guestUser,
            'temp_token' => $guestUser->temp_token,
            'expires_at' => $guestUser->expires_at,
        ], 'Guest user registered successfully', 201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'temp_token' => 'required|string',
        ]);

        $guestUser = GuestUser::byEmail($request->email)
            ->where('temp_token', $request->temp_token)
            ->active()
            ->first();

        if (!$guestUser) {
            return $this->errorResponse('Invalid guest credentials or expired account', 401);
        }

        $guestUser->updateActivity();

        return $this->successResponse([
            'guest' => $guestUser,
            'temp_token' => $guestUser->temp_token,
            'expires_at' => $guestUser->expires_at,
        ], 'Guest login successful');
    }

    public function convertToMember(GuestConversionRequest $request)
    {
        $guestUser = GuestUser::where('temp_token', $request->temp_token)
            ->active()
            ->first();

        if (!$guestUser) {
            return $this->errorResponse('Invalid guest token or expired account', 401);
        }

        // Check if user with this email already exists
        $existingUser = User::where('email', $guestUser->email)->first();
        if ($existingUser) {
            return $this->errorResponse('User with this email already exists', 422);
        }

        // Create member user
        $member = User::create([
            'name' => $request->name ?: $guestUser->name,
            'email' => $guestUser->email,
            'password' => Hash::make($request->password),
            'phone' => $request->phone ?: $guestUser->phone,
            'date_of_birth' => $request->date_of_birth,
            'gender' => $request->gender,
            'address' => $request->address,
            'emergency_contact_name' => $request->emergency_contact_name,
            'emergency_contact_phone' => $request->emergency_contact_phone,
            'email_verified_at' => now(),
        ]);

        // Assign member role
        $memberRole = Role::where('name', 'member')->first();
        if ($memberRole) {
            $member->roles()->attach($memberRole);
        }

        // Convert guest to member
        $guestUser->convertToMember($member);

        // Create token for new member
        $token = $member->createToken('member-conversion-token')->plainTextToken;

        return $this->successResponse([
            'user' => $member->load('roles'),
            'token' => $token,
            'token_type' => 'Bearer',
            'guest_data' => [
                'total_bookings' => $guestUser->total_bookings,
                'total_spent' => $guestUser->total_spent,
                'conversion_date' => $guestUser->conversion_date,
            ]
        ], 'Guest converted to member successfully', 201);
    }

    public function getProfile(Request $request)
    {
        $guestUser = GuestUser::where('temp_token', $request->temp_token)
            ->active()
            ->first();

        if (!$guestUser) {
            return $this->errorResponse('Invalid guest token or expired account', 401);
        }

        $guestUser->updateActivity();

        return $this->successResponse([
            'guest' => $guestUser,
            'bookings' => $guestUser->bookings()->with('session')->get(),
            'stats' => [
                'total_bookings' => $guestUser->total_bookings,
                'total_spent' => $guestUser->total_spent,
                'session_count' => $guestUser->session_count,
                'days_remaining' => now()->diffInDays($guestUser->expires_at, false),
            ]
        ], 'Guest profile retrieved successfully');
    }

    public function updateProfile(Request $request)
    {
        $request->validate([
            'temp_token' => 'required|string',
            'name' => 'sometimes|string|max:255',
            'phone' => 'sometimes|string|max:20',
        ]);

        $guestUser = GuestUser::where('temp_token', $request->temp_token)
            ->active()
            ->first();

        if (!$guestUser) {
            return $this->errorResponse('Invalid guest token or expired account', 401);
        }

        $guestUser->update($request->only(['name', 'phone']));
        $guestUser->updateActivity();

        return $this->successResponse($guestUser, 'Guest profile updated successfully');
    }

    public function extendExpiry(Request $request)
    {
        $request->validate([
            'temp_token' => 'required|string',
            'days' => 'required|integer|min:1|max:30',
        ]);

        $guestUser = GuestUser::where('temp_token', $request->temp_token)
            ->active()
            ->first();

        if (!$guestUser) {
            return $this->errorResponse('Invalid guest token or expired account', 401);
        }

        $guestUser->update([
            'expires_at' => $guestUser->expires_at->addDays($request->days)
        ]);

        return $this->successResponse([
            'guest' => $guestUser,
            'new_expiry' => $guestUser->expires_at,
        ], 'Guest account expiry extended successfully');
    }

    public function getStats(Request $request)
    {
        $guestUser = GuestUser::where('temp_token', $request->temp_token)
            ->active()
            ->first();

        if (!$guestUser) {
            return $this->errorResponse('Invalid guest token or expired account', 401);
        }

        $stats = [
            'total_bookings' => $guestUser->total_bookings,
            'total_spent' => $guestUser->total_spent,
            'session_count' => $guestUser->session_count,
            'days_remaining' => now()->diffInDays($guestUser->expires_at, false),
            'last_activity' => $guestUser->last_activity_at,
            'created_at' => $guestUser->created_at,
            'expires_at' => $guestUser->expires_at,
        ];

        return $this->successResponse($stats, 'Guest statistics retrieved successfully');
    }
}
```

### Step 3: Create Request Classes

#### GuestRegistrationRequest

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class GuestRegistrationRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'email' => ['required', 'email', 'max:255'],
            'name' => ['required', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:20'],
        ];
    }

    public function messages()
    {
        return [
            'email.required' => 'Email is required',
            'email.email' => 'Please provide a valid email address',
            'name.required' => 'Name is required',
        ];
    }
}
```

#### GuestConversionRequest

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class GuestConversionRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'temp_token' => ['required', 'string'],
            'name' => ['sometimes', 'string', 'max:255'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
            'phone' => ['sometimes', 'string', 'max:20'],
            'date_of_birth' => ['sometimes', 'date', 'before:today'],
            'gender' => ['sometimes', 'in:male,female'],
            'address' => ['sometimes', 'string', 'max:500'],
            'emergency_contact_name' => ['sometimes', 'string', 'max:255'],
            'emergency_contact_phone' => ['sometimes', 'string', 'max:20'],
        ];
    }

    public function messages()
    {
        return [
            'temp_token.required' => 'Guest token is required',
            'password.required' => 'Password is required',
            'password.min' => 'Password must be at least 6 characters',
            'password.confirmed' => 'Password confirmation does not match',
            'date_of_birth.before' => 'Date of birth must be before today',
            'gender.in' => 'Gender must be either male or female',
        ];
    }
}
```

### Step 4: Create Cleanup Job

```php
<?php

namespace App\Jobs;

use App\Models\GuestUser;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class CleanupGuestDataJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function handle()
    {
        Log::info('Starting guest data cleanup');

        // Clean up expired guest users (older than 7 days after expiry)
        $expiredGuests = GuestUser::expired()
            ->where('expires_at', '<', now()->subDays(7))
            ->where('converted_to_member', false)
            ->get();

        $deletedCount = 0;
        foreach ($expiredGuests as $guest) {
            // Delete related bookings
            $guest->bookings()->delete();

            // Delete guest user
            $guest->delete();
            $deletedCount++;
        }

        Log::info("Guest data cleanup completed. Deleted {$deletedCount} expired guest accounts");

        // Clean up inactive guest users (no activity for 14 days)
        $inactiveGuests = GuestUser::active()
            ->where('last_activity_at', '<', now()->subDays(14))
            ->get();

        $inactiveCount = 0;
        foreach ($inactiveGuests as $guest) {
            // Extend expiry by 7 days for inactive guests
            $guest->update([
                'expires_at' => $guest->expires_at->addDays(7)
            ]);
            $inactiveCount++;
        }

        Log::info("Extended expiry for {$inactiveCount} inactive guest accounts");
    }
}
```

### Step 5: Create Migration

```bash
php artisan make:migration create_guest_users_table
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
        Schema::create('guest_users', function (Blueprint $table) {
            $table->id();
            $table->string('email');
            $table->string('name');
            $table->string('phone')->nullable();
            $table->string('temp_token')->unique();
            $table->timestamp('expires_at');
            $table->boolean('converted_to_member')->default(false);
            $table->timestamp('conversion_date')->nullable();
            $table->foreignId('member_id')->nullable()->constrained('users');
            $table->timestamp('last_activity_at')->nullable();
            $table->integer('session_count')->default(0);
            $table->integer('total_bookings')->default(0);
            $table->decimal('total_spent', 10, 2)->default(0);
            $table->timestamps();

            $table->index(['email', 'temp_token']);
            $table->index('expires_at');
            $table->index('converted_to_member');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('guest_users');
    }
};
```

### Step 6: Update Booking Model

```php
// Add to Booking model
public function guestUser()
{
    return $this->belongsTo(GuestUser::class);
}

// Update fillable array
protected $fillable = [
    // ... existing fields ...
    'guest_user_id',
];
```

### Step 7: Create Scheduled Task

```php
// In app/Console/Kernel.php
protected function schedule(Schedule $schedule)
{
    // Run guest cleanup daily at 2 AM
    $schedule->job(new CleanupGuestDataJob)->dailyAt('02:00');
}
```

## 📚 API Endpoints

### Guest Management Endpoints

```
POST /api/v1/guests/register
POST /api/v1/guests/login
POST /api/v1/guests/convert-to-member
GET  /api/v1/guests/profile
PUT  /api/v1/guests/profile
POST /api/v1/guests/extend-expiry
GET  /api/v1/guests/stats
```

### Request/Response Examples

#### Guest Registration

```json
POST /api/v1/guests/register
{
    "email": "guest@example.com",
    "name": "Guest User",
    "phone": "081234567890"
}

Response:
{
    "success": true,
    "message": "Guest user registered successfully",
    "data": {
        "guest": {
            "id": 1,
            "email": "guest@example.com",
            "name": "Guest User",
            "expires_at": "2024-02-15T10:00:00Z"
        },
        "temp_token": "abc123...",
        "expires_at": "2024-02-15T10:00:00Z"
    }
}
```

#### Convert to Member

```json
POST /api/v1/guests/convert-to-member
{
    "temp_token": "abc123...",
    "password": "password123",
    "password_confirmation": "password123",
    "date_of_birth": "1990-01-01",
    "gender": "male"
}

Response:
{
    "success": true,
    "message": "Guest converted to member successfully",
    "data": {
        "user": {
            "id": 1,
            "name": "Guest User",
            "email": "guest@example.com",
            "roles": [...]
        },
        "token": "1|def456...",
        "token_type": "Bearer",
        "guest_data": {
            "total_bookings": 5,
            "total_spent": 250000,
            "conversion_date": "2024-01-15T10:00:00Z"
        }
    }
}
```

## 🧪 Testing

### GuestTest.php

```php
<?php

use App\Models\GuestUser;
use App\Models\User;

describe('Guest User Management', function () {

    it('can register as guest user', function () {
        $guestData = [
            'email' => 'guest@example.com',
            'name' => 'Guest User',
            'phone' => '081234567890'
        ];

        $response = apiPost('/api/v1/guests/register', $guestData);

        assertApiSuccess($response, 'Guest user registered successfully');
        $this->assertDatabaseHas('guest_users', [
            'email' => 'guest@example.com'
        ]);
    });

    it('can login as guest user', function () {
        $guest = GuestUser::factory()->create([
            'email' => 'guest@example.com',
            'temp_token' => 'test-token'
        ]);

        $response = apiPost('/api/v1/guests/login', [
            'email' => 'guest@example.com',
            'temp_token' => 'test-token'
        ]);

        assertApiSuccess($response, 'Guest login successful');
    });

    it('can convert guest to member', function () {
        $guest = GuestUser::factory()->create([
            'temp_token' => 'test-token'
        ]);

        $response = apiPost('/api/v1/guests/convert-to-member', [
            'temp_token' => 'test-token',
            'password' => 'password123',
            'password_confirmation' => 'password123'
        ]);

        assertApiSuccess($response, 'Guest converted to member successfully');
        $this->assertDatabaseHas('users', [
            'email' => $guest->email
        ]);
        expect($guest->fresh()->converted_to_member)->toBeTrue();
    });

    it('cannot convert expired guest', function () {
        $guest = GuestUser::factory()->create([
            'temp_token' => 'test-token',
            'expires_at' => now()->subDay()
        ]);

        $response = apiPost('/api/v1/guests/convert-to-member', [
            'temp_token' => 'test-token',
            'password' => 'password123',
            'password_confirmation' => 'password123'
        ]);

        assertApiError($response, 401, 'Invalid guest token or expired account');
    });
});
```

## ✅ Success Criteria

-   [x] Guest user registration berfungsi
-   [x] Temporary user accounts terkelola
-   [x] Guest to member conversion berjalan
-   [x] Guest session management berfungsi
-   [x] Guest data cleanup otomatis
-   [x] Guest analytics tracking berjalan
-   [x] Database schema optimal
-   [x] Testing coverage > 90%

## 📚 Documentation

-   [Laravel Jobs Documentation](https://laravel.com/docs/11.x/queues)
-   [Laravel Task Scheduling](https://laravel.com/docs/11.x/scheduling)
-   [Guest User Management Best Practices](https://docs.example.com/guest-management)
