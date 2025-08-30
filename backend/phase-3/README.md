# Phase 3: Booking System & Calendar

## 📋 Overview

Implementasi sistem booking dan calendar interface dengan real-time availability tracking.

## 🎯 Objectives

- Calendar interface backend implementation
- Booking management system
- Real-time availability tracking
- Session management
- Capacity management
- Booking validation & business rules

## 📁 Files Structure

```
phase-3/
├── 01-calendar-backend.md
├── 02-booking-management.md
├── 03-real-time-availability.md
├── 04-session-management.md
└── 05-capacity-management.md
```

## 🔧 Implementation Points

### Point 1: Calendar Backend Implementation

**Subpoints:**

- Calendar data structure design
- Date availability calculation
- Forward-only navigation logic
- Calendar API endpoints
- Calendar caching mechanism
- Calendar validation rules

**Files:**

- `app/Http/Controllers/CalendarController.php`
- `app/Services/CalendarService.php`
- `app/Models/CalendarAvailability.php`
- `database/migrations/` - Calendar tables

### Point 2: Booking Management System

**Subpoints:**

- Booking CRUD operations
- Booking validation rules
- Booking status management
- Booking confirmation system
- Booking cancellation logic
- Booking history tracking

**Files:**

- `app/Http/Controllers/BookingController.php`
- `app/Models/Booking.php`
- `app/Http/Requests/BookingRequest.php`
- `app/Services/BookingService.php`

### Point 3: Real-Time Availability Tracking

**Subpoints:**

- Real-time capacity calculation
- Availability status updates
- Concurrent booking prevention
- WebSocket integration untuk real-time updates
- Availability caching
- Availability notifications

**Files:**

- `app/Http/Controllers/AvailabilityController.php`
- `app/Services/AvailabilityService.php`
- `app/Events/AvailabilityUpdated.php`
- `app/Broadcasting/` - WebSocket channels

### Point 4: Session Management

**Subpoints:**

- Session scheduling system
- Session capacity management
- Session type management (Regular/Private)
- Session time slot management
- Session overlap prevention
- Session analytics

**Files:**

- `app/Models/Session.php`
- `app/Http/Controllers/SessionController.php`
- `app/Services/SessionService.php`
- `database/migrations/` - Sessions table

### Point 5: Capacity Management

**Subpoints:**

- Daily capacity configuration
- Capacity calculation logic
- Capacity override mechanisms
- Capacity reservation system
- Capacity reporting
- Capacity analytics

**Files:**

- `app/Models/DailyCapacity.php`
- `app/Services/CapacityService.php`
- `app/Http/Controllers/CapacityController.php`
- `database/migrations/` - Capacity tables

## 📊 Database Schema

### Bookings Table

```sql
CREATE TABLE bookings (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    session_id BIGINT UNSIGNED NOT NULL,
    booking_date DATE NOT NULL,
    booking_type ENUM('regular', 'private_silver', 'private_gold') NOT NULL,
    adult_count INT DEFAULT 0,
    child_count INT DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'confirmed', 'cancelled', 'completed') DEFAULT 'pending',
    payment_status ENUM('unpaid', 'paid', 'refunded') DEFAULT 'unpaid',
    booking_reference VARCHAR(50) UNIQUE NOT NULL,
    qr_code VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (session_id) REFERENCES sessions(id)
);
```

### Sessions Table

```sql
CREATE TABLE sessions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    session_type ENUM('regular', 'private') DEFAULT 'regular',
    capacity INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Calendar Availability Table

```sql
CREATE TABLE calendar_availability (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    date DATE NOT NULL,
    session_id BIGINT UNSIGNED NOT NULL,
    available_slots INT NOT NULL,
    booked_slots INT DEFAULT 0,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (session_id) REFERENCES sessions(id),
    UNIQUE KEY unique_date_session (date, session_id)
);
```

### Daily Capacity Table

```sql
CREATE TABLE daily_capacity (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    date DATE NOT NULL,
    max_capacity INT NOT NULL,
    reserved_capacity INT DEFAULT 0,
    is_override BOOLEAN DEFAULT FALSE,
    override_reason TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY unique_date (date)
);
```

## 🔄 Business Logic

### Booking Validation Rules

- User tidak dapat booking untuk tanggal yang sudah lewat
- Booking harus dilakukan minimal 1 jam sebelum sesi
- Capacity tidak boleh melebihi batas maksimum
- User member hanya dapat booking 1 sesi per hari (free)
- Private session memerlukan reservasi khusus

### Availability Calculation

```php
public function calculateAvailability($date, $sessionId)
{
    $calendar = CalendarAvailability::where('date', $date)
        ->where('session_id', $sessionId)
        ->first();

    $dailyCapacity = DailyCapacity::where('date', $date)->first();

    $availableSlots = $calendar->available_slots - $calendar->booked_slots;
    $dailyAvailable = $dailyCapacity->max_capacity - $dailyCapacity->reserved_capacity;

    return min($availableSlots, $dailyAvailable);
}
```

## 📚 API Endpoints

### Calendar Endpoints

```
GET  /api/calendar/availability
GET  /api/calendar/sessions
GET  /api/calendar/dates/{date}
POST /api/calendar/generate
```

### Booking Endpoints

```
GET    /api/bookings
POST   /api/bookings
GET    /api/bookings/{id}
PUT    /api/bookings/{id}
DELETE /api/bookings/{id}
POST   /api/bookings/{id}/confirm
POST   /api/bookings/{id}/cancel
```

### Session Endpoints

```
GET    /api/sessions
POST   /api/sessions
GET    /api/sessions/{id}
PUT    /api/sessions/{id}
DELETE /api/sessions/{id}
```

### Availability Endpoints

```
GET  /api/availability/realtime
GET  /api/availability/date/{date}
GET  /api/availability/session/{sessionId}
POST /api/availability/update
```

## 🧪 Testing

- Unit tests untuk booking logic
- Integration tests untuk calendar system
- Feature tests untuk booking flow
- API tests untuk availability endpoints
- Performance tests untuk real-time updates

## ✅ Success Criteria

- [ ] Calendar dapat menampilkan availability
- [ ] Booking dapat dibuat dan dikonfirmasi
- [ ] Real-time availability updates berfungsi
- [ ] Session management berjalan dengan baik
- [ ] Capacity management terimplementasi
- [ ] Booking validation rules berfungsi
- [ ] WebSocket integration untuk real-time updates
- [ ] Testing coverage > 85%

## 📚 Documentation

- Booking System Architecture
- Calendar Logic Documentation
- Real-time Updates Guide
- Capacity Management Rules
- WebSocket Implementation Guide
