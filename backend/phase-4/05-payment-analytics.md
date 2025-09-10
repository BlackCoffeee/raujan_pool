# Point 5: Payment Analytics

## 📋 Overview

Implementasi sistem analitik pembayaran dengan payment statistics, revenue tracking, dan payment performance metrics.

## 🎯 Objectives

-   Payment statistics
-   Revenue tracking
-   Payment method analytics
-   Payment performance metrics
-   Payment trends
-   Payment reports

## 📁 Files Structure

```
phase-4/
├── 05-payment-analytics.md
├── app/Http/Controllers/PaymentAnalyticsController.php
├── app/Services/AnalyticsService.php
└── app/Repositories/PaymentRepository.php
```

## 🔧 Implementation Steps

### Step 1: Create Payment Repository

```php
<?php

namespace App\Repositories;

use App\Models\Payment;
use App\Models\Refund;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class PaymentRepository
{
    public function getPaymentStats($filters = [])
    {
        $query = Payment::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        if (isset($filters['user_id'])) {
            $query->where('user_id', $filters['user_id']);
        }

        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (isset($filters['payment_method'])) {
            $query->where('payment_method', $filters['payment_method']);
        }

        return [
            'total_payments' => $query->count(),
            'total_amount' => $query->sum('amount'),
            'average_amount' => $query->avg('amount'),
            'pending_payments' => $query->clone()->where('status', 'pending')->count(),
            'verified_payments' => $query->clone()->where('status', 'verified')->count(),
            'rejected_payments' => $query->clone()->where('status', 'rejected')->count(),
            'expired_payments' => $query->clone()->where('status', 'expired')->count(),
            'refunded_payments' => $query->clone()->where('status', 'refunded')->count(),
        ];
    }

    public function getRevenueStats($filters = [])
    {
        $query = Payment::where('status', 'verified');

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('verified_at', [$filters['start_date'], $filters['end_date']]);
        }

        $revenue = $query->sum('amount');
        $refunded = Refund::where('status', 'processed')
            ->when(isset($filters['start_date']) && isset($filters['end_date']), function ($q) use ($filters) {
                return $q->whereBetween('processed_at', [$filters['start_date'], $filters['end_date']]);
            })
            ->sum('amount');

        return [
            'gross_revenue' => $revenue,
            'refunded_amount' => $refunded,
            'net_revenue' => $revenue - $refunded,
            'refund_rate' => $revenue > 0 ? round(($refunded / $revenue) * 100, 2) : 0,
        ];
    }

    public function getPaymentMethodStats($filters = [])
    {
        $query = Payment::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        return $query->selectRaw('payment_method, COUNT(*) as count, SUM(amount) as total, AVG(amount) as average')
            ->groupBy('payment_method')
            ->get();
    }

    public function getPaymentTrends($days = 30)
    {
        $startDate = now()->subDays($days);
        $endDate = now();

        $trends = [];
        $currentDate = $startDate->copy();

        while ($currentDate->lte($endDate)) {
            $date = $currentDate->format('Y-m-d');

            $dayStats = [
                'date' => $date,
                'total_payments' => Payment::whereDate('created_at', $date)->count(),
                'verified_payments' => Payment::whereDate('verified_at', $date)->where('status', 'verified')->count(),
                'total_amount' => Payment::whereDate('created_at', $date)->sum('amount'),
                'verified_amount' => Payment::whereDate('verified_at', $date)->where('status', 'verified')->sum('amount'),
            ];

            $trends[] = $dayStats;
            $currentDate->addDay();
        }

        return $trends;
    }

    public function getPaymentPerformanceMetrics($filters = [])
    {
        $query = Payment::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        $totalPayments = $query->count();
        $verifiedPayments = $query->clone()->where('status', 'verified')->count();
        $rejectedPayments = $query->clone()->where('status', 'rejected')->count();
        $expiredPayments = $query->clone()->where('status', 'expired')->count();

        return [
            'verification_rate' => $totalPayments > 0 ? round(($verifiedPayments / $totalPayments) * 100, 2) : 0,
            'rejection_rate' => $totalPayments > 0 ? round(($rejectedPayments / $totalPayments) * 100, 2) : 0,
            'expiry_rate' => $totalPayments > 0 ? round(($expiredPayments / $totalPayments) * 100, 2) : 0,
            'average_verification_time' => $this->getAverageVerificationTime($query->clone()),
            'average_payment_amount' => $query->clone()->avg('amount'),
        ];
    }

    public function getPaymentByHour($filters = [])
    {
        $query = Payment::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        return $query->selectRaw('HOUR(created_at) as hour, COUNT(*) as count, SUM(amount) as total')
            ->groupBy('hour')
            ->orderBy('hour')
            ->get();
    }

    public function getPaymentByDayOfWeek($filters = [])
    {
        $query = Payment::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        return $query->selectRaw('DAYOFWEEK(created_at) as day_of_week, COUNT(*) as count, SUM(amount) as total')
            ->groupBy('day_of_week')
            ->orderBy('day_of_week')
            ->get();
    }

    public function getTopUsersByPayment($limit = 10, $filters = [])
    {
        $query = Payment::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        return $query->selectRaw('user_id, COUNT(*) as payment_count, SUM(amount) as total_amount')
            ->groupBy('user_id')
            ->with('user')
            ->orderBy('total_amount', 'desc')
            ->limit($limit)
            ->get();
    }

    public function getPaymentStatusDistribution($filters = [])
    {
        $query = Payment::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        return $query->selectRaw('status, COUNT(*) as count, SUM(amount) as total')
            ->groupBy('status')
            ->get();
    }

    protected function getAverageVerificationTime($query)
    {
        $payments = $query->whereNotNull('verified_at')->get();

        if ($payments->isEmpty()) {
            return 0;
        }

        $totalTime = $payments->sum(function ($payment) {
            return $payment->created_at->diffInMinutes($payment->verified_at);
        });

        return round($totalTime / $payments->count(), 2);
    }
}
```

### Step 2: Create Analytics Service

```php
<?php

namespace App\Services;

use App\Repositories\PaymentRepository;
use App\Models\Payment;
use App\Models\Refund;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class AnalyticsService
{
    protected $paymentRepository;

    public function __construct(PaymentRepository $paymentRepository)
    {
        $this->paymentRepository = $paymentRepository;
    }

    public function getPaymentAnalytics($filters = [])
    {
        return [
            'payment_stats' => $this->paymentRepository->getPaymentStats($filters),
            'revenue_stats' => $this->paymentRepository->getRevenueStats($filters),
            'payment_method_stats' => $this->paymentRepository->getPaymentMethodStats($filters),
            'performance_metrics' => $this->paymentRepository->getPaymentPerformanceMetrics($filters),
            'status_distribution' => $this->paymentRepository->getPaymentStatusDistribution($filters),
        ];
    }

    public function getRevenueAnalytics($filters = [])
    {
        $revenueStats = $this->paymentRepository->getRevenueStats($filters);
        $trends = $this->paymentRepository->getPaymentTrends($filters['days'] ?? 30);

        return [
            'revenue_summary' => $revenueStats,
            'revenue_trends' => $trends,
            'monthly_revenue' => $this->getMonthlyRevenue($filters),
            'yearly_revenue' => $this->getYearlyRevenue($filters),
            'revenue_forecast' => $this->getRevenueForecast($trends),
        ];
    }

    public function getPaymentMethodAnalytics($filters = [])
    {
        $methodStats = $this->paymentRepository->getPaymentMethodStats($filters);
        $methodTrends = $this->getPaymentMethodTrends($filters);

        return [
            'method_summary' => $methodStats,
            'method_trends' => $methodTrends,
            'method_performance' => $this->getPaymentMethodPerformance($filters),
            'method_conversion_rates' => $this->getPaymentMethodConversionRates($filters),
        ];
    }

    public function getPaymentPerformanceMetrics($filters = [])
    {
        $performanceMetrics = $this->paymentRepository->getPaymentPerformanceMetrics($filters);
        $hourlyStats = $this->paymentRepository->getPaymentByHour($filters);
        $dailyStats = $this->paymentRepository->getPaymentByDayOfWeek($filters);

        return [
            'performance_summary' => $performanceMetrics,
            'hourly_distribution' => $hourlyStats,
            'daily_distribution' => $dailyStats,
            'peak_hours' => $this->getPeakHours($hourlyStats),
            'peak_days' => $this->getPeakDays($dailyStats),
            'verification_trends' => $this->getVerificationTrends($filters),
        ];
    }

    public function getPaymentTrends($filters = [])
    {
        $trends = $this->paymentRepository->getPaymentTrends($filters['days'] ?? 30);
        $topUsers = $this->paymentRepository->getTopUsersByPayment(10, $filters);

        return [
            'payment_trends' => $trends,
            'top_users' => $topUsers,
            'trend_analysis' => $this->analyzeTrends($trends),
            'seasonal_patterns' => $this->getSeasonalPatterns($filters),
            'growth_metrics' => $this->getGrowthMetrics($trends),
        ];
    }

    public function generatePaymentReport($filters = [])
    {
        $report = [
            'generated_at' => now(),
            'filters' => $filters,
            'executive_summary' => $this->getExecutiveSummary($filters),
            'payment_analytics' => $this->getPaymentAnalytics($filters),
            'revenue_analytics' => $this->getRevenueAnalytics($filters),
            'payment_method_analytics' => $this->getPaymentMethodAnalytics($filters),
            'performance_metrics' => $this->getPaymentPerformanceMetrics($filters),
            'trends' => $this->getPaymentTrends($filters),
            'recommendations' => $this->getRecommendations($filters),
        ];

        return $report;
    }

    public function exportPaymentData($filters = [], $format = 'csv')
    {
        $query = Payment::with(['user', 'booking', 'bankAccount']);

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (isset($filters['payment_method'])) {
            $query->where('payment_method', $filters['payment_method']);
        }

        $payments = $query->orderBy('created_at', 'desc')->get();

        $data = $payments->map(function ($payment) {
            return [
                'id' => $payment->id,
                'reference_number' => $payment->reference_number,
                'user_name' => $payment->user->name,
                'user_email' => $payment->user->email,
                'booking_reference' => $payment->booking->booking_reference,
                'amount' => $payment->amount,
                'status' => $payment->status,
                'payment_method' => $payment->payment_method,
                'bank_account' => $payment->bankAccount ? $payment->bankAccount->bank_name : 'N/A',
                'created_at' => $payment->created_at,
                'verified_at' => $payment->verified_at,
                'verification_time' => $payment->verification_time,
            ];
        });

        return $this->formatExportData($data, $format);
    }

    protected function getMonthlyRevenue($filters)
    {
        $query = Payment::where('status', 'verified');

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('verified_at', [$filters['start_date'], $filters['end_date']]);
        }

        return $query->selectRaw('YEAR(verified_at) as year, MONTH(verified_at) as month, SUM(amount) as total')
            ->groupBy('year', 'month')
            ->orderBy('year', 'desc')
            ->orderBy('month', 'desc')
            ->get();
    }

    protected function getYearlyRevenue($filters)
    {
        $query = Payment::where('status', 'verified');

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('verified_at', [$filters['start_date'], $filters['end_date']]);
        }

        return $query->selectRaw('YEAR(verified_at) as year, SUM(amount) as total')
            ->groupBy('year')
            ->orderBy('year', 'desc')
            ->get();
    }

    protected function getRevenueForecast($trends)
    {
        // Simple linear regression for revenue forecasting
        $revenueData = collect($trends)->pluck('verified_amount')->filter();

        if ($revenueData->count() < 2) {
            return null;
        }

        $n = $revenueData->count();
        $x = range(1, $n);
        $y = $revenueData->values()->toArray();

        $sumX = array_sum($x);
        $sumY = array_sum($y);
        $sumXY = 0;
        $sumXX = 0;

        for ($i = 0; $i < $n; $i++) {
            $sumXY += $x[$i] * $y[$i];
            $sumXX += $x[$i] * $x[$i];
        }

        $slope = ($n * $sumXY - $sumX * $sumY) / ($n * $sumXX - $sumX * $sumX);
        $intercept = ($sumY - $slope * $sumX) / $n;

        // Forecast next 7 days
        $forecast = [];
        for ($i = 1; $i <= 7; $i++) {
            $forecast[] = [
                'day' => $i,
                'predicted_revenue' => $intercept + $slope * ($n + $i),
            ];
        }

        return $forecast;
    }

    protected function getPaymentMethodTrends($filters)
    {
        $startDate = now()->subDays($filters['days'] ?? 30);
        $endDate = now();

        $trends = [];
        $currentDate = $startDate->copy();

        while ($currentDate->lte($endDate)) {
            $date = $currentDate->format('Y-m-d');

            $dayStats = Payment::whereDate('created_at', $date)
                ->selectRaw('payment_method, COUNT(*) as count, SUM(amount) as total')
                ->groupBy('payment_method')
                ->get()
                ->keyBy('payment_method');

            $trends[] = [
                'date' => $date,
                'methods' => $dayStats,
            ];

            $currentDate->addDay();
        }

        return $trends;
    }

    protected function getPaymentMethodPerformance($filters)
    {
        $query = Payment::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        return $query->selectRaw('payment_method,
                COUNT(*) as total_count,
                SUM(CASE WHEN status = "verified" THEN 1 ELSE 0 END) as verified_count,
                SUM(CASE WHEN status = "rejected" THEN 1 ELSE 0 END) as rejected_count,
                SUM(CASE WHEN status = "expired" THEN 1 ELSE 0 END) as expired_count,
                AVG(amount) as average_amount')
            ->groupBy('payment_method')
            ->get();
    }

    protected function getPaymentMethodConversionRates($filters)
    {
        $performance = $this->getPaymentMethodPerformance($filters);

        return $performance->map(function ($method) {
            $total = $method->total_count;
            $verified = $method->verified_count;
            $rejected = $method->rejected_count;
            $expired = $method->expired_count;

            return [
                'payment_method' => $method->payment_method,
                'conversion_rate' => $total > 0 ? round(($verified / $total) * 100, 2) : 0,
                'rejection_rate' => $total > 0 ? round(($rejected / $total) * 100, 2) : 0,
                'expiry_rate' => $total > 0 ? round(($expired / $total) * 100, 2) : 0,
                'average_amount' => round($method->average_amount, 2),
            ];
        });
    }

    protected function getPeakHours($hourlyStats)
    {
        return $hourlyStats->sortByDesc('count')->take(5);
    }

    protected function getPeakDays($dailyStats)
    {
        return $dailyStats->sortByDesc('count');
    }

    protected function getVerificationTrends($filters)
    {
        $query = Payment::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        return $query->selectRaw('DATE(created_at) as date,
                COUNT(*) as total_payments,
                SUM(CASE WHEN status = "verified" THEN 1 ELSE 0 END) as verified_payments,
                AVG(CASE WHEN verified_at IS NOT NULL THEN TIMESTAMPDIFF(MINUTE, created_at, verified_at) END) as avg_verification_time')
            ->groupBy('date')
            ->orderBy('date')
            ->get();
    }

    protected function getSeasonalPatterns($filters)
    {
        $query = Payment::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        return $query->selectRaw('MONTH(created_at) as month,
                DAYOFWEEK(created_at) as day_of_week,
                HOUR(created_at) as hour,
                COUNT(*) as count,
                SUM(amount) as total')
            ->groupBy('month', 'day_of_week', 'hour')
            ->get();
    }

    protected function getGrowthMetrics($trends)
    {
        if (count($trends) < 2) {
            return null;
        }

        $firstWeek = collect($trends)->take(7)->sum('verified_amount');
        $lastWeek = collect($trends)->take(-7)->sum('verified_amount');

        $growthRate = $firstWeek > 0 ? (($lastWeek - $firstWeek) / $firstWeek) * 100 : 0;

        return [
            'week_over_week_growth' => round($growthRate, 2),
            'first_week_revenue' => $firstWeek,
            'last_week_revenue' => $lastWeek,
        ];
    }

    protected function analyzeTrends($trends)
    {
        $revenueData = collect($trends)->pluck('verified_amount');
        $paymentData = collect($trends)->pluck('verified_payments');

        return [
            'revenue_trend' => $this->calculateTrend($revenueData),
            'payment_volume_trend' => $this->calculateTrend($paymentData),
            'average_daily_revenue' => $revenueData->avg(),
            'average_daily_payments' => $paymentData->avg(),
        ];
    }

    protected function calculateTrend($data)
    {
        if ($data->count() < 2) {
            return 'insufficient_data';
        }

        $first = $data->first();
        $last = $data->last();

        if ($first == 0) {
            return $last > 0 ? 'increasing' : 'stable';
        }

        $change = (($last - $first) / $first) * 100;

        if ($change > 10) {
            return 'increasing';
        } elseif ($change < -10) {
            return 'decreasing';
        } else {
            return 'stable';
        }
    }

    protected function getExecutiveSummary($filters)
    {
        $paymentStats = $this->paymentRepository->getPaymentStats($filters);
        $revenueStats = $this->paymentRepository->getRevenueStats($filters);
        $performanceMetrics = $this->paymentRepository->getPaymentPerformanceMetrics($filters);

        return [
            'total_payments' => $paymentStats['total_payments'],
            'total_revenue' => $revenueStats['net_revenue'],
            'verification_rate' => $performanceMetrics['verification_rate'],
            'average_payment_amount' => $performanceMetrics['average_payment_amount'],
            'refund_rate' => $revenueStats['refund_rate'],
        ];
    }

    protected function getRecommendations($filters)
    {
        $performanceMetrics = $this->paymentRepository->getPaymentPerformanceMetrics($filters);
        $recommendations = [];

        if ($performanceMetrics['verification_rate'] < 80) {
            $recommendations[] = [
                'type' => 'verification_rate',
                'priority' => 'high',
                'message' => 'Payment verification rate is below 80%. Consider improving payment proof validation.',
            ];
        }

        if ($performanceMetrics['expiry_rate'] > 20) {
            $recommendations[] = [
                'type' => 'expiry_rate',
                'priority' => 'medium',
                'message' => 'Payment expiry rate is above 20%. Consider extending payment expiry time.',
            ];
        }

        if ($performanceMetrics['rejection_rate'] > 15) {
            $recommendations[] = [
                'type' => 'rejection_rate',
                'priority' => 'medium',
                'message' => 'Payment rejection rate is above 15%. Review rejection criteria.',
            ];
        }

        return $recommendations;
    }

    protected function formatExportData($data, $format)
    {
        switch ($format) {
            case 'csv':
                return $this->formatAsCsv($data);
            case 'json':
                return $data->toJson();
            default:
                return $data->toArray();
        }
    }

    protected function formatAsCsv($data)
    {
        if ($data->isEmpty()) {
            return '';
        }

        $headers = array_keys($data->first());
        $csv = implode(',', $headers) . "\n";

        foreach ($data as $row) {
            $csv .= implode(',', array_values($row)) . "\n";
        }

        return $csv;
    }
}
```

### Step 3: Create Payment Analytics Controller

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseController;
use App\Services\AnalyticsService;
use Illuminate\Http\Request;

class PaymentAnalyticsController extends BaseController
{
    protected $analyticsService;

    public function __construct(AnalyticsService $analyticsService)
    {
        $this->analyticsService = $analyticsService;
    }

    public function getPaymentAnalytics(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date', 'user_id', 'status', 'payment_method']);
            $analytics = $this->analyticsService->getPaymentAnalytics($filters);

            return $this->successResponse($analytics, 'Payment analytics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getRevenueAnalytics(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date', 'days']);
            $analytics = $this->analyticsService->getRevenueAnalytics($filters);

            return $this->successResponse($analytics, 'Revenue analytics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getPaymentMethodAnalytics(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date', 'days']);
            $analytics = $this->analyticsService->getPaymentMethodAnalytics($filters);

            return $this->successResponse($analytics, 'Payment method analytics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getPerformanceMetrics(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date']);
            $metrics = $this->analyticsService->getPaymentPerformanceMetrics($filters);

            return $this->successResponse($metrics, 'Performance metrics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getPaymentTrends(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date', 'days']);
            $trends = $this->analyticsService->getPaymentTrends($filters);

            return $this->successResponse($trends, 'Payment trends retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function generateReport(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date', 'user_id', 'status', 'payment_method']);
            $report = $this->analyticsService->generatePaymentReport($filters);

            return $this->successResponse($report, 'Payment report generated successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function exportData(Request $request)
    {
        $request->validate([
            'format' => 'nullable|in:csv,json',
        ]);

        try {
            $filters = $request->only(['start_date', 'end_date', 'status', 'payment_method']);
            $format = $request->get('format', 'csv');

            $data = $this->analyticsService->exportPaymentData($filters, $format);

            return response($data)
                ->header('Content-Type', $format === 'csv' ? 'text/csv' : 'application/json')
                ->header('Content-Disposition', 'attachment; filename="payment_data_' . now()->format('Y-m-d') . '.' . $format . '"');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getDashboardData(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date']);

            $dashboardData = [
                'payment_analytics' => $this->analyticsService->getPaymentAnalytics($filters),
                'revenue_analytics' => $this->analyticsService->getRevenueAnalytics($filters),
                'performance_metrics' => $this->analyticsService->getPaymentPerformanceMetrics($filters),
                'recent_trends' => $this->analyticsService->getPaymentTrends(array_merge($filters, ['days' => 7])),
            ];

            return $this->successResponse($dashboardData, 'Dashboard data retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }
}
```

## 📚 API Endpoints

### Payment Analytics Endpoints

```
GET    /api/v1/admin/analytics/payments
GET    /api/v1/admin/analytics/revenue
GET    /api/v1/admin/analytics/payment-methods
GET    /api/v1/admin/analytics/performance
GET    /api/v1/admin/analytics/trends
GET    /api/v1/admin/analytics/report
GET    /api/v1/admin/analytics/export
GET    /api/v1/admin/analytics/dashboard
```

## 🧪 Testing

### PaymentAnalyticsTest.php

```php
<?php

use App\Models\Payment;
use App\Services\AnalyticsService;
use App\Repositories\PaymentRepository;

describe('Payment Analytics', function () {

    beforeEach(function () {
        $this->analyticsService = app(AnalyticsService::class);
        $this->paymentRepository = app(PaymentRepository::class);
    });

    it('can get payment analytics', function () {
        Payment::factory()->count(10)->create();
        actingAsAdmin();

        $analytics = $this->analyticsService->getPaymentAnalytics();

        expect($analytics)->toHaveKey('payment_stats');
        expect($analytics)->toHaveKey('revenue_stats');
        expect($analytics)->toHaveKey('payment_method_stats');
        expect($analytics['payment_stats']['total_payments'])->toBe(10);
    });

    it('can get revenue analytics', function () {
        Payment::factory()->count(5)->create(['status' => 'verified', 'amount' => 100000]);
        actingAsAdmin();

        $analytics = $this->analyticsService->getRevenueAnalytics();

        expect($analytics)->toHaveKey('revenue_summary');
        expect($analytics)->toHaveKey('revenue_trends');
        expect($analytics['revenue_summary']['gross_revenue'])->toBe(500000);
    });

    it('can get payment method analytics', function () {
        Payment::factory()->count(3)->create(['payment_method' => 'manual_transfer']);
        Payment::factory()->count(2)->create(['payment_method' => 'cash']);
        actingAsAdmin();

        $analytics = $this->analyticsService->getPaymentMethodAnalytics();

        expect($analytics)->toHaveKey('method_summary');
        expect($analytics)->toHaveKey('method_trends');
        expect($analytics['method_summary'])->toHaveCount(2);
    });

    it('can generate payment report', function () {
        Payment::factory()->count(5)->create();
        actingAsAdmin();

        $report = $this->analyticsService->generatePaymentReport();

        expect($report)->toHaveKey('executive_summary');
        expect($report)->toHaveKey('payment_analytics');
        expect($report)->toHaveKey('recommendations');
    });

    it('can export payment data', function () {
        Payment::factory()->count(3)->create();
        actingAsAdmin();

        $csvData = $this->analyticsService->exportPaymentData([], 'csv');

        expect($csvData)->toContain('id,reference_number,user_name');
        expect($csvData)->toContain('1,');
    });

    it('can get payment trends', function () {
        Payment::factory()->count(10)->create();
        actingAsAdmin();

        $trends = $this->analyticsService->getPaymentTrends(['days' => 30]);

        expect($trends)->toHaveKey('payment_trends');
        expect($trends)->toHaveKey('top_users');
        expect($trends)->toHaveKey('trend_analysis');
    });
});
```

## ✅ Success Criteria

-   [x] Payment statistics berfungsi
-   [x] Revenue tracking berjalan
-   [x] Payment method analytics berfungsi
-   [x] Payment performance metrics berjalan
-   [x] Payment trends berfungsi
-   [x] Payment reports berjalan
-   [x] Testing coverage > 90%

## 📚 Documentation

-   [Laravel Database Queries](https://laravel.com/docs/11.x/queries)
-   [Laravel Collections](https://laravel.com/docs/11.x/collections)
-   [Laravel File Downloads](https://laravel.com/docs/11.x/responses#file-downloads)
