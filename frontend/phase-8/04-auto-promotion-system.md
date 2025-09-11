# Auto-Promotion System Implementation

## 📋 Overview

Implementasi auto-promotion system interface dengan automatic promotion rules, promotion scheduling, dan promotion analytics untuk Raujan Pool Syariah frontend.

## 🎯 Objectives

- Automatic promotion rules configuration
- Promotion scheduling dan activation
- Promotion analytics dan reporting
- Promotion performance tracking
- Promotion optimization
- Promotion customer experience

## 🔧 Implementation Steps

### Step 1: Create Auto-Promotion Components

```bash
# Create auto-promotion components
mkdir -p src/components/auto-promotion
touch src/components/auto-promotion/PromotionRulesConfig.tsx
touch src/components/auto-promotion/PromotionScheduler.tsx
touch src/components/auto-promotion/PromotionAnalytics.tsx
touch src/components/auto-promotion/PromotionPerformance.tsx
```

**Component Structure:**

- `PromotionRulesConfig` - Promotion rules configuration
- `PromotionScheduler` - Promotion scheduling interface
- `PromotionAnalytics` - Promotion analytics dan reporting
- `PromotionPerformance` - Promotion performance tracking

### Step 2: Setup Auto-Promotion Validation

```bash
# Create auto-promotion validation schemas
mkdir -p src/schemas/auto-promotion
touch src/schemas/autoPromotionSchemas.ts
touch src/schemas/autoPromotionValidation.ts
```

**Validation Features:**

- Promotion rules validation
- Promotion scheduling validation
- Promotion analytics validation
- Promotion performance validation

### Step 3: Create Auto-Promotion Pages

```bash
# Create auto-promotion pages
mkdir -p src/pages/auto-promotion
touch src/pages/auto-promotion/PromotionRulesPage.tsx
touch src/pages/auto-promotion/PromotionSchedulerPage.tsx
touch src/pages/auto-promotion/PromotionAnalyticsPage.tsx
touch src/pages/auto-promotion/PromotionPerformancePage.tsx
```

**Page Structure:**

- `PromotionRulesPage` - Main promotion rules page
- `PromotionSchedulerPage` - Promotion scheduler page
- `PromotionAnalyticsPage` - Promotion analytics page
- `PromotionPerformancePage` - Promotion performance page

### Step 4: Setup Auto-Promotion Hooks

```bash
# Create auto-promotion hooks
touch src/hooks/useAutoPromotion.ts
touch src/hooks/usePromotionRules.ts
touch src/hooks/usePromotionScheduler.ts
touch src/hooks/usePromotionAnalytics.ts
```

**Hook Features:**

- Auto-promotion management
- Promotion rules management
- Promotion scheduling management
- Promotion analytics management

### Step 5: Create Auto-Promotion Services

```bash
# Create auto-promotion services
mkdir -p src/services/auto-promotion
touch src/services/auto-promotion/autoPromotionService.ts
touch src/services/auto-promotion/promotionRulesService.ts
touch src/services/auto-promotion/promotionSchedulerService.ts
```

**Service Features:**

- Auto-promotion API service
- Promotion rules API service
- Promotion scheduler API service
- Promotion analytics API service

## 📊 Configuration Files

### src/schemas/autoPromotionSchemas.ts

```typescript
// Auto-promotion validation schemas
import { z } from "zod";

export const promotionRulesSchema = z.object({
  name: z.string().min(2, "Nama rules minimal 2 karakter"),
  description: z.string().optional(),
  isActive: z.boolean().default(true),
  priority: z
    .number()
    .min(1, "Priority minimal 1")
    .max(10, "Priority maksimal 10"),
  conditions: z.object({
    minQueueLength: z.number().min(1, "Min queue length minimal 1").optional(),
    maxQueueLength: z.number().min(1, "Max queue length minimal 1").optional(),
    minWaitTime: z
      .number()
      .min(0, "Min wait time tidak boleh negatif")
      .optional(), // dalam menit
    maxWaitTime: z
      .number()
      .min(0, "Max wait time tidak boleh negatif")
      .optional(), // dalam menit
    userType: z
      .enum(["member", "guest", "new_user", "returning_user"])
      .optional(),
    membershipType: z.enum(["monthly", "quarterly"]).optional(),
    timeSlots: z.array(z.string()).optional(),
    daysOfWeek: z.array(z.number().min(0).max(6)).optional(),
    specialDates: z.array(z.string()).optional(),
  }),
  actions: z.object({
    promotionType: z.enum([
      "position_boost",
      "priority_increase",
      "skip_queue",
      "vip_access",
    ]),
    promotionValue: z.number().min(0, "Promotion value tidak boleh negatif"),
    promotionDuration: z
      .number()
      .min(1, "Promotion duration minimal 1")
      .optional(), // dalam menit
    maxPromotionsPerDay: z
      .number()
      .min(1, "Max promotions per day minimal 1")
      .optional(),
    maxPromotionsPerUser: z
      .number()
      .min(1, "Max promotions per user minimal 1")
      .optional(),
  }),
  notifications: z
    .object({
      enableUserNotification: z.boolean().default(true),
      enableAdminNotification: z.boolean().default(true),
      notificationChannels: z
        .array(z.enum(["email", "sms", "push", "in_app"]))
        .default(["in_app"]),
      notificationMessage: z.string().optional(),
    })
    .optional(),
});

export const promotionSchedulerSchema = z.object({
  name: z.string().min(2, "Nama scheduler minimal 2 karakter"),
  description: z.string().optional(),
  isActive: z.boolean().default(true),
  scheduleType: z.enum(["immediate", "scheduled", "recurring", "conditional"]),
  scheduleConfig: z.object({
    immediate: z
      .object({
        triggerEvent: z.enum([
          "queue_join",
          "wait_time_exceeded",
          "manual_trigger",
        ]),
        delay: z.number().min(0, "Delay tidak boleh negatif").optional(), // dalam detik
      })
      .optional(),
    scheduled: z
      .object({
        startDate: z.string().min(1, "Start date diperlukan"),
        endDate: z.string().min(1, "End date diperlukan"),
        startTime: z.string().min(1, "Start time diperlukan"),
        endTime: z.string().min(1, "End time diperlukan"),
      })
      .optional(),
    recurring: z
      .object({
        frequency: z.enum(["daily", "weekly", "monthly"]),
        interval: z.number().min(1, "Interval minimal 1"),
        startTime: z.string().min(1, "Start time diperlukan"),
        endTime: z.string().min(1, "End time diperlukan"),
        daysOfWeek: z.array(z.number().min(0).max(6)).optional(),
        daysOfMonth: z.array(z.number().min(1).max(31)).optional(),
      })
      .optional(),
    conditional: z
      .object({
        triggerConditions: z.array(z.string()),
        evaluationInterval: z.number().min(1, "Evaluation interval minimal 1"), // dalam menit
        maxExecutions: z.number().min(1, "Max executions minimal 1").optional(),
      })
      .optional(),
  }),
  promotionRules: z
    .array(z.string())
    .min(1, "Minimal 1 promotion rule diperlukan"),
  isActive: z.boolean().default(true),
});

export const promotionAnalyticsSchema = z.object({
  dateRange: z.object({
    startDate: z.string().min(1, "Tanggal mulai diperlukan"),
    endDate: z.string().min(1, "Tanggal berakhir diperlukan"),
  }),
  metrics: z
    .array(
      z.enum([
        "total_promotions",
        "successful_promotions",
        "failed_promotions",
        "promotion_rate",
        "average_promotion_time",
        "user_satisfaction",
        "queue_efficiency",
        "promotion_cost",
        "revenue_impact",
        "retention_rate",
      ])
    )
    .default(["total_promotions", "successful_promotions"]),
  groupBy: z.enum(["hour", "day", "week", "month"]).default("day"),
  filters: z
    .object({
      promotionType: z
        .enum([
          "position_boost",
          "priority_increase",
          "skip_queue",
          "vip_access",
        ])
        .optional(),
      userType: z
        .enum(["member", "guest", "new_user", "returning_user"])
        .optional(),
      membershipType: z.enum(["monthly", "quarterly"]).optional(),
      status: z.enum(["active", "inactive", "completed", "failed"]).optional(),
    })
    .optional(),
});

export const promotionPerformanceSchema = z.object({
  promotionId: z.string().min(1, "Promotion ID diperlukan"),
  dateRange: z.object({
    startDate: z.string().min(1, "Tanggal mulai diperlukan"),
    endDate: z.string().min(1, "Tanggal berakhir diperlukan"),
  }),
  performanceMetrics: z.object({
    totalExecutions: z.number().min(0, "Total executions tidak boleh negatif"),
    successfulExecutions: z
      .number()
      .min(0, "Successful executions tidak boleh negatif"),
    failedExecutions: z
      .number()
      .min(0, "Failed executions tidak boleh negatif"),
    averageExecutionTime: z
      .number()
      .min(0, "Average execution time tidak boleh negatif"),
    userSatisfactionScore: z
      .number()
      .min(0)
      .max(5, "User satisfaction score maksimal 5"),
    queueEfficiencyImprovement: z
      .number()
      .min(0, "Queue efficiency improvement tidak boleh negatif"),
    revenueImpact: z.number().min(0, "Revenue impact tidak boleh negatif"),
    costPerPromotion: z
      .number()
      .min(0, "Cost per promotion tidak boleh negatif"),
  }),
  recommendations: z
    .array(
      z.object({
        type: z.enum([
          "optimization",
          "scaling",
          "modification",
          "discontinuation",
        ]),
        description: z.string(),
        priority: z.enum(["low", "medium", "high", "critical"]),
        estimatedImpact: z.string(),
      })
    )
    .optional(),
});

export type PromotionRulesFormData = z.infer<typeof promotionRulesSchema>;
export type PromotionSchedulerFormData = z.infer<
  typeof promotionSchedulerSchema
>;
export type PromotionAnalyticsFormData = z.infer<
  typeof promotionAnalyticsSchema
>;
export type PromotionPerformanceFormData = z.infer<
  typeof promotionPerformanceSchema
>;
```

### src/hooks/useAutoPromotion.ts

```typescript
// Auto-promotion hook
import { useState, useEffect } from "react";
import { autoPromotionService } from "@/services/auto-promotion/autoPromotionService";
import { PromotionRulesFormData } from "@/schemas/autoPromotionSchemas";

export function useAutoPromotion() {
  const [autoPromotions, setAutoPromotions] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const createAutoPromotion = async (data: PromotionRulesFormData) => {
    setIsLoading(true);
    setError(null);
    try {
      const newPromotion = await autoPromotionService.createAutoPromotion(data);
      setAutoPromotions((prev) => [...prev, newPromotion]);
      return { success: true, promotion: newPromotion };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const updateAutoPromotion = async (
    id: string,
    data: PromotionRulesFormData
  ) => {
    setIsLoading(true);
    setError(null);
    try {
      const updatedPromotion = await autoPromotionService.updateAutoPromotion(
        id,
        data
      );
      setAutoPromotions((prev) =>
        prev.map((promotion) =>
          promotion.id === id ? updatedPromotion : promotion
        )
      );
      return { success: true, promotion: updatedPromotion };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const deleteAutoPromotion = async (id: string) => {
    setIsLoading(true);
    setError(null);
    try {
      await autoPromotionService.deleteAutoPromotion(id);
      setAutoPromotions((prev) =>
        prev.filter((promotion) => promotion.id !== id)
      );
      return { success: true };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getAutoPromotions = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const promotions = await autoPromotionService.getAutoPromotions();
      setAutoPromotions(promotions);
      return { success: true, promotions };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getAutoPromotion = async (id: string) => {
    setIsLoading(true);
    setError(null);
    try {
      const promotion = await autoPromotionService.getAutoPromotion(id);
      return { success: true, promotion };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const executeAutoPromotion = async (promotionId: string, userId: string) => {
    setIsLoading(true);
    setError(null);
    try {
      const result = await autoPromotionService.executeAutoPromotion(
        promotionId,
        userId
      );
      return { success: true, result };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getPromotionEligibility = async (userId: string, queueId: string) => {
    setIsLoading(true);
    setError(null);
    try {
      const eligibility = await autoPromotionService.getPromotionEligibility(
        userId,
        queueId
      );
      return { success: true, eligibility };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getPromotionHistory = async (
    userId: string,
    dateRange?: { startDate: string; endDate: string }
  ) => {
    setIsLoading(true);
    setError(null);
    try {
      const history = await autoPromotionService.getPromotionHistory(
        userId,
        dateRange
      );
      return { success: true, history };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    getAutoPromotions();
  }, []);

  return {
    autoPromotions,
    isLoading,
    error,
    createAutoPromotion,
    updateAutoPromotion,
    deleteAutoPromotion,
    getAutoPromotions,
    getAutoPromotion,
    executeAutoPromotion,
    getPromotionEligibility,
    getPromotionHistory,
    clearError: () => setError(null),
  };
}
```

### src/components/auto-promotion/PromotionRulesConfig.tsx

```typescript
// Promotion rules configuration component
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import {
  promotionRulesSchema,
  PromotionRulesFormData,
} from "@/schemas/autoPromotionSchemas";
import { useAutoPromotion } from "@/hooks/useAutoPromotion";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Checkbox } from "@/components/ui/checkbox";
import { Separator } from "@/components/ui/separator";

export function PromotionRulesConfig() {
  const { createAutoPromotion, isLoading, error, clearError } =
    useAutoPromotion();

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
    watch,
  } = useForm<PromotionRulesFormData>({
    resolver: zodResolver(promotionRulesSchema),
    defaultValues: {
      isActive: true,
      priority: 1,
      conditions: {
        minQueueLength: 1,
        maxQueueLength: 100,
        minWaitTime: 0,
        maxWaitTime: 60,
      },
      actions: {
        promotionType: "position_boost",
        promotionValue: 1,
        promotionDuration: 30,
        maxPromotionsPerDay: 10,
        maxPromotionsPerUser: 3,
      },
      notifications: {
        enableUserNotification: true,
        enableAdminNotification: true,
        notificationChannels: ["in_app"],
      },
    },
  });

  const promotionType = watch("actions.promotionType");
  const enableUserNotification = watch("notifications.enableUserNotification");

  const onSubmit = async (data: PromotionRulesFormData) => {
    clearError();
    const result = await createAutoPromotion(data);
    if (result.success) {
      reset();
      // Show success message
    }
  };

  return (
    <Card className="w-full max-w-4xl">
      <CardHeader>
        <CardTitle>Konfigurasi Aturan Promosi Otomatis</CardTitle>
        <p className="text-sm text-gray-500">
          Buat aturan promosi otomatis berdasarkan kondisi queue dan user
        </p>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="name">Nama Aturan</Label>
              <Input
                id="name"
                placeholder="Masukkan nama aturan"
                {...register("name")}
              />
              {errors.name && (
                <p className="text-sm text-red-500">{errors.name.message}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="priority">Priority</Label>
              <Input
                id="priority"
                type="number"
                min="1"
                max="10"
                placeholder="Masukkan priority (1-10)"
                {...register("priority", { valueAsNumber: true })}
              />
              {errors.priority && (
                <p className="text-sm text-red-500">
                  {errors.priority.message}
                </p>
              )}
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="description">Deskripsi</Label>
            <Input
              id="description"
              placeholder="Masukkan deskripsi aturan"
              {...register("description")}
            />
            {errors.description && (
              <p className="text-sm text-red-500">
                {errors.description.message}
              </p>
            )}
          </div>

          <Separator />

          {/* Conditions */}
          <div className="space-y-4">
            <h4 className="font-medium">Kondisi Promosi</h4>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="minQueueLength">Minimum Queue Length</Label>
                <Input
                  id="minQueueLength"
                  type="number"
                  placeholder="Masukkan minimum queue length"
                  {...register("conditions.minQueueLength", {
                    valueAsNumber: true,
                  })}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="maxQueueLength">Maximum Queue Length</Label>
                <Input
                  id="maxQueueLength"
                  type="number"
                  placeholder="Masukkan maximum queue length"
                  {...register("conditions.maxQueueLength", {
                    valueAsNumber: true,
                  })}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="minWaitTime">Minimum Wait Time (menit)</Label>
                <Input
                  id="minWaitTime"
                  type="number"
                  placeholder="Masukkan minimum wait time"
                  {...register("conditions.minWaitTime", {
                    valueAsNumber: true,
                  })}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="maxWaitTime">Maximum Wait Time (menit)</Label>
                <Input
                  id="maxWaitTime"
                  type="number"
                  placeholder="Masukkan maximum wait time"
                  {...register("conditions.maxWaitTime", {
                    valueAsNumber: true,
                  })}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="userType">Jenis User</Label>
                <Select {...register("conditions.userType")}>
                  <SelectTrigger>
                    <SelectValue placeholder="Pilih jenis user" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="member">Member</SelectItem>
                    <SelectItem value="guest">Tamu</SelectItem>
                    <SelectItem value="new_user">Pengguna Baru</SelectItem>
                    <SelectItem value="returning_user">
                      Pengguna Kembali
                    </SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="membershipType">Jenis Membership</Label>
                <Select {...register("conditions.membershipType")}>
                  <SelectTrigger>
                    <SelectValue placeholder="Pilih jenis membership" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="monthly">Bulanan</SelectItem>
                    <SelectItem value="quarterly">Triwulan</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
          </div>

          <Separator />

          {/* Actions */}
          <div className="space-y-4">
            <h4 className="font-medium">Aksi Promosi</h4>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="promotionType">Jenis Promosi</Label>
                <Select {...register("actions.promotionType")}>
                  <SelectTrigger>
                    <SelectValue placeholder="Pilih jenis promosi" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="position_boost">
                      Position Boost
                    </SelectItem>
                    <SelectItem value="priority_increase">
                      Priority Increase
                    </SelectItem>
                    <SelectItem value="skip_queue">Skip Queue</SelectItem>
                    <SelectItem value="vip_access">VIP Access</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="promotionValue">
                  {promotionType === "position_boost"
                    ? "Posisi Boost"
                    : promotionType === "priority_increase"
                    ? "Priority Increase"
                    : promotionType === "skip_queue"
                    ? "Skip Queue"
                    : "VIP Access"}
                </Label>
                <Input
                  id="promotionValue"
                  type="number"
                  placeholder="Masukkan nilai promosi"
                  {...register("actions.promotionValue", {
                    valueAsNumber: true,
                  })}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="promotionDuration">
                  Durasi Promosi (menit)
                </Label>
                <Input
                  id="promotionDuration"
                  type="number"
                  placeholder="Masukkan durasi promosi"
                  {...register("actions.promotionDuration", {
                    valueAsNumber: true,
                  })}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="maxPromotionsPerDay">
                  Maximum Promotions per Day
                </Label>
                <Input
                  id="maxPromotionsPerDay"
                  type="number"
                  placeholder="Masukkan maximum promotions per day"
                  {...register("actions.maxPromotionsPerDay", {
                    valueAsNumber: true,
                  })}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="maxPromotionsPerUser">
                  Maximum Promotions per User
                </Label>
                <Input
                  id="maxPromotionsPerUser"
                  type="number"
                  placeholder="Masukkan maximum promotions per user"
                  {...register("actions.maxPromotionsPerUser", {
                    valueAsNumber: true,
                  })}
                />
              </div>
            </div>
          </div>

          <Separator />

          {/* Notifications */}
          <div className="space-y-4">
            <h4 className="font-medium">Notifikasi</h4>

            <div className="space-y-2">
              <div className="flex items-center space-x-2">
                <Checkbox
                  id="enableUserNotification"
                  {...register("notifications.enableUserNotification")}
                />
                <Label htmlFor="enableUserNotification">Notifikasi User</Label>
              </div>

              <div className="flex items-center space-x-2">
                <Checkbox
                  id="enableAdminNotification"
                  {...register("notifications.enableAdminNotification")}
                />
                <Label htmlFor="enableAdminNotification">
                  Notifikasi Admin
                </Label>
              </div>
            </div>

            {enableUserNotification && (
              <div className="space-y-2">
                <Label htmlFor="notificationMessage">Pesan Notifikasi</Label>
                <Input
                  id="notificationMessage"
                  placeholder="Masukkan pesan notifikasi"
                  {...register("notifications.notificationMessage")}
                />
              </div>
            )}
          </div>

          <div className="flex items-center space-x-2">
            <Checkbox id="isActive" {...register("isActive")} />
            <Label htmlFor="isActive">Aturan Aktif</Label>
          </div>

          {error && <p className="text-sm text-red-500">{error}</p>}

          <div className="flex gap-4">
            <Button type="submit" disabled={isLoading}>
              {isLoading ? "Menyimpan..." : "Simpan Aturan"}
            </Button>
            <Button type="button" variant="outline" onClick={() => reset()}>
              Reset
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}
```

## 🛠️ Development Commands

### Auto-Promotion Development

```bash
# Start development server
npm run dev

# Test auto-promotion components
npm run test -- --testPathPattern=auto-promotion

# Test auto-promotion forms
npm run test -- --testPathPattern=auto-promotion-forms
```

### Auto-Promotion Testing

```bash
# Test auto-promotion functionality
npm run test src/components/auto-promotion

# Test auto-promotion hooks
npm run test src/hooks/useAutoPromotion

# Test auto-promotion services
npm run test src/services/auto-promotion
```

## 🎨 UI Implementation

### Auto-Promotion Styling

```bash
# Create auto-promotion styles
mkdir -p src/styles/auto-promotion
touch src/styles/auto-promotion/promotionRules.css
touch src/styles/auto-promotion/promotionScheduler.css
```

**Style Features:**

- Promotion rules configuration styling
- Promotion scheduler styling
- Promotion analytics styling
- Promotion performance styling

### Auto-Promotion Layout

```bash
# Create auto-promotion layout
touch src/components/auto-promotion/PromotionLayout.tsx
touch src/components/auto-promotion/PromotionSidebar.tsx
```

**Layout Features:**

- Auto-promotion page layout
- Auto-promotion sidebar navigation
- Auto-promotion content area
- Responsive design

## 🔧 Integration Points

### API Integration

```bash
# Create auto-promotion API service
touch src/services/api/autoPromotionApi.ts
touch src/services/api/promotionRulesApi.ts
```

**API Features:**

- Auto-promotion API integration
- Promotion rules API integration
- Promotion scheduler API integration
- Promotion analytics API integration

### State Management

```bash
# Create auto-promotion state management
touch src/store/auto-promotion/autoPromotionStore.ts
touch src/store/auto-promotion/autoPromotionActions.ts
```

**State Features:**

- Auto-promotion state management
- Promotion rules state management
- Promotion scheduler state management
- Promotion analytics state management

## 🧪 Testing Strategy

### Unit Tests

```bash
# Test auto-promotion components
mkdir -p src/components/auto-promotion/__tests__
touch src/components/auto-promotion/__tests__/PromotionRulesConfig.test.tsx
touch src/components/auto-promotion/__tests__/PromotionScheduler.test.tsx
```

**Test Coverage:**

- Promotion rules configuration rendering
- Promotion scheduler functionality
- Promotion analytics functionality
- Promotion performance functionality

### Integration Tests

```bash
# Test auto-promotion integration
mkdir -p src/__tests__/integration
touch src/__tests__/integration/auto-promotion.test.tsx
```

**Integration Tests:**

- Complete auto-promotion workflow
- API integration
- State management integration
- Promotion rules integration

## 📱 Mobile Considerations

### Mobile Auto-Promotion

```bash
# Mobile auto-promotion components
touch src/components/auto-promotion/mobile/MobilePromotionRulesConfig.tsx
touch src/components/auto-promotion/mobile/MobilePromotionScheduler.tsx
```

**Mobile Features:**

- Mobile-optimized promotion rules configuration
- Mobile promotion scheduler
- Touch-friendly interface
- Mobile auto-promotion management

### Performance Optimization

```bash
# Auto-promotion performance optimization
touch src/hooks/useAutoPromotionPerformance.ts
```

**Optimizations:**

- Promotion rules configuration optimization
- Promotion scheduler optimization
- Promotion analytics optimization
- API call optimization

## 🔒 Security Considerations

### Auto-Promotion Security

```bash
# Auto-promotion security utilities
touch src/utils/autoPromotionSecurity.ts
touch src/utils/autoPromotionValidation.ts
```

**Security Features:**

- Promotion rules validation
- Promotion scheduler validation
- Promotion analytics validation
- Promotion performance validation

### Data Protection

```bash
# Data protection utilities
touch src/utils/autoPromotionDataProtection.ts
touch src/utils/autoPromotionPrivacy.ts
```

**Protection Features:**

- Auto-promotion data protection
- Promotion rules data protection
- Sensitive promotion data masking
- Privacy compliance

## 📊 Analytics & Monitoring

### Auto-Promotion Analytics

```bash
# Auto-promotion analytics
touch src/utils/autoPromotionAnalytics.ts
touch src/hooks/useAutoPromotionAnalytics.ts
```

**Analytics Features:**

- Auto-promotion usage tracking
- Promotion rules analytics
- Promotion scheduler analytics
- Promotion performance analytics

### Error Monitoring

```bash
# Error monitoring untuk auto-promotion
touch src/utils/autoPromotionErrorMonitoring.ts
touch src/hooks/useAutoPromotionErrorMonitoring.ts
```

**Monitoring Features:**

- Auto-promotion error tracking
- Promotion rules error monitoring
- Promotion scheduler error monitoring
- API error monitoring

## ✅ Success Criteria

- [ ] Automatic promotion rules configuration berfungsi
- [ ] Promotion scheduling dan activation implemented
- [ ] Promotion analytics dan reporting berfungsi
- [ ] Promotion performance tracking implemented
- [ ] Promotion optimization berfungsi
- [ ] Promotion customer experience implemented
- [ ] Auto-promotion forms dengan proper validation
- [ ] Auto-promotion hooks dengan error handling
- [ ] Auto-promotion API integration
- [ ] Unit tests untuk auto-promotion components
- [ ] Integration tests untuk auto-promotion workflow
- [ ] Security measures untuk auto-promotion data
- [ ] Data protection untuk sensitive promotion information
- [ ] Analytics tracking untuk auto-promotion usage
- [ ] Error monitoring dan alerting
- [ ] Performance optimization untuk auto-promotion
- [ ] Mobile-responsive auto-promotion interface
- [ ] Accessibility features maintained
- [ ] Auto-promotion system health monitoring
- [ ] Auto-promotion system documentation dan user guides

## 📝 Notes

- Pastikan auto-promotion aman dan tidak vulnerable
- Implementasi proper validation untuk semua auto-promotion inputs
- Setup proper error handling untuk auto-promotion operations
- Test auto-promotion system dengan various scenarios
- Consider implementing auto-promotion backup strategies
- Implementasi auto-promotion system reporting features
- Consider adding auto-promotion notifications
- Implementasi auto-promotion system health monitoring
- Add auto-promotion system documentation dan training materials
