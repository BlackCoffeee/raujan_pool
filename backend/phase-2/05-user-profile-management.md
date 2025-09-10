# Point 5: User Profile Management

## 📋 Overview

Implementasi sistem manajemen profil user dengan CRUD operations, validasi, upload gambar, dan tracking history.

## 🎯 Objectives

-   User profile CRUD operations
-   Profile validation rules
-   Profile image upload
-   Emergency contact management
-   Profile history tracking
-   Profile export functionality

## 📁 Files Structure

```
phase-2/
├── 05-user-profile-management.md
├── app/Http/Controllers/ProfileController.php
├── app/Http/Requests/ProfileRequest.php
├── app/Models/UserProfile.php
└── database/migrations/
```

## 🔧 Implementation Steps

### Step 1: Create User Profile Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserProfile extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'phone',
        'date_of_birth',
        'gender',
        'address',
        'city',
        'postal_code',
        'country',
        'emergency_contact_name',
        'emergency_contact_phone',
        'emergency_contact_relationship',
        'medical_conditions',
        'allergies',
        'preferred_language',
        'timezone',
        'avatar_path',
        'bio',
        'occupation',
        'company',
        'website',
        'social_media',
        'preferences',
        'is_public',
        'last_updated_at',
    ];

    protected $casts = [
        'date_of_birth' => 'date',
        'social_media' => 'array',
        'preferences' => 'array',
        'is_public' => 'boolean',
        'last_updated_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function profileHistory()
    {
        return $this->hasMany(UserProfileHistory::class);
    }

    public function getAgeAttribute()
    {
        return $this->date_of_birth ? $this->date_of_birth->age : null;
    }

    public function getFullAddressAttribute()
    {
        $parts = array_filter([
            $this->address,
            $this->city,
            $this->postal_code,
            $this->country
        ]);

        return implode(', ', $parts);
    }

    public function getAvatarUrlAttribute()
    {
        if ($this->avatar_path) {
            return asset('storage/' . $this->avatar_path);
        }

        return $this->getDefaultAvatarUrl();
    }

    public function getDefaultAvatarUrl()
    {
        $hash = md5(strtolower(trim($this->user->email)));
        return "https://www.gravatar.com/avatar/{$hash}?d=identicon&s=200";
    }

    public function updateProfile(array $data)
    {
        // Store current data for history
        $oldData = $this->toArray();

        // Update profile
        $this->update($data);

        // Create history record
        $this->profileHistory()->create([
            'old_data' => $oldData,
            'new_data' => $this->toArray(),
            'changed_fields' => array_keys($data),
            'updated_by' => auth()->id(),
        ]);

        $this->update(['last_updated_at' => now()]);
    }

    public function scopePublic($query)
    {
        return $query->where('is_public', true);
    }

    public function scopeByGender($query, $gender)
    {
        return $query->where('gender', $gender);
    }

    public function scopeByAgeRange($query, $minAge, $maxAge)
    {
        $minDate = now()->subYears($maxAge)->format('Y-m-d');
        $maxDate = now()->subYears($minAge)->format('Y-m-d');

        return $query->whereBetween('date_of_birth', [$minDate, $maxDate]);
    }
}
```

### Step 2: Create Profile History Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserProfileHistory extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_profile_id',
        'old_data',
        'new_data',
        'changed_fields',
        'updated_by',
        'change_reason',
    ];

    protected $casts = [
        'old_data' => 'array',
        'new_data' => 'array',
        'changed_fields' => 'array',
    ];

    public function userProfile()
    {
        return $this->belongsTo(UserProfile::class);
    }

    public function updatedBy()
    {
        return $this->belongsTo(User::class, 'updated_by');
    }

    public function getChangesAttribute()
    {
        $changes = [];

        foreach ($this->changed_fields as $field) {
            $oldValue = $this->old_data[$field] ?? null;
            $newValue = $this->new_data[$field] ?? null;

            if ($oldValue !== $newValue) {
                $changes[$field] = [
                    'old' => $oldValue,
                    'new' => $newValue,
                ];
            }
        }

        return $changes;
    }
}
```

### Step 3: Create Profile Controller

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseController;
use App\Http\Requests\ProfileRequest;
use App\Http\Requests\ProfileImageRequest;
use App\Models\UserProfile;
use App\Models\UserProfileHistory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class ProfileController extends BaseController
{
    public function show(Request $request)
    {
        $user = $request->user();
        $profile = $user->profile;

        if (!$profile) {
            // Create default profile if doesn't exist
            $profile = UserProfile::create([
                'user_id' => $user->id,
                'phone' => $user->phone,
                'date_of_birth' => $user->date_of_birth,
                'gender' => $user->gender,
                'address' => $user->address,
                'emergency_contact_name' => $user->emergency_contact_name,
                'emergency_contact_phone' => $user->emergency_contact_phone,
            ]);
        }

        return $this->successResponse([
            'profile' => $profile,
            'user' => $user->only(['id', 'name', 'email', 'email_verified_at']),
        ], 'Profile retrieved successfully');
    }

    public function update(ProfileRequest $request)
    {
        $user = $request->user();
        $profile = $user->profile;

        if (!$profile) {
            $profile = UserProfile::create([
                'user_id' => $user->id,
            ]);
        }

        $validatedData = $request->validated();

        // Update profile with history tracking
        $profile->updateProfile($validatedData);

        // Update user basic info if provided
        if ($request->has('name')) {
            $user->update(['name' => $request->name]);
        }

        return $this->successResponse([
            'profile' => $profile->fresh(),
            'user' => $user->fresh()->only(['id', 'name', 'email']),
        ], 'Profile updated successfully');
    }

    public function uploadAvatar(ProfileImageRequest $request)
    {
        $user = $request->user();
        $profile = $user->profile;

        if (!$profile) {
            $profile = UserProfile::create(['user_id' => $user->id]);
        }

        // Delete old avatar if exists
        if ($profile->avatar_path) {
            Storage::disk('public')->delete($profile->avatar_path);
        }

        // Store new avatar
        $file = $request->file('avatar');
        $filename = 'avatars/' . $user->id . '_' . time() . '.' . $file->getClientOriginalExtension();
        $path = $file->storeAs('', $filename, 'public');

        // Update profile
        $profile->updateProfile(['avatar_path' => $path]);

        return $this->successResponse([
            'avatar_url' => $profile->fresh()->avatar_url,
            'avatar_path' => $path,
        ], 'Avatar uploaded successfully');
    }

    public function deleteAvatar(Request $request)
    {
        $user = $request->user();
        $profile = $user->profile;

        if (!$profile || !$profile->avatar_path) {
            return $this->errorResponse('No avatar to delete', 404);
        }

        // Delete file from storage
        Storage::disk('public')->delete($profile->avatar_path);

        // Update profile
        $profile->updateProfile(['avatar_path' => null]);

        return $this->successResponse([
            'avatar_url' => $profile->fresh()->avatar_url,
        ], 'Avatar deleted successfully');
    }

    public function getHistory(Request $request)
    {
        $user = $request->user();
        $profile = $user->profile;

        if (!$profile) {
            return $this->successResponse([], 'No profile history found');
        }

        $history = $profile->profileHistory()
            ->with('updatedBy:id,name')
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return $this->successResponse($history, 'Profile history retrieved successfully');
    }

    public function export(Request $request)
    {
        $user = $request->user();
        $profile = $user->profile;

        if (!$profile) {
            return $this->errorResponse('No profile data to export', 404);
        }

        $exportData = [
            'user' => $user->only(['name', 'email', 'email_verified_at']),
            'profile' => $profile->toArray(),
            'exported_at' => now()->toISOString(),
        ];

        // Generate filename
        $filename = 'profile_export_' . $user->id . '_' . now()->format('Y-m-d_H-i-s') . '.json';

        // Store export file
        $path = 'exports/' . $filename;
        Storage::disk('public')->put($path, json_encode($exportData, JSON_PRETTY_PRINT));

        return $this->successResponse([
            'download_url' => Storage::disk('public')->url($path),
            'filename' => $filename,
            'expires_at' => now()->addDays(7)->toISOString(),
        ], 'Profile exported successfully');
    }

    public function getPublicProfile($userId)
    {
        $user = User::findOrFail($userId);
        $profile = $user->profile;

        if (!$profile || !$profile->is_public) {
            return $this->errorResponse('Profile not found or not public', 404);
        }

        $publicData = $profile->only([
            'phone',
            'date_of_birth',
            'gender',
            'city',
            'country',
            'bio',
            'occupation',
            'company',
            'website',
            'social_media',
            'avatar_url',
        ]);

        return $this->successResponse([
            'user' => $user->only(['name']),
            'profile' => $publicData,
        ], 'Public profile retrieved successfully');
    }

    public function updatePreferences(Request $request)
    {
        $request->validate([
            'preferences' => 'required|array',
            'preferences.notifications' => 'array',
            'preferences.privacy' => 'array',
            'preferences.language' => 'string|in:en,id',
            'preferences.timezone' => 'string',
        ]);

        $user = $request->user();
        $profile = $user->profile;

        if (!$profile) {
            $profile = UserProfile::create(['user_id' => $user->id]);
        }

        $profile->updateProfile([
            'preferences' => $request->preferences,
            'preferred_language' => $request->preferences['language'] ?? $profile->preferred_language,
            'timezone' => $request->preferences['timezone'] ?? $profile->timezone,
        ]);

        return $this->successResponse([
            'preferences' => $profile->fresh()->preferences,
        ], 'Preferences updated successfully');
    }

    public function getStatistics(Request $request)
    {
        $user = $request->user();
        $profile = $user->profile;

        if (!$profile) {
            return $this->successResponse([
                'profile_completion' => 0,
                'last_updated' => null,
                'total_updates' => 0,
            ], 'Profile statistics retrieved successfully');
        }

        $requiredFields = [
            'phone', 'date_of_birth', 'gender', 'address',
            'emergency_contact_name', 'emergency_contact_phone'
        ];

        $completedFields = 0;
        foreach ($requiredFields as $field) {
            if (!empty($profile->$field)) {
                $completedFields++;
            }
        }

        $completionPercentage = round(($completedFields / count($requiredFields)) * 100);

        $stats = [
            'profile_completion' => $completionPercentage,
            'last_updated' => $profile->last_updated_at,
            'total_updates' => $profile->profileHistory()->count(),
            'avatar_uploaded' => !is_null($profile->avatar_path),
            'is_public' => $profile->is_public,
            'age' => $profile->age,
        ];

        return $this->successResponse($stats, 'Profile statistics retrieved successfully');
    }
}
```

### Step 4: Create Request Classes

#### ProfileRequest

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ProfileRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'phone' => ['sometimes', 'string', 'max:20'],
            'date_of_birth' => ['sometimes', 'date', 'before:today'],
            'gender' => ['sometimes', 'in:male,female'],
            'address' => ['sometimes', 'string', 'max:500'],
            'city' => ['sometimes', 'string', 'max:100'],
            'postal_code' => ['sometimes', 'string', 'max:20'],
            'country' => ['sometimes', 'string', 'max:100'],
            'emergency_contact_name' => ['sometimes', 'string', 'max:255'],
            'emergency_contact_phone' => ['sometimes', 'string', 'max:20'],
            'emergency_contact_relationship' => ['sometimes', 'string', 'max:100'],
            'medical_conditions' => ['sometimes', 'string', 'max:1000'],
            'allergies' => ['sometimes', 'string', 'max:1000'],
            'preferred_language' => ['sometimes', 'string', 'in:en,id'],
            'timezone' => ['sometimes', 'string', 'max:50'],
            'bio' => ['sometimes', 'string', 'max:1000'],
            'occupation' => ['sometimes', 'string', 'max:100'],
            'company' => ['sometimes', 'string', 'max:100'],
            'website' => ['sometimes', 'url', 'max:255'],
            'social_media' => ['sometimes', 'array'],
            'social_media.facebook' => ['sometimes', 'url'],
            'social_media.twitter' => ['sometimes', 'url'],
            'social_media.instagram' => ['sometimes', 'url'],
            'social_media.linkedin' => ['sometimes', 'url'],
            'is_public' => ['sometimes', 'boolean'],
        ];
    }

    public function messages()
    {
        return [
            'date_of_birth.before' => 'Date of birth must be before today',
            'gender.in' => 'Gender must be either male or female',
            'preferred_language.in' => 'Preferred language must be either en or id',
            'website.url' => 'Website must be a valid URL',
            'social_media.facebook.url' => 'Facebook URL must be valid',
            'social_media.twitter.url' => 'Twitter URL must be valid',
            'social_media.instagram.url' => 'Instagram URL must be valid',
            'social_media.linkedin.url' => 'LinkedIn URL must be valid',
        ];
    }
}
```

#### ProfileImageRequest

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ProfileImageRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'avatar' => [
                'required',
                'image',
                'mimes:jpeg,png,jpg,gif',
                'max:2048', // 2MB
                'dimensions:min_width=100,min_height=100,max_width=2000,max_height=2000'
            ],
        ];
    }

    public function messages()
    {
        return [
            'avatar.required' => 'Avatar image is required',
            'avatar.image' => 'File must be an image',
            'avatar.mimes' => 'Image must be jpeg, png, jpg, or gif',
            'avatar.max' => 'Image size must not exceed 2MB',
            'avatar.dimensions' => 'Image dimensions must be between 100x100 and 2000x2000 pixels',
        ];
    }
}
```

### Step 5: Update User Model

```php
// Add to User model
public function profile()
{
    return $this->hasOne(UserProfile::class);
}

public function getProfileAttribute()
{
    return $this->profile()->first();
}
```

### Step 6: Create Migrations

```bash
php artisan make:migration create_user_profiles_table
php artisan make:migration create_user_profile_histories_table
```

#### User Profiles Migration

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('phone')->nullable();
            $table->date('date_of_birth')->nullable();
            $table->enum('gender', ['male', 'female'])->nullable();
            $table->text('address')->nullable();
            $table->string('city')->nullable();
            $table->string('postal_code')->nullable();
            $table->string('country')->nullable();
            $table->string('emergency_contact_name')->nullable();
            $table->string('emergency_contact_phone')->nullable();
            $table->string('emergency_contact_relationship')->nullable();
            $table->text('medical_conditions')->nullable();
            $table->text('allergies')->nullable();
            $table->string('preferred_language')->default('en');
            $table->string('timezone')->default('UTC');
            $table->string('avatar_path')->nullable();
            $table->text('bio')->nullable();
            $table->string('occupation')->nullable();
            $table->string('company')->nullable();
            $table->string('website')->nullable();
            $table->json('social_media')->nullable();
            $table->json('preferences')->nullable();
            $table->boolean('is_public')->default(false);
            $table->timestamp('last_updated_at')->nullable();
            $table->timestamps();

            $table->unique('user_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_profiles');
    }
};
```

#### User Profile Histories Migration

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_profile_histories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_profile_id')->constrained()->onDelete('cascade');
            $table->json('old_data');
            $table->json('new_data');
            $table->json('changed_fields');
            $table->foreignId('updated_by')->constrained('users');
            $table->string('change_reason')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_profile_histories');
    }
};
```

## 📚 API Endpoints

### Profile Management Endpoints

```
GET    /api/v1/profile
PUT    /api/v1/profile
POST   /api/v1/profile/avatar
DELETE /api/v1/profile/avatar
GET    /api/v1/profile/history
GET    /api/v1/profile/export
GET    /api/v1/profile/public/{userId}
PUT    /api/v1/profile/preferences
GET    /api/v1/profile/statistics
```

### Request/Response Examples

#### Update Profile

```json
PUT /api/v1/profile
{
    "name": "John Doe",
    "phone": "081234567890",
    "date_of_birth": "1990-01-01",
    "gender": "male",
    "address": "Jl. Contoh No. 123",
    "city": "Jakarta",
    "emergency_contact_name": "Jane Doe",
    "emergency_contact_phone": "081234567891",
    "bio": "Swimming enthusiast"
}

Response:
{
    "success": true,
    "message": "Profile updated successfully",
    "data": {
        "profile": {
            "id": 1,
            "user_id": 1,
            "phone": "081234567890",
            "date_of_birth": "1990-01-01",
            "gender": "male",
            "address": "Jl. Contoh No. 123",
            "city": "Jakarta",
            "bio": "Swimming enthusiast",
            "avatar_url": "https://example.com/avatar.jpg"
        },
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com"
        }
    }
}
```

#### Upload Avatar

```json
POST /api/v1/profile/avatar
Content-Type: multipart/form-data

avatar: [image file]

Response:
{
    "success": true,
    "message": "Avatar uploaded successfully",
    "data": {
        "avatar_url": "https://example.com/storage/avatars/1_1234567890.jpg",
        "avatar_path": "avatars/1_1234567890.jpg"
    }
}
```

## 🧪 Testing

### ProfileTest.php

```php
<?php

use App\Models\User;
use App\Models\UserProfile;

describe('User Profile Management', function () {

    it('can get user profile', function () {
        $user = User::factory()->create();
        UserProfile::factory()->create(['user_id' => $user->id]);
        actingAsUser($user);

        $response = apiGet('/api/v1/profile');

        assertApiSuccess($response, 'Profile retrieved successfully');
        $response->assertJsonStructure([
            'data' => [
                'profile',
                'user'
            ]
        ]);
    });

    it('can update user profile', function () {
        $user = User::factory()->create();
        $profile = UserProfile::factory()->create(['user_id' => $user->id]);
        actingAsUser($user);

        $updateData = [
            'phone' => '081234567890',
            'date_of_birth' => '1990-01-01',
            'gender' => 'male',
            'address' => 'New Address'
        ];

        $response = apiPut('/api/v1/profile', $updateData);

        assertApiSuccess($response, 'Profile updated successfully');
        $this->assertDatabaseHas('user_profiles', [
            'user_id' => $user->id,
            'phone' => '081234567890',
            'gender' => 'male'
        ]);
    });

    it('can upload avatar', function () {
        $user = User::factory()->create();
        $profile = UserProfile::factory()->create(['user_id' => $user->id]);
        actingAsUser($user);

        $response = apiPost('/api/v1/profile/avatar', [
            'avatar' => UploadedFile::fake()->image('avatar.jpg', 200, 200)
        ]);

        assertApiSuccess($response, 'Avatar uploaded successfully');
        $response->assertJsonStructure([
            'data' => [
                'avatar_url',
                'avatar_path'
            ]
        ]);
    });

    it('can get profile history', function () {
        $user = User::factory()->create();
        $profile = UserProfile::factory()->create(['user_id' => $user->id]);
        actingAsUser($user);

        $response = apiGet('/api/v1/profile/history');

        assertApiSuccess($response, 'Profile history retrieved successfully');
    });

    it('can export profile data', function () {
        $user = User::factory()->create();
        $profile = UserProfile::factory()->create(['user_id' => $user->id]);
        actingAsUser($user);

        $response = apiGet('/api/v1/profile/export');

        assertApiSuccess($response, 'Profile exported successfully');
        $response->assertJsonStructure([
            'data' => [
                'download_url',
                'filename',
                'expires_at'
            ]
        ]);
    });
});
```

## ✅ Success Criteria

-   [x] User profile CRUD operations berfungsi
-   [x] Profile validation rules terimplementasi
-   [x] Profile image upload berjalan
-   [x] Emergency contact management berfungsi
-   [x] Profile history tracking berjalan
-   [x] Profile export functionality berfungsi
-   [x] Database schema optimal
-   [x] Testing coverage > 90%

## 📚 Documentation

-   [Laravel File Storage](https://laravel.com/docs/11.x/filesystem)
-   [Laravel Validation](https://laravel.com/docs/11.x/validation)
-   [Laravel Eloquent Relationships](https://laravel.com/docs/11.x/eloquent-relationships)
