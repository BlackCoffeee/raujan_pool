# Branch Analytics - Phase 7.6

## 📋 Overview

Implementasi sistem analitik per cabang untuk Raujan Pool Syariah. Fitur ini memungkinkan admin dan manager cabang untuk melihat performa dan statistik cabang mereka.

## 🎯 Objectives

- **Branch Performance Analytics**: Analitik performa cabang
- **Cross-branch Comparison**: Perbandingan antar cabang
- **Revenue Analytics**: Analitik pendapatan per cabang
- **Customer Analytics**: Analitik pelanggan per cabang
- **Operational Analytics**: Analitik operasional per cabang

## 🏗️ Database Schema

### 6.1 Branch Analytics Table

```sql
CREATE TABLE branch_analytics (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    branch_id BIGINT UNSIGNED NOT NULL,
    date DATE NOT NULL,
    total_bookings INT NOT NULL DEFAULT 0,
    total_revenue DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total_orders INT NOT NULL DEFAULT 0,
    total_customers INT NOT NULL DEFAULT 0,
    average_booking_value DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    occupancy_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    customer_satisfaction DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,

    FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE,

    UNIQUE KEY unique_branch_date (branch_id, date),
    INDEX idx_branch_analytics_branch (branch_id),
    INDEX idx_branch_analytics_date (date)
);
```

### 6.2 Branch Analytics Summary Table

```sql
CREATE TABLE branch_analytics_summary (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    branch_id BIGINT UNSIGNED NOT NULL,
    period_type ENUM('daily', 'weekly', 'monthly', 'yearly') NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    total_bookings INT NOT NULL DEFAULT 0,
    total_revenue DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total_orders INT NOT NULL DEFAULT 0,
    total_customers INT NOT NULL DEFAULT 0,
    average_booking_value DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    average_occupancy_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    average_customer_satisfaction DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    growth_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,

    FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE,

    UNIQUE KEY unique_branch_period (branch_id, period_type, period_start),
    INDEX idx_branch_analytics_summary_branch (branch_id),
    INDEX idx_branch_analytics_summary_period (period_type, period_start)
);
```

## 🔧 Implementation

### 6.1 Service

```php
<?php
// app/Services/BranchAnalyticsService.php

namespace App\Services;

use App\Models\Branch;
use App\Models\BranchAnalytics;
use App\Models\BranchAnalyticsSummary;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;

class BranchAnalyticsService
{
    public function generateDailyAnalytics(Branch $branch, string $date): BranchAnalytics
    {
        $bookings = $branch->bookings()->where('date', $date)->get();
        $orders = $branch->orders()->whereDate('created_at', $date)->get();

        $totalBookings = $bookings->count();
        $totalRevenue = $bookings->where('status', 'confirmed')->sum('total_amount') +
                       $orders->where('status', 'completed')->sum('total_amount');
        $totalOrders = $orders->count();
        $totalCustomers = $bookings->pluck('user_id')->unique()->count();

        $averageBookingValue = $totalBookings > 0 ? $totalRevenue / $totalBookings : 0;

        // Calculate occupancy rate
        $totalCapacity = $branch->pools()->sum('capacity');
        $occupiedSlots = $bookings->where('status', 'confirmed')->count();
        $occupancyRate = $totalCapacity > 0 ? ($occupiedSlots / $totalCapacity) * 100 : 0;

        // Calculate customer satisfaction (from ratings)
        $customerSatisfaction = $this->calculateCustomerSatisfaction($branch, $date);

        return BranchAnalytics::updateOrCreate(
            [
                'branch_id' => $branch->id,
                'date' => $date
            ],
            [
                'total_bookings' => $totalBookings,
                'total_revenue' => $totalRevenue,
                'total_orders' => $totalOrders,
                'total_customers' => $totalCustomers,
                'average_booking_value' => $averageBookingValue,
                'occupancy_rate' => $occupancyRate,
                'customer_satisfaction' => $customerSatisfaction
            ]
        );
    }

    public function generatePeriodAnalytics(Branch $branch, string $startDate, string $endDate, string $periodType): BranchAnalyticsSummary
    {
        $analytics = $branch->analytics()
            ->whereBetween('date', [$startDate, $endDate])
            ->get();

        $totalBookings = $analytics->sum('total_bookings');
        $totalRevenue = $analytics->sum('total_revenue');
        $totalOrders = $analytics->sum('total_orders');
        $totalCustomers = $analytics->sum('total_customers');

        $averageBookingValue = $totalBookings > 0 ? $totalRevenue / $totalBookings : 0;
        $averageOccupancyRate = $analytics->avg('occupancy_rate') ?? 0;
        $averageCustomerSatisfaction = $analytics->avg('customer_satisfaction') ?? 0;

        // Calculate growth rate
        $previousPeriod = $this->getPreviousPeriodAnalytics($branch, $startDate, $endDate, $periodType);
        $growthRate = $this->calculateGrowthRate($totalRevenue, $previousPeriod['total_revenue'] ?? 0);

        return BranchAnalyticsSummary::updateOrCreate(
            [
                'branch_id' => $branch->id,
                'period_type' => $periodType,
                'period_start' => $startDate
            ],
            [
                'period_end' => $endDate,
                'total_bookings' => $totalBookings,
                'total_revenue' => $totalRevenue,
                'total_orders' => $totalOrders,
                'total_customers' => $totalCustomers,
                'average_booking_value' => $averageBookingValue,
                'average_occupancy_rate' => $averageOccupancyRate,
                'average_customer_satisfaction' => $averageCustomerSatisfaction,
                'growth_rate' => $growthRate
            ]
        );
    }

    public function getBranchAnalytics(Branch $branch, string $startDate, string $endDate): Collection
    {
        return $branch->analytics()
            ->whereBetween('date', [$startDate, $endDate])
            ->orderBy('date')
            ->get();
    }

    public function getBranchAnalyticsSummary(Branch $branch, string $periodType, int $limit = 12): Collection
    {
        return $branch->analyticsSummary()
            ->where('period_type', $periodType)
            ->orderBy('period_start', 'desc')
            ->limit($limit)
            ->get();
    }

    public function getCrossBranchComparison(string $startDate, string $endDate, string $periodType): Collection
    {
        return BranchAnalyticsSummary::with('branch')
            ->where('period_type', $periodType)
            ->where('period_start', '>=', $startDate)
            ->where('period_end', '<=', $endDate)
            ->orderBy('total_revenue', 'desc')
            ->get();
    }

    public function getBranchRanking(string $startDate, string $endDate, string $metric = 'total_revenue'): Collection
    {
        $analytics = BranchAnalyticsSummary::with('branch')
            ->where('period_type', 'monthly')
            ->where('period_start', '>=', $startDate)
            ->where('period_end', '<=', $endDate)
            ->orderBy($metric, 'desc')
            ->get();

        return $analytics->map(function ($item, $index) {
            $item->rank = $index + 1;
            return $item;
        });
    }

    public function getBranchTrends(Branch $branch, string $startDate, string $endDate): array
    {
        $analytics = $this->getBranchAnalytics($branch, $startDate, $endDate);

        return [
            'revenue_trend' => $this->calculateTrend($analytics->pluck('total_revenue')->toArray()),
            'booking_trend' => $this->calculateTrend($analytics->pluck('total_bookings')->toArray()),
            'occupancy_trend' => $this->calculateTrend($analytics->pluck('occupancy_rate')->toArray()),
            'satisfaction_trend' => $this->calculateTrend($analytics->pluck('customer_satisfaction')->toArray())
        ];
    }

    public function getBranchInsights(Branch $branch, string $startDate, string $endDate): array
    {
        $analytics = $this->getBranchAnalytics($branch, $startDate, $endDate);
        $summary = $this->generatePeriodAnalytics($branch, $startDate, $endDate, 'monthly');

        $insights = [];

        // Revenue insights
        if ($summary->growth_rate > 10) {
            $insights[] = "Revenue growth is strong at {$summary->growth_rate}%";
        } elseif ($summary->growth_rate < -10) {
            $insights[] = "Revenue decline needs attention at {$summary->growth_rate}%";
        }

        // Occupancy insights
        if ($summary->average_occupancy_rate > 80) {
            $insights[] = "High occupancy rate indicates good demand";
        } elseif ($summary->average_occupancy_rate < 50) {
            $insights[] = "Low occupancy rate suggests need for marketing";
        }

        // Customer satisfaction insights
        if ($summary->average_customer_satisfaction > 4.5) {
            $insights[] = "Excellent customer satisfaction";
        } elseif ($summary->average_customer_satisfaction < 3.5) {
            $insights[] = "Customer satisfaction needs improvement";
        }

        return $insights;
    }

    private function calculateCustomerSatisfaction(Branch $branch, string $date): float
    {
        // This would typically come from customer ratings/reviews
        // For now, return a random value between 3.5 and 5.0
        return rand(350, 500) / 100;
    }

    private function getPreviousPeriodAnalytics(Branch $branch, string $startDate, string $endDate, string $periodType): array
    {
        $start = \Carbon\Carbon::parse($startDate);
        $end = \Carbon\Carbon::parse($endDate);

        switch ($periodType) {
            case 'daily':
                $prevStart = $start->subDay();
                $prevEnd = $end->subDay();
                break;
            case 'weekly':
                $prevStart = $start->subWeek();
                $prevEnd = $end->subWeek();
                break;
            case 'monthly':
                $prevStart = $start->subMonth();
                $prevEnd = $end->subMonth();
                break;
            case 'yearly':
                $prevStart = $start->subYear();
                $prevEnd = $end->subYear();
                break;
            default:
                return ['total_revenue' => 0];
        }

        $analytics = $branch->analytics()
            ->whereBetween('date', [$prevStart->format('Y-m-d'), $prevEnd->format('Y-m-d')])
            ->get();

        return [
            'total_revenue' => $analytics->sum('total_revenue'),
            'total_bookings' => $analytics->sum('total_bookings')
        ];
    }

    private function calculateGrowthRate(float $current, float $previous): float
    {
        if ($previous == 0) {
            return $current > 0 ? 100 : 0;
        }

        return (($current - $previous) / $previous) * 100;
    }

    private function calculateTrend(array $values): string
    {
        if (count($values) < 2) {
            return 'stable';
        }

        $first = $values[0];
        $last = end($values);

        if ($last > $first * 1.1) {
            return 'increasing';
        } elseif ($last < $first * 0.9) {
            return 'decreasing';
        } else {
            return 'stable';
        }
    }
}
```

### 6.2 Controller

```php
<?php
// app/Http/Controllers/Api/V1/BranchAnalyticsController.php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\BranchAnalyticsResource;
use App\Http\Resources\BranchAnalyticsSummaryResource;
use App\Models\Branch;
use App\Services\BranchAnalyticsService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BranchAnalyticsController extends Controller
{
    public function __construct(
        private BranchAnalyticsService $branchAnalyticsService
    ) {}

    public function getAnalytics(Branch $branch, Request $request): JsonResponse
    {
        $request->validate([
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date'
        ]);

        $analytics = $this->branchAnalyticsService->getBranchAnalytics(
            $branch,
            $request->start_date,
            $request->end_date
        );

        return response()->json([
            'success' => true,
            'message' => 'Branch analytics retrieved successfully',
            'data' => BranchAnalyticsResource::collection($analytics)
        ]);
    }

    public function getAnalyticsSummary(Branch $branch, Request $request): JsonResponse
    {
        $request->validate([
            'period_type' => 'required|in:daily,weekly,monthly,yearly',
            'limit' => 'integer|min:1|max:24'
        ]);

        $summary = $this->branchAnalyticsService->getBranchAnalyticsSummary(
            $branch,
            $request->period_type,
            $request->get('limit', 12)
        );

        return response()->json([
            'success' => true,
            'message' => 'Branch analytics summary retrieved successfully',
            'data' => BranchAnalyticsSummaryResource::collection($summary)
        ]);
    }

    public function getCrossBranchComparison(Request $request): JsonResponse
    {
        $request->validate([
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'period_type' => 'required|in:daily,weekly,monthly,yearly'
        ]);

        $comparison = $this->branchAnalyticsService->getCrossBranchComparison(
            $request->start_date,
            $request->end_date,
            $request->period_type
        );

        return response()->json([
            'success' => true,
            'message' => 'Cross-branch comparison retrieved successfully',
            'data' => BranchAnalyticsSummaryResource::collection($comparison)
        ]);
    }

    public function getBranchRanking(Request $request): JsonResponse
    {
        $request->validate([
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'metric' => 'in:total_revenue,total_bookings,total_orders,average_occupancy_rate,average_customer_satisfaction'
        ]);

        $ranking = $this->branchAnalyticsService->getBranchRanking(
            $request->start_date,
            $request->end_date,
            $request->get('metric', 'total_revenue')
        );

        return response()->json([
            'success' => true,
            'message' => 'Branch ranking retrieved successfully',
            'data' => BranchAnalyticsSummaryResource::collection($ranking)
        ]);
    }

    public function getBranchTrends(Branch $branch, Request $request): JsonResponse
    {
        $request->validate([
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date'
        ]);

        $trends = $this->branchAnalyticsService->getBranchTrends(
            $branch,
            $request->start_date,
            $request->end_date
        );

        return response()->json([
            'success' => true,
            'message' => 'Branch trends retrieved successfully',
            'data' => $trends
        ]);
    }

    public function getBranchInsights(Branch $branch, Request $request): JsonResponse
    {
        $request->validate([
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date'
        ]);

        $insights = $this->branchAnalyticsService->getBranchInsights(
            $branch,
            $request->start_date,
            $request->end_date
        );

        return response()->json([
            'success' => true,
            'message' => 'Branch insights retrieved successfully',
            'data' => $insights
        ]);
    }

    public function generateAnalytics(Branch $branch, Request $request): JsonResponse
    {
        $request->validate([
            'date' => 'required|date',
            'period_type' => 'sometimes|in:daily,weekly,monthly,yearly'
        ]);

        $analytics = $this->branchAnalyticsService->generateDailyAnalytics($branch, $request->date);

        if ($request->has('period_type')) {
            $startDate = $request->date;
            $endDate = $request->date;

            // Adjust dates based on period type
            switch ($request->period_type) {
                case 'weekly':
                    $startDate = \Carbon\Carbon::parse($request->date)->startOfWeek()->format('Y-m-d');
                    $endDate = \Carbon\Carbon::parse($request->date)->endOfWeek()->format('Y-m-d');
                    break;
                case 'monthly':
                    $startDate = \Carbon\Carbon::parse($request->date)->startOfMonth()->format('Y-m-d');
                    $endDate = \Carbon\Carbon::parse($request->date)->endOfMonth()->format('Y-m-d');
                    break;
                case 'yearly':
                    $startDate = \Carbon\Carbon::parse($request->date)->startOfYear()->format('Y-m-d');
                    $endDate = \Carbon\Carbon::parse($request->date)->endOfYear()->format('Y-m-d');
                    break;
            }

            $this->branchAnalyticsService->generatePeriodAnalytics(
                $branch,
                $startDate,
                $endDate,
                $request->period_type
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Analytics generated successfully',
            'data' => new BranchAnalyticsResource($analytics)
        ]);
    }
}
```

## 🧪 Testing

### 6.1 Unit Tests

```php
<?php
// tests/Unit/Services/BranchAnalyticsServiceTest.php

namespace Tests\Unit\Services;

use App\Models\Branch;
use App\Models\BranchAnalytics;
use App\Services\BranchAnalyticsService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BranchAnalyticsServiceTest extends TestCase
{
    use RefreshDatabase;

    private BranchAnalyticsService $branchAnalyticsService;

    protected function setUp(): void
    {
        parent::setUp();
        $this->branchAnalyticsService = app(BranchAnalyticsService::class);
    }

    public function test_can_generate_daily_analytics(): void
    {
        $branch = Branch::factory()->create();
        $date = now()->format('Y-m-d');

        $analytics = $this->branchAnalyticsService->generateDailyAnalytics($branch, $date);

        $this->assertInstanceOf(BranchAnalytics::class, $analytics);
        $this->assertEquals($branch->id, $analytics->branch_id);
        $this->assertEquals($date, $analytics->date);
        $this->assertGreaterThanOrEqual(0, $analytics->total_bookings);
        $this->assertGreaterThanOrEqual(0, $analytics->total_revenue);
    }

    public function test_can_get_branch_analytics(): void
    {
        $branch = Branch::factory()->create();
        BranchAnalytics::factory()->count(5)->create(['branch_id' => $branch->id]);

        $analytics = $this->branchAnalyticsService->getBranchAnalytics(
            $branch,
            now()->subDays(7)->format('Y-m-d'),
            now()->format('Y-m-d')
        );

        $this->assertCount(5, $analytics);
        $this->assertTrue($analytics->every(fn($item) => $item->branch_id === $branch->id));
    }

    public function test_can_get_cross_branch_comparison(): void
    {
        $branch1 = Branch::factory()->create();
        $branch2 = Branch::factory()->create();

        $comparison = $this->branchAnalyticsService->getCrossBranchComparison(
            now()->subMonth()->format('Y-m-d'),
            now()->format('Y-m-d'),
            'monthly'
        );

        $this->assertInstanceOf(\Illuminate\Database\Eloquent\Collection::class, $comparison);
    }

    public function test_can_get_branch_insights(): void
    {
        $branch = Branch::factory()->create();

        $insights = $this->branchAnalyticsService->getBranchInsights(
            $branch,
            now()->subMonth()->format('Y-m-d'),
            now()->format('Y-m-d')
        );

        $this->assertIsArray($insights);
    }
}
```

## 📊 API Endpoints

### 6.1 Branch Analytics

```http
GET /api/v1/branches/{branch_id}/analytics
GET /api/v1/branches/{branch_id}/analytics/summary
GET /api/v1/branches/{branch_id}/analytics/trends
GET /api/v1/branches/{branch_id}/analytics/insights
POST /api/v1/branches/{branch_id}/analytics/generate
```

### 6.2 Cross-branch Analytics

```http
GET /api/v1/analytics/cross-branch-comparison
GET /api/v1/analytics/branch-ranking
```

## 🎯 Success Criteria

- [ ] Branch performance analytics working
- [ ] Cross-branch comparison working
- [ ] Revenue analytics working
- [ ] Customer analytics working
- [ ] Operational analytics working
- [ ] All tests passing
- [ ] API documentation complete
- [ ] Performance optimized
- [ ] Security implemented
- [ ] Error handling complete

---

**Versi**: 1.0  
**Tanggal**: 4 September 2025  
**Status**: Planning  
**Dependencies**: Phase 7.1-7.5 Complete  
**Key Features**:

- 📊 **Branch Performance Analytics** dengan metrik lengkap
- 🔄 **Cross-branch Comparison** untuk perbandingan performa
- 💰 **Revenue Analytics** dengan tracking pendapatan
- 👥 **Customer Analytics** dengan insights pelanggan
- 🏃‍♂️ **Operational Analytics** dengan metrik operasional
- 🧪 **Comprehensive Testing** dengan unit dan feature tests
- 📊 **API Documentation** lengkap dengan examples
- 🔒 **Security & Validation** untuk semua operasi
