# Member Expiry Tracking Implementation

## 📋 Overview

Implementasi member expiry tracking interface dengan expiry monitoring, expiry warnings, dan auto-deactivation system untuk Raujan Pool Syariah frontend.

## 🎯 Objectives

- Member expiry monitoring
- Expiry warning system
- Auto-deactivation system
- Member reactivation process
- Expiry analytics dan reporting
- Expiry optimization

## 🔧 Implementation Steps

### Step 1: Create Member Expiry Components

```bash
# Create member expiry components
mkdir -p src/components/member-expiry
touch src/components/member-expiry/ExpiryTracking.tsx
touch src/components/member-expiry/ExpiryWarnings.tsx
touch src/components/member-expiry/AutoDeactivation.tsx
touch src/components/member-expiry/MemberReactivation.tsx
```

**Component Structure:**

- `ExpiryTracking` - Member expiry tracking interface
- `ExpiryWarnings` - Expiry warning system
- `AutoDeactivation` - Auto-deactivation system
- `MemberReactivation` - Member reactivation process

### Step 2: Setup Member Expiry Validation

```bash
# Create member expiry validation schemas
mkdir -p src/schemas/member-expiry
touch src/schemas/memberExpirySchemas.ts
touch src/schemas/memberExpiryValidation.ts
```

**Validation Features:**

- Member expiry validation
- Expiry warning validation
- Auto-deactivation validation
- Member reactivation validation

### Step 3: Create Member Expiry Pages

```bash
# Create member expiry pages
mkdir -p src/pages/member-expiry
touch src/pages/member-expiry/ExpiryTrackingPage.tsx
touch src/pages/member-expiry/ExpiryWarningsPage.tsx
touch src/pages/member-expiry/AutoDeactivationPage.tsx
touch src/pages/member-expiry/MemberReactivationPage.tsx
```

**Page Structure:**

- `ExpiryTrackingPage` - Main expiry tracking page
- `ExpiryWarningsPage` - Expiry warnings page
- `AutoDeactivationPage` - Auto-deactivation page
- `MemberReactivationPage` - Member reactivation page

### Step 4: Setup Member Expiry Hooks

```bash
# Create member expiry hooks
touch src/hooks/useMemberExpiry.ts
touch src/hooks/useExpiryWarnings.ts
touch src/hooks/useAutoDeactivation.ts
touch src/hooks/useMemberReactivation.ts
```

**Hook Features:**

- Member expiry management
- Expiry warning management
- Auto-deactivation management
- Member reactivation management

### Step 5: Create Member Expiry Services

```bash
# Create member expiry services
mkdir -p src/services/member-expiry
touch src/services/member-expiry/memberExpiryService.ts
touch src/services/member-expiry/expiryWarningsService.ts
touch src/services/member-expiry/autoDeactivationService.ts
```

**Service Features:**

- Member expiry API service
- Expiry warning API service
- Auto-deactivation API service
- Member reactivation API service

## 📊 Configuration Files

### src/schemas/memberExpirySchemas.ts

```typescript
// Member expiry validation schemas
import { z } from "zod";

export const memberExpirySchema = z.object({
  memberId: z.string().min(1, "Member ID diperlukan"),
  membershipType: z.enum(["monthly", "quarterly"]),
  startDate: z.string().min(1, "Start date diperlukan"),
  endDate: z.string().min(1, "End date diperlukan"),
  status: z
    .enum(["active", "expired", "suspended", "cancelled"])
    .default("active"),
  gracePeriodDays: z
    .number()
    .min(0, "Grace period tidak boleh negatif")
    .default(30),
  warningPeriodDays: z
    .number()
    .min(0, "Warning period tidak boleh negatif")
    .default(7),
  lastWarningSent: z.string().optional(),
  autoDeactivationDate: z.string().optional(),
  reactivationDate: z.string().optional(),
  metadata: z
    .object({
      originalEndDate: z.string().optional(),
      extensionCount: z.number().min(0).default(0),
      totalExtensions: z.number().min(0).default(0),
      lastPaymentDate: z.string().optional(),
      paymentStatus: z
        .enum(["paid", "pending", "failed", "refunded"])
        .optional(),
    })
    .optional(),
});

export const expiryWarningSchema = z.object({
  memberId: z.string().min(1, "Member ID diperlukan"),
  warningType: z.enum([
    "expiry_reminder",
    "grace_period",
    "final_warning",
    "deactivation_notice",
  ]),
  warningDate: z.string().min(1, "Warning date diperlukan"),
  expiryDate: z.string().min(1, "Expiry date diperlukan"),
  daysUntilExpiry: z.number().min(0, "Days until expiry tidak boleh negatif"),
  isSent: z.boolean().default(false),
  sentAt: z.string().optional(),
  sentVia: z
    .array(z.enum(["email", "sms", "push", "in_app"]))
    .default(["email"]),
  message: z.string().optional(),
  actions: z
    .array(z.enum(["renew", "extend", "contact_support", "view_details"]))
    .default(["renew"]),
});

export const autoDeactivationSchema = z.object({
  memberId: z.string().min(1, "Member ID diperlukan"),
  deactivationDate: z.string().min(1, "Deactivation date diperlukan"),
  deactivationReason: z
    .enum(["expiry", "non_payment", "violation", "manual"])
    .default("expiry"),
  gracePeriodUsed: z.boolean().default(false),
  warningSent: z.boolean().default(false),
  isReversible: z.boolean().default(true),
  reversibleUntil: z.string().optional(),
  metadata: z
    .object({
      originalExpiryDate: z.string().optional(),
      gracePeriodDays: z.number().min(0).optional(),
      warningCount: z.number().min(0).default(0),
      lastActivityDate: z.string().optional(),
      totalUsage: z.number().min(0).default(0),
    })
    .optional(),
});

export const memberReactivationSchema = z.object({
  memberId: z.string().min(1, "Member ID diperlukan"),
  reactivationDate: z.string().min(1, "Reactivation date diperlukan"),
  reactivationReason: z
    .enum(["payment", "manual", "appeal", "extension"])
    .default("payment"),
  newEndDate: z.string().min(1, "New end date diperlukan"),
  paymentAmount: z
    .number()
    .min(0, "Payment amount tidak boleh negatif")
    .optional(),
  paymentMethod: z
    .enum(["credit_card", "bank_transfer", "cash", "qr_payment"])
    .optional(),
  isActive: z.boolean().default(true),
  metadata: z
    .object({
      originalExpiryDate: z.string().optional(),
      deactivationDate: z.string().optional(),
      daysInactive: z.number().min(0).default(0),
      reactivationFee: z.number().min(0).default(0),
      notes: z.string().optional(),
    })
    .optional(),
});

export const expiryAnalyticsSchema = z.object({
  dateRange: z.object({
    startDate: z.string().min(1, "Tanggal mulai diperlukan"),
    endDate: z.string().min(1, "Tanggal berakhir diperlukan"),
  }),
  metrics: z
    .array(
      z.enum([
        "total_expirations",
        "expired_members",
        "reactivated_members",
        "grace_period_usage",
        "warning_sent_count",
        "auto_deactivations",
        "manual_deactivations",
        "renewal_rate",
        "retention_rate",
      ])
    )
    .default(["total_expirations", "expired_members"]),
  groupBy: z.enum(["day", "week", "month", "quarter"]).default("day"),
  filters: z
    .object({
      membershipType: z.enum(["monthly", "quarterly"]).optional(),
      status: z
        .enum(["active", "expired", "suspended", "cancelled"])
        .optional(),
      warningType: z
        .enum([
          "expiry_reminder",
          "grace_period",
          "final_warning",
          "deactivation_notice",
        ])
        .optional(),
    })
    .optional(),
});

export type MemberExpiryFormData = z.infer<typeof memberExpirySchema>;
export type ExpiryWarningFormData = z.infer<typeof expiryWarningSchema>;
export type AutoDeactivationFormData = z.infer<typeof autoDeactivationSchema>;
export type MemberReactivationFormData = z.infer<
  typeof memberReactivationSchema
>;
export type ExpiryAnalyticsFormData = z.infer<typeof expiryAnalyticsSchema>;
```

### src/hooks/useMemberExpiry.ts

```typescript
// Member expiry hook
import { useState, useEffect } from "react";
import { memberExpiryService } from "@/services/member-expiry/memberExpiryService";
import { MemberExpiryFormData } from "@/schemas/memberExpirySchemas";

export function useMemberExpiry() {
  const [memberExpiries, setMemberExpiries] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const createMemberExpiry = async (data: MemberExpiryFormData) => {
    setIsLoading(true);
    setError(null);
    try {
      const newExpiry = await memberExpiryService.createMemberExpiry(data);
      setMemberExpiries((prev) => [...prev, newExpiry]);
      return { success: true, expiry: newExpiry };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const updateMemberExpiry = async (id: string, data: MemberExpiryFormData) => {
    setIsLoading(true);
    setError(null);
    try {
      const updatedExpiry = await memberExpiryService.updateMemberExpiry(
        id,
        data
      );
      setMemberExpiries((prev) =>
        prev.map((expiry) => (expiry.id === id ? updatedExpiry : expiry))
      );
      return { success: true, expiry: updatedExpiry };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const deleteMemberExpiry = async (id: string) => {
    setIsLoading(true);
    setError(null);
    try {
      await memberExpiryService.deleteMemberExpiry(id);
      setMemberExpiries((prev) => prev.filter((expiry) => expiry.id !== id));
      return { success: true };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getMemberExpiries = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const expiries = await memberExpiryService.getMemberExpiries();
      setMemberExpiries(expiries);
      return { success: true, expiries };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getMemberExpiry = async (id: string) => {
    setIsLoading(true);
    setError(null);
    try {
      const expiry = await memberExpiryService.getMemberExpiry(id);
      return { success: true, expiry };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getExpiringMembers = async (days: number = 30) => {
    setIsLoading(true);
    setError(null);
    try {
      const expiringMembers = await memberExpiryService.getExpiringMembers(
        days
      );
      return { success: true, expiringMembers };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getExpiredMembers = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const expiredMembers = await memberExpiryService.getExpiredMembers();
      return { success: true, expiredMembers };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const extendMembership = async (memberId: string, extensionDays: number) => {
    setIsLoading(true);
    setError(null);
    try {
      const result = await memberExpiryService.extendMembership(
        memberId,
        extensionDays
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
    getMemberExpiries();
  }, []);

  return {
    memberExpiries,
    isLoading,
    error,
    createMemberExpiry,
    updateMemberExpiry,
    deleteMemberExpiry,
    getMemberExpiries,
    getMemberExpiry,
    getExpiringMembers,
    getExpiredMembers,
    extendMembership,
    clearError: () => setError(null),
  };
}
```

### src/components/member-expiry/ExpiryTracking.tsx

```typescript
// Member expiry tracking component
import { useState, useEffect } from "react";
import { useMemberExpiry } from "@/hooks/useMemberExpiry";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import {
  Calendar,
  Clock,
  AlertTriangle,
  CheckCircle,
  XCircle,
} from "lucide-react";

interface ExpiryTrackingProps {
  memberId: string;
  onExtendMembership?: (memberId: string, days: number) => void;
  onViewDetails?: (memberId: string) => void;
}

export function ExpiryTracking({
  memberId,
  onExtendMembership,
  onViewDetails,
}: ExpiryTrackingProps) {
  const { getMemberExpiry, extendMembership, isLoading, error } =
    useMemberExpiry();
  const [expiryData, setExpiryData] = useState(null);
  const [daysUntilExpiry, setDaysUntilExpiry] = useState(0);
  const [isExpired, setIsExpired] = useState(false);
  const [isInGracePeriod, setIsInGracePeriod] = useState(false);
  const [isInWarningPeriod, setIsInWarningPeriod] = useState(false);

  useEffect(() => {
    const loadExpiryData = async () => {
      const result = await getMemberExpiry(memberId);
      if (result.success) {
        setExpiryData(result.expiry);
        calculateExpiryStatus(result.expiry);
      }
    };

    loadExpiryData();
  }, [memberId]);

  const calculateExpiryStatus = (expiry: any) => {
    const now = new Date();
    const endDate = new Date(expiry.endDate);
    const daysDiff = Math.ceil(
      (endDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24)
    );

    setDaysUntilExpiry(daysDiff);
    setIsExpired(daysDiff < 0);
    setIsInGracePeriod(daysDiff < 0 && daysDiff >= -expiry.gracePeriodDays);
    setIsInWarningPeriod(daysDiff <= expiry.warningPeriodDays && daysDiff > 0);
  };

  const handleExtendMembership = async (days: number) => {
    const result = await extendMembership(memberId, days);
    if (result.success) {
      // Reload expiry data
      const updatedResult = await getMemberExpiry(memberId);
      if (updatedResult.success) {
        setExpiryData(updatedResult.expiry);
        calculateExpiryStatus(updatedResult.expiry);
      }
      onExtendMembership?.(memberId, days);
    }
  };

  if (isLoading) {
    return (
      <Card className="w-full">
        <CardContent className="p-6">
          <div className="flex items-center justify-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            <span className="ml-2">Memuat data expiry...</span>
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
            <XCircle className="h-8 w-8 mx-auto mb-2" />
            <p>Error: {error}</p>
          </div>
        </CardContent>
      </Card>
    );
  }

  if (!expiryData) {
    return (
      <Card className="w-full">
        <CardContent className="p-6">
          <div className="text-center text-gray-500">
            <p>Data expiry tidak ditemukan</p>
          </div>
        </CardContent>
      </Card>
    );
  }

  const getStatusColor = () => {
    if (isExpired && !isInGracePeriod) return "destructive";
    if (isExpired && isInGracePeriod) return "secondary";
    if (isInWarningPeriod) return "default";
    return "default";
  };

  const getStatusText = () => {
    if (isExpired && !isInGracePeriod) return "Expired";
    if (isExpired && isInGracePeriod) return "Grace Period";
    if (isInWarningPeriod) return "Expiring Soon";
    return "Active";
  };

  const getStatusIcon = () => {
    if (isExpired && !isInGracePeriod) return <XCircle className="h-4 w-4" />;
    if (isExpired && isInGracePeriod)
      return <AlertTriangle className="h-4 w-4" />;
    if (isInWarningPeriod) return <AlertTriangle className="h-4 w-4" />;
    return <CheckCircle className="h-4 w-4" />;
  };

  const membershipDuration = Math.ceil(
    (new Date(expiryData.endDate).getTime() -
      new Date(expiryData.startDate).getTime()) /
      (1000 * 60 * 60 * 24)
  );

  const membershipProgress = Math.max(
    0,
    Math.min(
      100,
      ((membershipDuration - daysUntilExpiry) / membershipDuration) * 100
    )
  );

  return (
    <Card className="w-full">
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg">Status Membership</CardTitle>
          <Badge variant={getStatusColor()}>
            {getStatusIcon()}
            <span className="ml-1">{getStatusText()}</span>
          </Badge>
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        {/* Membership Info */}
        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <span className="text-sm font-medium">Jenis Membership:</span>
            <Badge variant="outline">
              {expiryData.membershipType === "monthly" ? "Bulanan" : "Triwulan"}
            </Badge>
          </div>

          <div className="flex items-center justify-between">
            <span className="text-sm font-medium">Tanggal Mulai:</span>
            <span className="text-sm text-gray-600">
              {new Date(expiryData.startDate).toLocaleDateString()}
            </span>
          </div>

          <div className="flex items-center justify-between">
            <span className="text-sm font-medium">Tanggal Berakhir:</span>
            <span className="text-sm text-gray-600">
              {new Date(expiryData.endDate).toLocaleDateString()}
            </span>
          </div>
        </div>

        {/* Progress Bar */}
        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <span className="text-sm font-medium">Progress Membership:</span>
            <span className="text-sm text-gray-600">
              {membershipProgress.toFixed(0)}%
            </span>
          </div>
          <Progress value={membershipProgress} className="h-2" />
        </div>

        {/* Days Until Expiry */}
        <div className="bg-blue-50 p-4 rounded-lg">
          <div className="flex items-center">
            <Clock className="h-5 w-5 text-blue-600 mr-2" />
            <span className="font-medium text-blue-800">
              Hari Hingga Berakhir:
            </span>
          </div>
          <div className="text-2xl font-bold text-blue-600 mt-1">
            {isExpired ? Math.abs(daysUntilExpiry) : daysUntilExpiry} hari
          </div>
          {isExpired && (
            <p className="text-sm text-blue-600 mt-1">
              {isInGracePeriod ? "Dalam masa tenggang" : "Sudah berakhir"}
            </p>
          )}
        </div>

        {/* Grace Period Info */}
        {isInGracePeriod && (
          <div className="bg-yellow-50 p-4 rounded-lg">
            <div className="flex items-center">
              <AlertTriangle className="h-5 w-5 text-yellow-600 mr-2" />
              <span className="font-medium text-yellow-800">Masa Tenggang</span>
            </div>
            <p className="text-sm text-yellow-600 mt-1">
              Anda memiliki {expiryData.gracePeriodDays} hari untuk
              memperpanjang membership
            </p>
          </div>
        )}

        {/* Warning Period Info */}
        {isInWarningPeriod && !isExpired && (
          <div className="bg-orange-50 p-4 rounded-lg">
            <div className="flex items-center">
              <AlertTriangle className="h-5 w-5 text-orange-600 mr-2" />
              <span className="font-medium text-orange-800">Peringatan</span>
            </div>
            <p className="text-sm text-orange-600 mt-1">
              Membership akan berakhir dalam {daysUntilExpiry} hari
            </p>
          </div>
        )}

        {/* Actions */}
        <div className="space-y-2">
          {!isExpired && (
            <div className="grid grid-cols-2 gap-2">
              <Button
                onClick={() => handleExtendMembership(30)}
                variant="outline"
                size="sm"
              >
                Perpanjang 30 Hari
              </Button>
              <Button
                onClick={() => handleExtendMembership(90)}
                variant="outline"
                size="sm"
              >
                Perpanjang 90 Hari
              </Button>
            </div>
          )}

          {isExpired && isInGracePeriod && (
            <Button
              onClick={() => handleExtendMembership(30)}
              className="w-full"
            >
              Perpanjang Membership
            </Button>
          )}

          <Button
            onClick={() => onViewDetails?.(memberId)}
            variant="outline"
            className="w-full"
          >
            Lihat Detail
          </Button>
        </div>

        {/* Metadata */}
        {expiryData.metadata && (
          <div className="space-y-2 pt-4 border-t">
            <h4 className="font-medium text-sm">Informasi Tambahan:</h4>
            <div className="grid grid-cols-2 gap-2 text-sm">
              <div>
                <span className="text-gray-600">Jumlah Perpanjangan:</span>
                <span className="ml-1 font-medium">
                  {expiryData.metadata.extensionCount}
                </span>
              </div>
              <div>
                <span className="text-gray-600">Total Perpanjangan:</span>
                <span className="ml-1 font-medium">
                  {expiryData.metadata.totalExtensions}
                </span>
              </div>
              {expiryData.metadata.lastPaymentDate && (
                <div className="col-span-2">
                  <span className="text-gray-600">Pembayaran Terakhir:</span>
                  <span className="ml-1 font-medium">
                    {new Date(
                      expiryData.metadata.lastPaymentDate
                    ).toLocaleDateString()}
                  </span>
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

### Member Expiry Development

```bash
# Start development server
npm run dev

# Test member expiry components
npm run test -- --testPathPattern=member-expiry

# Test member expiry forms
npm run test -- --testPathPattern=member-expiry-forms
```

### Member Expiry Testing

```bash
# Test member expiry functionality
npm run test src/components/member-expiry

# Test member expiry hooks
npm run test src/hooks/useMemberExpiry

# Test member expiry services
npm run test src/services/member-expiry
```

## 🎨 UI Implementation

### Member Expiry Styling

```bash
# Create member expiry styles
mkdir -p src/styles/member-expiry
touch src/styles/member-expiry/expiryTracking.css
touch src/styles/member-expiry/expiryWarnings.css
```

**Style Features:**

- Member expiry tracking styling
- Expiry warning styling
- Auto-deactivation styling
- Member reactivation styling

### Member Expiry Layout

```bash
# Create member expiry layout
touch src/components/member-expiry/ExpiryLayout.tsx
touch src/components/member-expiry/ExpirySidebar.tsx
```

**Layout Features:**

- Member expiry page layout
- Member expiry sidebar navigation
- Member expiry content area
- Responsive design

## 🔧 Integration Points

### API Integration

```bash
# Create member expiry API service
touch src/services/api/memberExpiryApi.ts
touch src/services/api/expiryWarningsApi.ts
```

**API Features:**

- Member expiry API integration
- Expiry warning API integration
- Auto-deactivation API integration
- Member reactivation API integration

### State Management

```bash
# Create member expiry state management
touch src/store/member-expiry/memberExpiryStore.ts
touch src/store/member-expiry/memberExpiryActions.ts
```

**State Features:**

- Member expiry state management
- Expiry warning state management
- Auto-deactivation state management
- Member reactivation state management

## 🧪 Testing Strategy

### Unit Tests

```bash
# Test member expiry components
mkdir -p src/components/member-expiry/__tests__
touch src/components/member-expiry/__tests__/ExpiryTracking.test.tsx
touch src/components/member-expiry/__tests__/ExpiryWarnings.test.tsx
```

**Test Coverage:**

- Member expiry tracking rendering
- Expiry warning functionality
- Auto-deactivation functionality
- Member reactivation functionality

### Integration Tests

```bash
# Test member expiry integration
mkdir -p src/__tests__/integration
touch src/__tests__/integration/member-expiry.test.tsx
```

**Integration Tests:**

- Complete member expiry workflow
- API integration
- State management integration
- Expiry warning integration

## 📱 Mobile Considerations

### Mobile Member Expiry

```bash
# Mobile member expiry components
touch src/components/member-expiry/mobile/MobileExpiryTracking.tsx
touch src/components/member-expiry/mobile/MobileExpiryWarnings.tsx
```

**Mobile Features:**

- Mobile-optimized expiry tracking
- Mobile expiry warnings
- Touch-friendly interface
- Mobile expiry management

### Performance Optimization

```bash
# Member expiry performance optimization
touch src/hooks/useMemberExpiryPerformance.ts
```

**Optimizations:**

- Member expiry tracking optimization
- Expiry warning optimization
- Auto-deactivation optimization
- API call optimization

## 🔒 Security Considerations

### Member Expiry Security

```bash
# Member expiry security utilities
touch src/utils/memberExpirySecurity.ts
touch src/utils/memberExpiryValidation.ts
```

**Security Features:**

- Member expiry validation
- Expiry warning validation
- Auto-deactivation validation
- Member reactivation validation

### Data Protection

```bash
# Data protection utilities
touch src/utils/memberExpiryDataProtection.ts
touch src/utils/memberExpiryPrivacy.ts
```

**Protection Features:**

- Member expiry data protection
- Expiry warning data protection
- Sensitive expiry data masking
- Privacy compliance

## 📊 Analytics & Monitoring

### Member Expiry Analytics

```bash
# Member expiry analytics
touch src/utils/memberExpiryAnalytics.ts
touch src/hooks/useMemberExpiryAnalytics.ts
```

**Analytics Features:**

- Member expiry usage tracking
- Expiry warning analytics
- Auto-deactivation analytics
- Member reactivation analytics

### Error Monitoring

```bash
# Error monitoring untuk member expiry
touch src/utils/memberExpiryErrorMonitoring.ts
touch src/hooks/useMemberExpiryErrorMonitoring.ts
```

**Monitoring Features:**

- Member expiry error tracking
- Expiry warning error monitoring
- Auto-deactivation error monitoring
- API error monitoring

## ✅ Success Criteria

- [ ] Member expiry monitoring berfungsi
- [ ] Expiry warning system implemented
- [ ] Auto-deactivation system berfungsi
- [ ] Member reactivation process implemented
- [ ] Expiry analytics dan reporting berfungsi
- [ ] Expiry optimization implemented
- [ ] Member expiry forms dengan proper validation
- [ ] Member expiry hooks dengan error handling
- [ ] Member expiry API integration
- [ ] Unit tests untuk member expiry components
- [ ] Integration tests untuk member expiry workflow
- [ ] Security measures untuk member expiry data
- [ ] Data protection untuk sensitive expiry information
- [ ] Analytics tracking untuk member expiry usage
- [ ] Error monitoring dan alerting
- [ ] Performance optimization untuk member expiry
- [ ] Mobile-responsive member expiry interface
- [ ] Accessibility features maintained
- [ ] Member expiry system health monitoring
- [ ] Member expiry system documentation dan user guides

## 📝 Notes

- Pastikan member expiry aman dan tidak vulnerable
- Implementasi proper validation untuk semua member expiry inputs
- Setup proper error handling untuk member expiry operations
- Test member expiry system dengan various scenarios
- Consider implementing member expiry backup strategies
- Implementasi member expiry system reporting features
- Consider adding member expiry notifications
- Implementasi member expiry system health monitoring
- Add member expiry system documentation dan training materials
