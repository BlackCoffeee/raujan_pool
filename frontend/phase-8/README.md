# Phase 8: Check-in & Attendance System

## 📋 Overview

Implementasi sistem check-in dan attendance dengan QR code scanning, tracking kehadiran, dan manajemen no-show.

## 🎯 Objectives

- QR code check-in interface
- Attendance tracking display
- No-show management
- Equipment issuance interface
- Attendance reports
- Real-time attendance monitoring

## 📁 Files Structure

```
phase-8/
├── 01-qr-checkin.md
├── 02-attendance-tracking.md
├── 03-noshow-management.md
├── 04-equipment-issuance.md
└── 05-attendance-reports.md
```

## 🔧 Implementation Points

### Point 1: QR Code Check-in Interface

**Subpoints:**

- QR code scanner
- Check-in validation
- Check-in confirmation
- Check-in history
- Check-in notifications
- Check-in analytics

**Files:**

- `components/checkin/QRScanner.tsx`
- `components/checkin/CheckinForm.tsx`
- `components/checkin/CheckinConfirmation.tsx`
- `components/checkin/CheckinHistory.tsx`
- `hooks/useCheckin.ts`
- `lib/checkin-utils.ts`

### Point 2: Attendance Tracking Display

**Subpoints:**

- Attendance dashboard
- Real-time attendance
- Attendance statistics
- Attendance timeline
- Attendance alerts
- Attendance monitoring

**Files:**

- `components/attendance/AttendanceDashboard.tsx`
- `components/attendance/RealTimeAttendance.tsx`
- `components/attendance/AttendanceStats.tsx`
- `components/attendance/AttendanceTimeline.tsx`
- `hooks/useAttendance.ts`
- `lib/attendance-utils.ts`

### Point 3: No-show Management

**Subpoints:**

- No-show tracking
- No-show notifications
- No-show penalties
- No-show reports
- No-show analytics
- No-show prevention

**Files:**

- `components/noshow/NoShowTracking.tsx`
- `components/noshow/NoShowNotifications.tsx`
- `components/noshow/NoShowPenalties.tsx`
- `components/noshow/NoShowReports.tsx`
- `hooks/useNoShow.ts`
- `lib/noshow-utils.ts`

### Point 4: Equipment Issuance Interface

**Subpoints:**

- Equipment management
- Equipment tracking
- Equipment return
- Equipment maintenance
- Equipment reports
- Equipment analytics

**Files:**

- `components/equipment/EquipmentManagement.tsx`
- `components/equipment/EquipmentTracking.tsx`
- `components/equipment/EquipmentReturn.tsx`
- `components/equipment/EquipmentMaintenance.tsx`
- `hooks/useEquipment.ts`
- `lib/equipment-utils.ts`

### Point 5: Attendance Reports

**Subpoints:**

- Attendance reports
- Attendance analytics
- Attendance export
- Attendance insights
- Attendance trends
- Attendance forecasting

**Files:**

- `components/reports/AttendanceReports.tsx`
- `components/reports/AttendanceAnalytics.tsx`
- `components/reports/AttendanceExport.tsx`
- `components/reports/AttendanceInsights.tsx`
- `hooks/useAttendanceReports.ts`
- `lib/reports-utils.ts`

## 📦 Dependencies

### Check-in & Attendance Dependencies

```json
{
  "html5-qrcode": "^2.3.0",
  "react-qr-reader": "^3.0.0",
  "react-hook-form": "^7.48.0",
  "zod": "^3.22.0",
  "@hookform/resolvers": "^3.3.0",
  "recharts": "^2.8.0",
  "date-fns": "^2.30.0"
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
  "react-hot-toast": "^2.4.0"
}
```

### State Management

```json
{
  "zustand": "^4.4.0",
  "react-query": "^3.39.0",
  "socket.io-client": "^4.7.0"
}
```

## 🎨 Component Examples

### QR Code Scanner Component

```typescript
import { useState, useRef, useEffect } from "react";
import { Html5QrcodeScanner } from "html5-qrcode";
import { useCheckin } from "@/hooks/useCheckin";

interface QRScannerProps {
  onCheckinSuccess: (checkin: Checkin) => void;
  onCheckinError: (error: string) => void;
}

export const QRScanner = ({
  onCheckinSuccess,
  onCheckinError,
}: QRScannerProps) => {
  const [scanning, setScanning] = useState(false);
  const [scannedData, setScannedData] = useState("");
  const scannerRef = useRef<Html5QrcodeScanner | null>(null);

  const { processCheckin, isLoading } = useCheckin();

  const startScanning = () => {
    setScanning(true);
    scannerRef.current = new Html5QrcodeScanner(
      "qr-reader",
      {
        fps: 10,
        qrbox: { width: 250, height: 250 },
        aspectRatio: 1.0,
      },
      false
    );

    scannerRef.current.render(onScanSuccess, onScanFailure);
  };

  const stopScanning = () => {
    if (scannerRef.current) {
      scannerRef.current.clear();
      scannerRef.current = null;
    }
    setScanning(false);
  };

  const onScanSuccess = async (decodedText: string) => {
    setScannedData(decodedText);
    stopScanning();

    try {
      const checkin = await processCheckin(decodedText);
      onCheckinSuccess(checkin);
      toast.success("Check-in successful!");
    } catch (error) {
      onCheckinError(error.message);
      toast.error("Check-in failed: " + error.message);
    }
  };

  const onScanFailure = (error: any) => {
    console.warn(`QR scan failure: ${error}`);
  };

  useEffect(() => {
    return () => {
      if (scannerRef.current) {
        scannerRef.current.clear();
      }
    };
  }, []);

  return (
    <div className="space-y-4">
      <div className="text-center">
        <h2 className="text-xl font-semibold mb-2">Check-in with QR Code</h2>
        <p className="text-gray-600">Scan your booking QR code to check in</p>
      </div>

      {!scanning ? (
        <div className="text-center">
          <button
            onClick={startScanning}
            disabled={isLoading}
            className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 disabled:opacity-50"
          >
            {isLoading ? "Processing..." : "Start Scanning"}
          </button>
        </div>
      ) : (
        <div className="space-y-4">
          <div id="qr-reader" className="mx-auto max-w-md"></div>
          <div className="text-center">
            <button
              onClick={stopScanning}
              className="bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700"
            >
              Stop Scanning
            </button>
          </div>
        </div>
      )}

      {scannedData && (
        <div className="bg-green-50 border border-green-200 rounded-lg p-4">
          <div className="text-center">
            <div className="text-green-800 font-medium">Scanned Data:</div>
            <div className="text-green-600 font-mono text-sm break-all">
              {scannedData}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
```

### Check-in Confirmation Component

```typescript
import { useState } from "react";
import { CheckCircle, Clock, MapPin, User } from "lucide-react";

interface CheckinConfirmationProps {
  checkin: Checkin;
  onClose: () => void;
}

export const CheckinConfirmation = ({
  checkin,
  onClose,
}: CheckinConfirmationProps) => {
  const [showDetails, setShowDetails] = useState(false);

  const formatTime = (date: string) => {
    return new Date(date).toLocaleTimeString("id-ID", {
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  const formatDate = (date: string) => {
    return new Date(date).toLocaleDateString("id-ID", {
      weekday: "long",
      year: "numeric",
      month: "long",
      day: "numeric",
    });
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        {/* Success Header */}
        <div className="text-center mb-6">
          <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <CheckCircle className="w-8 h-8 text-green-600" />
          </div>
          <h3 className="text-xl font-semibold text-gray-900 mb-2">
            Check-in Successful!
          </h3>
          <p className="text-gray-600">
            You have successfully checked in to your session
          </p>
        </div>

        {/* Check-in Details */}
        <div className="space-y-4 mb-6">
          <div className="flex items-center space-x-3">
            <User className="w-5 h-5 text-gray-400" />
            <div>
              <div className="text-sm text-gray-600">Guest Name</div>
              <div className="font-medium">{checkin.guest_name}</div>
            </div>
          </div>

          <div className="flex items-center space-x-3">
            <Clock className="w-5 h-5 text-gray-400" />
            <div>
              <div className="text-sm text-gray-600">Check-in Time</div>
              <div className="font-medium">
                {formatTime(checkin.checkin_time)} -{" "}
                {formatDate(checkin.checkin_time)}
              </div>
            </div>
          </div>

          <div className="flex items-center space-x-3">
            <MapPin className="w-5 h-5 text-gray-400" />
            <div>
              <div className="text-sm text-gray-600">Session</div>
              <div className="font-medium">{checkin.session_name}</div>
            </div>
          </div>
        </div>

        {/* Additional Details Toggle */}
        <div className="mb-6">
          <button
            onClick={() => setShowDetails(!showDetails)}
            className="text-blue-600 hover:text-blue-700 text-sm font-medium"
          >
            {showDetails ? "Hide" : "Show"} Additional Details
          </button>

          {showDetails && (
            <div className="mt-3 p-3 bg-gray-50 rounded-lg space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Booking Reference:</span>
                <span className="font-mono">{checkin.booking_reference}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Session Time:</span>
                <span>{checkin.session_time}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Pool Area:</span>
                <span>{checkin.pool_area}</span>
              </div>
            </div>
          )}
        </div>

        {/* Actions */}
        <div className="flex space-x-3">
          <button
            onClick={onClose}
            className="flex-1 bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700"
          >
            Continue
          </button>
          <button
            onClick={() => window.print()}
            className="px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50"
          >
            Print Receipt
          </button>
        </div>
      </div>
    </div>
  );
};
```

### Attendance Dashboard Component

```typescript
import { useState, useEffect } from "react";
import { useAttendance } from "@/hooks/useAttendance";
import { RealTimeAttendance } from "./RealTimeAttendance";
import { AttendanceStats } from "./AttendanceStats";

export const AttendanceDashboard = () => {
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [selectedSession, setSelectedSession] = useState("all");

  const { attendance, stats, realTimeData, isLoading } = useAttendance({
    date: selectedDate,
    session: selectedSession,
  });

  const formatDate = (date: Date) => {
    return date.toLocaleDateString("id-ID", {
      weekday: "long",
      year: "numeric",
      month: "long",
      day: "numeric",
    });
  };

  if (isLoading) {
    return (
      <div className="animate-pulse space-y-6">
        <div className="h-32 bg-gray-200 rounded-lg"></div>
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
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">
            Attendance Dashboard
          </h1>
          <p className="text-gray-600">{formatDate(selectedDate)}</p>
        </div>

        <div className="flex space-x-3">
          <input
            type="date"
            value={selectedDate.toISOString().split("T")[0]}
            onChange={(e) => setSelectedDate(new Date(e.target.value))}
            className="px-3 py-2 border rounded-md"
          />
          <select
            value={selectedSession}
            onChange={(e) => setSelectedSession(e.target.value)}
            className="px-3 py-2 border rounded-md"
          >
            <option value="all">All Sessions</option>
            <option value="morning">Morning Session</option>
            <option value="afternoon">Afternoon Session</option>
            <option value="evening">Evening Session</option>
          </select>
        </div>
      </div>

      {/* Real-time Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
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
                  d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            </div>
            <div className="ml-4">
              <div className="text-sm font-medium text-gray-600">
                Checked In
              </div>
              <div className="text-2xl font-bold text-green-600">
                {stats.checkedIn}
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg p-6 border">
          <div className="flex items-center">
            <div className="p-2 bg-red-100 rounded-lg">
              <svg
                className="w-6 h-6 text-red-600"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </div>
            <div className="ml-4">
              <div className="text-sm font-medium text-gray-600">No Show</div>
              <div className="text-2xl font-bold text-red-600">
                {stats.noShow}
              </div>
            </div>
          </div>
        </div>

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
                  d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            </div>
            <div className="ml-4">
              <div className="text-sm font-medium text-gray-600">
                Total Bookings
              </div>
              <div className="text-2xl font-bold text-blue-600">
                {stats.totalBookings}
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg p-6 border">
          <div className="flex items-center">
            <div className="p-2 bg-yellow-100 rounded-lg">
              <svg
                className="w-6 h-6 text-yellow-600"
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
                Attendance Rate
              </div>
              <div className="text-2xl font-bold text-yellow-600">
                {stats.attendanceRate}%
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Real-time Attendance */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-lg p-6 border">
          <h3 className="text-lg font-semibold mb-4">Real-time Attendance</h3>
          <RealTimeAttendance data={realTimeData} />
        </div>

        <div className="bg-white rounded-lg p-6 border">
          <h3 className="text-lg font-semibold mb-4">Attendance Statistics</h3>
          <AttendanceStats stats={stats} />
        </div>
      </div>

      {/* Attendance List */}
      <div className="bg-white rounded-lg p-6 border">
        <h3 className="text-lg font-semibold mb-4">Today's Attendance</h3>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Guest Name
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Session
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Check-in Time
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {attendance.map((record) => (
                <tr key={record.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                        <span className="text-blue-600 font-semibold text-sm">
                          {record.guest_name.charAt(0).toUpperCase()}
                        </span>
                      </div>
                      <div className="ml-3">
                        <div className="text-sm font-medium text-gray-900">
                          {record.guest_name}
                        </div>
                        <div className="text-sm text-gray-500">
                          {record.booking_reference}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">
                      {record.session_name}
                    </div>
                    <div className="text-sm text-gray-500">
                      {record.session_time}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    {record.checkin_time ? (
                      <div className="text-sm text-gray-900">
                        {new Date(record.checkin_time).toLocaleTimeString()}
                      </div>
                    ) : (
                      <span className="text-sm text-gray-500">
                        Not checked in
                      </span>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span
                      className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                        record.status === "checked_in"
                          ? "bg-green-100 text-green-800"
                          : record.status === "no_show"
                          ? "bg-red-100 text-red-800"
                          : "bg-yellow-100 text-yellow-800"
                      }`}
                    >
                      {record.status.replace("_", " ")}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex space-x-2">
                      {record.status === "pending" && (
                        <button
                          onClick={() => markAsNoShow(record.id)}
                          className="text-red-600 hover:text-red-900"
                        >
                          Mark No Show
                        </button>
                      )}
                      <button
                        onClick={() => viewDetails(record.id)}
                        className="text-blue-600 hover:text-blue-900"
                      >
                        View Details
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
```

### No-show Management Component

```typescript
import { useState } from "react";
import { useNoShow } from "@/hooks/useNoShow";
import { AlertTriangle, Clock, User, Calendar } from "lucide-react";

export const NoShowManagement = () => {
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [filter, setFilter] = useState("all");

  const { noShows, stats, isLoading, markAsNoShow, sendReminder } = useNoShow({
    date: selectedDate,
    filter,
  });

  const handleMarkNoShow = async (bookingId: string) => {
    try {
      await markAsNoShow(bookingId);
      toast.success("Marked as no-show");
    } catch (error) {
      toast.error("Failed to mark as no-show");
    }
  };

  const handleSendReminder = async (bookingId: string) => {
    try {
      await sendReminder(bookingId);
      toast.success("Reminder sent");
    } catch (error) {
      toast.error("Failed to send reminder");
    }
  };

  if (isLoading) {
    return <div className="animate-pulse h-64 bg-gray-200 rounded-lg"></div>;
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">
            No-show Management
          </h1>
          <p className="text-gray-600">Track and manage no-show bookings</p>
        </div>

        <div className="flex space-x-3">
          <input
            type="date"
            value={selectedDate.toISOString().split("T")[0]}
            onChange={(e) => setSelectedDate(new Date(e.target.value))}
            className="px-3 py-2 border rounded-md"
          />
          <select
            value={filter}
            onChange={(e) => setFilter(e.target.value)}
            className="px-3 py-2 border rounded-md"
          >
            <option value="all">All Bookings</option>
            <option value="pending">Pending Check-in</option>
            <option value="no_show">No Show</option>
            <option value="late">Late Arrivals</option>
          </select>
        </div>
      </div>

      {/* No-show Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white rounded-lg p-6 border">
          <div className="flex items-center">
            <div className="p-2 bg-red-100 rounded-lg">
              <AlertTriangle className="w-6 h-6 text-red-600" />
            </div>
            <div className="ml-4">
              <div className="text-sm font-medium text-gray-600">
                No Shows Today
              </div>
              <div className="text-2xl font-bold text-red-600">
                {stats.noShowsToday}
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg p-6 border">
          <div className="flex items-center">
            <div className="p-2 bg-yellow-100 rounded-lg">
              <Clock className="w-6 h-6 text-yellow-600" />
            </div>
            <div className="ml-4">
              <div className="text-sm font-medium text-gray-600">
                Pending Check-in
              </div>
              <div className="text-2xl font-bold text-yellow-600">
                {stats.pendingCheckin}
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg p-6 border">
          <div className="flex items-center">
            <div className="p-2 bg-blue-100 rounded-lg">
              <User className="w-6 h-6 text-blue-600" />
            </div>
            <div className="ml-4">
              <div className="text-sm font-medium text-gray-600">
                Total Bookings
              </div>
              <div className="text-2xl font-bold text-blue-600">
                {stats.totalBookings}
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg p-6 border">
          <div className="flex items-center">
            <div className="p-2 bg-green-100 rounded-lg">
              <Calendar className="w-6 h-6 text-green-600" />
            </div>
            <div className="ml-4">
              <div className="text-sm font-medium text-gray-600">
                Attendance Rate
              </div>
              <div className="text-2xl font-bold text-green-600">
                {stats.attendanceRate}%
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* No-show List */}
      <div className="bg-white rounded-lg p-6 border">
        <h3 className="text-lg font-semibold mb-4">No-show Bookings</h3>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Guest Name
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Session
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Booking Time
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {noShows.map((booking) => (
                <tr key={booking.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="w-8 h-8 bg-red-100 rounded-full flex items-center justify-center">
                        <span className="text-red-600 font-semibold text-sm">
                          {booking.guest_name.charAt(0).toUpperCase()}
                        </span>
                      </div>
                      <div className="ml-3">
                        <div className="text-sm font-medium text-gray-900">
                          {booking.guest_name}
                        </div>
                        <div className="text-sm text-gray-500">
                          {booking.booking_reference}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">
                      {booking.session_name}
                    </div>
                    <div className="text-sm text-gray-500">
                      {booking.session_time}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">
                      {new Date(booking.booking_time).toLocaleString()}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800">
                      No Show
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex space-x-2">
                      <button
                        onClick={() => handleSendReminder(booking.id)}
                        className="text-blue-600 hover:text-blue-900"
                      >
                        Send Reminder
                      </button>
                      <button
                        onClick={() => viewDetails(booking.id)}
                        className="text-gray-600 hover:text-gray-900"
                      >
                        View Details
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
```

## 📱 Mobile Optimization

### Responsive Check-in Interface

```typescript
export const ResponsiveCheckinInterface = () => {
  const isMobile = useMediaQuery("(max-width: 768px)");

  return (
    <div className={`checkin-interface ${isMobile ? "mobile" : "desktop"}`}>
      {isMobile ? <MobileCheckinInterface /> : <DesktopCheckinInterface />}
    </div>
  );
};
```

## 🔄 State Management

### Check-in Store (Zustand)

```typescript
import { create } from "zustand";

interface CheckinState {
  checkins: Checkin[];
  attendance: AttendanceRecord[];
  equipment: Equipment[];
  isLoading: boolean;

  processCheckin: (qrCode: string) => Promise<Checkin>;
  markNoShow: (bookingId: string) => Promise<void>;
  issueEquipment: (equipmentId: string, guestId: string) => Promise<void>;
  returnEquipment: (equipmentId: string) => Promise<void>;
  fetchAttendance: (date: Date, session?: string) => Promise<void>;
  exportReport: (format: string, dateRange: DateRange) => Promise<void>;
}

export const useCheckinStore = create<CheckinState>((set, get) => ({
  checkins: [],
  attendance: [],
  equipment: [],
  isLoading: false,

  processCheckin: async (qrCode) => {
    set({ isLoading: true });
    try {
      const response = await fetch("/api/checkin", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ qr_code: qrCode }),
      });

      const checkin = await response.json();
      set((state) => ({ checkins: [checkin, ...state.checkins] }));
      return checkin;
    } catch (error) {
      console.error("Check-in failed:", error);
      throw error;
    } finally {
      set({ isLoading: false });
    }
  },

  markNoShow: async (bookingId) => {
    await fetch(`/api/bookings/${bookingId}/no-show`, {
      method: "PUT",
    });
  },

  issueEquipment: async (equipmentId, guestId) => {
    const response = await fetch("/api/equipment/issue", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ equipment_id: equipmentId, guest_id: guestId }),
    });

    const equipment = await response.json();
    set((state) => ({
      equipment: state.equipment.map((e) =>
        e.id === equipmentId ? equipment : e
      ),
    }));
  },

  returnEquipment: async (equipmentId) => {
    const response = await fetch(`/api/equipment/${equipmentId}/return`, {
      method: "PUT",
    });

    const equipment = await response.json();
    set((state) => ({
      equipment: state.equipment.map((e) =>
        e.id === equipmentId ? equipment : e
      ),
    }));
  },

  fetchAttendance: async (date, session) => {
    set({ isLoading: true });
    try {
      const params = new URLSearchParams({
        date: date.toISOString().split("T")[0],
        ...(session && { session }),
      });

      const response = await fetch(`/api/attendance?${params}`);
      const data = await response.json();
      set({ attendance: data.attendance });
    } catch (error) {
      console.error("Failed to fetch attendance:", error);
    } finally {
      set({ isLoading: false });
    }
  },

  exportReport: async (format, dateRange) => {
    const params = new URLSearchParams({
      format,
      start_date: dateRange.start.toISOString().split("T")[0],
      end_date: dateRange.end.toISOString().split("T")[0],
    });

    const response = await fetch(`/api/reports/attendance?${params}`);
    const blob = await response.blob();

    const url = window.URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `attendance-report.${format}`;
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
    document.body.removeChild(a);
  },
}));
```

## 🧪 Testing

### Check-in Component Testing

```typescript
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { QRScanner } from "@/components/checkin/QRScanner";
import { CheckinConfirmation } from "@/components/checkin/CheckinConfirmation";

describe("Check-in Components", () => {
  it("renders QR scanner interface", () => {
    render(<QRScanner onCheckinSuccess={() => {}} onCheckinError={() => {}} />);

    expect(screen.getByText("Check-in with QR Code")).toBeInTheDocument();
    expect(screen.getByText("Start Scanning")).toBeInTheDocument();
  });

  it("shows check-in confirmation after successful scan", async () => {
    const mockCheckin = {
      id: "1",
      guest_name: "John Doe",
      checkin_time: "2024-01-01T10:00:00Z",
      session_name: "Morning Session",
      booking_reference: "BK001",
    };

    render(<CheckinConfirmation checkin={mockCheckin} onClose={() => {}} />);

    expect(screen.getByText("Check-in Successful!")).toBeInTheDocument();
    expect(screen.getByText("John Doe")).toBeInTheDocument();
    expect(screen.getByText("Morning Session")).toBeInTheDocument();
  });

  it("displays attendance dashboard with stats", () => {
    const mockStats = {
      checkedIn: 25,
      noShow: 5,
      totalBookings: 30,
      attendanceRate: 83,
    };

    render(<AttendanceDashboard stats={mockStats} />);

    expect(screen.getByText("25")).toBeInTheDocument(); // Checked In
    expect(screen.getByText("5")).toBeInTheDocument(); // No Show
    expect(screen.getByText("30")).toBeInTheDocument(); // Total Bookings
    expect(screen.getByText("83%")).toBeInTheDocument(); // Attendance Rate
  });

  it("allows marking booking as no-show", async () => {
    const mockMarkNoShow = jest.fn();
    const mockBooking = {
      id: "1",
      guest_name: "John Doe",
      status: "pending",
    };

    render(
      <NoShowManagement
        bookings={[mockBooking]}
        onMarkNoShow={mockMarkNoShow}
      />
    );

    const markButton = screen.getByText("Mark No Show");
    fireEvent.click(markButton);

    await waitFor(() => {
      expect(mockMarkNoShow).toHaveBeenCalledWith("1");
    });
  });
});
```

## ✅ Success Criteria

- [ ] QR code scanner berfungsi dengan baik
- [ ] Check-in confirmation interface responsif
- [ ] Attendance dashboard terimplementasi
- [ ] No-show management berjalan
- [ ] Equipment management interface berfungsi
- [ ] Attendance reports dapat di-generate
- [ ] Real-time updates via WebSocket
- [ ] Mobile optimization terpasang
- [ ] Testing coverage > 85%

## 📚 Documentation

- Check-in System Guide
- Attendance Management Guide
- Equipment Tracking Guide
- No-show Management Guide
- Reports Generation Guide
- Mobile Optimization Guide

```

```
