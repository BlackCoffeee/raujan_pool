# Calendar Interface Implementation

## 📋 Overview

Implementasi calendar interface untuk booking system dengan time slot management, availability display, dan interactive booking selection.

## 🎯 Objectives

- Setup calendar component dengan multiple views
- Implementasi time slot grid system
- Availability indicators dan status colors
- Interactive booking selection
- Responsive calendar design
- Keyboard navigation support

## 🔧 Implementation Steps

### Step 1: Setup Calendar Store

```bash
# Create booking store untuk state management
mkdir -p src/stores
touch src/stores/bookingStore.ts
```

**Store Structure:**

- Selected date dan time slots
- Available time slots data
- Booking conflicts detection
- Calendar view state (month/week/day)
- Loading states

### Step 2: Install Calendar Dependencies

```bash
# Dependencies sudah terinstall di phase-1
# react-big-calendar, react-datepicker, dayjs
```

**Required Dependencies:**

- `react-big-calendar` - Main calendar component
- `react-datepicker` - Date picker component
- `dayjs` - Date manipulation
- `@types/react-big-calendar` - TypeScript support

### Step 3: Create Calendar Components

```bash
# Create calendar components
mkdir -p src/components/calendar
touch src/components/calendar/BookingCalendar.tsx
touch src/components/calendar/TimeSlotGrid.tsx
touch src/components/calendar/AvailabilityIndicator.tsx
touch src/components/calendar/CalendarToolbar.tsx
```

**Component Structure:**

- `BookingCalendar` - Main calendar wrapper
- `TimeSlotGrid` - Time slot display grid
- `AvailabilityIndicator` - Availability status display
- `CalendarToolbar` - Calendar navigation controls

### Step 4: Setup Calendar Views

```bash
# Create calendar view components
mkdir -p src/components/calendar/views
touch src/components/calendar/views/MonthView.tsx
touch src/components/calendar/views/WeekView.tsx
touch src/components/calendar/views/DayView.tsx
```

**View Types:**

- Month view - Overview booking calendar
- Week view - Detailed weekly schedule
- Day view - Hourly time slot view

### Step 5: Implement Time Slot System

```bash
# Create time slot components
mkdir -p src/components/booking
touch src/components/booking/TimeSlotSelector.tsx
touch src/components/booking/SlotAvailability.tsx
```

**Time Slot Features:**

- Hourly slots (08:00 - 20:00)
- Pool-specific availability
- Capacity indicators
- Booking status colors

## 📊 Configuration Files

### src/types/booking.ts

```typescript
// Booking types dan interfaces
export interface TimeSlot {
  id: string;
  time: string;
  available: boolean;
  capacity: number;
  booked: number;
  poolId: string;
}

export interface CalendarEvent {
  id: string;
  title: string;
  start: Date;
  end: Date;
  resource: {
    poolId: string;
    status: "available" | "booked" | "maintenance";
  };
}
```

### src/config/calendar.ts

```typescript
// Calendar configuration
export const CALENDAR_CONFIG = {
  timeSlots: {
    start: "08:00",
    end: "20:00",
    interval: 60, // minutes
  },
  views: ["month", "week", "day"],
  defaultView: "week",
  step: 60,
  timeslots: 1,
};
```

### src/utils/calendarHelpers.ts

```typescript
// Calendar utility functions
export const generateTimeSlots = (
  start: string,
  end: string,
  interval: number
) => {
  // Generate time slots array
};

export const checkAvailability = (
  date: Date,
  timeSlot: string,
  poolId: string
) => {
  // Check slot availability
};

export const formatTimeSlot = (time: string) => {
  // Format time display
};
```

## 🛠️ Development Commands

### Calendar Development

```bash
# Start development dengan calendar focus
npm run dev

# Test calendar components
npm run test -- --testPathPattern=calendar

# Build calendar bundle
npm run build
```

### Calendar Testing

```bash
# Test calendar functionality
npm run test src/components/calendar

# Test time slot logic
npm run test src/utils/calendarHelpers

# Test booking store
npm run test src/stores/bookingStore
```

## 🎨 UI Implementation

### Calendar Styling

```bash
# Create calendar styles
mkdir -p src/styles/calendar
touch src/styles/calendar/calendar.css
touch src/styles/calendar/timeSlots.css
```

**Style Features:**

- Custom calendar theme
- Time slot color coding
- Availability indicators
- Responsive breakpoints
- Dark/light mode support

### Responsive Design

```bash
# Mobile calendar optimization
touch src/components/calendar/MobileCalendar.tsx
touch src/components/calendar/CalendarSwipe.tsx
```

**Mobile Features:**

- Touch-friendly navigation
- Swipe gestures
- Mobile-optimized time slots
- Collapsible sidebar

## 🔧 Integration Points

### API Integration

```bash
# Create booking API service
mkdir -p src/services
touch src/services/bookingApi.ts
```

**API Endpoints:**

- `GET /api/availability` - Get time slot availability
- `GET /api/bookings/calendar` - Get calendar events
- `POST /api/bookings/check-availability` - Check specific slot

### Real-time Updates

```bash
# Setup Socket.io integration
touch src/hooks/useBookingSocket.ts
```

**Socket Events:**

- `booking:created` - New booking created
- `booking:updated` - Booking status changed
- `booking:cancelled` - Booking cancelled
- `availability:changed` - Slot availability updated

## 🧪 Testing Strategy

### Unit Tests

```bash
# Test calendar components
mkdir -p src/components/calendar/__tests__
touch src/components/calendar/__tests__/BookingCalendar.test.tsx
touch src/components/calendar/__tests__/TimeSlotGrid.test.tsx
```

**Test Coverage:**

- Calendar rendering
- Time slot selection
- Availability checking
- Date navigation
- Responsive behavior

### Integration Tests

```bash
# Test calendar integration
mkdir -p src/__tests__/integration
touch src/__tests__/integration/calendar-booking.test.tsx
```

**Integration Tests:**

- Calendar dengan booking flow
- Real-time updates
- API integration
- State management

## 📱 Mobile Considerations

### Touch Interactions

```bash
# Mobile touch handlers
touch src/hooks/useCalendarTouch.ts
```

**Touch Features:**

- Swipe navigation
- Pinch to zoom
- Touch selection
- Haptic feedback

### Performance Optimization

```bash
# Calendar performance optimization
touch src/hooks/useCalendarPerformance.ts
```

**Optimizations:**

- Virtual scrolling
- Lazy loading
- Memoization
- Debounced updates

## ✅ Success Criteria

- [ ] Calendar component renders dengan multiple views (month/week/day)
- [ ] Time slot grid displays dengan proper availability indicators
- [ ] Interactive booking selection berfungsi dengan baik
- [ ] Real-time availability updates terintegrasi
- [ ] Responsive design works di mobile dan desktop
- [ ] Keyboard navigation support implemented
- [ ] Calendar state management dengan Zustand
- [ ] API integration untuk availability data
- [ ] Socket.io integration untuk real-time updates
- [ ] Unit tests untuk calendar components
- [ ] Integration tests untuk booking flow
- [ ] Performance optimization implemented
- [ ] Accessibility features (ARIA labels, keyboard support)
- [ ] Error handling untuk booking conflicts
- [ ] Loading states untuk semua async operations

## 📝 Notes

- Pastikan calendar component compatible dengan semua browsers
- Implementasi proper error boundaries untuk calendar
- Consider implementing calendar caching strategy
- Test calendar performance dengan large datasets
- Implementasi calendar analytics untuk user behavior
- Consider adding calendar export functionality
- Implementasi calendar sharing features
- Add calendar keyboard shortcuts documentation
