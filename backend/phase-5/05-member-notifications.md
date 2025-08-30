# Point 5: Member Notifications

## 📋 Overview

Implementasi sistem notifikasi untuk member dengan berbagai jenis notifikasi, delivery channels, dan notification preferences.

## 🎯 Objectives

- Notification types
- Delivery channels
- Notification preferences
- Notification scheduling
- Notification analytics
- Notification automation

## 📁 Files Structure

```
phase-5/
├── 05-member-notifications.md
├── app/Http/Controllers/MemberNotificationController.php
├── app/Models/MemberNotification.php
├── app/Services/NotificationService.php
└── app/Jobs/SendNotificationJob.php
```

## 🔧 Implementation Steps

### Step 1: Create Member Notification Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class MemberNotification extends Model
{
    use HasFactory;

    protected $fillable = [
        'member_id',
        'type',
        'title',
        'message',
        'data',
        'delivery_channels',
        'scheduled_at',
        'sent_at',
        'status',
        'priority',
        'read_at',
        'clicked_at',
        'delivery_attempts',
        'last_delivery_attempt',
        'error_message',
    ];

    protected $casts = [
        'data' => 'array',
        'delivery_channels' => 'array',
        'scheduled_at' => 'datetime',
        'sent_at' => 'datetime',
        'read_at' => 'datetime',
        'clicked_at' => 'datetime',
        'last_delivery_attempt' => 'datetime',
    ];

    public function member()
    {
        return $this->belongsTo(Member::class);
    }

    public function getStatusDisplayAttribute()
    {
        return match($this->status) {
            'pending' => 'Pending',
            'scheduled' => 'Scheduled',
            'sent' => 'Sent',
            'delivered' => 'Delivered',
            'read' => 'Read',
            'clicked' => 'Clicked',
            'failed' => 'Failed',
            'cancelled' => 'Cancelled',
            default => 'Unknown'
        };
    }

    public function getPriorityDisplayAttribute()
    {
        return match($this->priority) {
            'low' => 'Low',
            'normal' => 'Normal',
            'high' => 'High',
            'urgent' => 'Urgent',
            default => 'Normal'
        };
    }

    public function getTypeDisplayAttribute()
    {
        return match($this->type) {
            'booking_confirmation' => 'Booking Confirmation',
            'booking_reminder' => 'Booking Reminder',
            'booking_cancellation' => 'Booking Cancellation',
            'payment_confirmation' => 'Payment Confirmation',
            'payment_reminder' => 'Payment Reminder',
            'membership_expiry' => 'Membership Expiry',
            'membership_renewal' => 'Membership Renewal',
            'quota_update' => 'Quota Update',
            'queue_position' => 'Queue Position',
            'general' => 'General',
            'promotional' => 'Promotional',
            'system' => 'System',
            default => 'Unknown'
        };
    }

    public function getIsReadAttribute()
    {
        return !is_null($this->read_at);
    }

    public function getIsSentAttribute()
    {
        return !is_null($this->sent_at);
    }

    public function getIsDeliveredAttribute()
    {
        return $this->status === 'delivered' || $this->status === 'read' || $this->status === 'clicked';
    }

    public function getIsFailedAttribute()
    {
        return $this->status === 'failed';
    }

    public function getIsScheduledAttribute()
    {
        return $this->status === 'scheduled' && $this->scheduled_at > now();
    }

    public function getDeliveryChannelsDisplayAttribute()
    {
        return collect($this->delivery_channels)->map(function ($channel) {
            return match($channel) {
                'email' => 'Email',
                'sms' => 'SMS',
                'push' => 'Push Notification',
                'in_app' => 'In-App',
                'whatsapp' => 'WhatsApp',
                default => ucfirst($channel)
            };
        })->join(', ');
    }

    public function getTimeToSendAttribute()
    {
        if (!$this->scheduled_at) {
            return null;
        }

        return $this->scheduled_at->diffForHumans();
    }

    public function getDeliveryTimeAttribute()
    {
        if (!$this->sent_at) {
            return null;
        }

        return $this->sent_at->diffForHumans();
    }

    public function getReadTimeAttribute()
    {
        if (!$this->read_at) {
            return null;
        }

        return $this->read_at->diffForHumans();
    }

    public function scopeByType($query, $type)
    {
        return $query->where('type', $type);
    }

    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    public function scopeByPriority($query, $priority)
    {
        return $query->where('priority', $priority);
    }

    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeScheduled($query)
    {
        return $query->where('status', 'scheduled');
    }

    public function scopeSent($query)
    {
        return $query->where('status', 'sent');
    }

    public function scopeDelivered($query)
    {
        return $query->whereIn('status', ['delivered', 'read', 'clicked']);
    }

    public function scopeRead($query)
    {
        return $query->where('status', 'read');
    }

    public function scopeFailed($query)
    {
        return $query->where('status', 'failed');
    }

    public function scopeDueForSending($query)
    {
        return $query->where('status', 'scheduled')
            ->where('scheduled_at', '<=', now());
    }

    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('created_at', [$startDate, $endDate]);
    }

    public function scopeByMember($query, $memberId)
    {
        return $query->where('member_id', $memberId);
    }

    public function scopeUnread($query)
    {
        return $query->whereNull('read_at');
    }

    public function scopeRead($query)
    {
        return $query->whereNotNull('read_at');
    }

    public function scopeByDeliveryChannel($query, $channel)
    {
        return $query->whereJsonContains('delivery_channels', $channel);
    }

    public function scopeHighPriority($query)
    {
        return $query->whereIn('priority', ['high', 'urgent']);
    }

    public function scopeRecent($query, $days = 7)
    {
        return $query->where('created_at', '>=', now()->subDays($days));
    }
}
```

### Step 2: Create Notification Service

```php
<?php

namespace App\Services;

use App\Models\Member;
use App\Models\MemberNotification;
use App\Jobs\SendNotificationJob;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class NotificationService
{
    public function createNotification($memberId, $type, $title, $message, $options = [])
    {
        return DB::transaction(function () use ($memberId, $type, $title, $message, $options) {
            $member = Member::findOrFail($memberId);

            // Get member's notification preferences
            $preferences = $member->notificationPreferences ?? [];
            $deliveryChannels = $preferences[$type] ?? ['email', 'in_app'];

            $notification = MemberNotification::create([
                'member_id' => $member->id,
                'type' => $type,
                'title' => $title,
                'message' => $message,
                'data' => $options['data'] ?? [],
                'delivery_channels' => $deliveryChannels,
                'scheduled_at' => $options['scheduled_at'] ?? null,
                'status' => $options['scheduled_at'] ? 'scheduled' : 'pending',
                'priority' => $options['priority'] ?? 'normal',
            ]);

            // Queue for immediate sending if not scheduled
            if (!$options['scheduled_at']) {
                SendNotificationJob::dispatch($notification);
            }

            Log::info('Notification created', [
                'notification_id' => $notification->id,
                'member_id' => $member->id,
                'type' => $type,
                'title' => $title,
                'delivery_channels' => $deliveryChannels,
            ]);

            return $notification;
        });
    }

    public function sendNotification($notificationId)
    {
        return DB::transaction(function () use ($notificationId) {
            $notification = MemberNotification::findOrFail($notificationId);

            if ($notification->status !== 'pending' && $notification->status !== 'scheduled') {
                throw new \Exception('Notification cannot be sent');
            }

            $member = $notification->member;
            $user = $member->user;
            $sentChannels = [];

            foreach ($notification->delivery_channels as $channel) {
                try {
                    $this->sendToChannel($notification, $channel, $user);
                    $sentChannels[] = $channel;
                } catch (\Exception $e) {
                    Log::error('Failed to send notification to channel', [
                        'notification_id' => $notification->id,
                        'channel' => $channel,
                        'error' => $e->getMessage(),
                    ]);
                }
            }

            // Update notification status
            $notification->update([
                'status' => count($sentChannels) > 0 ? 'sent' : 'failed',
                'sent_at' => now(),
                'delivery_attempts' => $notification->delivery_attempts + 1,
                'last_delivery_attempt' => now(),
                'error_message' => count($sentChannels) === 0 ? 'All delivery channels failed' : null,
            ]);

            return $notification;
        });
    }

    public function markAsRead($notificationId)
    {
        $notification = MemberNotification::findOrFail($notificationId);

        if (!$notification->is_read) {
            $notification->update([
                'status' => 'read',
                'read_at' => now(),
            ]);

            Log::info('Notification marked as read', [
                'notification_id' => $notification->id,
                'member_id' => $notification->member_id,
            ]);
        }

        return $notification;
    }

    public function markAsClicked($notificationId)
    {
        $notification = MemberNotification::findOrFail($notificationId);

        $notification->update([
            'status' => 'clicked',
            'clicked_at' => now(),
        ]);

        Log::info('Notification marked as clicked', [
            'notification_id' => $notification->id,
            'member_id' => $notification->member_id,
        ]);

        return $notification;
    }

    public function scheduleNotification($memberId, $type, $title, $message, $scheduledAt, $options = [])
    {
        $options['scheduled_at'] = $scheduledAt;

        return $this->createNotification($memberId, $type, $title, $message, $options);
    }

    public function sendBulkNotification($memberIds, $type, $title, $message, $options = [])
    {
        $notifications = [];

        foreach ($memberIds as $memberId) {
            try {
                $notification = $this->createNotification($memberId, $type, $title, $message, $options);
                $notifications[] = $notification;
            } catch (\Exception $e) {
                Log::error('Failed to create bulk notification', [
                    'member_id' => $memberId,
                    'type' => $type,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        return $notifications;
    }

    public function processScheduledNotifications()
    {
        $scheduledNotifications = MemberNotification::dueForSending()->get();
        $processedCount = 0;

        foreach ($scheduledNotifications as $notification) {
            try {
                $this->sendNotification($notification->id);
                $processedCount++;
            } catch (\Exception $e) {
                Log::error('Failed to process scheduled notification', [
                    'notification_id' => $notification->id,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        return $processedCount;
    }

    public function retryFailedNotifications()
    {
        $failedNotifications = MemberNotification::failed()
            ->where('delivery_attempts', '<', 3)
            ->where('last_delivery_attempt', '<', now()->subMinutes(30))
            ->get();

        $retriedCount = 0;

        foreach ($failedNotifications as $notification) {
            try {
                $notification->update(['status' => 'pending']);
                SendNotificationJob::dispatch($notification);
                $retriedCount++;
            } catch (\Exception $e) {
                Log::error('Failed to retry notification', [
                    'notification_id' => $notification->id,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        return $retriedCount;
    }

    public function getNotificationStats($filters = [])
    {
        $query = MemberNotification::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        if (isset($filters['type'])) {
            $query->where('type', $filters['type']);
        }

        if (isset($filters['member_id'])) {
            $query->where('member_id', $filters['member_id']);
        }

        $stats = [
            'total_notifications' => $query->count(),
            'pending_notifications' => $query->clone()->pending()->count(),
            'scheduled_notifications' => $query->clone()->scheduled()->count(),
            'sent_notifications' => $query->clone()->sent()->count(),
            'delivered_notifications' => $query->clone()->delivered()->count(),
            'read_notifications' => $query->clone()->read()->count(),
            'failed_notifications' => $query->clone()->failed()->count(),
            'unread_notifications' => $query->clone()->unread()->count(),
        ];

        return $stats;
    }

    public function getNotificationAnalytics($filters = [])
    {
        $query = MemberNotification::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        $analytics = [
            'delivery_rates' => $this->getDeliveryRates($query->clone()),
            'read_rates' => $this->getReadRates($query->clone()),
            'click_rates' => $this->getClickRates($query->clone()),
            'notification_types' => $this->getNotificationTypes($query->clone()),
            'delivery_channels' => $this->getDeliveryChannels($query->clone()),
            'time_analytics' => $this->getTimeAnalytics($query->clone()),
        ];

        return $analytics;
    }

    public function updateNotificationPreferences($memberId, $preferences)
    {
        $member = Member::findOrFail($memberId);

        $member->update([
            'notification_preferences' => $preferences,
        ]);

        Log::info('Notification preferences updated', [
            'member_id' => $member->id,
            'preferences' => $preferences,
        ]);

        return $member;
    }

    public function getMemberNotifications($memberId, $filters = [])
    {
        $query = MemberNotification::where('member_id', $memberId);

        // Apply filters
        if (isset($filters['type'])) {
            $query->where('type', $filters['type']);
        }

        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (isset($filters['unread_only']) && $filters['unread_only']) {
            $query->unread();
        }

        return $query->orderBy('created_at', 'desc')->paginate($filters['per_page'] ?? 15);
    }

    public function deleteNotification($notificationId)
    {
        $notification = MemberNotification::findOrFail($notificationId);

        // Only allow deletion of pending or failed notifications
        if (!in_array($notification->status, ['pending', 'failed'])) {
            throw new \Exception('Cannot delete sent notifications');
        }

        $notification->delete();

        Log::info('Notification deleted', [
            'notification_id' => $notificationId,
            'member_id' => $notification->member_id,
        ]);

        return true;
    }

    protected function sendToChannel($notification, $channel, $user)
    {
        switch ($channel) {
            case 'email':
                $this->sendEmailNotification($notification, $user);
                break;
            case 'sms':
                $this->sendSmsNotification($notification, $user);
                break;
            case 'push':
                $this->sendPushNotification($notification, $user);
                break;
            case 'in_app':
                $this->sendInAppNotification($notification, $user);
                break;
            case 'whatsapp':
                $this->sendWhatsAppNotification($notification, $user);
                break;
            default:
                throw new \Exception("Unsupported delivery channel: {$channel}");
        }
    }

    protected function sendEmailNotification($notification, $user)
    {
        // Implement email sending logic
        Log::info('Email notification sent', [
            'notification_id' => $notification->id,
            'user_email' => $user->email,
            'title' => $notification->title,
        ]);
    }

    protected function sendSmsNotification($notification, $user)
    {
        // Implement SMS sending logic
        Log::info('SMS notification sent', [
            'notification_id' => $notification->id,
            'user_phone' => $user->phone,
            'title' => $notification->title,
        ]);
    }

    protected function sendPushNotification($notification, $user)
    {
        // Implement push notification logic
        Log::info('Push notification sent', [
            'notification_id' => $notification->id,
            'user_id' => $user->id,
            'title' => $notification->title,
        ]);
    }

    protected function sendInAppNotification($notification, $user)
    {
        // Implement in-app notification logic
        Log::info('In-app notification sent', [
            'notification_id' => $notification->id,
            'user_id' => $user->id,
            'title' => $notification->title,
        ]);
    }

    protected function sendWhatsAppNotification($notification, $user)
    {
        // Implement WhatsApp notification logic
        Log::info('WhatsApp notification sent', [
            'notification_id' => $notification->id,
            'user_phone' => $user->phone,
            'title' => $notification->title,
        ]);
    }

    protected function getDeliveryRates($query)
    {
        $total = $query->count();
        $delivered = $query->delivered()->count();

        return [
            'total' => $total,
            'delivered' => $delivered,
            'delivery_rate' => $total > 0 ? round(($delivered / $total) * 100, 2) : 0,
        ];
    }

    protected function getReadRates($query)
    {
        $delivered = $query->delivered()->count();
        $read = $query->read()->count();

        return [
            'delivered' => $delivered,
            'read' => $read,
            'read_rate' => $delivered > 0 ? round(($read / $delivered) * 100, 2) : 0,
        ];
    }

    protected function getClickRates($query)
    {
        $delivered = $query->delivered()->count();
        $clicked = $query->where('status', 'clicked')->count();

        return [
            'delivered' => $delivered,
            'clicked' => $clicked,
            'click_rate' => $delivered > 0 ? round(($clicked / $delivered) * 100, 2) : 0,
        ];
    }

    protected function getNotificationTypes($query)
    {
        return $query->selectRaw('type, COUNT(*) as count')
            ->groupBy('type')
            ->orderBy('count', 'desc')
            ->get()
            ->map(function ($item) {
                return [
                    'type' => $item->type,
                    'count' => $item->count,
                    'percentage' => round(($item->count / $query->count()) * 100, 2),
                ];
            });
    }

    protected function getDeliveryChannels($query)
    {
        $channels = [];
        $notifications = $query->get();

        foreach ($notifications as $notification) {
            foreach ($notification->delivery_channels as $channel) {
                if (!isset($channels[$channel])) {
                    $channels[$channel] = 0;
                }
                $channels[$channel]++;
            }
        }

        return collect($channels)->map(function ($count, $channel) use ($notifications) {
            return [
                'channel' => $channel,
                'count' => $count,
                'percentage' => round(($count / $notifications->count()) * 100, 2),
            ];
        })->values();
    }

    protected function getTimeAnalytics($query)
    {
        $notifications = $query->get();

        return [
            'average_delivery_time' => $this->calculateAverageDeliveryTime($notifications),
            'average_read_time' => $this->calculateAverageReadTime($notifications),
            'peak_sending_hours' => $this->getPeakSendingHours($notifications),
            'peak_reading_hours' => $this->getPeakReadingHours($notifications),
        ];
    }

    protected function calculateAverageDeliveryTime($notifications)
    {
        $deliveredNotifications = $notifications->where('sent_at', '!=', null);

        if ($deliveredNotifications->isEmpty()) {
            return 0;
        }

        $totalSeconds = $deliveredNotifications->sum(function ($notification) {
            return $notification->created_at->diffInSeconds($notification->sent_at);
        });

        return round($totalSeconds / $deliveredNotifications->count());
    }

    protected function calculateAverageReadTime($notifications)
    {
        $readNotifications = $notifications->where('read_at', '!=', null);

        if ($readNotifications->isEmpty()) {
            return 0;
        }

        $totalSeconds = $readNotifications->sum(function ($notification) {
            return $notification->sent_at->diffInSeconds($notification->read_at);
        });

        return round($totalSeconds / $readNotifications->count());
    }

    protected function getPeakSendingHours($notifications)
    {
        $hourlyCounts = $notifications->where('sent_at', '!=', null)
            ->groupBy(function ($notification) {
                return $notification->sent_at->format('H');
            })
            ->map(function ($group) {
                return $group->count();
            });

        return $hourlyCounts->sortDesc()->take(5);
    }

    protected function getPeakReadingHours($notifications)
    {
        $hourlyCounts = $notifications->where('read_at', '!=', null)
            ->groupBy(function ($notification) {
                return $notification->read_at->format('H');
            })
            ->map(function ($group) {
                return $group->count();
            });

        return $hourlyCounts->sortDesc()->take(5);
    }
}
```

### Step 3: Create Notification Controller

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseController;
use App\Services\NotificationService;
use App\Models\MemberNotification;
use Illuminate\Http\Request;

class MemberNotificationController extends BaseController
{
    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    public function index(Request $request)
    {
        $query = MemberNotification::with(['member.user']);

        // Filter by type
        if ($request->type) {
            $query->where('type', $request->type);
        }

        // Filter by status
        if ($request->status) {
            $query->where('status', $request->status);
        }

        // Filter by priority
        if ($request->priority) {
            $query->where('priority', $request->priority);
        }

        // Filter by member
        if ($request->member_id) {
            $query->where('member_id', $request->member_id);
        }

        // Filter by date range
        if ($request->start_date && $request->end_date) {
            $query->whereBetween('created_at', [$request->start_date, $request->end_date]);
        }

        $notifications = $query->orderBy('created_at', 'desc')->paginate($request->per_page ?? 15);

        return $this->successResponse($notifications, 'Notifications retrieved successfully');
    }

    public function create(Request $request)
    {
        $request->validate([
            'member_id' => 'required|exists:members,id',
            'type' => 'required|string|max:50',
            'title' => 'required|string|max:255',
            'message' => 'required|string',
            'data' => 'nullable|array',
            'delivery_channels' => 'nullable|array',
            'scheduled_at' => 'nullable|date|after:now',
            'priority' => 'nullable|string|in:low,normal,high,urgent',
        ]);

        try {
            $options = $request->only(['data', 'delivery_channels', 'scheduled_at', 'priority']);
            $notification = $this->notificationService->createNotification(
                $request->member_id,
                $request->type,
                $request->title,
                $request->message,
                $options
            );

            return $this->successResponse($notification, 'Notification created successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function sendBulk(Request $request)
    {
        $request->validate([
            'member_ids' => 'required|array|min:1',
            'member_ids.*' => 'exists:members,id',
            'type' => 'required|string|max:50',
            'title' => 'required|string|max:255',
            'message' => 'required|string',
            'data' => 'nullable|array',
            'delivery_channels' => 'nullable|array',
            'scheduled_at' => 'nullable|date|after:now',
            'priority' => 'nullable|string|in:low,normal,high,urgent',
        ]);

        try {
            $options = $request->only(['data', 'delivery_channels', 'scheduled_at', 'priority']);
            $notifications = $this->notificationService->sendBulkNotification(
                $request->member_ids,
                $request->type,
                $request->title,
                $request->message,
                $options
            );

            return $this->successResponse($notifications, 'Bulk notifications created successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function send($notificationId)
    {
        try {
            $notification = $this->notificationService->sendNotification($notificationId);

            return $this->successResponse($notification, 'Notification sent successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function markAsRead($notificationId)
    {
        try {
            $notification = $this->notificationService->markAsRead($notificationId);

            return $this->successResponse($notification, 'Notification marked as read');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function markAsClicked($notificationId)
    {
        try {
            $notification = $this->notificationService->markAsClicked($notificationId);

            return $this->successResponse($notification, 'Notification marked as clicked');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function processScheduled()
    {
        try {
            $processedCount = $this->notificationService->processScheduledNotifications();

            return $this->successResponse([
                'processed_count' => $processedCount,
            ], 'Scheduled notifications processed successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function retryFailed()
    {
        try {
            $retriedCount = $this->notificationService->retryFailedNotifications();

            return $this->successResponse([
                'retried_count' => $retriedCount,
            ], 'Failed notifications retried successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getStats(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date', 'type', 'member_id']);
            $stats = $this->notificationService->getNotificationStats($filters);

            return $this->successResponse($stats, 'Notification statistics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getAnalytics(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date', 'type', 'member_id']);
            $analytics = $this->notificationService->getNotificationAnalytics($filters);

            return $this->successResponse($analytics, 'Notification analytics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function updatePreferences(Request $request, $memberId)
    {
        $request->validate([
            'preferences' => 'required|array',
        ]);

        try {
            $member = $this->notificationService->updateNotificationPreferences($memberId, $request->preferences);

            return $this->successResponse($member, 'Notification preferences updated successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getMyNotifications(Request $request)
    {
        try {
            $member = Member::where('user_id', auth()->id())->firstOrFail();
            $filters = $request->only(['type', 'status', 'unread_only', 'per_page']);
            $notifications = $this->notificationService->getMemberNotifications($member->id, $filters);

            return $this->successResponse($notifications, 'My notifications retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 404);
        }
    }

    public function markMyNotificationAsRead($notificationId)
    {
        try {
            $member = Member::where('user_id', auth()->id())->firstOrFail();
            $notification = MemberNotification::where('id', $notificationId)
                ->where('member_id', $member->id)
                ->firstOrFail();

            $notification = $this->notificationService->markAsRead($notification->id);

            return $this->successResponse($notification, 'Notification marked as read');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 404);
        }
    }

    public function markMyNotificationAsClicked($notificationId)
    {
        try {
            $member = Member::where('user_id', auth()->id())->firstOrFail();
            $notification = MemberNotification::where('id', $notificationId)
                ->where('member_id', $member->id)
                ->firstOrFail();

            $notification = $this->notificationService->markAsClicked($notification->id);

            return $this->successResponse($notification, 'Notification marked as clicked');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 404);
        }
    }

    public function delete($notificationId)
    {
        try {
            $this->notificationService->deleteNotification($notificationId);

            return $this->successResponse(null, 'Notification deleted successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }
}
```

### Step 4: Create Send Notification Job

```php
<?php

namespace App\Jobs;

use App\Models\MemberNotification;
use App\Services\NotificationService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class SendNotificationJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $tries = 3;
    public $timeout = 60;

    protected $notification;

    public function __construct(MemberNotification $notification)
    {
        $this->notification = $notification;
    }

    public function handle(NotificationService $notificationService)
    {
        try {
            $notificationService->sendNotification($this->notification->id);
        } catch (\Exception $e) {
            Log::error('Send notification job failed', [
                'notification_id' => $this->notification->id,
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }

    public function failed(\Throwable $exception)
    {
        Log::error('Send notification job permanently failed', [
            'notification_id' => $this->notification->id,
            'error' => $exception->getMessage(),
        ]);

        // Update notification status to failed
        $this->notification->update([
            'status' => 'failed',
            'error_message' => $exception->getMessage(),
        ]);
    }
}
```

## 📚 API Endpoints

### Member Notification Endpoints

```
GET    /api/v1/admin/notifications
POST   /api/v1/admin/notifications
POST   /api/v1/admin/notifications/bulk
POST   /api/v1/admin/notifications/{id}/send
POST   /api/v1/admin/notifications/{id}/read
POST   /api/v1/admin/notifications/{id}/clicked
POST   /api/v1/admin/notifications/process-scheduled
POST   /api/v1/admin/notifications/retry-failed
GET    /api/v1/admin/notifications/stats
GET    /api/v1/admin/notifications/analytics
PUT    /api/v1/admin/notifications/{memberId}/preferences
DELETE /api/v1/admin/notifications/{id}
GET    /api/v1/members/my-notifications
POST   /api/v1/members/my-notifications/{id}/read
POST   /api/v1/members/my-notifications/{id}/clicked
```

## 🧪 Testing

### NotificationTest.php

```php
<?php

use App\Models\Member;
use App\Models\MemberNotification;
use App\Services\NotificationService;

describe('Member Notifications', function () {

    beforeEach(function () {
        $this->notificationService = app(NotificationService::class);
    });

    it('can create notification', function () {
        $member = Member::factory()->create();

        $notification = $this->notificationService->createNotification(
            $member->id,
            'booking_confirmation',
            'Booking Confirmed',
            'Your booking has been confirmed.',
            ['data' => ['booking_id' => 1]]
        );

        expect($notification->member_id)->toBe($member->id);
        expect($notification->type)->toBe('booking_confirmation');
        expect($notification->title)->toBe('Booking Confirmed');
        expect($notification->status)->toBe('pending');
    });

    it('can send notification', function () {
        $member = Member::factory()->create();
        $notification = MemberNotification::factory()->create([
            'member_id' => $member->id,
            'status' => 'pending'
        ]);

        $sentNotification = $this->notificationService->sendNotification($notification->id);

        expect($sentNotification->status)->toBe('sent');
        expect($sentNotification->sent_at)->not->toBeNull();
    });

    it('can mark notification as read', function () {
        $notification = MemberNotification::factory()->create([
            'status' => 'sent'
        ]);

        $readNotification = $this->notificationService->markAsRead($notification->id);

        expect($readNotification->status)->toBe('read');
        expect($readNotification->read_at)->not->toBeNull();
    });

    it('can schedule notification', function () {
        $member = Member::factory()->create();
        $scheduledAt = now()->addHour();

        $notification = $this->notificationService->scheduleNotification(
            $member->id,
            'booking_reminder',
            'Booking Reminder',
            'Your booking is tomorrow.',
            $scheduledAt
        );

        expect($notification->status)->toBe('scheduled');
        expect($notification->scheduled_at->format('Y-m-d H:i:s'))->toBe($scheduledAt->format('Y-m-d H:i:s'));
    });

    it('can send bulk notifications', function () {
        $members = Member::factory()->count(3)->create();
        $memberIds = $members->pluck('id')->toArray();

        $notifications = $this->notificationService->sendBulkNotification(
            $memberIds,
            'general',
            'General Announcement',
            'This is a general announcement.'
        );

        expect($notifications)->toHaveCount(3);
        expect($notifications[0]->type)->toBe('general');
    });

    it('can process scheduled notifications', function () {
        MemberNotification::factory()->create([
            'status' => 'scheduled',
            'scheduled_at' => now()->subMinute()
        ]);

        $processedCount = $this->notificationService->processScheduledNotifications();

        expect($processedCount)->toBe(1);
    });

    it('can get notification statistics', function () {
        MemberNotification::factory()->count(5)->create();
        actingAsAdmin();

        $response = apiGet('/api/v1/admin/notifications/stats');

        assertApiSuccess($response, 'Notification statistics retrieved successfully');
        expect($response->json('data.total_notifications'))->toBe(5);
    });

    it('can get member notifications', function () {
        $member = Member::factory()->create();
        MemberNotification::factory()->count(3)->create(['member_id' => $member->id]);
        actingAs($member->user);

        $response = apiGet('/api/v1/members/my-notifications');

        assertApiSuccess($response, 'My notifications retrieved successfully');
        expect($response->json('data.data'))->toHaveCount(3);
    });

    it('can update notification preferences', function () {
        $member = Member::factory()->create();
        $preferences = [
            'booking_confirmation' => ['email', 'in_app'],
            'payment_reminder' => ['sms', 'email']
        ];

        $updatedMember = $this->notificationService->updateNotificationPreferences($member->id, $preferences);

        expect($updatedMember->notification_preferences)->toBe($preferences);
    });

    it('cannot delete sent notifications', function () {
        $notification = MemberNotification::factory()->create([
            'status' => 'sent'
        ]);

        expect(function () use ($notification) {
            $this->notificationService->deleteNotification($notification->id);
        })->toThrow(Exception::class, 'Cannot delete sent notifications');
    });
});
```

## ✅ Success Criteria

- [ ] Notification types berfungsi
- [ ] Delivery channels berjalan
- [ ] Notification preferences berfungsi
- [ ] Notification scheduling berjalan
- [ ] Notification analytics berfungsi
- [ ] Notification automation berjalan
- [ ] Testing coverage > 90%

## 📚 Documentation

- [Laravel Jobs](https://laravel.com/docs/11.x/queues)
- [Laravel Notifications](https://laravel.com/docs/11.x/notifications)
- [Laravel Events](https://laravel.com/docs/11.x/events)
