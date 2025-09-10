# WebSocket Integration

Panduan lengkap untuk integrasi WebSocket dan real-time features.

## Setup WebSocket Server

### 1. Laravel Reverb Configuration

```env
# .env
REVERB_APP_ID=your_app_id
REVERB_APP_KEY=your_app_key
REVERB_APP_SECRET=your_app_secret
REVERB_HOST="localhost"
REVERB_PORT=8080
REVERB_SCHEME=http

BROADCAST_DRIVER=reverb
```

### 2. Start Reverb Server

```bash
php artisan reverb:start
```

### 3. Broadcasting Configuration

```php
// config/broadcasting.php
'reverb' => [
    'driver' => 'reverb',
    'key' => env('REVERB_APP_KEY'),
    'secret' => env('REVERB_APP_SECRET'),
    'app_id' => env('REVERB_APP_ID'),
    'options' => [
        'host' => env('REVERB_HOST', '127.0.0.1'),
        'port' => env('REVERB_PORT', 443),
        'scheme' => env('REVERB_SCHEME', 'https'),
        'useTLS' => env('REVERB_SCHEME', 'https') === 'https',
    ],
],
```

## Frontend Integration

### 1. Laravel Echo Setup

```javascript
// Install dependencies
npm install laravel-echo pusher-js

// resources/js/bootstrap.js
import Echo from 'laravel-echo';
import Pusher from 'pusher-js';

window.Pusher = Pusher;

window.Echo = new Echo({
    broadcaster: 'reverb',
    key: import.meta.env.VITE_REVERB_APP_KEY,
    wsHost: import.meta.env.VITE_REVERB_HOST,
    wsPort: import.meta.env.VITE_REVERB_PORT ?? 80,
    wssPort: import.meta.env.VITE_REVERB_PORT ?? 443,
    forceTLS: (import.meta.env.VITE_REVERB_SCHEME ?? 'https') === 'https',
    enabledTransports: ['ws', 'wss'],
    authEndpoint: '/api/broadcasting/auth',
    auth: {
        headers: {
            Authorization: `Bearer ${localStorage.getItem('token')}`,
        },
    },
});
```

### 2. React WebSocket Hook

```jsx
// src/hooks/useWebSocket.js
import { useEffect, useState } from "react";
import Echo from "laravel-echo";

const useWebSocket = () => {
    const [echo, setEcho] = useState(null);
    const [connected, setConnected] = useState(false);

    useEffect(() => {
        const echoInstance = new Echo({
            broadcaster: "reverb",
            key: process.env.REACT_APP_REVERB_KEY,
            wsHost: process.env.REACT_APP_REVERB_HOST,
            wsPort: process.env.REACT_APP_REVERB_PORT,
            forceTLS: process.env.REACT_APP_REVERB_SCHEME === "https",
            authEndpoint: "/api/broadcasting/auth",
            auth: {
                headers: {
                    Authorization: `Bearer ${localStorage.getItem("token")}`,
                },
            },
        });

        echoInstance.connector.pusher.connection.bind("connected", () => {
            setConnected(true);
        });

        echoInstance.connector.pusher.connection.bind("disconnected", () => {
            setConnected(false);
        });

        setEcho(echoInstance);

        return () => {
            echoInstance.disconnect();
        };
    }, []);

    return { echo, connected };
};

export default useWebSocket;
```

### 3. Real-time Availability Component

```jsx
// src/components/RealTimeAvailability.jsx
import React, { useState, useEffect } from "react";
import { useWebSocket } from "../hooks/useWebSocket";

const RealTimeAvailability = () => {
    const { echo, connected } = useWebSocket();
    const [availability, setAvailability] = useState({});
    const [sessions, setSessions] = useState([]);

    useEffect(() => {
        if (echo) {
            // Listen to availability updates
            echo.channel("availability")
                .listen("AvailabilityUpdated", (e) => {
                    setAvailability((prev) => ({
                        ...prev,
                        [e.data.session_id]: e.data,
                    }));
                })
                .listen("CapacityUpdated", (e) => {
                    setAvailability((prev) => ({
                        ...prev,
                        [e.data.session_id]: {
                            ...prev[e.data.session_id],
                            current_capacity: e.data.current_capacity,
                            max_capacity: e.data.max_capacity,
                        },
                    }));
                });

            return () => {
                echo.leave("availability");
            };
        }
    }, [echo]);

    const getAvailabilityStatus = (sessionId) => {
        const sessionAvailability = availability[sessionId];
        if (!sessionAvailability) return "loading";

        const { current_capacity, max_capacity } = sessionAvailability;
        const percentage = (current_capacity / max_capacity) * 100;

        if (percentage >= 90) return "full";
        if (percentage >= 70) return "almost-full";
        return "available";
    };

    const getStatusColor = (status) => {
        switch (status) {
            case "available":
                return "green";
            case "almost-full":
                return "orange";
            case "full":
                return "red";
            default:
                return "gray";
        }
    };

    return (
        <div>
            <h2>Real-time Session Availability</h2>
            <div className="connection-status">
                Status: {connected ? "Connected" : "Disconnected"}
            </div>

            <div className="sessions-grid">
                {sessions.map((session) => {
                    const status = getAvailabilityStatus(session.id);
                    const sessionAvailability = availability[session.id];

                    return (
                        <div key={session.id} className="session-card">
                            <h3>{session.name}</h3>
                            <p>
                                Time: {session.start_time} - {session.end_time}
                            </p>

                            {sessionAvailability ? (
                                <div className="availability-info">
                                    <p>
                                        Capacity:{" "}
                                        {sessionAvailability.current_capacity}/
                                        {sessionAvailability.max_capacity}
                                    </p>
                                    <div
                                        className="status-indicator"
                                        style={{
                                            backgroundColor:
                                                getStatusColor(status),
                                        }}
                                    >
                                        {status.replace("-", " ").toUpperCase()}
                                    </div>
                                </div>
                            ) : (
                                <p>Loading availability...</p>
                            )}
                        </div>
                    );
                })}
            </div>
        </div>
    );
};

export default RealTimeAvailability;
```

### 4. Vue.js WebSocket Composable

```javascript
// src/composables/useWebSocket.js
import { ref, onMounted, onUnmounted } from "vue";
import Echo from "laravel-echo";

export const useWebSocket = () => {
    const echo = ref(null);
    const connected = ref(false);

    onMounted(() => {
        echo.value = new Echo({
            broadcaster: "reverb",
            key: import.meta.env.VITE_REVERB_KEY,
            wsHost: import.meta.env.VITE_REVERB_HOST,
            wsPort: import.meta.env.VITE_REVERB_PORT,
            forceTLS: import.meta.env.VITE_REVERB_SCHEME === "https",
            authEndpoint: "/api/broadcasting/auth",
            auth: {
                headers: {
                    Authorization: `Bearer ${localStorage.getItem("token")}`,
                },
            },
        });

        echo.value.connector.pusher.connection.bind("connected", () => {
            connected.value = true;
        });

        echo.value.connector.pusher.connection.bind("disconnected", () => {
            connected.value = false;
        });
    });

    onUnmounted(() => {
        if (echo.value) {
            echo.value.disconnect();
        }
    });

    return { echo, connected };
};
```

### 5. Real-time Notifications Component

```vue
<template>
    <div>
        <h2>Real-time Notifications</h2>
        <div class="connection-status">
            Status: {{ connected ? "Connected" : "Disconnected" }}
        </div>

        <div class="notifications-list">
            <div
                v-for="notification in notifications"
                :key="notification.id"
                class="notification-item"
                :class="notification.type"
            >
                <div class="notification-content">
                    <h4>{{ notification.title }}</h4>
                    <p>{{ notification.message }}</p>
                    <small>{{ formatTime(notification.timestamp) }}</small>
                </div>
                <button @click="dismissNotification(notification.id)">×</button>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from "vue";
import { useWebSocket } from "../composables/useWebSocket";

const { echo, connected } = useWebSocket();
const notifications = ref([]);

onMounted(() => {
    if (echo.value) {
        // Listen to user-specific notifications
        const userId = localStorage.getItem("user_id");
        echo.value
            .private(`user.${userId}`)
            .listen("BookingStatusUpdated", (e) => {
                addNotification({
                    type: "booking",
                    title: "Booking Update",
                    message: `Your booking ${e.data.booking_code} status has been updated to ${e.data.status}`,
                    data: e.data,
                });
            })
            .listen("PaymentStatusUpdated", (e) => {
                addNotification({
                    type: "payment",
                    title: "Payment Update",
                    message: `Payment for booking ${e.data.booking_code} has been ${e.data.payment_status}`,
                    data: e.data,
                });
            });

        // Listen to general notifications
        echo.value
            .channel("notifications")
            .listen("SystemNotification", (e) => {
                addNotification({
                    type: "system",
                    title: "System Notification",
                    message: e.data.message,
                    data: e.data,
                });
            });
    }
});

const addNotification = (notification) => {
    const newNotification = {
        id: Date.now(),
        timestamp: new Date(),
        ...notification,
    };

    notifications.value.unshift(newNotification);

    // Auto-dismiss after 5 seconds
    setTimeout(() => {
        dismissNotification(newNotification.id);
    }, 5000);
};

const dismissNotification = (id) => {
    const index = notifications.value.findIndex((n) => n.id === id);
    if (index > -1) {
        notifications.value.splice(index, 1);
    }
};

const formatTime = (timestamp) => {
    return new Date(timestamp).toLocaleTimeString("id-ID");
};
</script>

<style scoped>
.notification-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem;
    margin-bottom: 0.5rem;
    border-radius: 0.5rem;
    border-left: 4px solid;
}

.notification-item.booking {
    background-color: #e3f2fd;
    border-left-color: #2196f3;
}

.notification-item.payment {
    background-color: #e8f5e8;
    border-left-color: #4caf50;
}

.notification-item.system {
    background-color: #fff3e0;
    border-left-color: #ff9800;
}

.connection-status {
    padding: 0.5rem;
    margin-bottom: 1rem;
    border-radius: 0.25rem;
    background-color: #f5f5f5;
}
</style>
```

## Backend Event Broadcasting

### 1. Availability Events

```php
// app/Events/AvailabilityUpdated.php
<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class AvailabilityUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $sessionId;
    public $sessionName;
    public $date;
    public $availableSlots;
    public $totalCapacity;

    public function __construct($sessionId, $sessionName, $date, $availableSlots, $totalCapacity)
    {
        $this->sessionId = $sessionId;
        $this->sessionName = $sessionName;
        $this->date = $date;
        $this->availableSlots = $availableSlots;
        $this->totalCapacity = $totalCapacity;
    }

    public function broadcastOn()
    {
        return new Channel('availability');
    }

    public function broadcastAs()
    {
        return 'AvailabilityUpdated';
    }

    public function broadcastWith()
    {
        return [
            'session_id' => $this->sessionId,
            'session_name' => $this->sessionName,
            'date' => $this->date,
            'available_slots' => $this->availableSlots,
            'total_capacity' => $this->totalCapacity,
            'updated_at' => now()->toISOString(),
        ];
    }
}
```

### 2. Booking Events

```php
// app/Events/BookingStatusUpdated.php
<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class BookingStatusUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $bookingId;
    public $userId;
    public $bookingCode;
    public $status;
    public $paymentStatus;

    public function __construct($bookingId, $userId, $bookingCode, $status, $paymentStatus)
    {
        $this->bookingId = $bookingId;
        $this->userId = $userId;
        $this->bookingCode = $bookingCode;
        $this->status = $status;
        $this->paymentStatus = $paymentStatus;
    }

    public function broadcastOn()
    {
        return new PrivateChannel("booking.{$this->userId}");
    }

    public function broadcastAs()
    {
        return 'BookingStatusUpdated';
    }

    public function broadcastWith()
    {
        return [
            'booking_id' => $this->bookingId,
            'booking_code' => $this->bookingCode,
            'status' => $this->status,
            'payment_status' => $this->paymentStatus,
            'updated_at' => now()->toISOString(),
        ];
    }
}
```

### 3. Broadcasting in Controllers

```php
// app/Http/Controllers/Api/V1/BookingController.php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Events\BookingStatusUpdated;
use App\Events\AvailabilityUpdated;
use App\Models\Booking;
use App\Models\Session;
use Illuminate\Http\Request;

class BookingController extends Controller
{
    public function store(Request $request)
    {
        $booking = Booking::create($request->validated());

        // Broadcast availability update
        $session = Session::find($booking->session_id);
        $availableSlots = $session->max_capacity - $session->bookings()->count();

        broadcast(new AvailabilityUpdated(
            $session->id,
            $session->name,
            $booking->booking_date,
            $availableSlots,
            $session->max_capacity
        ));

        // Broadcast booking status update
        broadcast(new BookingStatusUpdated(
            $booking->id,
            $booking->user_id,
            $booking->booking_code,
            $booking->status,
            $booking->payment_status
        ));

        return response()->json([
            'success' => true,
            'message' => 'Booking created successfully',
            'data' => ['booking' => $booking]
        ]);
    }
}
```

## Authentication for Private Channels

### 1. Broadcasting Auth Route

```php
// routes/api.php
Route::post('/broadcasting/auth', function (Request $request) {
    $user = $request->user();

    if (!$user) {
        return response()->json(['message' => 'Unauthorized'], 401);
    }

    $channelName = $request->input('channel_name');

    // Validate channel access
    if (str_starts_with($channelName, 'private-booking.')) {
        $userId = str_replace('private-booking.', '', $channelName);
        if ($user->id != $userId && !$user->hasRole('admin')) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
    }

    return response()->json([
        'auth' => base64_encode(json_encode([
            'user_id' => $user->id,
            'user_info' => $user->toArray()
        ]))
    ]);
});
```

### 2. Channel Authorization

```php
// app/Providers/BroadcastServiceProvider.php
<?php

namespace App\Providers;

use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\ServiceProvider;

class BroadcastServiceProvider extends ServiceProvider
{
    public function boot()
    {
        Broadcast::routes(['middleware' => ['auth:sanctum']]);

        require base_path('routes/channels.php');
    }
}
```

```php
// routes/channels.php
<?php

use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('booking.{userId}', function ($user, $userId) {
    return $user->id == $userId || $user->hasRole('admin');
});

Broadcast::channel('user.{userId}', function ($user, $userId) {
    return $user->id == $userId || $user->hasRole('admin');
});
```

## Error Handling and Reconnection

### 1. Connection Error Handling

```javascript
// src/utils/websocketErrorHandler.js
export const handleWebSocketError = (echo) => {
    echo.connector.pusher.connection.bind("error", (error) => {
        console.error("WebSocket error:", error);

        // Show user-friendly error message
        showNotification(
            "Connection error. Attempting to reconnect...",
            "warning"
        );
    });

    echo.connector.pusher.connection.bind("disconnected", () => {
        console.log("WebSocket disconnected");
        showNotification("Disconnected from server", "info");
    });

    echo.connector.pusher.connection.bind("reconnected", () => {
        console.log("WebSocket reconnected");
        showNotification("Reconnected to server", "success");
    });
};
```

### 2. Automatic Reconnection

```javascript
// src/hooks/useWebSocketWithReconnect.js
import { useEffect, useState, useRef } from "react";
import Echo from "laravel-echo";

const useWebSocketWithReconnect = () => {
    const [echo, setEcho] = useState(null);
    const [connected, setConnected] = useState(false);
    const reconnectTimeoutRef = useRef(null);
    const reconnectAttempts = useRef(0);
    const maxReconnectAttempts = 5;

    const createEcho = () => {
        return new Echo({
            broadcaster: "reverb",
            key: process.env.REACT_APP_REVERB_KEY,
            wsHost: process.env.REACT_APP_REVERB_HOST,
            wsPort: process.env.REACT_APP_REVERB_PORT,
            forceTLS: process.env.REACT_APP_REVERB_SCHEME === "https",
            authEndpoint: "/api/broadcasting/auth",
            auth: {
                headers: {
                    Authorization: `Bearer ${localStorage.getItem("token")}`,
                },
            },
        });
    };

    const handleReconnect = () => {
        if (reconnectAttempts.current < maxReconnectAttempts) {
            reconnectAttempts.current++;
            const delay = Math.pow(2, reconnectAttempts.current) * 1000; // Exponential backoff

            reconnectTimeoutRef.current = setTimeout(() => {
                console.log(
                    `Reconnection attempt ${reconnectAttempts.current}`
                );
                const newEcho = createEcho();
                setEcho(newEcho);
            }, delay);
        } else {
            console.error("Max reconnection attempts reached");
        }
    };

    useEffect(() => {
        const echoInstance = createEcho();

        echoInstance.connector.pusher.connection.bind("connected", () => {
            setConnected(true);
            reconnectAttempts.current = 0;
        });

        echoInstance.connector.pusher.connection.bind("disconnected", () => {
            setConnected(false);
            handleReconnect();
        });

        setEcho(echoInstance);

        return () => {
            if (reconnectTimeoutRef.current) {
                clearTimeout(reconnectTimeoutRef.current);
            }
            echoInstance.disconnect();
        };
    }, []);

    return { echo, connected };
};

export default useWebSocketWithReconnect;
```

## Notes

-   WebSocket memerlukan autentikasi untuk private channels
-   Implementasikan error handling dan reconnection
-   Monitor connection status dan berikan feedback ke user
-   Gunakan exponential backoff untuk reconnection
-   Test WebSocket functionality secara menyeluruh
-   Monitor WebSocket performance dan error rates
-   Implementasikan rate limiting untuk WebSocket events
-   Gunakan secure WebSocket (WSS) di production
