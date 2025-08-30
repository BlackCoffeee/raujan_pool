# Phase 5: Member Portal & Quota Management

## 📋 Overview

Implementasi member portal dengan quota management, queue monitoring, dan membership tracking interface.

## 🎯 Objectives

- Member dashboard interface
- Quota monitoring interface
- Queue status display
- Membership management
- Usage tracking display
- Member notifications

## 📁 Files Structure

```
phase-5/
├── 01-member-dashboard.md
├── 02-quota-monitoring.md
├── 03-queue-status.md
├── 04-membership-management.md
└── 05-usage-tracking.md
```

## 🔧 Implementation Points

### Point 1: Member Dashboard Interface

**Subpoints:**

- Dashboard layout
- Member profile display
- Quick stats overview
- Recent activities
- Notifications center
- Quick actions

**Files:**

- `components/member/Dashboard.tsx`
- `components/member/ProfileCard.tsx`
- `components/member/QuickStats.tsx`
- `components/member/RecentActivities.tsx`
- `hooks/useMemberDashboard.ts`
- `lib/dashboard-utils.ts`

### Point 2: Quota Monitoring Interface

**Subpoints:**

- Quota display component
- Quota usage chart
- Quota history tracking
- Quota alerts
- Quota renewal interface
- Quota analytics

**Files:**

- `components/member/QuotaMonitor.tsx`
- `components/member/QuotaChart.tsx`
- `components/member/QuotaHistory.tsx`
- `components/member/QuotaAlert.tsx`
- `hooks/useQuota.ts`
- `lib/quota-utils.ts`

### Point 3: Queue Status Display

**Subpoints:**

- Queue position display
- Queue timeline
- Queue notifications
- Queue status updates
- Queue acceptance interface
- Queue analytics

**Files:**

- `components/member/QueueStatus.tsx`
- `components/member/QueueTimeline.tsx`
- `components/member/QueueNotification.tsx`
- `components/member/QueueAcceptance.tsx`
- `hooks/useQueue.ts`
- `lib/queue-utils.ts`

### Point 4: Membership Management

**Subpoints:**

- Membership details
- Membership renewal
- Membership settings
- Membership benefits
- Membership history
- Membership analytics

**Files:**

- `components/member/MembershipDetails.tsx`
- `components/member/MembershipRenewal.tsx`
- `components/member/MembershipSettings.tsx`
- `components/member/MembershipBenefits.tsx`
- `hooks/useMembership.ts`
- `lib/membership-utils.ts`

### Point 5: Usage Tracking Display

**Subpoints:**

- Usage statistics
- Usage history
- Usage charts
- Usage alerts
- Usage limits
- Usage analytics

**Files:**

- `components/member/UsageStats.tsx`
- `components/member/UsageHistory.tsx`
- `components/member/UsageChart.tsx`
- `components/member/UsageAlert.tsx`
- `hooks/useUsage.ts`
- `lib/usage-utils.ts`

## 📦 Dependencies

### Member Portal Dependencies

```json
{
  "react-hook-form": "^7.48.0",
  "zod": "^3.22.0",
  "@hookform/resolvers": "^3.3.0",
  "recharts": "^2.8.0",
  "date-fns": "^2.30.0",
  "react-calendar": "^4.6.0"
}
```

### UI Dependencies

```json
{
  "@headlessui/react": "^1.7.0",
  "@heroicons/react": "^2.0.0",
  "clsx": "^2.0.0",
  "tailwind-merge": "^2.0.0",
  "lucide-react": "^0.294.0",
  "react-countup": "^6.4.0"
}
```

### State Management

```json
{
  "zustand": "^4.4.0",
  "react-query": "^3.39.0",
  "react-hot-toast": "^2.4.0"
}
```

## 🎨 Component Examples

### Member Dashboard Component

```typescript
import { useEffect, useState } from "react";
import { useMemberDashboard } from "@/hooks/useMemberDashboard";
import { ProfileCard } from "./ProfileCard";
import { QuickStats } from "./QuickStats";
import { RecentActivities } from "./RecentActivities";

export const MemberDashboard = () => {
  const { member, stats, activities, isLoading } = useMemberDashboard();

  if (isLoading) {
    return (
      <div className="animate-pulse space-y-6">
        <div className="h-64 bg-gray-200 rounded-lg"></div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {[1, 2, 3].map((i) => (
            <div key={i} className="h-24 bg-gray-200 rounded-lg"></div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Welcome Section */}
      <div className="bg-gradient-to-r from-blue-600 to-blue-800 rounded-lg p-6 text-white">
        <h1 className="text-2xl font-bold mb-2">
          Welcome back, {member?.user.name}!
        </h1>
        <p className="text-blue-100">
          Your membership is active until {member?.membership_end}
        </p>
      </div>

      {/* Quick Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <QuickStats
          title="Quota Remaining"
          value={stats.quota_remaining}
          total={stats.total_quota}
          icon="ticket"
          color="blue"
        />
        <QuickStats
          title="This Month Usage"
          value={stats.monthly_usage}
          total={stats.monthly_limit}
          icon="calendar"
          color="green"
        />
        <QuickStats
          title="Total Bookings"
          value={stats.total_bookings}
          total={null}
          icon="bookmark"
          color="purple"
        />
      </div>

      {/* Main Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Profile Card */}
        <div className="lg:col-span-1">
          <ProfileCard member={member} />
        </div>

        {/* Recent Activities */}
        <div className="lg:col-span-2">
          <RecentActivities activities={activities} />
        </div>
      </div>

      {/* Membership Status */}
      <div className="bg-white rounded-lg p-6 border">
        <h2 className="text-lg font-semibold mb-4">Membership Status</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="text-sm font-medium text-gray-600">
              Membership Type
            </label>
            <p className="text-lg font-semibold capitalize">
              {member?.membership_type}
            </p>
          </div>
          <div>
            <label className="text-sm font-medium text-gray-600">Status</label>
            <span
              className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                member?.status === "active"
                  ? "bg-green-100 text-green-800"
                  : "bg-red-100 text-red-800"
              }`}
            >
              {member?.status}
            </span>
          </div>
          <div>
            <label className="text-sm font-medium text-gray-600">
              Joined Date
            </label>
            <p className="text-lg">
              {new Date(member?.joined_date).toLocaleDateString()}
            </p>
          </div>
          <div>
            <label className="text-sm font-medium text-gray-600">
              Expiry Date
            </label>
            <p className="text-lg">
              {new Date(member?.membership_end).toLocaleDateString()}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};
```

### Quota Monitor Component

```typescript
import { useQuota } from "@/hooks/useQuota";
import { QuotaChart } from "./QuotaChart";
import { QuotaHistory } from "./QuotaHistory";

export const QuotaMonitor = () => {
  const { quota, history, isLoading } = useQuota();

  const getQuotaPercentage = () => {
    if (!quota) return 0;
    return (
      ((quota.total_quota - quota.remaining_quota) / quota.total_quota) * 100
    );
  };

  const getQuotaColor = (percentage: number) => {
    if (percentage >= 80) return "text-red-600";
    if (percentage >= 60) return "text-yellow-600";
    return "text-green-600";
  };

  if (isLoading) {
    return <div className="animate-pulse h-64 bg-gray-200 rounded-lg"></div>;
  }

  return (
    <div className="space-y-6">
      {/* Quota Overview */}
      <div className="bg-white rounded-lg p-6 border">
        <h3 className="text-lg font-semibold mb-4">Quota Overview</h3>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          <div className="text-center">
            <div className="text-2xl font-bold text-blue-600">
              {quota?.total_quota}
            </div>
            <div className="text-sm text-gray-600">Total Quota</div>
          </div>
          <div className="text-center">
            <div
              className={`text-2xl font-bold ${getQuotaColor(
                getQuotaPercentage()
              )}`}
            >
              {quota?.remaining_quota}
            </div>
            <div className="text-sm text-gray-600">Remaining</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-purple-600">
              {quota?.used_quota}
            </div>
            <div className="text-sm text-gray-600">Used</div>
          </div>
        </div>

        {/* Progress Bar */}
        <div className="mb-4">
          <div className="flex justify-between text-sm text-gray-600 mb-2">
            <span>Usage Progress</span>
            <span>{getQuotaPercentage().toFixed(1)}%</span>
          </div>
          <div className="w-full bg-gray-200 rounded-full h-2">
            <div
              className="bg-blue-600 h-2 rounded-full transition-all duration-300"
              style={{ width: `${getQuotaPercentage()}%` }}
            ></div>
          </div>
        </div>

        {/* Quota Alert */}
        {getQuotaPercentage() >= 80 && (
          <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
            <div className="flex items-center">
              <svg
                className="h-5 w-5 text-yellow-400 mr-2"
                fill="currentColor"
                viewBox="0 0 20 20"
              >
                <path
                  fillRule="evenodd"
                  d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z"
                  clipRule="evenodd"
                />
              </svg>
              <span className="text-yellow-800">
                You've used {getQuotaPercentage().toFixed(1)}% of your quota.
                Consider renewing your membership.
              </span>
            </div>
          </div>
        )}
      </div>

      {/* Quota Chart */}
      <div className="bg-white rounded-lg p-6 border">
        <h3 className="text-lg font-semibold mb-4">Usage Trends</h3>
        <QuotaChart history={history} />
      </div>

      {/* Quota History */}
      <div className="bg-white rounded-lg p-6 border">
        <h3 className="text-lg font-semibold mb-4">Recent Usage</h3>
        <QuotaHistory history={history} />
      </div>
    </div>
  );
};
```

### Queue Status Component

```typescript
import { useQueue } from "@/hooks/useQueue";
import { useState } from "react";

export const QueueStatus = () => {
  const { queueEntry, position, waitingCount, estimatedTime, isLoading } =
    useQueue();
  const [showAcceptanceModal, setShowAcceptanceModal] = useState(false);

  const formatWaitTime = (minutes: number) => {
    if (minutes < 60) return `${minutes} minutes`;
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return `${hours}h ${mins}m`;
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case "waiting":
        return "bg-yellow-100 text-yellow-800";
      case "offered":
        return "bg-blue-100 text-blue-800";
      case "accepted":
        return "bg-green-100 text-green-800";
      case "rejected":
        return "bg-red-100 text-red-800";
      default:
        return "bg-gray-100 text-gray-800";
    }
  };

  if (isLoading) {
    return <div className="animate-pulse h-32 bg-gray-200 rounded-lg"></div>;
  }

  if (!queueEntry) {
    return (
      <div className="bg-white rounded-lg p-6 border text-center">
        <h3 className="text-lg font-semibold mb-4">Membership Queue</h3>
        <p className="text-gray-600 mb-4">
          You are not currently in the membership queue.
        </p>
        <button
          onClick={() => joinQueue()}
          className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700"
        >
          Join Queue
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Queue Status */}
      <div className="bg-white rounded-lg p-6 border">
        <h3 className="text-lg font-semibold mb-4">Queue Status</h3>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
          <div>
            <label className="text-sm font-medium text-gray-600">
              Your Position
            </label>
            <div className="text-2xl font-bold text-blue-600">{position}</div>
          </div>
          <div>
            <label className="text-sm font-medium text-gray-600">Status</label>
            <span
              className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(
                queueEntry.status
              )}`}
            >
              {queueEntry.status}
            </span>
          </div>
          <div>
            <label className="text-sm font-medium text-gray-600">
              People Waiting
            </label>
            <div className="text-lg">{waitingCount}</div>
          </div>
          <div>
            <label className="text-sm font-medium text-gray-600">
              Estimated Wait
            </label>
            <div className="text-lg">{formatWaitTime(estimatedTime)}</div>
          </div>
        </div>

        {/* Queue Progress */}
        {queueEntry.status === "waiting" && (
          <div className="mb-4">
            <div className="flex justify-between text-sm text-gray-600 mb-2">
              <span>Queue Progress</span>
              <span>
                {((1 - position / (position + waitingCount)) * 100).toFixed(1)}%
              </span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div
                className="bg-blue-600 h-2 rounded-full transition-all duration-300"
                style={{
                  width: `${(1 - position / (position + waitingCount)) * 100}%`,
                }}
              ></div>
            </div>
          </div>
        )}

        {/* Action Buttons */}
        <div className="flex gap-2">
          {queueEntry.status === "waiting" && (
            <button
              onClick={() => leaveQueue()}
              className="bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700"
            >
              Leave Queue
            </button>
          )}

          {queueEntry.status === "offered" && (
            <>
              <button
                onClick={() => setShowAcceptanceModal(true)}
                className="bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700"
              >
                Accept Offer
              </button>
              <button
                onClick={() => rejectOffer()}
                className="bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700"
              >
                Reject Offer
              </button>
            </>
          )}
        </div>
      </div>

      {/* Queue Timeline */}
      <div className="bg-white rounded-lg p-6 border">
        <h3 className="text-lg font-semibold mb-4">Queue Timeline</h3>
        <div className="space-y-4">
          <div className="flex items-center space-x-3">
            <div className="w-3 h-3 rounded-full bg-green-500"></div>
            <div>
              <div className="font-medium">Joined Queue</div>
              <div className="text-sm text-gray-600">
                {new Date(queueEntry.applied_date).toLocaleDateString()}
              </div>
            </div>
          </div>

          {queueEntry.offered_date && (
            <div className="flex items-center space-x-3">
              <div className="w-3 h-3 rounded-full bg-blue-500"></div>
              <div>
                <div className="font-medium">Membership Offered</div>
                <div className="text-sm text-gray-600">
                  {new Date(queueEntry.offered_date).toLocaleDateString()}
                </div>
              </div>
            </div>
          )}

          {queueEntry.accepted_date && (
            <div className="flex items-center space-x-3">
              <div className="w-3 h-3 rounded-full bg-green-500"></div>
              <div>
                <div className="font-medium">Offer Accepted</div>
                <div className="text-sm text-gray-600">
                  {new Date(queueEntry.accepted_date).toLocaleDateString()}
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Acceptance Modal */}
      {showAcceptanceModal && (
        <QueueAcceptance
          queueEntry={queueEntry}
          onAccept={() => {
            acceptOffer();
            setShowAcceptanceModal(false);
          }}
          onClose={() => setShowAcceptanceModal(false)}
        />
      )}
    </div>
  );
};
```

### Usage Tracking Component

```typescript
import { useUsage } from "@/hooks/useUsage";
import { UsageChart } from "./UsageChart";

export const UsageTracking = () => {
  const { usage, stats, history, isLoading } = useUsage();

  const formatDate = (date: string) => {
    return new Date(date).toLocaleDateString("id-ID", {
      weekday: "short",
      month: "short",
      day: "numeric",
    });
  };

  if (isLoading) {
    return <div className="animate-pulse h-64 bg-gray-200 rounded-lg"></div>;
  }

  return (
    <div className="space-y-6">
      {/* Usage Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white rounded-lg p-6 border">
          <div className="flex items-center">
            <div className="p-2 bg-blue-100 rounded-lg">
              <svg
                className="w-6 h-6 text-blue-600"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"
                />
              </svg>
            </div>
            <div className="ml-4">
              <div className="text-sm font-medium text-gray-600">
                Today's Usage
              </div>
              <div className="text-2xl font-bold">
                {usage?.today_usage || 0}
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg p-6 border">
          <div className="flex items-center">
            <div className="p-2 bg-green-100 rounded-lg">
              <svg
                className="w-6 h-6 text-green-600"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
                />
              </svg>
            </div>
            <div className="ml-4">
              <div className="text-sm font-medium text-gray-600">This Week</div>
              <div className="text-2xl font-bold">{usage?.week_usage || 0}</div>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg p-6 border">
          <div className="flex items-center">
            <div className="p-2 bg-purple-100 rounded-lg">
              <svg
                className="w-6 h-6 text-purple-600"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
                />
              </svg>
            </div>
            <div className="ml-4">
              <div className="text-sm font-medium text-gray-600">
                This Month
              </div>
              <div className="text-2xl font-bold">
                {usage?.month_usage || 0}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Usage Chart */}
      <div className="bg-white rounded-lg p-6 border">
        <h3 className="text-lg font-semibold mb-4">Usage Trends</h3>
        <UsageChart history={history} />
      </div>

      {/* Usage History */}
      <div className="bg-white rounded-lg p-6 border">
        <h3 className="text-lg font-semibold mb-4">Recent Usage</h3>
        <div className="space-y-4">
          {history.map((entry, index) => (
            <div
              key={index}
              className="flex items-center justify-between p-4 border rounded-lg"
            >
              <div className="flex items-center space-x-4">
                <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                  <svg
                    className="w-5 h-5 text-blue-600"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
                    />
                  </svg>
                </div>
                <div>
                  <div className="font-medium">Swimming Session</div>
                  <div className="text-sm text-gray-600">
                    {formatDate(entry.date)}
                  </div>
                </div>
              </div>
              <div className="text-right">
                <div className="font-medium">
                  Session #{entry.session_number}
                </div>
                <div className="text-sm text-gray-600">
                  {entry.is_free ? "Free Session" : `Paid Session`}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Usage Limits */}
      <div className="bg-white rounded-lg p-6 border">
        <h3 className="text-lg font-semibold mb-4">Usage Limits</h3>
        <div className="space-y-4">
          <div>
            <div className="flex justify-between text-sm font-medium text-gray-600 mb-1">
              <span>Daily Limit</span>
              <span>{usage?.daily_limit || 1} session</span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div
                className="bg-blue-600 h-2 rounded-full"
                style={{
                  width: `${
                    ((usage?.today_usage || 0) / (usage?.daily_limit || 1)) *
                    100
                  }%`,
                }}
              ></div>
            </div>
          </div>

          <div>
            <div className="flex justify-between text-sm font-medium text-gray-600 mb-1">
              <span>Weekly Limit</span>
              <span>{usage?.weekly_limit || 7} sessions</span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div
                className="bg-green-600 h-2 rounded-full"
                style={{
                  width: `${
                    ((usage?.week_usage || 0) / (usage?.weekly_limit || 7)) *
                    100
                  }%`,
                }}
              ></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
```

## 📱 Mobile Optimization

### Responsive Member Dashboard

```typescript
export const ResponsiveMemberDashboard = () => {
  const isMobile = useMediaQuery("(max-width: 768px)");

  return (
    <div className={`member-dashboard ${isMobile ? "mobile" : "desktop"}`}>
      {isMobile ? <MobileMemberDashboard /> : <DesktopMemberDashboard />}
    </div>
  );
};
```

## 🔄 State Management

### Member Store (Zustand)

```typescript
import { create } from "zustand";

interface MemberState {
  member: Member | null;
  quota: QuotaInfo | null;
  queueEntry: QueueEntry | null;
  usage: UsageInfo | null;
  isLoading: boolean;

  fetchMemberData: () => Promise<void>;
  updateQuota: (quotaData: Partial<QuotaInfo>) => Promise<void>;
  joinQueue: () => Promise<void>;
  leaveQueue: () => Promise<void>;
  acceptOffer: () => Promise<void>;
  rejectOffer: () => Promise<void>;
}

export const useMemberStore = create<MemberState>((set, get) => ({
  member: null,
  quota: null,
  queueEntry: null,
  usage: null,
  isLoading: false,

  fetchMemberData: async () => {
    set({ isLoading: true });
    try {
      const [memberRes, quotaRes, queueRes, usageRes] = await Promise.all([
        fetch("/api/members/profile"),
        fetch("/api/members/quota"),
        fetch("/api/members/queue/status"),
        fetch("/api/members/usage"),
      ]);

      const [member, quota, queueEntry, usage] = await Promise.all([
        memberRes.json(),
        quotaRes.json(),
        queueRes.json(),
        usageRes.json(),
      ]);

      set({ member, quota, queueEntry, usage });
    } catch (error) {
      console.error("Failed to fetch member data:", error);
    } finally {
      set({ isLoading: false });
    }
  },

  updateQuota: async (quotaData) => {
    // Update quota logic
  },

  joinQueue: async () => {
    const response = await fetch("/api/members/queue/join", {
      method: "POST",
    });

    const queueEntry = await response.json();
    set({ queueEntry });
  },

  leaveQueue: async () => {
    await fetch("/api/members/queue/leave", {
      method: "DELETE",
    });

    set({ queueEntry: null });
  },

  acceptOffer: async () => {
    const response = await fetch("/api/members/queue/accept", {
      method: "PUT",
    });

    const { member, queueEntry } = await response.json();
    set({ member, queueEntry });
  },

  rejectOffer: async () => {
    await fetch("/api/members/queue/reject", {
      method: "PUT",
    });

    set({ queueEntry: null });
  },
}));
```

## 🧪 Testing

### Member Component Testing

```typescript
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { MemberDashboard } from "@/components/member/Dashboard";

describe("MemberDashboard", () => {
  it("renders member dashboard with profile information", () => {
    const mockMember = {
      id: "1",
      membership_number: "MEM001",
      membership_type: "regular",
      status: "active",
      joined_date: "2024-01-01",
      membership_end: "2024-12-31",
      user: { name: "John Doe" },
    };

    render(<MemberDashboard member={mockMember} />);

    expect(screen.getByText("Welcome back, John Doe!")).toBeInTheDocument();
    expect(screen.getByText("MEM001")).toBeInTheDocument();
    expect(screen.getByText("regular")).toBeInTheDocument();
  });

  it("shows queue status when in queue", () => {
    const mockQueueEntry = {
      id: "1",
      queue_position: 5,
      status: "waiting",
      applied_date: "2024-01-01",
    };

    render(<QueueStatus queueEntry={mockQueueEntry} />);

    expect(screen.getByText("Your Position")).toBeInTheDocument();
    expect(screen.getByText("5")).toBeInTheDocument();
    expect(screen.getByText("waiting")).toBeInTheDocument();
  });

  it("allows user to accept membership offer", async () => {
    const mockQueueEntry = {
      id: "1",
      status: "offered",
      applied_date: "2024-01-01",
      offered_date: "2024-01-02",
    };

    const mockAcceptOffer = jest.fn();

    render(
      <QueueStatus queueEntry={mockQueueEntry} onAccept={mockAcceptOffer} />
    );

    const acceptButton = screen.getByRole("button", { name: /accept offer/i });
    fireEvent.click(acceptButton);

    await waitFor(() => {
      expect(mockAcceptOffer).toHaveBeenCalled();
    });
  });
});
```

## ✅ Success Criteria

- [ ] Member dashboard berfungsi dengan baik
- [ ] Quota monitoring interface responsif
- [ ] Queue status display real-time
- [ ] Membership management berjalan
- [ ] Usage tracking terdisplay
- [ ] Mobile optimization terpasang
- [ ] Notifications terkirim
- [ ] Analytics dapat diakses
- [ ] Testing coverage > 85%

## 📚 Documentation

- Member Portal Guide
- Quota Management Guide
- Queue System Guide
- Usage Tracking Guide
- Mobile Optimization Guide
