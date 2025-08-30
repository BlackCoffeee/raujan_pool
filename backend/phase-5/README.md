# Phase 5: Member Management & Quota System

## 📋 Overview

Implementasi sistem manajemen member dengan dynamic quota management, queue system, dan membership expiry handling.

## 🎯 Objectives

- Member registration and management
- Dynamic quota management system
- Queue system for member applications
- Membership expiry tracking
- Member daily usage limits
- Member notifications system

## 📁 Files Structure

```
phase-5/
├── 01-member-registration.md
├── 02-quota-management.md
├── 03-queue-system.md
├── 04-membership-expiry.md
└── 05-daily-usage-limits.md
```

## 🔧 Implementation Points

### Point 1: Member Registration System

**Subpoints:**

- Member registration workflow
- Member profile management
- Member validation rules
- Member status management
- Member conversion from guest
- Member analytics

**Files:**

- `app/Http/Controllers/MemberController.php`
- `app/Models/Member.php`
- `app/Services/MemberService.php`
- `app/Jobs/ProcessMemberRegistrationJob.php`

### Point 2: Dynamic Quota Management

**Subpoints:**

- Dynamic quota configuration
- Quota calculation logic
- Quota allocation system
- Quota override mechanisms
- Quota history tracking
- Quota analytics

**Files:**

- `app/Http/Controllers/QuotaController.php`
- `app/Models/MemberQuota.php`
- `app/Services/QuotaService.php`
- `app/Repositories/QuotaRepository.php`

### Point 3: Queue System

**Subpoints:**

- Queue management system
- Queue position tracking
- Queue notification system
- Queue processing workflow
- Queue analytics
- Queue optimization

**Files:**

- `app/Http/Controllers/QueueController.php`
- `app/Models/MemberQueue.php`
- `app/Services/QueueService.php`
- `app/Jobs/ProcessQueueJob.php`

### Point 4: Membership Expiry Management

**Subpoints:**

- Expiry date tracking
- Expiry notifications
- Expiry processing
- Membership renewal
- Expiry analytics
- Expiry automation

**Files:**

- `app/Http/Controllers/MembershipExpiryController.php`
- `app/Models/MembershipExpiry.php`
- `app/Services/ExpiryService.php`
- `app/Jobs/ProcessExpiryJob.php`

### Point 5: Daily Usage Limits

**Subpoints:**

- Daily usage tracking
- Usage limit enforcement
- Additional session billing
- Usage analytics
- Usage notifications
- Usage optimization

**Files:**

- `app/Http/Controllers/DailyUsageController.php`
- `app/Models/DailyUsage.php`
- `app/Services/UsageService.php`
- `app/Jobs/TrackUsageJob.php`

## 📊 Database Schema

### Members Table

```sql
CREATE TABLE members (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    membership_number VARCHAR(50) UNIQUE NOT NULL,
    membership_type ENUM('regular', 'premium', 'vip') DEFAULT 'regular',
    status ENUM('active', 'inactive', 'suspended', 'expired') DEFAULT 'active',
    joined_date DATE NOT NULL,
    membership_start DATE NOT NULL,
    membership_end DATE NOT NULL,
    quota_used INT DEFAULT 0,
    quota_remaining INT DEFAULT 0,
    daily_usage_count INT DEFAULT 0,
    last_usage_date DATE NULL,
    total_bookings INT DEFAULT 0,
    total_amount_spent DECIMAL(10,2) DEFAULT 0,
    is_premium BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### Member Quota Configuration Table

```sql
CREATE TABLE member_quota_config (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    membership_type ENUM('regular', 'premium', 'vip') NOT NULL,
    max_quota INT NOT NULL,
    daily_limit INT NOT NULL DEFAULT 1,
    additional_session_cost DECIMAL(10,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (created_by) REFERENCES users(id)
);
```

### Member Queue Table

```sql
CREATE TABLE member_queue (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    queue_position INT NOT NULL,
    status ENUM('waiting', 'offered', 'accepted', 'rejected', 'expired') DEFAULT 'waiting',
    applied_date DATETIME NOT NULL,
    offered_date DATETIME NULL,
    accepted_date DATETIME NULL,
    expiry_date DATETIME NOT NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### Membership Expiry Tracking Table

```sql
CREATE TABLE membership_expiry_tracking (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    member_id BIGINT UNSIGNED NOT NULL,
    expiry_date DATE NOT NULL,
    notification_sent_3_days BOOLEAN DEFAULT FALSE,
    notification_sent_1_day BOOLEAN DEFAULT FALSE,
    notification_sent_expired BOOLEAN DEFAULT FALSE,
    status ENUM('active', 'expired', 'renewed') DEFAULT 'active',
    renewal_date DATE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (member_id) REFERENCES members(id)
);
```

### Member Daily Usage Tracking Table

```sql
CREATE TABLE member_daily_usage_tracking (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    member_id BIGINT UNSIGNED NOT NULL,
    usage_date DATE NOT NULL,
    usage_count INT DEFAULT 0,
    free_sessions_used INT DEFAULT 0,
    paid_sessions_used INT DEFAULT 0,
    total_amount DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (member_id) REFERENCES members(id),
    UNIQUE KEY unique_member_date (member_id, usage_date)
);
```

## 📚 API Routes & Endpoints

### Member Management Routes (Guest/Member)

```php
// Member Registration
GET    /api/members/register              // Get registration form
POST   /api/members/register              // Submit registration
GET    /api/members/profile               // Get member profile
PUT    /api/members/profile               // Update member profile
GET    /api/members/status                // Get membership status

// Member Quota
GET    /api/members/quota                 // Get quota information
GET    /api/members/quota/history         // Get quota history
GET    /api/members/quota/usage           // Get usage statistics

// Member Queue
GET    /api/members/queue/status          // Get queue status
POST   /api/members/queue/join            // Join membership queue
PUT    /api/members/queue/accept          // Accept membership offer
PUT    /api/members/queue/reject          // Reject membership offer
DELETE /api/members/queue/leave           // Leave queue

// Member Usage
GET    /api/members/usage/daily           // Get daily usage
GET    /api/members/usage/history         // Get usage history
GET    /api/members/usage/stats           // Get usage statistics

// Member Notifications
GET    /api/members/notifications         // Get member notifications
PUT    /api/members/notifications/{id}/read // Mark notification as read
```

### Member Admin Routes (Admin/Staff)

```php
// Member Management (Admin)
GET    /api/admin/members                 // List all members
GET    /api/admin/members/{id}            // Get member details
POST   /api/admin/members                 // Create member
PUT    /api/admin/members/{id}            // Update member
DELETE /api/admin/members/{id}            // Delete member
PUT    /api/admin/members/{id}/suspend    // Suspend member
PUT    /api/admin/members/{id}/activate   // Activate member

// Quota Management (Admin)
GET    /api/admin/quota/config            // Get quota configuration
POST   /api/admin/quota/config            // Create quota configuration
PUT    /api/admin/quota/config/{id}       // Update quota configuration
DELETE /api/admin/quota/config/{id}       // Delete quota configuration
GET    /api/admin/quota/analytics         // Get quota analytics

// Queue Management (Admin)
GET    /api/admin/queue                   // List queue members
PUT    /api/admin/queue/{id}/offer        // Offer membership
PUT    /api/admin/queue/{id}/process      // Process queue member
GET    /api/admin/queue/stats             // Get queue statistics

// Expiry Management (Admin)
GET    /api/admin/expiry                  // List expiring members
PUT    /api/admin/expiry/{id}/renew       // Renew membership
GET    /api/admin/expiry/notifications    // Get expiry notifications
POST   /api/admin/expiry/bulk-renew       // Bulk renew memberships

// Usage Management (Admin)
GET    /api/admin/usage                   // List member usage
GET    /api/admin/usage/analytics         // Get usage analytics
PUT    /api/admin/usage/{id}/override     // Override usage limits
```

### Member Analytics Routes

```php
// Member Analytics
GET    /api/admin/analytics/members       // Member statistics
GET    /api/admin/analytics/quota         // Quota analytics
GET    /api/admin/analytics/queue         // Queue analytics
GET    /api/admin/analytics/expiry        // Expiry analytics
GET    /api/admin/analytics/usage         // Usage analytics
GET    /api/admin/analytics/revenue       // Revenue analytics
```

## 🔄 CRUD Operations

### Member CRUD Operations

#### Create Member

```php
// POST /api/members
public function store(MemberRequest $request)
{
    $user = User::findOrFail($request->user_id);

    $member = Member::create([
        'user_id' => $user->id,
        'membership_number' => $this->generateMembershipNumber(),
        'membership_type' => $request->membership_type,
        'joined_date' => now(),
        'membership_start' => $request->membership_start,
        'membership_end' => $request->membership_end,
        'quota_remaining' => $this->getQuotaForType($request->membership_type),
    ]);

    // Create expiry tracking
    MembershipExpiryTracking::create([
        'member_id' => $member->id,
        'expiry_date' => $request->membership_end,
    ]);

    // Send welcome notification
    event(new MemberRegistered($member));

    return response()->json($member, 201);
}
```

#### Read Member

```php
// GET /api/members/{id}
public function show($id)
{
    $member = Member::with([
        'user',
        'expiryTracking',
        'dailyUsage',
        'quotaHistory'
    ])->findOrFail($id);

    return response()->json($member);
}
```

#### Update Member

```php
// PUT /api/members/{id}
public function update(MemberRequest $request, $id)
{
    $member = Member::findOrFail($id);
    $member->update($request->validated());

    // Update expiry tracking if membership end date changed
    if ($request->has('membership_end')) {
        $member->expiryTracking->update([
            'expiry_date' => $request->membership_end
        ]);
    }

    return response()->json($member);
}
```

#### Delete Member

```php
// DELETE /api/members/{id}
public function destroy($id)
{
    $member = Member::findOrFail($id);

    // Check if member has active bookings
    if ($member->hasActiveBookings()) {
        return response()->json(['error' => 'Cannot delete member with active bookings'], 422);
    }

    $member->delete();

    return response()->json(['message' => 'Member deleted successfully']);
}
```

### Quota Management CRUD Operations

#### Create Quota Configuration

```php
// POST /api/admin/quota/config
public function storeQuotaConfig(QuotaConfigRequest $request)
{
    $quotaConfig = MemberQuotaConfig::create([
        'membership_type' => $request->membership_type,
        'max_quota' => $request->max_quota,
        'daily_limit' => $request->daily_limit,
        'additional_session_cost' => $request->additional_session_cost,
        'created_by' => auth()->id(),
    ]);

    // Update existing members of this type
    $this->updateExistingMembersQuota($request->membership_type, $request->max_quota);

    return response()->json($quotaConfig, 201);
}
```

#### Update Quota Configuration

```php
// PUT /api/admin/quota/config/{id}
public function updateQuotaConfig(QuotaConfigRequest $request, $id)
{
    $quotaConfig = MemberQuotaConfig::findOrFail($id);
    $oldQuota = $quotaConfig->max_quota;

    $quotaConfig->update($request->validated());

    // If quota changed, update existing members
    if ($oldQuota != $request->max_quota) {
        $this->updateExistingMembersQuota($quotaConfig->membership_type, $request->max_quota);
    }

    return response()->json($quotaConfig);
}
```

### Queue Management CRUD Operations

#### Join Queue

```php
// POST /api/members/queue/join
public function joinQueue(QueueRequest $request)
{
    $user = auth()->user();

    // Check if user is already in queue
    if ($user->queueEntry()->exists()) {
        return response()->json(['error' => 'Already in queue'], 422);
    }

    // Get next queue position
    $nextPosition = MemberQueue::max('queue_position') + 1;

    $queueEntry = MemberQueue::create([
        'user_id' => $user->id,
        'queue_position' => $nextPosition,
        'applied_date' => now(),
        'expiry_date' => now()->addDays(7),
    ]);

    // Send confirmation notification
    event(new UserJoinedQueue($queueEntry));

    return response()->json($queueEntry, 201);
}
```

#### Offer Membership (Admin)

```php
// PUT /api/admin/queue/{id}/offer
public function offerMembership($id, OfferMembershipRequest $request)
{
    $queueEntry = MemberQueue::findOrFail($id);

    $queueEntry->update([
        'status' => 'offered',
        'offered_date' => now(),
        'expiry_date' => now()->addDays(3),
    ]);

    // Send offer notification
    event(new MembershipOffered($queueEntry));

    return response()->json(['message' => 'Membership offered successfully']);
}
```

### Daily Usage Tracking CRUD Operations

#### Track Daily Usage

```php
// POST /api/members/usage/track
public function trackUsage(TrackUsageRequest $request)
{
    $member = Member::findOrFail($request->member_id);
    $today = now()->toDateString();

    $dailyUsage = MemberDailyUsageTracking::firstOrCreate([
        'member_id' => $member->id,
        'usage_date' => $today,
    ]);

    // Update usage count
    $dailyUsage->increment('usage_count');

    // Check if this is a free or paid session
    if ($dailyUsage->usage_count <= $member->dailyLimit) {
        $dailyUsage->increment('free_sessions_used');
    } else {
        $dailyUsage->increment('paid_sessions_used');
        $dailyUsage->increment('total_amount', $member->additionalSessionCost);
    }

    // Update member's daily usage count
    $member->update(['daily_usage_count' => $dailyUsage->usage_count]);

    return response()->json($dailyUsage);
}
```

## 🎭 Actor Perspectives

### Guest User Perspective

- **Join Queue**: Apply for membership
- **Track Queue**: Monitor queue position
- **Accept/Reject Offer**: Respond to membership offers
- **View Requirements**: Check membership requirements

### Member Perspective

- **View Profile**: Access membership details
- **Track Quota**: Monitor quota usage
- **Track Usage**: View daily usage statistics
- **Renew Membership**: Extend membership period
- **View Benefits**: Access member benefits

### Staff Front Desk Perspective

- **Register Members**: Process new member registrations
- **Manage Quota**: Handle quota adjustments
- **Process Queue**: Offer memberships to queue
- **Track Usage**: Monitor member usage
- **Handle Expiry**: Process membership renewals

### Admin Perspective

- **Configure System**: Set quota limits and policies
- **Manage Queue**: Oversee queue processing
- **Analytics**: Access comprehensive analytics
- **System Settings**: Configure membership rules
- **Bulk Operations**: Perform bulk updates

## 🧪 Testing

### Member Testing

```php
// tests/Feature/MemberTest.php
class MemberTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register_as_member()
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)
            ->postJson('/api/members/register', [
                'membership_type' => 'regular',
                'membership_start' => now(),
                'membership_end' => now()->addYear(),
            ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('members', [
            'user_id' => $user->id,
            'membership_type' => 'regular',
        ]);
    }

    public function test_admin_can_create_quota_config()
    {
        $admin = User::factory()->create(['role' => 'admin']);

        $response = $this->actingAs($admin)
            ->postJson('/api/admin/quota/config', [
                'membership_type' => 'regular',
                'max_quota' => 100,
                'daily_limit' => 1,
                'additional_session_cost' => 50000,
            ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('member_quota_config', [
            'membership_type' => 'regular',
            'max_quota' => 100,
        ]);
    }

    public function test_user_can_join_membership_queue()
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)
            ->postJson('/api/members/queue/join');

        $response->assertStatus(201);
        $this->assertDatabaseHas('member_queue', [
            'user_id' => $user->id,
            'status' => 'waiting',
        ]);
    }
}
```

## ✅ Success Criteria

- [ ] Member registration berfungsi dengan baik
- [ ] Dynamic quota management berjalan
- [ ] Queue system terimplementasi
- [ ] Membership expiry tracking berfungsi
- [ ] Daily usage limits terenforce
- [ ] Member notifications terkirim
- [ ] Member analytics dapat diakses
- [ ] Queue processing otomatis
- [ ] Expiry automation berjalan
- [ ] Testing coverage > 90%

## 📚 Documentation

- Member Management Architecture
- Quota System Guide
- Queue Management Guide
- Expiry Management Guide
- Usage Tracking Guide
