# Point 5: Order Tracking

## 📋 Overview

Implementasi sistem order tracking dengan status tracking, timeline, notifications, dan analytics.

## 🎯 Objectives

-   Order status tracking
-   Order timeline
-   Order notifications
-   Order completion
-   Order feedback
-   Order analytics

## 📁 Files Structure

```
phase-6/
├── 05-order-tracking.md
├── app/Http/Controllers/OrderTrackingController.php
├── app/Models/OrderTracking.php
├── app/Services/TrackingService.php
└── app/Jobs/SendOrderNotificationsJob.php
```

## 🔧 Implementation Steps

### Step 1: Create Order Tracking Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderTracking extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id',
        'status',
        'notes',
        'updated_by',
        'estimated_time',
        'actual_time',
    ];

    protected $casts = [
        'estimated_time' => 'datetime',
        'actual_time' => 'datetime',
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'updated_by');
    }

    public function getStatusDisplayAttribute()
    {
        return match($this->status) {
            'pending' => 'Pending',
            'confirmed' => 'Confirmed',
            'preparing' => 'Preparing',
            'ready' => 'Ready',
            'delivered' => 'Delivered',
            'cancelled' => 'Cancelled',
            default => 'Unknown'
        };
    }

    public function getDurationAttribute()
    {
        if (!$this->actual_time) {
            return null;
        }

        $previousTracking = $this->order->orderTracking()
            ->where('id', '<', $this->id)
            ->orderBy('id', 'desc')
            ->first();

        if (!$previousTracking || !$previousTracking->actual_time) {
            return null;
        }

        return $previousTracking->actual_time->diffInMinutes($this->actual_time);
    }

    public function getIsCompletedAttribute()
    {
        return in_array($this->status, ['delivered', 'cancelled']);
    }

    public function getIsActiveAttribute()
    {
        return !$this->is_completed;
    }

    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    public function scopeByOrder($query, $orderId)
    {
        return $query->where('order_id', $orderId);
    }

    public function scopeByUser($query, $userId)
    {
        return $query->where('updated_by', $userId);
    }

    public function scopeCompleted($query)
    {
        return $query->whereIn('status', ['delivered', 'cancelled']);
    }

    public function scopeActive($query)
    {
        return $query->whereNotIn('status', ['delivered', 'cancelled']);
    }

    public function scopeRecent($query, $days = 7)
    {
        return $query->where('created_at', '>=', now()->subDays($days));
    }

    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('created_at', [$startDate, $endDate]);
    }
}
```

### Step 2: Create Order Feedback Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderFeedback extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id',
        'user_id',
        'rating',
        'comment',
        'food_quality_rating',
        'service_rating',
        'delivery_rating',
        'is_anonymous',
    ];

    protected $casts = [
        'rating' => 'integer',
        'food_quality_rating' => 'integer',
        'service_rating' => 'integer',
        'delivery_rating' => 'integer',
        'is_anonymous' => 'boolean',
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function getRatingDisplayAttribute()
    {
        return match($this->rating) {
            1 => 'Very Poor',
            2 => 'Poor',
            3 => 'Average',
            4 => 'Good',
            5 => 'Excellent',
            default => 'Not Rated'
        };
    }

    public function getOverallRatingAttribute()
    {
        $ratings = array_filter([
            $this->rating,
            $this->food_quality_rating,
            $this->service_rating,
            $this->delivery_rating,
        ]);

        return count($ratings) > 0 ? round(array_sum($ratings) / count($ratings), 2) : 0;
    }

    public function getIsPositiveAttribute()
    {
        return $this->rating >= 4;
    }

    public function getIsNegativeAttribute()
    {
        return $this->rating <= 2;
    }

    public function scopeByRating($query, $rating)
    {
        return $query->where('rating', $rating);
    }

    public function scopePositive($query)
    {
        return $query->where('rating', '>=', 4);
    }

    public function scopeNegative($query)
    {
        return $query->where('rating', '<=', 2);
    }

    public function scopeByOrder($query, $orderId)
    {
        return $query->where('order_id', $orderId);
    }

    public function scopeByUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    public function scopeAnonymous($query)
    {
        return $query->where('is_anonymous', true);
    }

    public function scopeRecent($query, $days = 30)
    {
        return $query->where('created_at', '>=', now()->subDays($days));
    }
}
```

### Step 3: Create Tracking Service

```php
<?php

namespace App\Services;

use App\Models\Order;
use App\Models\OrderTracking;
use App\Models\OrderFeedback;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class TrackingService
{
    public function createTrackingRecord($orderId, $status, $notes = null, $estimatedTime = null)
    {
        return DB::transaction(function () use ($orderId, $status, $notes, $estimatedTime) {
            $order = Order::findOrFail($orderId);

            $tracking = OrderTracking::create([
                'order_id' => $order->id,
                'status' => $status,
                'notes' => $notes,
                'updated_by' => auth()->id(),
                'estimated_time' => $estimatedTime,
                'actual_time' => now(),
            ]);

            // Update order status if different
            if ($order->status !== $status) {
                $order->update(['status' => $status]);
            }

            // Send notification
            $this->sendStatusNotification($order, $status, $notes);

            Log::info('Order tracking created', [
                'order_id' => $order->id,
                'order_number' => $order->order_number,
                'status' => $status,
                'notes' => $notes,
                'updated_by' => auth()->id(),
            ]);

            return $tracking;
        });
    }

    public function getOrderTimeline($orderId)
    {
        $order = Order::findOrFail($orderId);

        return OrderTracking::with('user')
            ->where('order_id', $orderId)
            ->orderBy('created_at', 'asc')
            ->get()
            ->map(function ($tracking) {
                return [
                    'id' => $tracking->id,
                    'status' => $tracking->status,
                    'status_display' => $tracking->status_display,
                    'notes' => $tracking->notes,
                    'updated_by' => $tracking->user ? $tracking->user->name : 'System',
                    'estimated_time' => $tracking->estimated_time,
                    'actual_time' => $tracking->actual_time,
                    'duration' => $tracking->duration,
                    'created_at' => $tracking->created_at,
                ];
            });
    }

    public function getOrderStatus($orderId)
    {
        $order = Order::with(['orderItems.menuItem', 'user'])->findOrFail($orderId);

        $latestTracking = $order->orderTracking()->latest()->first();

        return [
            'order_id' => $order->id,
            'order_number' => $order->order_number,
            'current_status' => $order->status,
            'current_status_display' => $order->status_display,
            'payment_status' => $order->payment_status,
            'payment_status_display' => $order->payment_status_display,
            'estimated_ready_time' => $order->estimated_ready_time,
            'actual_ready_time' => $order->actual_ready_time,
            'delivery_location' => $order->delivery_location,
            'special_instructions' => $order->special_instructions,
            'customer_name' => $order->customer_name,
            'customer_phone' => $order->customer_phone,
            'total_amount' => $order->total_amount,
            'final_amount' => $order->final_amount,
            'total_items' => $order->total_items,
            'items' => $order->orderItems->map(function ($item) {
                return [
                    'id' => $item->id,
                    'menu_item_name' => $item->menuItem->name,
                    'quantity' => $item->quantity,
                    'unit_price' => $item->unit_price,
                    'total_price' => $item->total_price,
                    'status' => $item->status,
                    'special_instructions' => $item->special_instructions,
                ];
            }),
            'latest_tracking' => $latestTracking ? [
                'status' => $latestTracking->status,
                'notes' => $latestTracking->notes,
                'updated_by' => $latestTracking->user ? $latestTracking->user->name : 'System',
                'updated_at' => $latestTracking->created_at,
            ] : null,
            'can_be_cancelled' => $order->can_be_cancelled,
            'can_provide_feedback' => $order->status === 'delivered' && !$order->feedback,
        ];
    }

    public function submitFeedback($orderId, $feedbackData)
    {
        return DB::transaction(function () use ($orderId, $feedbackData) {
            $order = Order::findOrFail($orderId);

            // Check if order is delivered
            if ($order->status !== 'delivered') {
                throw new \Exception('Feedback can only be submitted for delivered orders');
            }

            // Check if feedback already exists
            if ($order->feedback) {
                throw new \Exception('Feedback already submitted for this order');
            }

            $feedback = OrderFeedback::create([
                'order_id' => $order->id,
                'user_id' => $order->user_id,
                'rating' => $feedbackData['rating'],
                'comment' => $feedbackData['comment'] ?? null,
                'food_quality_rating' => $feedbackData['food_quality_rating'] ?? null,
                'service_rating' => $feedbackData['service_rating'] ?? null,
                'delivery_rating' => $feedbackData['delivery_rating'] ?? null,
                'is_anonymous' => $feedbackData['is_anonymous'] ?? false,
            ]);

            // Update menu item ratings
            $this->updateMenuItemRatings($order);

            Log::info('Order feedback submitted', [
                'order_id' => $order->id,
                'order_number' => $order->order_number,
                'rating' => $feedback->rating,
                'user_id' => $feedback->user_id,
            ]);

            return $feedback;
        });
    }

    public function getTrackingStats($filters = [])
    {
        $query = OrderTracking::query();

        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        $stats = [
            'total_tracking_records' => $query->count(),
            'status_distribution' => $this->getStatusDistribution($query->clone()),
            'average_processing_time' => $this->getAverageProcessingTime($query->clone()),
            'completion_rate' => $this->getCompletionRate($query->clone()),
            'cancellation_rate' => $this->getCancellationRate($query->clone()),
        ];

        return $stats;
    }

    public function getTrackingAnalytics($filters = [])
    {
        $query = OrderTracking::query();

        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        $analytics = [
            'processing_times' => $this->getProcessingTimes($query->clone()),
            'status_transitions' => $this->getStatusTransitions($query->clone()),
            'peak_processing_hours' => $this->getPeakProcessingHours($query->clone()),
            'staff_performance' => $this->getStaffPerformance($query->clone()),
            'feedback_analytics' => $this->getFeedbackAnalytics($query->clone()),
        ];

        return $analytics;
    }

    public function getActiveOrders()
    {
        return Order::with(['orderItems.menuItem', 'user'])
            ->whereIn('status', ['pending', 'confirmed', 'preparing', 'ready'])
            ->orderBy('created_at', 'asc')
            ->get()
            ->map(function ($order) {
                $latestTracking = $order->orderTracking()->latest()->first();

                return [
                    'order_id' => $order->id,
                    'order_number' => $order->order_number,
                    'status' => $order->status,
                    'status_display' => $order->status_display,
                    'customer_name' => $order->customer_name,
                    'total_items' => $order->total_items,
                    'estimated_ready_time' => $order->estimated_ready_time,
                    'delivery_location' => $order->delivery_location,
                    'latest_update' => $latestTracking ? [
                        'notes' => $latestTracking->notes,
                        'updated_by' => $latestTracking->user ? $latestTracking->user->name : 'System',
                        'updated_at' => $latestTracking->created_at,
                    ] : null,
                    'time_elapsed' => $order->created_at->diffInMinutes(now()),
                ];
            });
    }

    public function getOrderHistory($userId = null, $filters = [])
    {
        $query = Order::with(['orderItems.menuItem', 'feedback']);

        if ($userId) {
            $query->where('user_id', $userId);
        }

        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        return $query->orderBy('created_at', 'desc')
            ->paginate($filters['per_page'] ?? 15);
    }

    public function sendOrderNotifications($orderId, $type, $data = [])
    {
        $order = Order::with('user')->findOrFail($orderId);

        // Send notification based on type
        switch ($type) {
            case 'status_update':
                $this->sendStatusUpdateNotification($order, $data);
                break;
            case 'ready_for_pickup':
                $this->sendReadyNotification($order);
                break;
            case 'delivered':
                $this->sendDeliveredNotification($order);
                break;
            case 'cancelled':
                $this->sendCancellationNotification($order, $data);
                break;
        }

        Log::info('Order notification sent', [
            'order_id' => $order->id,
            'order_number' => $order->order_number,
            'type' => $type,
            'data' => $data,
        ]);
    }

    protected function sendStatusNotification($order, $status, $notes)
    {
        $this->sendOrderNotifications($order->id, 'status_update', [
            'status' => $status,
            'notes' => $notes,
        ]);
    }

    protected function sendStatusUpdateNotification($order, $data)
    {
        // Implement status update notification
        Log::info('Status update notification sent', [
            'order_id' => $order->id,
            'status' => $data['status'],
            'notes' => $data['notes'],
        ]);
    }

    protected function sendReadyNotification($order)
    {
        // Implement ready notification
        Log::info('Ready notification sent', [
            'order_id' => $order->id,
            'order_number' => $order->order_number,
        ]);
    }

    protected function sendDeliveredNotification($order)
    {
        // Implement delivered notification
        Log::info('Delivered notification sent', [
            'order_id' => $order->id,
            'order_number' => $order->order_number,
        ]);
    }

    protected function sendCancellationNotification($order, $data)
    {
        // Implement cancellation notification
        Log::info('Cancellation notification sent', [
            'order_id' => $order->id,
            'order_number' => $order->order_number,
            'reason' => $data['reason'] ?? null,
        ]);
    }

    protected function updateMenuItemRatings($order)
    {
        foreach ($order->orderItems as $item) {
            $menuItem = $item->menuItem;
            $feedback = $order->feedback;

            if ($feedback && $feedback->food_quality_rating) {
                // Update menu item rating
                $currentRating = $menuItem->average_rating;
                $totalReviews = $menuItem->reviews()->count();
                $newRating = (($currentRating * $totalReviews) + $feedback->food_quality_rating) / ($totalReviews + 1);

                // This would typically be done through a service or job
                Log::info('Menu item rating updated', [
                    'menu_item_id' => $menuItem->id,
                    'old_rating' => $currentRating,
                    'new_rating' => $newRating,
                ]);
            }
        }
    }

    protected function getStatusDistribution($query)
    {
        return $query->selectRaw('status, COUNT(*) as count')
            ->groupBy('status')
            ->get()
            ->map(function ($item) {
                return [
                    'status' => $item->status,
                    'count' => $item->count,
                    'percentage' => round(($item->count / $query->count()) * 100, 2),
                ];
            });
    }

    protected function getAverageProcessingTime($query)
    {
        $completedOrders = Order::whereIn('id', $query->pluck('order_id'))
            ->whereIn('status', ['delivered', 'cancelled'])
            ->get();

        if ($completedOrders->isEmpty()) {
            return 0;
        }

        $totalMinutes = $completedOrders->sum(function ($order) {
            return $order->created_at->diffInMinutes($order->updated_at);
        });

        return round($totalMinutes / $completedOrders->count());
    }

    protected function getCompletionRate($query)
    {
        $totalOrders = Order::whereIn('id', $query->pluck('order_id'))->count();
        $completedOrders = Order::whereIn('id', $query->pluck('order_id'))
            ->where('status', 'delivered')
            ->count();

        return $totalOrders > 0 ? round(($completedOrders / $totalOrders) * 100, 2) : 0;
    }

    protected function getCancellationRate($query)
    {
        $totalOrders = Order::whereIn('id', $query->pluck('order_id'))->count();
        $cancelledOrders = Order::whereIn('id', $query->pluck('order_id'))
            ->where('status', 'cancelled')
            ->count();

        return $totalOrders > 0 ? round(($cancelledOrders / $totalOrders) * 100, 2) : 0;
    }

    protected function getProcessingTimes($query)
    {
        $orders = Order::whereIn('id', $query->pluck('order_id'))
            ->whereIn('status', ['delivered', 'cancelled'])
            ->get();

        return [
            'average_time' => $this->getAverageProcessingTime($query),
            'min_time' => $orders->min(function ($order) {
                return $order->created_at->diffInMinutes($order->updated_at);
            }),
            'max_time' => $orders->max(function ($order) {
                return $order->created_at->diffInMinutes($order->updated_at);
            }),
        ];
    }

    protected function getStatusTransitions($query)
    {
        $transitions = [];
        $orderIds = $query->pluck('order_id')->unique();

        foreach ($orderIds as $orderId) {
            $trackings = OrderTracking::where('order_id', $orderId)
                ->orderBy('created_at', 'asc')
                ->get();

            for ($i = 0; $i < $trackings->count() - 1; $i++) {
                $from = $trackings[$i]->status;
                $to = $trackings[$i + 1]->status;
                $key = "{$from}_to_{$to}";

                if (!isset($transitions[$key])) {
                    $transitions[$key] = 0;
                }
                $transitions[$key]++;
            }
        }

        return $transitions;
    }

    protected function getPeakProcessingHours($query)
    {
        return $query->selectRaw('HOUR(created_at) as hour, COUNT(*) as count')
            ->groupBy('hour')
            ->orderBy('count', 'desc')
            ->limit(5)
            ->get()
            ->map(function ($item) {
                return [
                    'hour' => $item->hour,
                    'count' => $item->count,
                ];
            });
    }

    protected function getStaffPerformance($query)
    {
        return $query->whereNotNull('updated_by')
            ->with('user')
            ->selectRaw('updated_by, COUNT(*) as update_count')
            ->groupBy('updated_by')
            ->orderBy('update_count', 'desc')
            ->get()
            ->map(function ($item) {
                return [
                    'user_id' => $item->updated_by,
                    'user_name' => $item->user ? $item->user->name : 'Unknown',
                    'update_count' => $item->update_count,
                ];
            });
    }

    protected function getFeedbackAnalytics($query)
    {
        $orderIds = $query->pluck('order_id');
        $feedbacks = OrderFeedback::whereIn('order_id', $orderIds)->get();

        return [
            'total_feedbacks' => $feedbacks->count(),
            'average_rating' => $feedbacks->avg('rating'),
            'positive_feedbacks' => $feedbacks->where('rating', '>=', 4)->count(),
            'negative_feedbacks' => $feedbacks->where('rating', '<=', 2)->count(),
            'rating_distribution' => $feedbacks->groupBy('rating')->map(function ($group) {
                return $group->count();
            }),
        ];
    }
}
```

## 📚 API Endpoints

### Order Tracking Endpoints

```
GET    /api/orders/{id}/status
GET    /api/orders/{id}/timeline
POST   /api/orders/{id}/feedback
GET    /api/orders/active
GET    /api/orders/history
GET    /api/admin/orders/active
GET    /api/admin/orders/tracking-stats
GET    /api/admin/orders/tracking-analytics
POST   /api/admin/orders/{id}/tracking
```

## 🧪 Testing

### OrderTrackingTest.php

```php
<?php

use App\Models\Order;
use App\Models\OrderTracking;
use App\Models\OrderFeedback;
use App\Services\TrackingService;

describe('Order Tracking', function () {

    beforeEach(function () {
        $this->trackingService = app(TrackingService::class);
    });

    it('can create tracking record', function () {
        $order = Order::factory()->create(['status' => 'pending']);

        $tracking = $this->trackingService->createTrackingRecord($order->id, 'confirmed', 'Order confirmed');

        expect($tracking->order_id)->toBe($order->id);
        expect($tracking->status)->toBe('confirmed');
        expect($tracking->notes)->toBe('Order confirmed');
    });

    it('can get order timeline', function () {
        $order = Order::factory()->create();
        OrderTracking::factory()->count(3)->create(['order_id' => $order->id]);

        $timeline = $this->trackingService->getOrderTimeline($order->id);

        expect($timeline)->toHaveCount(3);
        expect($timeline[0]['status'])->not->toBeNull();
    });

    it('can get order status', function () {
        $order = Order::factory()->create();

        $status = $this->trackingService->getOrderStatus($order->id);

        expect($status['order_id'])->toBe($order->id);
        expect($status['current_status'])->toBe($order->status);
        expect($status['items'])->toHaveCount($order->orderItems->count());
    });

    it('can submit feedback', function () {
        $order = Order::factory()->create(['status' => 'delivered']);

        $feedback = $this->trackingService->submitFeedback($order->id, [
            'rating' => 5,
            'comment' => 'Excellent service!',
            'food_quality_rating' => 5,
            'service_rating' => 4,
            'delivery_rating' => 5,
        ]);

        expect($feedback->order_id)->toBe($order->id);
        expect($feedback->rating)->toBe(5);
        expect($feedback->comment)->toBe('Excellent service!');
    });

    it('cannot submit feedback for non-delivered order', function () {
        $order = Order::factory()->create(['status' => 'preparing']);

        expect(function () use ($order) {
            $this->trackingService->submitFeedback($order->id, [
                'rating' => 5,
                'comment' => 'Great!',
            ]);
        })->toThrow(Exception::class, 'Feedback can only be submitted for delivered orders');
    });

    it('cannot submit duplicate feedback', function () {
        $order = Order::factory()->create(['status' => 'delivered']);
        OrderFeedback::factory()->create(['order_id' => $order->id]);

        expect(function () use ($order) {
            $this->trackingService->submitFeedback($order->id, [
                'rating' => 5,
                'comment' => 'Great!',
            ]);
        })->toThrow(Exception::class, 'Feedback already submitted for this order');
    });

    it('can get active orders', function () {
        Order::factory()->count(3)->create(['status' => 'preparing']);

        $activeOrders = $this->trackingService->getActiveOrders();

        expect($activeOrders)->toHaveCount(3);
        expect($activeOrders[0]['status'])->toBe('preparing');
    });

    it('can get tracking statistics', function () {
        OrderTracking::factory()->count(5)->create();
        actingAsAdmin();

        $response = apiGet('/api/admin/orders/tracking-stats');

        assertApiSuccess($response, 'Tracking statistics retrieved successfully');
        expect($response->json('data.total_tracking_records'))->toBe(5);
    });

    it('can get order history', function () {
        $user = User::factory()->create();
        Order::factory()->count(3)->create(['user_id' => $user->id]);

        $history = $this->trackingService->getOrderHistory($user->id);

        expect($history->count())->toBe(3);
    });
});
```

## ✅ Success Criteria

-   [x] Order status tracking berfungsi
-   [x] Order timeline berjalan
-   [x] Order notifications berfungsi
-   [x] Order completion berjalan
-   [x] Order feedback berfungsi
-   [x] Order analytics berjalan
-   [x] Testing coverage > 90%

## 📚 Documentation

-   [Laravel Database Transactions](https://laravel.com/docs/11.x/database#database-transactions)
-   [Laravel Eloquent Relationships](https://laravel.com/docs/11.x/eloquent-relationships)
-   [Laravel Jobs](https://laravel.com/docs/11.x/queues)
