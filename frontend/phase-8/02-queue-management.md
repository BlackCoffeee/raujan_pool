# Queue Management System Implementation

## 📋 Overview

Implementasi queue management system interface dengan queue position monitoring, queue status tracking, dan queue promotion management untuk Raujan Pool Syariah frontend.

## 🎯 Objectives

- Queue position monitoring
- Queue status tracking
- Queue promotion management
- Queue analytics dan reporting
- Queue performance metrics
- Queue optimization

## 🔧 Implementation Steps

### Step 1: Create Queue Management Components

```bash
# Create queue management components
mkdir -p src/components/queue
touch src/components/queue/QueuePositionDisplay.tsx
touch src/components/queue/QueueStatusTracker.tsx
touch src/components/queue/QueuePromotionManager.tsx
touch src/components/queue/QueueAnalytics.tsx
```

**Component Structure:**

- `QueuePositionDisplay` - Queue position display interface
- `QueueStatusTracker` - Queue status tracking
- `QueuePromotionManager` - Queue promotion management
- `QueueAnalytics` - Queue analytics dan reporting

### Step 2: Setup Queue Management Validation

```bash
# Create queue management validation schemas
mkdir -p src/schemas/queue
touch src/schemas/queueSchemas.ts
touch src/schemas/queueValidation.ts
```

**Validation Features:**

- Queue position validation
- Queue status validation
- Queue promotion validation
- Queue analytics validation

### Step 3: Create Queue Management Pages

```bash
# Create queue management pages
mkdir -p src/pages/queue
touch src/pages/queue/QueueManagementPage.tsx
touch src/pages/queue/QueuePositionPage.tsx
touch src/pages/queue/QueuePromotionPage.tsx
touch src/pages/queue/QueueAnalyticsPage.tsx
```

**Page Structure:**

- `QueueManagementPage` - Main queue management page
- `QueuePositionPage` - Queue position page
- `QueuePromotionPage` - Queue promotion page
- `QueueAnalyticsPage` - Queue analytics page

### Step 4: Setup Queue Management Hooks

```bash
# Create queue management hooks
touch src/hooks/useQueueManagement.ts
touch src/hooks/useQueuePosition.ts
touch src/hooks/useQueuePromotion.ts
touch src/hooks/useQueueAnalytics.ts
```

**Hook Features:**

- Queue management
- Queue position management
- Queue promotion management
- Queue analytics management

### Step 5: Create Queue Management Services

```bash
# Create queue management services
mkdir -p src/services/queue
touch src/services/queue/queueManagementService.ts
touch src/services/queue/queuePositionService.ts
touch src/services/queue/queuePromotionService.ts
```

**Service Features:**

- Queue management API service
- Queue position API service
- Queue promotion API service
- Queue analytics API service

## 📊 Configuration Files

### src/schemas/queueSchemas.ts

```typescript
// Queue management validation schemas
import { z } from "zod";

export const queuePositionSchema = z.object({
  userId: z.string().min(1, "User ID diperlukan"),
  queueId: z.string().min(1, "Queue ID diperlukan"),
  position: z.number().min(1, "Position minimal 1"),
  estimatedWaitTime: z
    .number()
    .min(0, "Estimated wait time tidak boleh negatif"),
  status: z
    .enum(["waiting", "processing", "promoted", "cancelled", "expired"])
    .default("waiting"),
  joinedAt: z.string().min(1, "Joined at diperlukan"),
  lastUpdated: z.string().min(1, "Last updated diperlukan"),
  priority: z.enum(["low", "normal", "high", "urgent"]).default("normal"),
  metadata: z
    .object({
      userType: z
        .enum(["member", "guest", "new_user", "returning_user"])
        .optional(),
      membershipType: z.enum(["monthly", "quarterly"]).optional(),
      previousQueueHistory: z.array(z.string()).optional(),
      specialRequests: z.array(z.string()).optional(),
    })
    .optional(),
});

export const queuePromotionSchema = z.object({
  queueId: z.string().min(1, "Queue ID diperlukan"),
  userId: z.string().min(1, "User ID diperlukan"),
  promotionType: z.enum(["automatic", "manual", "priority", "vip"]),
  promotionReason: z.string().min(1, "Promotion reason diperlukan"),
  promotedBy: z.string().min(1, "Promoted by diperlukan"),
  promotedAt: z.string().min(1, "Promoted at diperlukan"),
  newPosition: z.number().min(1, "New position minimal 1"),
  oldPosition: z.number().min(1, "Old position minimal 1"),
  isActive: z.boolean().default(true),
  conditions: z
    .object({
      minWaitTime: z.number().min(0).optional(),
      maxWaitTime: z.number().min(0).optional(),
      userType: z
        .enum(["member", "guest", "new_user", "returning_user"])
        .optional(),
      membershipType: z.enum(["monthly", "quarterly"]).optional(),
    })
    .optional(),
});

export const queueAnalyticsSchema = z.object({
  queueId: z.string().min(1, "Queue ID diperlukan"),
  dateRange: z.object({
    startDate: z.string().min(1, "Tanggal mulai diperlukan"),
    endDate: z.string().min(1, "Tanggal berakhir diperlukan"),
  }),
  metrics: z
    .array(
      z.enum([
        "average_wait_time",
        "total_queue_length",
        "promotion_count",
        "cancellation_count",
        "completion_rate",
        "user_satisfaction",
        "queue_efficiency",
        "peak_hours",
        "average_position",
        "queue_turnover",
      ])
    )
    .default(["average_wait_time", "total_queue_length"]),
  groupBy: z.enum(["hour", "day", "week", "month"]).default("day"),
  filters: z
    .object({
      userType: z
        .enum(["member", "guest", "new_user", "returning_user"])
        .optional(),
      membershipType: z.enum(["monthly", "quarterly"]).optional(),
      status: z
        .enum(["waiting", "processing", "promoted", "cancelled", "expired"])
        .optional(),
    })
    .optional(),
});

export const queueManagementSchema = z.object({
  name: z.string().min(2, "Nama queue minimal 2 karakter"),
  description: z.string().optional(),
  maxQueueLength: z.number().min(1, "Max queue length minimal 1"),
  currentQueueLength: z
    .number()
    .min(0, "Current queue length tidak boleh negatif"),
  isActive: z.boolean().default(true),
  autoPromotion: z.boolean().default(true),
  promotionRules: z
    .object({
      minWaitTime: z.number().min(0).optional(),
      maxWaitTime: z.number().min(0).optional(),
      promotionInterval: z.number().min(1).optional(), // dalam menit
      maxPromotionsPerDay: z.number().min(1).optional(),
      promotionPriority: z
        .enum(["fifo", "lifo", "priority", "random"])
        .default("fifo"),
    })
    .optional(),
  notifications: z
    .object({
      enablePositionUpdates: z.boolean().default(true),
      enablePromotionNotifications: z.boolean().default(true),
      enableWaitTimeEstimates: z.boolean().default(true),
      notificationChannels: z
        .array(z.enum(["email", "sms", "push", "in_app"]))
        .default(["in_app"]),
    })
    .optional(),
});

export type QueuePositionFormData = z.infer<typeof queuePositionSchema>;
export type QueuePromotionFormData = z.infer<typeof queuePromotionSchema>;
export type QueueAnalyticsFormData = z.infer<typeof queueAnalyticsSchema>;
export type QueueManagementFormData = z.infer<typeof queueManagementSchema>;
```

### src/hooks/useQueueManagement.ts

```typescript
// Queue management hook
import { useState, useEffect } from "react";
import { queueManagementService } from "@/services/queue/queueManagementService";
import { QueueManagementFormData } from "@/schemas/queueSchemas";

export function useQueueManagement() {
  const [queues, setQueues] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const createQueue = async (data: QueueManagementFormData) => {
    setIsLoading(true);
    setError(null);
    try {
      const newQueue = await queueManagementService.createQueue(data);
      setQueues((prev) => [...prev, newQueue]);
      return { success: true, queue: newQueue };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const updateQueue = async (id: string, data: QueueManagementFormData) => {
    setIsLoading(true);
    setError(null);
    try {
      const updatedQueue = await queueManagementService.updateQueue(id, data);
      setQueues((prev) =>
        prev.map((queue) => (queue.id === id ? updatedQueue : queue))
      );
      return { success: true, queue: updatedQueue };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const deleteQueue = async (id: string) => {
    setIsLoading(true);
    setError(null);
    try {
      await queueManagementService.deleteQueue(id);
      setQueues((prev) => prev.filter((queue) => queue.id !== id));
      return { success: true };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getQueues = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const queuesData = await queueManagementService.getQueues();
      setQueues(queuesData);
      return { success: true, queues: queuesData };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getQueue = async (id: string) => {
    setIsLoading(true);
    setError(null);
    try {
      const queue = await queueManagementService.getQueue(id);
      return { success: true, queue };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const joinQueue = async (queueId: string, userId: string) => {
    setIsLoading(true);
    setError(null);
    try {
      const result = await queueManagementService.joinQueue(queueId, userId);
      return { success: true, result };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const leaveQueue = async (queueId: string, userId: string) => {
    setIsLoading(true);
    setError(null);
    try {
      const result = await queueManagementService.leaveQueue(queueId, userId);
      return { success: true, result };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const promoteUser = async (
    queueId: string,
    userId: string,
    promotionType: string
  ) => {
    setIsLoading(true);
    setError(null);
    try {
      const result = await queueManagementService.promoteUser(
        queueId,
        userId,
        promotionType
      );
      return { success: true, result };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    getQueues();
  }, []);

  return {
    queues,
    isLoading,
    error,
    createQueue,
    updateQueue,
    deleteQueue,
    getQueues,
    getQueue,
    joinQueue,
    leaveQueue,
    promoteUser,
    clearError: () => setError(null),
  };
}
```

### src/components/queue/QueuePositionDisplay.tsx

```typescript
// Queue position display component
import { useState, useEffect } from "react";
import { useQueueManagement } from "@/hooks/useQueueManagement";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Clock, Users, TrendingUp, AlertCircle } from "lucide-react";

interface QueuePositionDisplayProps {
  queueId: string;
  userId: string;
  onJoinQueue?: () => void;
  onLeaveQueue?: () => void;
}

export function QueuePositionDisplay({
  queueId,
  userId,
  onJoinQueue,
  onLeaveQueue,
}: QueuePositionDisplayProps) {
  const { getQueue, joinQueue, leaveQueue, isLoading, error } =
    useQueueManagement();
  const [queueData, setQueueData] = useState(null);
  const [userPosition, setUserPosition] = useState(null);
  const [estimatedWaitTime, setEstimatedWaitTime] = useState(0);
  const [isInQueue, setIsInQueue] = useState(false);

  useEffect(() => {
    const loadQueueData = async () => {
      const result = await getQueue(queueId);
      if (result.success) {
        setQueueData(result.queue);
        // Check if user is in queue
        const userInQueue = result.queue.queuePositions?.find(
          (pos) => pos.userId === userId
        );
        if (userInQueue) {
          setUserPosition(userInQueue);
          setIsInQueue(true);
          setEstimatedWaitTime(userInQueue.estimatedWaitTime);
        }
      }
    };

    loadQueueData();

    // Refresh queue data every 30 seconds
    const interval = setInterval(loadQueueData, 30000);
    return () => clearInterval(interval);
  }, [queueId, userId]);

  const handleJoinQueue = async () => {
    const result = await joinQueue(queueId, userId);
    if (result.success) {
      setIsInQueue(true);
      setUserPosition(result.result.position);
      setEstimatedWaitTime(result.result.estimatedWaitTime);
      onJoinQueue?.();
    }
  };

  const handleLeaveQueue = async () => {
    const result = await leaveQueue(queueId, userId);
    if (result.success) {
      setIsInQueue(false);
      setUserPosition(null);
      setEstimatedWaitTime(0);
      onLeaveQueue?.();
    }
  };

  if (isLoading) {
    return (
      <Card className="w-full">
        <CardContent className="p-6">
          <div className="flex items-center justify-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            <span className="ml-2">Memuat data queue...</span>
          </div>
        </CardContent>
      </Card>
    );
  }

  if (error) {
    return (
      <Card className="w-full">
        <CardContent className="p-6">
          <div className="text-center text-red-500">
            <AlertCircle className="h-8 w-8 mx-auto mb-2" />
            <p>Error: {error}</p>
          </div>
        </CardContent>
      </Card>
    );
  }

  if (!queueData) {
    return (
      <Card className="w-full">
        <CardContent className="p-6">
          <div className="text-center text-gray-500">
            <p>Queue tidak ditemukan</p>
          </div>
        </CardContent>
      </Card>
    );
  }

  const queueUtilization =
    (queueData.currentQueueLength / queueData.maxQueueLength) * 100;
  const isQueueFull = queueData.currentQueueLength >= queueData.maxQueueLength;

  return (
    <Card className="w-full">
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg">{queueData.name}</CardTitle>
          <Badge
            variant={
              isQueueFull
                ? "destructive"
                : queueUtilization > 80
                ? "secondary"
                : "default"
            }
          >
            {isQueueFull
              ? "Penuh"
              : `${queueData.currentQueueLength}/${queueData.maxQueueLength}`}
          </Badge>
        </div>
        {queueData.description && (
          <p className="text-sm text-gray-500">{queueData.description}</p>
        )}
      </CardHeader>
      <CardContent className="space-y-4">
        {/* Queue Status */}
        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <span className="text-sm font-medium">Status Queue:</span>
            <Badge variant={queueData.isActive ? "default" : "secondary"}>
              {queueData.isActive ? "Aktif" : "Tidak Aktif"}
            </Badge>
          </div>

          <div className="space-y-1">
            <div className="flex items-center justify-between text-sm">
              <span>Kapasitas Queue:</span>
              <span>
                {queueData.currentQueueLength} / {queueData.maxQueueLength}
              </span>
            </div>
            <Progress value={queueUtilization} className="h-2" />
          </div>
        </div>

        {/* User Position */}
        {isInQueue && userPosition && (
          <div className="bg-blue-50 p-4 rounded-lg space-y-2">
            <div className="flex items-center">
              <Users className="h-5 w-5 text-blue-600 mr-2" />
              <span className="font-medium text-blue-800">
                Posisi Anda dalam Queue
              </span>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="text-center">
                <div className="text-2xl font-bold text-blue-600">
                  {userPosition.position}
                </div>
                <div className="text-sm text-blue-600">Posisi</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-blue-600">
                  {Math.floor(estimatedWaitTime / 60)}m
                </div>
                <div className="text-sm text-blue-600">Estimasi Waktu</div>
              </div>
            </div>
            <div className="flex items-center text-sm text-blue-600">
              <Clock className="h-4 w-4 mr-1" />
              <span>
                Bergabung: {new Date(userPosition.joinedAt).toLocaleString()}
              </span>
            </div>
          </div>
        )}

        {/* Queue Actions */}
        <div className="space-y-2">
          {isInQueue ? (
            <div className="space-y-2">
              <Button
                onClick={handleLeaveQueue}
                variant="outline"
                className="w-full"
              >
                Keluar dari Queue
              </Button>
              <p className="text-xs text-gray-500 text-center">
                Anda dapat keluar dari queue kapan saja
              </p>
            </div>
          ) : (
            <div className="space-y-2">
              <Button
                onClick={handleJoinQueue}
                disabled={isQueueFull || !queueData.isActive}
                className="w-full"
              >
                {isQueueFull ? "Queue Penuh" : "Bergabung ke Queue"}
              </Button>
              {isQueueFull && (
                <p className="text-xs text-red-500 text-center">
                  Queue sudah penuh, silakan coba lagi nanti
                </p>
              )}
              {!queueData.isActive && (
                <p className="text-xs text-gray-500 text-center">
                  Queue sedang tidak aktif
                </p>
              )}
            </div>
          )}
        </div>

        {/* Queue Statistics */}
        <div className="grid grid-cols-2 gap-4 pt-4 border-t">
          <div className="text-center">
            <div className="text-lg font-semibold text-gray-700">
              {queueData.currentQueueLength}
            </div>
            <div className="text-sm text-gray-500">Total dalam Queue</div>
          </div>
          <div className="text-center">
            <div className="text-lg font-semibold text-gray-700">
              {queueData.autoPromotion ? "Aktif" : "Tidak Aktif"}
            </div>
            <div className="text-sm text-gray-500">Auto Promosi</div>
          </div>
        </div>

        {/* Queue Notifications */}
        {queueData.notifications && (
          <div className="space-y-2">
            <h4 className="font-medium text-sm">Notifikasi:</h4>
            <div className="space-y-1">
              {queueData.notifications.enablePositionUpdates && (
                <div className="flex items-center text-sm text-gray-600">
                  <TrendingUp className="h-4 w-4 mr-2" />
                  <span>Update posisi otomatis</span>
                </div>
              )}
              {queueData.notifications.enablePromotionNotifications && (
                <div className="flex items-center text-sm text-gray-600">
                  <TrendingUp className="h-4 w-4 mr-2" />
                  <span>Notifikasi promosi</span>
                </div>
              )}
              {queueData.notifications.enableWaitTimeEstimates && (
                <div className="flex items-center text-sm text-gray-600">
                  <Clock className="h-4 w-4 mr-2" />
                  <span>Estimasi waktu tunggu</span>
                </div>
              )}
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  );
}
```

## 🛠️ Development Commands

### Queue Management Development

```bash
# Start development server
npm run dev

# Test queue management components
npm run test -- --testPathPattern=queue-management

# Test queue management forms
npm run test -- --testPathPattern=queue-management-forms
```

### Queue Management Testing

```bash
# Test queue management functionality
npm run test src/components/queue

# Test queue management hooks
npm run test src/hooks/useQueueManagement

# Test queue management services
npm run test src/services/queue
```

## 🎨 UI Implementation

### Queue Management Styling

```bash
# Create queue management styles
mkdir -p src/styles/queue
touch src/styles/queue/queueManagement.css
touch src/styles/queue/queuePosition.css
```

**Style Features:**

- Queue management form styling
- Queue position display styling
- Queue promotion styling
- Queue analytics styling

### Queue Management Layout

```bash
# Create queue management layout
touch src/components/queue/QueueLayout.tsx
touch src/components/queue/QueueSidebar.tsx
```

**Layout Features:**

- Queue management page layout
- Queue management sidebar navigation
- Queue management content area
- Responsive design

## 🔧 Integration Points

### API Integration

```bash
# Create queue management API service
touch src/services/api/queueManagementApi.ts
touch src/services/api/queuePositionApi.ts
```

**API Features:**

- Queue management API integration
- Queue position API integration
- Queue promotion API integration
- Queue analytics API integration

### State Management

```bash
# Create queue management state management
touch src/store/queue/queueManagementStore.ts
touch src/store/queue/queueManagementActions.ts
```

**State Features:**

- Queue management state management
- Queue position state management
- Queue promotion state management
- Queue analytics state management

## 🧪 Testing Strategy

### Unit Tests

```bash
# Test queue management components
mkdir -p src/components/queue/__tests__
touch src/components/queue/__tests__/QueuePositionDisplay.test.tsx
touch src/components/queue/__tests__/QueueStatusTracker.test.tsx
```

**Test Coverage:**

- Queue position display rendering
- Queue status tracking functionality
- Queue promotion functionality
- Queue analytics functionality

### Integration Tests

```bash
# Test queue management integration
mkdir -p src/__tests__/integration
touch src/__tests__/integration/queue-management.test.tsx
```

**Integration Tests:**

- Complete queue management workflow
- API integration
- State management integration
- Queue position integration

## 📱 Mobile Considerations

### Mobile Queue Management

```bash
# Mobile queue management components
touch src/components/queue/mobile/MobileQueuePositionDisplay.tsx
touch src/components/queue/mobile/MobileQueueStatusTracker.tsx
```

**Mobile Features:**

- Mobile-optimized queue position display
- Mobile queue status tracking
- Touch-friendly interface
- Mobile queue management

### Performance Optimization

```bash
# Queue management performance optimization
touch src/hooks/useQueueManagementPerformance.ts
```

**Optimizations:**

- Queue position display optimization
- Queue status tracking optimization
- Queue promotion optimization
- API call optimization

## 🔒 Security Considerations

### Queue Management Security

```bash
# Queue management security utilities
touch src/utils/queueManagementSecurity.ts
touch src/utils/queueManagementValidation.ts
```

**Security Features:**

- Queue position validation
- Queue status validation
- Queue promotion validation
- Queue analytics validation

### Data Protection

```bash
# Data protection utilities
touch src/utils/queueManagementDataProtection.ts
touch src/utils/queueManagementPrivacy.ts
```

**Protection Features:**

- Queue management data protection
- Queue position data protection
- Sensitive queue data masking
- Privacy compliance

## 📊 Analytics & Monitoring

### Queue Management Analytics

```bash
# Queue management analytics
touch src/utils/queueManagementAnalytics.ts
touch src/hooks/useQueueManagementAnalytics.ts
```

**Analytics Features:**

- Queue management usage tracking
- Queue position analytics
- Queue promotion analytics
- Queue performance analytics

### Error Monitoring

```bash
# Error monitoring untuk queue management
touch src/utils/queueManagementErrorMonitoring.ts
touch src/hooks/useQueueManagementErrorMonitoring.ts
```

**Monitoring Features:**

- Queue management error tracking
- Queue position error monitoring
- Queue promotion error monitoring
- API error monitoring

## ✅ Success Criteria

- [ ] Queue position monitoring berfungsi
- [ ] Queue status tracking implemented
- [ ] Queue promotion management berfungsi
- [ ] Queue analytics dan reporting implemented
- [ ] Queue performance metrics berfungsi
- [ ] Queue optimization implemented
- [ ] Queue management forms dengan proper validation
- [ ] Queue management hooks dengan error handling
- [ ] Queue management API integration
- [ ] Unit tests untuk queue management components
- [ ] Integration tests untuk queue management workflow
- [ ] Security measures untuk queue management data
- [ ] Data protection untuk sensitive queue information
- [ ] Analytics tracking untuk queue management usage
- [ ] Error monitoring dan alerting
- [ ] Performance optimization untuk queue management
- [ ] Mobile-responsive queue management interface
- [ ] Accessibility features maintained
- [ ] Queue management system health monitoring
- [ ] Queue management system documentation dan user guides

## 📝 Notes

- Pastikan queue management aman dan tidak vulnerable
- Implementasi proper validation untuk semua queue inputs
- Setup proper error handling untuk queue management operations
- Test queue management system dengan various scenarios
- Consider implementing queue management backup strategies
- Implementasi queue management system reporting features
- Consider adding queue management notifications
- Implementasi queue management system health monitoring
- Add queue management system documentation dan training materials
