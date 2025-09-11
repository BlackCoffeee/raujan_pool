# Pricing History & Analytics Implementation

## 📋 Overview

Implementasi pricing history dan analytics interface dengan historical pricing data, pricing trends, dan pricing optimization insights untuk Raujan Pool Syariah frontend.

## 🎯 Objectives

- Pricing history tracking dan visualization
- Pricing trends analysis
- Pricing optimization insights
- Revenue impact analysis
- Customer behavior analysis
- Pricing performance metrics

## 🔧 Implementation Steps

### Step 1: Create Pricing History Components

```bash
# Create pricing history components
mkdir -p src/components/pricing/history
touch src/components/pricing/history/PricingHistoryChart.tsx
touch src/components/pricing/history/PricingTrendsAnalysis.tsx
touch src/components/pricing/history/PricingOptimizationInsights.tsx
touch src/components/pricing/history/RevenueImpactAnalysis.tsx
```

**Component Structure:**

- `PricingHistoryChart` - Pricing history visualization
- `PricingTrendsAnalysis` - Pricing trends analysis
- `PricingOptimizationInsights` - Pricing optimization insights
- `RevenueImpactAnalysis` - Revenue impact analysis

### Step 2: Setup Pricing History Validation

```bash
# Create pricing history validation schemas
mkdir -p src/schemas/pricing/history
touch src/schemas/pricingHistorySchemas.ts
touch src/schemas/pricingAnalyticsSchemas.ts
```

**Validation Features:**

- Pricing history data validation
- Pricing analytics validation
- Pricing trends validation
- Revenue impact validation

### Step 3: Create Pricing History Pages

```bash
# Create pricing history pages
mkdir -p src/pages/pricing/history
touch src/pages/pricing/history/PricingHistoryPage.tsx
touch src/pages/pricing/history/PricingAnalyticsPage.tsx
touch src/pages/pricing/history/PricingOptimizationPage.tsx
touch src/pages/pricing/history/RevenueImpactPage.tsx
```

**Page Structure:**

- `PricingHistoryPage` - Main pricing history page
- `PricingAnalyticsPage` - Pricing analytics page
- `PricingOptimizationPage` - Pricing optimization page
- `RevenueImpactPage` - Revenue impact page

### Step 4: Setup Pricing History Hooks

```bash
# Create pricing history hooks
touch src/hooks/usePricingHistory.ts
touch src/hooks/usePricingAnalytics.ts
touch src/hooks/usePricingOptimization.ts
touch src/hooks/useRevenueImpact.ts
```

**Hook Features:**

- Pricing history management
- Pricing analytics management
- Pricing optimization management
- Revenue impact management

### Step 5: Create Pricing History Services

```bash
# Create pricing history services
mkdir -p src/services/pricing/history
touch src/services/pricing/history/pricingHistoryService.ts
touch src/services/pricing/history/pricingAnalyticsService.ts
touch src/services/pricing/history/pricingOptimizationService.ts
```

**Service Features:**

- Pricing history API service
- Pricing analytics API service
- Pricing optimization API service
- Revenue impact API service

## 📊 Configuration Files

### src/schemas/pricingHistorySchemas.ts

```typescript
// Pricing history validation schemas
import { z } from "zod";

export const pricingHistoryQuerySchema = z.object({
  startDate: z.string().min(1, "Tanggal mulai diperlukan"),
  endDate: z.string().min(1, "Tanggal berakhir diperlukan"),
  serviceType: z
    .enum(["pool_booking", "cafe_order", "private_pool", "all"])
    .default("all"),
  poolId: z.string().optional(),
  sessionType: z.enum(["regular", "private", "vip"]).optional(),
  membershipType: z.enum(["monthly", "quarterly"]).optional(),
  groupBy: z.enum(["day", "week", "month", "quarter", "year"]).default("day"),
});

export const pricingAnalyticsSchema = z.object({
  dateRange: z.object({
    startDate: z.string().min(1, "Tanggal mulai diperlukan"),
    endDate: z.string().min(1, "Tanggal berakhir diperlukan"),
  }),
  metrics: z
    .array(
      z.enum([
        "revenue",
        "booking_count",
        "average_price",
        "price_variance",
        "customer_satisfaction",
        "conversion_rate",
        "retention_rate",
      ])
    )
    .default(["revenue", "booking_count"]),
  filters: z
    .object({
      serviceType: z
        .enum(["pool_booking", "cafe_order", "private_pool", "all"])
        .optional(),
      poolId: z.string().optional(),
      sessionType: z.enum(["regular", "private", "vip"]).optional(),
      membershipType: z.enum(["monthly", "quarterly"]).optional(),
    })
    .optional(),
});

export const pricingOptimizationSchema = z.object({
  optimizationType: z.enum([
    "revenue",
    "customer_satisfaction",
    "conversion_rate",
    "retention_rate",
  ]),
  constraints: z
    .object({
      minPrice: z.number().min(0).optional(),
      maxPrice: z.number().min(0).optional(),
      minBookingCount: z.number().min(0).optional(),
      maxBookingCount: z.number().min(0).optional(),
    })
    .optional(),
  targetMetrics: z
    .object({
      revenue: z.number().min(0).optional(),
      customerSatisfaction: z.number().min(0).max(5).optional(),
      conversionRate: z.number().min(0).max(1).optional(),
      retentionRate: z.number().min(0).max(1).optional(),
    })
    .optional(),
});

export type PricingHistoryQueryData = z.infer<typeof pricingHistoryQuerySchema>;
export type PricingAnalyticsFormData = z.infer<typeof pricingAnalyticsSchema>;
export type PricingOptimizationFormData = z.infer<
  typeof pricingOptimizationSchema
>;
```

### src/hooks/usePricingHistory.ts

```typescript
// Pricing history hook
import { useState, useEffect } from "react";
import { pricingHistoryService } from "@/services/pricing/history/pricingHistoryService";
import { PricingHistoryQueryData } from "@/schemas/pricingHistorySchemas";

export function usePricingHistory() {
  const [historyData, setHistoryData] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const getPricingHistory = async (query: PricingHistoryQueryData) => {
    setIsLoading(true);
    setError(null);
    try {
      const data = await pricingHistoryService.getPricingHistory(query);
      setHistoryData(data);
      return { success: true, data };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getPricingTrends = async (query: PricingHistoryQueryData) => {
    setIsLoading(true);
    setError(null);
    try {
      const trends = await pricingHistoryService.getPricingTrends(query);
      return { success: true, trends };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getPricingComparison = async (query: PricingHistoryQueryData) => {
    setIsLoading(true);
    setError(null);
    try {
      const comparison = await pricingHistoryService.getPricingComparison(
        query
      );
      return { success: true, comparison };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const exportPricingHistory = async (
    query: PricingHistoryQueryData,
    format: "csv" | "excel" | "pdf"
  ) => {
    setIsLoading(true);
    setError(null);
    try {
      const exportData = await pricingHistoryService.exportPricingHistory(
        query,
        format
      );
      return { success: true, exportData };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  return {
    historyData,
    isLoading,
    error,
    getPricingHistory,
    getPricingTrends,
    getPricingComparison,
    exportPricingHistory,
    clearError: () => setError(null),
  };
}
```

### src/components/pricing/history/PricingHistoryChart.tsx

```typescript
// Pricing history chart component
import { useState, useEffect } from "react";
import { usePricingHistory } from "@/hooks/usePricingHistory";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from "recharts";
import { Calendar, Download, TrendingUp, TrendingDown } from "lucide-react";

export function PricingHistoryChart() {
  const {
    historyData,
    isLoading,
    error,
    getPricingHistory,
    exportPricingHistory,
  } = usePricingHistory();
  const [dateRange, setDateRange] = useState({
    startDate: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)
      .toISOString()
      .split("T")[0],
    endDate: new Date().toISOString().split("T")[0],
  });
  const [filters, setFilters] = useState({
    serviceType: "all",
    groupBy: "day",
  });

  useEffect(() => {
    const query = {
      startDate: dateRange.startDate,
      endDate: dateRange.endDate,
      serviceType: filters.serviceType as any,
      groupBy: filters.groupBy as any,
    };
    getPricingHistory(query);
  }, [dateRange, filters]);

  const handleExport = async (format: "csv" | "excel" | "pdf") => {
    const query = {
      startDate: dateRange.startDate,
      endDate: dateRange.endDate,
      serviceType: filters.serviceType as any,
      groupBy: filters.groupBy as any,
    };
    const result = await exportPricingHistory(query, format);
    if (result.success) {
      // Handle download
    }
  };

  const formatChartData = (data: any[]) => {
    return data.map((item) => ({
      date: item.date,
      averagePrice: item.averagePrice,
      bookingCount: item.bookingCount,
      revenue: item.revenue,
      priceVariance: item.priceVariance,
    }));
  };

  return (
    <Card className="w-full">
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle>Riwayat Harga</CardTitle>
          <div className="flex items-center space-x-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => handleExport("csv")}
            >
              <Download className="h-4 w-4 mr-2" />
              CSV
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => handleExport("excel")}
            >
              <Download className="h-4 w-4 mr-2" />
              Excel
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => handleExport("pdf")}
            >
              <Download className="h-4 w-4 mr-2" />
              PDF
            </Button>
          </div>
        </div>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {/* Filters */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div className="space-y-2">
              <label className="text-sm font-medium">Tanggal Mulai</label>
              <input
                type="date"
                value={dateRange.startDate}
                onChange={(e) =>
                  setDateRange((prev) => ({
                    ...prev,
                    startDate: e.target.value,
                  }))
                }
                className="w-full p-2 border rounded-md"
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">Tanggal Berakhir</label>
              <input
                type="date"
                value={dateRange.endDate}
                onChange={(e) =>
                  setDateRange((prev) => ({ ...prev, endDate: e.target.value }))
                }
                className="w-full p-2 border rounded-md"
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">Jenis Layanan</label>
              <Select
                value={filters.serviceType}
                onValueChange={(value) =>
                  setFilters((prev) => ({ ...prev, serviceType: value }))
                }
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">Semua Layanan</SelectItem>
                  <SelectItem value="pool_booking">Booking Pool</SelectItem>
                  <SelectItem value="cafe_order">Pesanan Cafe</SelectItem>
                  <SelectItem value="private_pool">Private Pool</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">Kelompok Data</label>
              <Select
                value={filters.groupBy}
                onValueChange={(value) =>
                  setFilters((prev) => ({ ...prev, groupBy: value }))
                }
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="day">Harian</SelectItem>
                  <SelectItem value="week">Mingguan</SelectItem>
                  <SelectItem value="month">Bulanan</SelectItem>
                  <SelectItem value="quarter">Triwulan</SelectItem>
                  <SelectItem value="year">Tahunan</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          {/* Chart */}
          <div className="h-96">
            {isLoading ? (
              <div className="flex items-center justify-center h-full">
                <div className="text-center">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
                  <p className="mt-2 text-sm text-gray-500">Memuat data...</p>
                </div>
              </div>
            ) : error ? (
              <div className="flex items-center justify-center h-full">
                <div className="text-center">
                  <p className="text-red-500">{error}</p>
                </div>
              </div>
            ) : (
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={formatChartData(historyData)}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="date" />
                  <YAxis yAxisId="left" />
                  <YAxis yAxisId="right" orientation="right" />
                  <Tooltip />
                  <Legend />
                  <Line
                    yAxisId="left"
                    type="monotone"
                    dataKey="averagePrice"
                    stroke="#8884d8"
                    strokeWidth={2}
                    name="Harga Rata-rata"
                  />
                  <Line
                    yAxisId="right"
                    type="monotone"
                    dataKey="bookingCount"
                    stroke="#82ca9d"
                    strokeWidth={2}
                    name="Jumlah Booking"
                  />
                  <Line
                    yAxisId="left"
                    type="monotone"
                    dataKey="revenue"
                    stroke="#ffc658"
                    strokeWidth={2}
                    name="Pendapatan"
                  />
                </LineChart>
              </ResponsiveContainer>
            )}
          </div>

          {/* Summary Stats */}
          {historyData.length > 0 && (
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <div className="bg-blue-50 p-4 rounded-lg">
                <div className="flex items-center">
                  <TrendingUp className="h-5 w-5 text-blue-600 mr-2" />
                  <div>
                    <p className="text-sm text-blue-600">Harga Rata-rata</p>
                    <p className="text-lg font-semibold text-blue-800">
                      Rp{" "}
                      {historyData.reduce(
                        (sum, item) => sum + item.averagePrice,
                        0
                      ) / historyData.length.toLocaleString()}
                    </p>
                  </div>
                </div>
              </div>
              <div className="bg-green-50 p-4 rounded-lg">
                <div className="flex items-center">
                  <TrendingUp className="h-5 w-5 text-green-600 mr-2" />
                  <div>
                    <p className="text-sm text-green-600">Total Booking</p>
                    <p className="text-lg font-semibold text-green-800">
                      {historyData
                        .reduce((sum, item) => sum + item.bookingCount, 0)
                        .toLocaleString()}
                    </p>
                  </div>
                </div>
              </div>
              <div className="bg-yellow-50 p-4 rounded-lg">
                <div className="flex items-center">
                  <TrendingUp className="h-5 w-5 text-yellow-600 mr-2" />
                  <div>
                    <p className="text-sm text-yellow-600">Total Pendapatan</p>
                    <p className="text-lg font-semibold text-yellow-800">
                      Rp{" "}
                      {historyData
                        .reduce((sum, item) => sum + item.revenue, 0)
                        .toLocaleString()}
                    </p>
                  </div>
                </div>
              </div>
              <div className="bg-purple-50 p-4 rounded-lg">
                <div className="flex items-center">
                  <TrendingDown className="h-5 w-5 text-purple-600 mr-2" />
                  <div>
                    <p className="text-sm text-purple-600">Variansi Harga</p>
                    <p className="text-lg font-semibold text-purple-800">
                      {historyData.reduce(
                        (sum, item) => sum + item.priceVariance,
                        0
                      ) / historyData.length.toFixed(2)}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}
```

## 🛠️ Development Commands

### Pricing History Development

```bash
# Start development server
npm run dev

# Test pricing history components
npm run test -- --testPathPattern=pricing-history

# Test pricing history charts
npm run test -- --testPathPattern=pricing-charts
```

### Pricing History Testing

```bash
# Test pricing history functionality
npm run test src/components/pricing/history

# Test pricing history hooks
npm run test src/hooks/usePricingHistory

# Test pricing history services
npm run test src/services/pricing/history
```

## 🎨 UI Implementation

### Pricing History Styling

```bash
# Create pricing history styles
mkdir -p src/styles/pricing/history
touch src/styles/pricing/history/pricingHistory.css
touch src/styles/pricing/history/pricingCharts.css
```

**Style Features:**

- Pricing history chart styling
- Pricing trends styling
- Pricing analytics styling
- Revenue impact styling

### Pricing History Layout

```bash
# Create pricing history layout
touch src/components/pricing/history/PricingHistoryLayout.tsx
touch src/components/pricing/history/PricingHistorySidebar.tsx
```

**Layout Features:**

- Pricing history page layout
- Pricing history sidebar navigation
- Pricing history content area
- Responsive design

## 🔧 Integration Points

### API Integration

```bash
# Create pricing history API service
touch src/services/api/pricingHistoryApi.ts
touch src/services/api/pricingAnalyticsApi.ts
```

**API Features:**

- Pricing history API integration
- Pricing analytics API integration
- Pricing optimization API integration
- Revenue impact API integration

### State Management

```bash
# Create pricing history state management
touch src/store/pricing/history/pricingHistoryStore.ts
touch src/store/pricing/history/pricingHistoryActions.ts
```

**State Features:**

- Pricing history state management
- Pricing analytics state management
- Pricing optimization state management
- Revenue impact state management

## 🧪 Testing Strategy

### Unit Tests

```bash
# Test pricing history components
mkdir -p src/components/pricing/history/__tests__
touch src/components/pricing/history/__tests__/PricingHistoryChart.test.tsx
touch src/components/pricing/history/__tests__/PricingTrendsAnalysis.test.tsx
```

**Test Coverage:**

- Pricing history chart rendering
- Pricing trends analysis
- Pricing optimization insights
- Revenue impact analysis

### Integration Tests

```bash
# Test pricing history integration
mkdir -p src/__tests__/integration
touch src/__tests__/integration/pricing-history.test.tsx
```

**Integration Tests:**

- Complete pricing history workflow
- API integration
- State management integration
- Chart rendering integration

## 📱 Mobile Considerations

### Mobile Pricing History

```bash
# Mobile pricing history components
touch src/components/pricing/history/mobile/MobilePricingHistoryChart.tsx
touch src/components/pricing/history/mobile/MobilePricingAnalytics.tsx
```

**Mobile Features:**

- Mobile-optimized pricing history charts
- Mobile pricing analytics
- Touch-friendly interface
- Mobile pricing trends

### Performance Optimization

```bash
# Pricing history performance optimization
touch src/hooks/usePricingHistoryPerformance.ts
```

**Optimizations:**

- Pricing history chart optimization
- Pricing analytics optimization
- Data loading optimization
- Chart rendering optimization

## 🔒 Security Considerations

### Pricing History Security

```bash
# Pricing history security utilities
touch src/utils/pricingHistorySecurity.ts
touch src/utils/pricingAnalyticsSecurity.ts
```

**Security Features:**

- Pricing history data validation
- Pricing analytics validation
- Pricing trends validation
- Revenue impact validation

### Data Protection

```bash
# Data protection utilities
touch src/utils/pricingHistoryDataProtection.ts
touch src/utils/pricingAnalyticsDataProtection.ts
```

**Protection Features:**

- Pricing history data protection
- Pricing analytics data protection
- Sensitive pricing data masking
- Privacy compliance

## 📊 Analytics & Monitoring

### Pricing History Analytics

```bash
# Pricing history analytics
touch src/utils/pricingHistoryAnalytics.ts
touch src/hooks/usePricingHistoryAnalytics.ts
```

**Analytics Features:**

- Pricing history usage tracking
- Pricing analytics usage tracking
- Pricing trends analytics
- Revenue impact analytics

### Error Monitoring

```bash
# Error monitoring untuk pricing history
touch src/utils/pricingHistoryErrorMonitoring.ts
touch src/hooks/usePricingHistoryErrorMonitoring.ts
```

**Monitoring Features:**

- Pricing history error tracking
- Pricing analytics error monitoring
- Chart rendering error monitoring
- API error monitoring

## ✅ Success Criteria

- [ ] Pricing history tracking dan visualization berfungsi
- [ ] Pricing trends analysis implemented
- [ ] Pricing optimization insights berfungsi
- [ ] Revenue impact analysis implemented
- [ ] Customer behavior analysis berfungsi
- [ ] Pricing performance metrics implemented
- [ ] Pricing history charts dengan proper visualization
- [ ] Pricing history hooks dengan error handling
- [ ] Pricing history API integration
- [ ] Unit tests untuk pricing history components
- [ ] Integration tests untuk pricing history workflow
- [ ] Security measures untuk pricing history data
- [ ] Data protection untuk sensitive pricing information
- [ ] Analytics tracking untuk pricing history usage
- [ ] Error monitoring dan alerting
- [ ] Performance optimization untuk pricing history charts
- [ ] Mobile-responsive pricing history interface
- [ ] Accessibility features maintained
- [ ] Pricing history system health monitoring
- [ ] Pricing history system documentation dan user guides

## 📝 Notes

- Pastikan pricing history aman dan tidak vulnerable
- Implementasi proper validation untuk semua pricing history inputs
- Setup proper error handling untuk pricing history operations
- Test pricing history system dengan various scenarios
- Consider implementing pricing history backup strategies
- Implementasi pricing history system reporting features
- Consider adding pricing history notifications
- Implementasi pricing history system health monitoring
- Add pricing history system documentation dan training materials
