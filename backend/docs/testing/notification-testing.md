# Member Notifications Testing Guide

## Overview

Dokumentasi ini menjelaskan cara melakukan testing untuk sistem notifikasi member, termasuk unit tests, feature tests, dan integration tests.

## Test Structure

```
tests/
├── Feature/
│   └── MemberNotificationTest.php
├── Unit/
│   ├── NotificationServiceTest.php
│   └── MemberNotificationModelTest.php
└── Integration/
    └── NotificationIntegrationTest.php
```

## Running Tests

### Run All Notification Tests
```bash
php artisan test --filter=Notification
```

### Run Specific Test File
```bash
php artisan test tests/Feature/MemberNotificationTest.php
```

### Run with Coverage
```bash
php artisan test --coverage --filter=Notification
```

## Unit Tests

### NotificationServiceTest

Test untuk service layer notification system.

```php
<?php

namespace Tests\Unit;

use App\Models\Member;
use App\Models\MemberNotification;
use App\Services\NotificationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class NotificationServiceTest extends TestCase
{
    use RefreshDatabase;

    protected $notificationService;

    protected function setUp(): void
    {
        parent::setUp();
        $this->notificationService = app(NotificationService::class);
    }

    /** @test */
    public function it_can_create_notification()
    {
        $member = Member::factory()->create();

        $notification = $this->notificationService->createNotification(
            $member->id,
            'booking_confirmation',
            'Booking Confirmed',
            'Your booking has been confirmed.'
        );

        $this->assertInstanceOf(MemberNotification::class, $notification);
        $this->assertEquals($member->id, $notification->member_id);
        $this->assertEquals('booking_confirmation', $notification->type);
        $this->assertEquals('pending', $notification->status);
    }

    /** @test */
    public function it_can_send_notification()
    {
        $member = Member::factory()->create();
        $notification = MemberNotification::factory()->create([
            'member_id' => $member->id,
            'status' => 'pending'
        ]);

        $sentNotification = $this->notificationService->sendNotification($notification->id);

        $this->assertEquals('sent', $sentNotification->status);
        $this->assertNotNull($sentNotification->sent_at);
    }

    /** @test */
    public function it_can_schedule_notification()
    {
        $member = Member::factory()->create();
        $scheduledAt = now()->addHour();

        $notification = $this->notificationService->scheduleNotification(
            $member->id,
            'booking_reminder',
            'Booking Reminder',
            'Your booking is tomorrow.',
            $scheduledAt
        );

        $this->assertEquals('scheduled', $notification->status);
        $this->assertEquals($scheduledAt->format('Y-m-d H:i:s'), $notification->scheduled_at->format('Y-m-d H:i:s'));
    }

    /** @test */
    public function it_can_send_bulk_notifications()
    {
        $members = Member::factory()->count(3)->create();
        $memberIds = $members->pluck('id')->toArray();

        $notifications = $this->notificationService->sendBulkNotification(
            $memberIds,
            'general',
            'General Announcement',
            'This is a general announcement.'
        );

        $this->assertCount(3, $notifications);
    }

    /** @test */
    public function it_can_get_notification_statistics()
    {
        MemberNotification::factory()->count(5)->create();
        
        $stats = $this->notificationService->getNotificationStats();

        $this->assertArrayHasKey('total_notifications', $stats);
        $this->assertEquals(5, $stats['total_notifications']);
    }

    /** @test */
    public function it_can_get_notification_analytics()
    {
        MemberNotification::factory()->count(10)->create();
        
        $analytics = $this->notificationService->getNotificationAnalytics();

        $this->assertArrayHasKey('delivery_rates', $analytics);
        $this->assertArrayHasKey('read_rates', $analytics);
        $this->assertArrayHasKey('click_rates', $analytics);
    }

    /** @test */
    public function it_can_update_notification_preferences()
    {
        $member = Member::factory()->create();
        $preferences = [
            'booking_confirmation' => ['email', 'in_app'],
            'payment_reminder' => ['sms', 'email']
        ];

        $updatedMember = $this->notificationService->updateNotificationPreferences($member->id, $preferences);

        $this->assertEquals($preferences, $updatedMember->notification_preferences);
    }

    /** @test */
    public function it_cannot_delete_sent_notifications()
    {
        $notification = MemberNotification::factory()->sent()->create();

        $this->expectException(\Exception::class);
        $this->expectExceptionMessage('Cannot delete sent notifications');

        $this->notificationService->deleteNotification($notification->id);
    }
}
```

### MemberNotificationModelTest

Test untuk model MemberNotification.

```php
<?php

namespace Tests\Unit;

use App\Models\Member;
use App\Models\MemberNotification;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MemberNotificationModelTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function it_belongs_to_member()
    {
        $member = Member::factory()->create();
        $notification = MemberNotification::factory()->create(['member_id' => $member->id]);

        $this->assertInstanceOf(Member::class, $notification->member);
        $this->assertEquals($member->id, $notification->member->id);
    }

    /** @test */
    public function it_can_scope_by_type()
    {
        MemberNotification::factory()->create(['type' => 'booking_confirmation']);
        MemberNotification::factory()->create(['type' => 'payment_reminder']);

        $bookingNotifications = MemberNotification::byType('booking_confirmation')->get();

        $this->assertCount(1, $bookingNotifications);
        $this->assertEquals('booking_confirmation', $bookingNotifications->first()->type);
    }

    /** @test */
    public function it_can_scope_by_status()
    {
        MemberNotification::factory()->pending()->create();
        MemberNotification::factory()->sent()->create();

        $pendingNotifications = MemberNotification::pending()->get();

        $this->assertCount(1, $pendingNotifications);
        $this->assertEquals('pending', $pendingNotifications->first()->status);
    }

    /** @test */
    public function it_can_scope_due_for_sending()
    {
        MemberNotification::factory()->create([
            'status' => 'scheduled',
            'scheduled_at' => now()->subMinute()
        ]);
        MemberNotification::factory()->create([
            'status' => 'scheduled',
            'scheduled_at' => now()->addHour()
        ]);

        $dueNotifications = MemberNotification::dueForSending()->get();

        $this->assertCount(1, $dueNotifications);
    }

    /** @test */
    public function it_can_scope_unread()
    {
        MemberNotification::factory()->create(['read_at' => null]);
        MemberNotification::factory()->create(['read_at' => now()]);

        $unreadNotifications = MemberNotification::unread()->get();

        $this->assertCount(1, $unreadNotifications);
    }

    /** @test */
    public function it_can_get_status_display()
    {
        $notification = MemberNotification::factory()->create(['status' => 'pending']);

        $this->assertEquals('Pending', $notification->status_display);
    }

    /** @test */
    public function it_can_get_priority_display()
    {
        $notification = MemberNotification::factory()->create(['priority' => 'high']);

        $this->assertEquals('High', $notification->priority_display);
    }

    /** @test */
    public function it_can_get_type_display()
    {
        $notification = MemberNotification::factory()->create(['type' => 'booking_confirmation']);

        $this->assertEquals('Booking Confirmation', $notification->type_display);
    }

    /** @test */
    public function it_can_check_if_read()
    {
        $unreadNotification = MemberNotification::factory()->create(['read_at' => null]);
        $readNotification = MemberNotification::factory()->create(['read_at' => now()]);

        $this->assertFalse($unreadNotification->is_read);
        $this->assertTrue($readNotification->is_read);
    }

    /** @test */
    public function it_can_check_if_sent()
    {
        $unsentNotification = MemberNotification::factory()->create(['sent_at' => null]);
        $sentNotification = MemberNotification::factory()->create(['sent_at' => now()]);

        $this->assertFalse($unsentNotification->is_sent);
        $this->assertTrue($sentNotification->is_sent);
    }

    /** @test */
    public function it_can_check_if_delivered()
    {
        $pendingNotification = MemberNotification::factory()->create(['status' => 'pending']);
        $deliveredNotification = MemberNotification::factory()->create(['status' => 'delivered']);

        $this->assertFalse($pendingNotification->is_delivered);
        $this->assertTrue($deliveredNotification->is_delivered);
    }
}
```

## Feature Tests

### MemberNotificationTest

Test untuk API endpoints notification system.

```php
<?php

namespace Tests\Feature;

use App\Models\Member;
use App\Models\MemberNotification;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MemberNotificationTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function admin_can_get_all_notifications()
    {
        MemberNotification::factory()->count(5)->create();
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        $response = $this->actingAs($admin, 'sanctum')
            ->getJson('/api/v1/admin/notifications');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'data' => [
                        '*' => [
                            'id',
                            'member_id',
                            'type',
                            'title',
                            'message',
                            'status',
                            'priority',
                            'created_at'
                        ]
                    ]
                ]
            ]);
    }

    /** @test */
    public function admin_can_create_notification()
    {
        $member = Member::factory()->create();
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        $response = $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/admin/notifications', [
                'member_id' => $member->id,
                'type' => 'general',
                'title' => 'Test Notification',
                'message' => 'This is a test notification',
                'priority' => 'normal'
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Notification created successfully'
            ]);

        $this->assertDatabaseHas('member_notifications', [
            'member_id' => $member->id,
            'type' => 'general',
            'title' => 'Test Notification'
        ]);
    }

    /** @test */
    public function admin_can_send_bulk_notifications()
    {
        $members = Member::factory()->count(3)->create();
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        $response = $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/admin/notifications/bulk', [
                'member_ids' => $members->pluck('id')->toArray(),
                'type' => 'general',
                'title' => 'Bulk Notification',
                'message' => 'This is a bulk notification',
                'priority' => 'normal'
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Bulk notifications created successfully'
            ]);

        $this->assertDatabaseCount('member_notifications', 3);
    }

    /** @test */
    public function admin_can_get_notification_statistics()
    {
        MemberNotification::factory()->count(5)->create();
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        $response = $this->actingAs($admin, 'sanctum')
            ->getJson('/api/v1/admin/notifications/stats');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'total_notifications',
                    'pending_notifications',
                    'sent_notifications',
                    'failed_notifications'
                ]
            ]);
    }

    /** @test */
    public function member_can_get_their_notifications()
    {
        $member = Member::factory()->create();
        MemberNotification::factory()->count(3)->create(['member_id' => $member->id]);

        $response = $this->actingAs($member->user, 'sanctum')
            ->getJson('/api/v1/members/my-notifications');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'My notifications retrieved successfully'
            ])
            ->assertJsonCount(3, 'data.data');
    }

    /** @test */
    public function member_can_mark_notification_as_read()
    {
        $member = Member::factory()->create();
        $notification = MemberNotification::factory()->sent()->create(['member_id' => $member->id]);

        $response = $this->actingAs($member->user, 'sanctum')
            ->postJson("/api/v1/members/my-notifications/{$notification->id}/read");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Notification marked as read'
            ]);

        $this->assertDatabaseHas('member_notifications', [
            'id' => $notification->id,
            'status' => 'read'
        ]);
    }

    /** @test */
    public function member_cannot_access_other_member_notifications()
    {
        $member1 = Member::factory()->create();
        $member2 = Member::factory()->create();
        $notification = MemberNotification::factory()->create(['member_id' => $member2->id]);

        $response = $this->actingAs($member1->user, 'sanctum')
            ->postJson("/api/v1/members/my-notifications/{$notification->id}/read");

        $response->assertStatus(404);
    }

    /** @test */
    public function it_validates_notification_creation_data()
    {
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        $response = $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/admin/notifications', [
                'member_id' => 999, // Non-existent member
                'type' => 'invalid_type',
                'title' => '', // Empty title
                'message' => '', // Empty message
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['member_id', 'type', 'title', 'message']);
    }

    /** @test */
    public function it_can_filter_notifications_by_type()
    {
        MemberNotification::factory()->count(3)->create(['type' => 'booking_confirmation']);
        MemberNotification::factory()->count(2)->create(['type' => 'payment_reminder']);
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        $response = $this->actingAs($admin, 'sanctum')
            ->getJson('/api/v1/admin/notifications?type=booking_confirmation');

        $response->assertStatus(200);
        $this->assertCount(3, $response->json('data.data'));
    }

    /** @test */
    public function it_can_filter_notifications_by_status()
    {
        MemberNotification::factory()->count(3)->pending()->create();
        MemberNotification::factory()->count(2)->sent()->create();
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        $response = $this->actingAs($admin, 'sanctum')
            ->getJson('/api/v1/admin/notifications?status=pending');

        $response->assertStatus(200);
        $this->assertCount(3, $response->json('data.data'));
    }
}
```

## Integration Tests

### NotificationIntegrationTest

Test untuk integrasi dengan sistem lain.

```php
<?php

namespace Tests\Integration;

use App\Models\Member;
use App\Models\MemberNotification;
use App\Services\NotificationService;
use App\Jobs\SendNotificationJob;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Queue;
use Tests\TestCase;

class NotificationIntegrationTest extends TestCase
{
    use RefreshDatabase;

    protected $notificationService;

    protected function setUp(): void
    {
        parent::setUp();
        $this->notificationService = app(NotificationService::class);
    }

    /** @test */
    public function it_can_integrate_with_booking_system()
    {
        Queue::fake();
        
        $member = Member::factory()->create();

        // Simulate booking confirmation
        $notification = $this->notificationService->createNotification(
            $member->id,
            'booking_confirmation',
            'Booking Confirmed',
            'Your booking has been confirmed.',
            [
                'data' => [
                    'booking_id' => 123,
                    'session_date' => '2024-01-16',
                    'session_time' => '10:00'
                ]
            ]
        );

        // Assert job is dispatched
        Queue::assertPushed(SendNotificationJob::class, function ($job) use ($notification) {
            return $job->notification->id === $notification->id;
        });
    }

    /** @test */
    public function it_can_integrate_with_payment_system()
    {
        $member = Member::factory()->create();

        // Simulate payment confirmation
        $notification = $this->notificationService->createNotification(
            $member->id,
            'payment_confirmation',
            'Payment Confirmed',
            'Your payment has been successfully processed.',
            [
                'data' => [
                    'payment_id' => 456,
                    'amount' => 100000,
                    'payment_method' => 'bank_transfer'
                ]
            ]
        );

        $this->assertDatabaseHas('member_notifications', [
            'member_id' => $member->id,
            'type' => 'payment_confirmation',
            'data' => json_encode([
                'payment_id' => 456,
                'amount' => 100000,
                'payment_method' => 'bank_transfer'
            ])
        ]);
    }

    /** @test */
    public function it_can_integrate_with_membership_expiry_system()
    {
        $member = Member::factory()->create();

        // Simulate membership expiry notification
        $notification = $this->notificationService->createNotification(
            $member->id,
            'membership_expiry',
            'Membership Expiring Soon',
            'Your membership will expire in 3 days.',
            [
                'data' => [
                    'expiry_date' => now()->addDays(3)->format('Y-m-d'),
                    'days_remaining' => 3
                ]
            ]
        );

        $this->assertDatabaseHas('member_notifications', [
            'member_id' => $member->id,
            'type' => 'membership_expiry',
            'title' => 'Membership Expiring Soon'
        ]);
    }

    /** @test */
    public function it_can_process_scheduled_notifications()
    {
        $member = Member::factory()->create();
        
        // Create scheduled notification
        $notification = MemberNotification::factory()->create([
            'member_id' => $member->id,
            'status' => 'scheduled',
            'scheduled_at' => now()->subMinute()
        ]);

        // Process scheduled notifications
        $processedCount = $this->notificationService->processScheduledNotifications();

        $this->assertEquals(1, $processedCount);
        
        // Assert notification status is updated
        $this->assertDatabaseHas('member_notifications', [
            'id' => $notification->id,
            'status' => 'sent'
        ]);
    }

    /** @test */
    public function it_can_retry_failed_notifications()
    {
        Queue::fake();
        
        $member = Member::factory()->create();
        
        // Create failed notification
        $notification = MemberNotification::factory()->create([
            'member_id' => $member->id,
            'status' => 'failed',
            'delivery_attempts' => 1,
            'last_delivery_attempt' => now()->subHour()
        ]);

        // Retry failed notifications
        $retriedCount = $this->notificationService->retryFailedNotifications();

        $this->assertEquals(1, $retriedCount);
        
        // Assert job is dispatched for retry
        Queue::assertPushed(SendNotificationJob::class, function ($job) use ($notification) {
            return $job->notification->id === $notification->id;
        });
    }
}
```

## Test Data Setup

### Database Seeders

```php
<?php

namespace Database\Seeders;

use App\Models\Member;
use App\Models\MemberNotification;
use Illuminate\Database\Seeder;

class NotificationTestSeeder extends Seeder
{
    public function run()
    {
        // Create test members
        $members = Member::factory()->count(10)->create();

        // Create various notification types
        foreach ($members as $member) {
            MemberNotification::factory()->create([
                'member_id' => $member->id,
                'type' => 'booking_confirmation',
                'status' => 'sent'
            ]);

            MemberNotification::factory()->create([
                'member_id' => $member->id,
                'type' => 'payment_reminder',
                'status' => 'pending'
            ]);

            MemberNotification::factory()->create([
                'member_id' => $member->id,
                'type' => 'general',
                'status' => 'read'
            ]);
        }
    }
}
```

## Performance Testing

### Load Testing

```php
<?php

namespace Tests\Performance;

use App\Models\Member;
use App\Models\MemberNotification;
use App\Services\NotificationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class NotificationPerformanceTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function it_can_handle_bulk_notifications_performance()
    {
        $members = Member::factory()->count(100)->create();
        $memberIds = $members->pluck('id')->toArray();
        
        $startTime = microtime(true);
        
        $notifications = app(NotificationService::class)->sendBulkNotification(
            $memberIds,
            'general',
            'Performance Test',
            'This is a performance test notification.'
        );
        
        $endTime = microtime(true);
        $executionTime = $endTime - $startTime;
        
        $this->assertCount(100, $notifications);
        $this->assertLessThan(5, $executionTime); // Should complete within 5 seconds
    }

    /** @test */
    public function it_can_handle_large_notification_queries()
    {
        // Create 1000 notifications
        MemberNotification::factory()->count(1000)->create();
        
        $startTime = microtime(true);
        
        $notifications = MemberNotification::with(['member.user'])
            ->orderBy('created_at', 'desc')
            ->paginate(50);
        
        $endTime = microtime(true);
        $executionTime = $endTime - $startTime;
        
        $this->assertCount(50, $notifications->items());
        $this->assertLessThan(2, $executionTime); // Should complete within 2 seconds
    }
}
```

## Test Coverage

Target test coverage untuk notification system:

- **Unit Tests**: 90%+
- **Feature Tests**: 85%+
- **Integration Tests**: 80%+

### Running Coverage Report

```bash
php artisan test --coverage --filter=Notification
```

## Continuous Integration

### GitHub Actions Workflow

```yaml
name: Notification Tests

on:
  push:
    paths:
      - 'app/Models/MemberNotification.php'
      - 'app/Services/NotificationService.php'
      - 'app/Http/Controllers/Api/V1/MemberNotificationController.php'
      - 'tests/**/Notification*Test.php'

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup PHP
      uses: shivammathur/setup-php@v2
      with:
        php-version: '8.2'
        
    - name: Install dependencies
      run: composer install
      
    - name: Run notification tests
      run: php artisan test --filter=Notification --coverage
      
    - name: Upload coverage
      uses: codecov/codecov-action@v1
      with:
        file: ./coverage.xml
```

## Best Practices

1. **Test Isolation**: Setiap test harus independen dan tidak bergantung pada test lain
2. **Database Cleanup**: Gunakan `RefreshDatabase` trait untuk membersihkan database
3. **Mocking**: Mock external services seperti email dan SMS providers
4. **Data Factories**: Gunakan factories untuk membuat test data yang konsisten
5. **Assertions**: Gunakan assertions yang spesifik dan meaningful
6. **Performance**: Test performance untuk operasi bulk dan query yang kompleks
7. **Error Handling**: Test berbagai skenario error dan edge cases
