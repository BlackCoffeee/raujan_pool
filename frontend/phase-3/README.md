# Phase 3: Calendar Interface & Booking System

## 📋 Overview

Implementasi calendar interface dan booking system dengan real-time availability display dan mobile-optimized booking flow.

## 🎯 Objectives

- Calendar component development
- Session selection interface
- Booking form implementation
- Real-time availability display
- Mobile-optimized booking flow
- Booking confirmation interface

## 📁 Files Structure

```
phase-3/
├── 01-calendar-component.md
├── 02-session-selection.md
├── 03-booking-form.md
├── 04-real-time-availability.md
└── 05-booking-confirmation.md
```

## 🔧 Implementation Points

### Point 1: Calendar Component Development

**Subpoints:**

- Calendar grid component
- Date navigation (forward-only)
- Availability status indicators
- Date selection functionality
- Calendar caching
- Responsive calendar design

**Files:**

- `components/calendar/Calendar.tsx`
- `components/calendar/CalendarGrid.tsx`
- `components/calendar/DateCell.tsx`
- `hooks/useCalendar.ts`
- `lib/calendar-utils.ts`

### Point 2: Session Selection Interface

**Subpoints:**

- Session list component
- Session card design
- Session details modal
- Session availability status
- Session type filtering
- Session selection logic

**Files:**

- `components/calendar/SessionList.tsx`
- `components/calendar/SessionCard.tsx`
- `components/calendar/SessionModal.tsx`
- `components/calendar/SessionFilter.tsx`

### Point 3: Booking Form Implementation

**Subpoints:**

- Multi-step booking form
- Guest information form
- Member selection interface
- Payment method selection
- Form validation
- Progress indicator

**Files:**

- `components/booking/BookingForm.tsx`
- `components/booking/GuestForm.tsx`
- `components/booking/MemberForm.tsx`
- `components/booking/PaymentForm.tsx`
- `hooks/useBooking.ts`

### Point 4: Real-Time Availability Display

**Subpoints:**

- Real-time availability updates
- WebSocket integration
- Availability status indicators
- Capacity display
- Concurrent booking prevention
- Availability notifications

**Files:**

- `components/availability/AvailabilityIndicator.tsx`
- `components/availability/CapacityDisplay.tsx`
- `hooks/useWebSocket.ts`
- `lib/availability-utils.ts`

### Point 5: Booking Confirmation Interface

**Subpoints:**

- Booking confirmation page
- QR code generation
- Booking reference display
- Email confirmation
- SMS confirmation
- Booking summary

**Files:**

- `components/booking/ConfirmationPage.tsx`
- `components/booking/QRCode.tsx`
- `components/booking/BookingSummary.tsx`
- `lib/confirmation-utils.ts`

## 📦 Dependencies

### Calendar Dependencies

```json
{
  "date-fns": "^2.30.0",
  "react-calendar": "^4.6.0",
  "react-datepicker": "^4.21.0"
}
```

### WebSocket Dependencies

```json
{
  "react-use-websocket": "^4.4.0",
  "socket.io-client": "^4.7.0"
}
```

### Form Dependencies

```json
{
  "react-hook-form": "^7.48.0",
  "zod": "^3.22.0",
  "@hookform/resolvers": "^3.3.0"
}
```

## 🎨 Component Examples

### Calendar Component

```typescript
import { useState, useEffect } from "react";
import { format, addMonths, startOfMonth, endOfMonth } from "date-fns";

interface CalendarProps {
  onDateSelect: (date: Date) => void;
  availability: AvailabilityData[];
}

export const Calendar = ({ onDateSelect, availability }: CalendarProps) => {
  const [currentMonth, setCurrentMonth] = useState(new Date());
  const [selectedDate, setSelectedDate] = useState<Date | null>(null);

  const handleDateClick = (date: Date) => {
    setSelectedDate(date);
    onDateSelect(date);
  };

  const nextMonth = () => {
    setCurrentMonth(addMonths(currentMonth, 1));
  };

  const prevMonth = () => {
    // Disabled for forward-only navigation
  };

  return (
    <div className="calendar-container">
      <div className="calendar-header">
        <button onClick={prevMonth} disabled className="opacity-50">
          Previous
        </button>
        <h2 className="calendar-title">{format(currentMonth, "MMMM yyyy")}</h2>
        <button onClick={nextMonth} className="hover:bg-gray-100">
          Next
        </button>
      </div>

      <div className="calendar-grid">{/* Calendar grid implementation */}</div>
    </div>
  );
};
```

### Session Selection Component

```typescript
interface SessionCardProps {
  session: Session;
  availability: number;
  onSelect: (session: Session) => void;
}

export const SessionCard = ({
  session,
  availability,
  onSelect,
}: SessionCardProps) => {
  const isAvailable = availability > 0;
  const statusColor = isAvailable ? "bg-green-500" : "bg-red-500";

  return (
    <div className="session-card bg-white rounded-lg shadow-md p-4 border">
      <div className="session-header">
        <h3 className="session-name font-semibold">{session.name}</h3>
        <span
          className={`status-indicator ${statusColor} w-3 h-3 rounded-full`}
        />
      </div>

      <div className="session-details mt-2">
        <p className="session-time text-sm text-gray-600">
          {session.startTime} - {session.endTime}
        </p>
        <p className="availability text-sm text-gray-600">
          Available: {availability} slots
        </p>
      </div>

      <button
        onClick={() => onSelect(session)}
        disabled={!isAvailable}
        className="mt-3 w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 disabled:opacity-50"
      >
        {isAvailable ? "Select Session" : "Fully Booked"}
      </button>
    </div>
  );
};
```

### Booking Form Component

```typescript
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";

export const BookingForm = ({ session, date }: BookingFormProps) => {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm({
    resolver: zodResolver(bookingSchema),
  });

  const onSubmit = async (data: BookingFormData) => {
    try {
      // Handle booking submission
      await createBooking({ ...data, session, date });
    } catch (error) {
      // Handle error
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
      <div className="booking-summary bg-gray-50 p-4 rounded-lg">
        <h3 className="font-semibold">Booking Summary</h3>
        <p>Session: {session.name}</p>
        <p>Date: {format(date, "PPP")}</p>
        <p>
          Time: {session.startTime} - {session.endTime}
        </p>
      </div>

      <div className="guest-information">
        <h3 className="text-lg font-semibold mb-4">Guest Information</h3>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label htmlFor="name">Full Name</label>
            <input
              {...register("name")}
              type="text"
              className="w-full px-3 py-2 border rounded-md"
            />
            {errors.name && (
              <span className="text-red-500 text-sm">
                {errors.name.message}
              </span>
            )}
          </div>

          <div>
            <label htmlFor="email">Email</label>
            <input
              {...register("email")}
              type="email"
              className="w-full px-3 py-2 border rounded-md"
            />
            {errors.email && (
              <span className="text-red-500 text-sm">
                {errors.email.message}
              </span>
            )}
          </div>
        </div>
      </div>

      <div className="payment-section">
        <h3 className="text-lg font-semibold mb-4">Payment Method</h3>
        <div className="space-y-2">
          <label className="flex items-center">
            <input
              type="radio"
              {...register("paymentMethod")}
              value="manual"
              className="mr-2"
            />
            Manual Transfer
          </label>
        </div>
      </div>

      <button
        type="submit"
        className="w-full bg-blue-600 text-white py-3 px-4 rounded-md hover:bg-blue-700"
      >
        Confirm Booking
      </button>
    </form>
  );
};
```

## 🔄 Real-Time Updates

### WebSocket Hook

```typescript
import useWebSocket from "react-use-websocket";

export const useAvailabilityWebSocket = () => {
  const { sendMessage, lastMessage, readyState } = useWebSocket(
    "ws://localhost:8080",
    {
      onOpen: () => console.log("Connected to availability updates"),
      onMessage: (event) => {
        const data = JSON.parse(event.data);
        if (data.type === "availability_update") {
          // Update availability state
          updateAvailability(data.payload);
        }
      },
      shouldReconnect: () => true,
      reconnectInterval: 3000,
    }
  );

  return { sendMessage, lastMessage, readyState };
};
```

## 📱 Mobile Optimization

### Responsive Calendar

```typescript
export const ResponsiveCalendar = ({ ...props }) => {
  const isMobile = useMediaQuery("(max-width: 768px)");

  return (
    <div className={`calendar-container ${isMobile ? "mobile" : "desktop"}`}>
      {isMobile ? (
        <MobileCalendar {...props} />
      ) : (
        <DesktopCalendar {...props} />
      )}
    </div>
  );
};
```

## 🧪 Testing

### Calendar Testing

```typescript
import { render, screen, fireEvent } from "@testing-library/react";
import { Calendar } from "@/components/calendar/Calendar";

describe("Calendar", () => {
  it("renders calendar with current month", () => {
    render(<Calendar onDateSelect={() => {}} availability={[]} />);
    expect(screen.getByText(/january 2024/i)).toBeInTheDocument();
  });

  it("allows forward navigation only", () => {
    render(<Calendar onDateSelect={() => {}} availability={[]} />);
    const prevButton = screen.getByText(/previous/i);
    const nextButton = screen.getByText(/next/i);

    expect(prevButton).toBeDisabled();
    expect(nextButton).not.toBeDisabled();
  });

  it("calls onDateSelect when date is clicked", () => {
    const mockOnDateSelect = jest.fn();
    render(<Calendar onDateSelect={mockOnDateSelect} availability={[]} />);

    const dateCell = screen.getByTestId("date-cell-15");
    fireEvent.click(dateCell);

    expect(mockOnDateSelect).toHaveBeenCalled();
  });
});
```

## ✅ Success Criteria

- [ ] Calendar component berfungsi dengan baik
- [ ] Session selection interface responsif
- [ ] Booking form terimplementasi
- [ ] Real-time availability updates berjalan
- [ ] Mobile booking flow optimal
- [ ] Booking confirmation interface lengkap
- [ ] WebSocket integration berfungsi
- [ ] Form validation berjalan
- [ ] Error handling terimplementasi
- [ ] Testing coverage > 85%

## 📚 Documentation

- Calendar Component Guide
- Booking Flow Documentation
- WebSocket Integration Guide
- Mobile Optimization Guide
- Real-time Updates Guide
