# Integration Examples

Contoh integrasi API dengan berbagai frontend frameworks.

## React Integration

### 1. Setup dan Configuration

```jsx
// src/config/api.js
import axios from "axios";

const API_BASE_URL =
    process.env.REACT_APP_API_URL || "http://localhost:8000/api/v1";

const api = axios.create({
    baseURL: API_BASE_URL,
    timeout: 10000,
    headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
    },
});

// Request interceptor
api.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem("token");
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

// Response interceptor
api.interceptors.response.use(
    (response) => {
        return response;
    },
    (error) => {
        if (error.response?.status === 401) {
            localStorage.removeItem("token");
            window.location.href = "/login";
        }
        return Promise.reject(error);
    }
);

export default api;
```

### 2. Authentication Hook

```jsx
// src/hooks/useAuth.js
import { useState, useEffect, createContext, useContext } from "react";
import api from "../config/api";

const AuthContext = createContext();

export const useAuth = () => {
    const context = useContext(AuthContext);
    if (!context) {
        throw new Error("useAuth must be used within AuthProvider");
    }
    return context;
};

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const token = localStorage.getItem("token");
        if (token) {
            fetchUser();
        } else {
            setLoading(false);
        }
    }, []);

    const fetchUser = async () => {
        try {
            const response = await api.get("/auth/me");
            setUser(response.data.data);
        } catch (error) {
            localStorage.removeItem("token");
        } finally {
            setLoading(false);
        }
    };

    const login = async (credentials) => {
        try {
            const response = await api.post("/auth/login", credentials);
            const { token, user } = response.data.data;

            localStorage.setItem("token", token);
            setUser(user);

            return { success: true };
        } catch (error) {
            return {
                success: false,
                message: error.response?.data?.message || "Login failed",
            };
        }
    };

    const logout = () => {
        localStorage.removeItem("token");
        setUser(null);
    };

    const value = {
        user,
        loading,
        login,
        logout,
        isAuthenticated: !!user,
    };

    return (
        <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
    );
};
```

### 3. Booking Management Component

```jsx
// src/components/BookingManagement.jsx
import React, { useState, useEffect } from "react";
import api from "../config/api";

const BookingManagement = () => {
    const [bookings, setBookings] = useState([]);
    const [loading, setLoading] = useState(true);
    const [sessions, setSessions] = useState([]);
    const [showCreateForm, setShowCreateForm] = useState(false);

    useEffect(() => {
        fetchBookings();
        fetchSessions();
    }, []);

    const fetchBookings = async () => {
        try {
            const response = await api.get("/bookings");
            setBookings(response.data.data.bookings);
        } catch (error) {
            console.error("Error fetching bookings:", error);
        } finally {
            setLoading(false);
        }
    };

    const fetchSessions = async () => {
        try {
            const response = await api.get("/sessions");
            setSessions(response.data.data.sessions);
        } catch (error) {
            console.error("Error fetching sessions:", error);
        }
    };

    const createBooking = async (bookingData) => {
        try {
            const response = await api.post("/bookings", bookingData);
            setBookings((prev) => [response.data.data.booking, ...prev]);
            setShowCreateForm(false);
            return { success: true };
        } catch (error) {
            return {
                success: false,
                message:
                    error.response?.data?.message || "Failed to create booking",
            };
        }
    };

    const cancelBooking = async (bookingId) => {
        try {
            await api.post(`/bookings/${bookingId}/cancel`);
            setBookings((prev) =>
                prev.map((booking) =>
                    booking.id === bookingId
                        ? { ...booking, status: "cancelled" }
                        : booking
                )
            );
            return { success: true };
        } catch (error) {
            return {
                success: false,
                message:
                    error.response?.data?.message || "Failed to cancel booking",
            };
        }
    };

    if (loading) return <div>Loading...</div>;

    return (
        <div>
            <h2>My Bookings</h2>
            <button onClick={() => setShowCreateForm(true)}>
                Create New Booking
            </button>

            {showCreateForm && (
                <CreateBookingForm
                    sessions={sessions}
                    onSubmit={createBooking}
                    onCancel={() => setShowCreateForm(false)}
                />
            )}

            <div className="bookings-list">
                {bookings.map((booking) => (
                    <BookingCard
                        key={booking.id}
                        booking={booking}
                        onCancel={cancelBooking}
                    />
                ))}
            </div>
        </div>
    );
};

export default BookingManagement;
```

## Vue.js Integration

### 1. API Service

```javascript
// src/services/api.js
import axios from "axios";

const API_BASE_URL =
    import.meta.env.VITE_API_URL || "http://localhost:8000/api/v1";

const api = axios.create({
    baseURL: API_BASE_URL,
    timeout: 10000,
    headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
    },
});

// Request interceptor
api.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem("token");
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

// Response interceptor
api.interceptors.response.use(
    (response) => {
        return response;
    },
    (error) => {
        if (error.response?.status === 401) {
            localStorage.removeItem("token");
            window.location.href = "/login";
        }
        return Promise.reject(error);
    }
);

export default api;
```

### 2. Authentication Store (Pinia)

```javascript
// src/stores/auth.js
import { defineStore } from "pinia";
import api from "../services/api";

export const useAuthStore = defineStore("auth", {
    state: () => ({
        user: null,
        loading: false,
    }),

    getters: {
        isAuthenticated: (state) => !!state.user,
        userRole: (state) => state.user?.role,
    },

    actions: {
        async login(credentials) {
            this.loading = true;
            try {
                const response = await api.post("/auth/login", credentials);
                const { token, user } = response.data.data;

                localStorage.setItem("token", token);
                this.user = user;

                return { success: true };
            } catch (error) {
                return {
                    success: false,
                    message: error.response?.data?.message || "Login failed",
                };
            } finally {
                this.loading = false;
            }
        },

        async logout() {
            localStorage.removeItem("token");
            this.user = null;
        },

        async fetchUser() {
            try {
                const response = await api.get("/auth/me");
                this.user = response.data.data;
            } catch (error) {
                localStorage.removeItem("token");
                this.user = null;
            }
        },
    },
});
```

### 3. Booking Component

```vue
<template>
    <div>
        <h2>My Bookings</h2>
        <button @click="showCreateForm = true">Create New Booking</button>

        <div v-if="showCreateForm" class="create-form">
            <h3>Create Booking</h3>
            <form @submit.prevent="handleCreateBooking">
                <div>
                    <label>Session:</label>
                    <select v-model="newBooking.session_id" required>
                        <option value="">Select Session</option>
                        <option
                            v-for="session in sessions"
                            :key="session.id"
                            :value="session.id"
                        >
                            {{ session.name }} - {{ session.start_time }}
                        </option>
                    </select>
                </div>

                <div>
                    <label>Booking Date:</label>
                    <input
                        v-model="newBooking.booking_date"
                        type="date"
                        required
                    />
                </div>

                <div>
                    <label>Notes:</label>
                    <textarea v-model="newBooking.notes"></textarea>
                </div>

                <button type="submit" :disabled="loading">
                    {{ loading ? "Creating..." : "Create Booking" }}
                </button>
                <button type="button" @click="showCreateForm = false">
                    Cancel
                </button>
            </form>
        </div>

        <div class="bookings-list">
            <div
                v-for="booking in bookings"
                :key="booking.id"
                class="booking-card"
            >
                <h3>{{ booking.booking_code }}</h3>
                <p>Session: {{ booking.session_name }}</p>
                <p>Date: {{ formatDate(booking.booking_date) }}</p>
                <p>Status: {{ booking.status }}</p>

                <button
                    v-if="booking.status === 'confirmed'"
                    @click="cancelBooking(booking.id)"
                    :disabled="loading"
                >
                    Cancel Booking
                </button>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import api from "../services/api";

const bookings = ref([]);
const sessions = ref([]);
const loading = ref(false);
const showCreateForm = ref(false);

const newBooking = ref({
    session_id: "",
    booking_date: "",
    notes: "",
});

const fetchBookings = async () => {
    try {
        const response = await api.get("/bookings");
        bookings.value = response.data.data.bookings;
    } catch (error) {
        console.error("Error fetching bookings:", error);
    }
};

const fetchSessions = async () => {
    try {
        const response = await api.get("/sessions");
        sessions.value = response.data.data.sessions;
    } catch (error) {
        console.error("Error fetching sessions:", error);
    }
};

const handleCreateBooking = async () => {
    loading.value = true;
    try {
        const response = await api.post("/bookings", newBooking.value);
        bookings.value.unshift(response.data.data.booking);
        showCreateForm.value = false;
        newBooking.value = { session_id: "", booking_date: "", notes: "" };
    } catch (error) {
        console.error("Error creating booking:", error);
    } finally {
        loading.value = false;
    }
};

const cancelBooking = async (bookingId) => {
    loading.value = true;
    try {
        await api.post(`/bookings/${bookingId}/cancel`);
        const booking = bookings.value.find((b) => b.id === bookingId);
        if (booking) {
            booking.status = "cancelled";
        }
    } catch (error) {
        console.error("Error cancelling booking:", error);
    } finally {
        loading.value = false;
    }
};

const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString("id-ID");
};

onMounted(() => {
    fetchBookings();
    fetchSessions();
});
</script>
```

## Angular Integration

### 1. API Service

```typescript
// src/app/services/api.service.ts
import { Injectable } from "@angular/core";
import {
    HttpClient,
    HttpHeaders,
    HttpErrorResponse,
} from "@angular/common/http";
import { Observable, throwError } from "rxjs";
import { catchError } from "rxjs/operators";

@Injectable({
    providedIn: "root",
})
export class ApiService {
    private baseUrl = "http://localhost:8000/api/v1";

    constructor(private http: HttpClient) {}

    private getHeaders(): HttpHeaders {
        const token = localStorage.getItem("token");
        return new HttpHeaders({
            "Content-Type": "application/json",
            Accept: "application/json",
            Authorization: token ? `Bearer ${token}` : "",
        });
    }

    private handleError(error: HttpErrorResponse) {
        if (error.status === 401) {
            localStorage.removeItem("token");
            window.location.href = "/login";
        }
        return throwError(() => error);
    }

    get<T>(endpoint: string): Observable<T> {
        return this.http
            .get<T>(`${this.baseUrl}${endpoint}`, {
                headers: this.getHeaders(),
            })
            .pipe(catchError(this.handleError));
    }

    post<T>(endpoint: string, data: any): Observable<T> {
        return this.http
            .post<T>(`${this.baseUrl}${endpoint}`, data, {
                headers: this.getHeaders(),
            })
            .pipe(catchError(this.handleError));
    }

    put<T>(endpoint: string, data: any): Observable<T> {
        return this.http
            .put<T>(`${this.baseUrl}${endpoint}`, data, {
                headers: this.getHeaders(),
            })
            .pipe(catchError(this.handleError));
    }

    delete<T>(endpoint: string): Observable<T> {
        return this.http
            .delete<T>(`${this.baseUrl}${endpoint}`, {
                headers: this.getHeaders(),
            })
            .pipe(catchError(this.handleError));
    }
}
```

### 2. Authentication Service

```typescript
// src/app/services/auth.service.ts
import { Injectable } from "@angular/core";
import { BehaviorSubject, Observable } from "rxjs";
import { ApiService } from "./api.service";

export interface User {
    id: number;
    name: string;
    email: string;
    role: string;
}

export interface LoginResponse {
    success: boolean;
    message: string;
    data: {
        user: User;
        token: string;
    };
}

@Injectable({
    providedIn: "root",
})
export class AuthService {
    private userSubject = new BehaviorSubject<User | null>(null);
    public user$ = this.userSubject.asObservable();

    constructor(private api: ApiService) {
        const token = localStorage.getItem("token");
        if (token) {
            this.fetchUser();
        }
    }

    get user(): User | null {
        return this.userSubject.value;
    }

    get isAuthenticated(): boolean {
        return !!this.user;
    }

    async login(credentials: {
        email: string;
        password: string;
    }): Promise<LoginResponse> {
        try {
            const response = await this.api
                .post<LoginResponse>("/auth/login", credentials)
                .toPromise();
            if (response?.success) {
                localStorage.setItem("token", response.data.token);
                this.userSubject.next(response.data.user);
            }
            return response!;
        } catch (error) {
            throw error;
        }
    }

    logout(): void {
        localStorage.removeItem("token");
        this.userSubject.next(null);
    }

    private async fetchUser(): Promise<void> {
        try {
            const response = await this.api
                .get<{ success: boolean; data: User }>("/auth/me")
                .toPromise();
            if (response?.success) {
                this.userSubject.next(response.data);
            }
        } catch (error) {
            localStorage.removeItem("token");
            this.userSubject.next(null);
        }
    }
}
```

### 3. Booking Component

```typescript
// src/app/components/booking/booking.component.ts
import { Component, OnInit } from "@angular/core";
import { ApiService } from "../../services/api.service";
import { AuthService } from "../../services/auth.service";

interface Booking {
    id: number;
    booking_code: string;
    session_name: string;
    booking_date: string;
    status: string;
}

interface Session {
    id: number;
    name: string;
    start_time: string;
    end_time: string;
}

@Component({
    selector: "app-booking",
    templateUrl: "./booking.component.html",
    styleUrls: ["./booking.component.css"],
})
export class BookingComponent implements OnInit {
    bookings: Booking[] = [];
    sessions: Session[] = [];
    loading = false;
    showCreateForm = false;

    newBooking = {
        session_id: "",
        booking_date: "",
        notes: "",
    };

    constructor(private api: ApiService, private auth: AuthService) {}

    ngOnInit(): void {
        this.fetchBookings();
        this.fetchSessions();
    }

    async fetchBookings(): Promise<void> {
        try {
            const response = await this.api
                .get<{ success: boolean; data: { bookings: Booking[] } }>(
                    "/bookings"
                )
                .toPromise();
            if (response?.success) {
                this.bookings = response.data.bookings;
            }
        } catch (error) {
            console.error("Error fetching bookings:", error);
        }
    }

    async fetchSessions(): Promise<void> {
        try {
            const response = await this.api
                .get<{ success: boolean; data: { sessions: Session[] } }>(
                    "/sessions"
                )
                .toPromise();
            if (response?.success) {
                this.sessions = response.data.sessions;
            }
        } catch (error) {
            console.error("Error fetching sessions:", error);
        }
    }

    async createBooking(): Promise<void> {
        this.loading = true;
        try {
            const response = await this.api
                .post<{ success: boolean; data: { booking: Booking } }>(
                    "/bookings",
                    this.newBooking
                )
                .toPromise();
            if (response?.success) {
                this.bookings.unshift(response.data.booking);
                this.showCreateForm = false;
                this.newBooking = {
                    session_id: "",
                    booking_date: "",
                    notes: "",
                };
            }
        } catch (error) {
            console.error("Error creating booking:", error);
        } finally {
            this.loading = false;
        }
    }

    async cancelBooking(bookingId: number): Promise<void> {
        this.loading = true;
        try {
            await this.api.post(`/bookings/${bookingId}/cancel`).toPromise();
            const booking = this.bookings.find((b) => b.id === bookingId);
            if (booking) {
                booking.status = "cancelled";
            }
        } catch (error) {
            console.error("Error cancelling booking:", error);
        } finally {
            this.loading = false;
        }
    }
}
```

## Flutter Integration

### 1. API Service

```dart
// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
    static const String baseUrl = 'http://localhost:8000/api/v1';

    static Map<String, String> _getHeaders() {
        return {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
        };
    }

    static Map<String, String> _getAuthHeaders() {
        final token = _getToken();
        final headers = _getHeaders();
        if (token != null) {
            headers['Authorization'] = 'Bearer $token';
        }
        return headers;
    }

    static String? _getToken() {
        // Get token from secure storage
        return null; // Implement secure storage
    }

    static Future<Map<String, dynamic>> get(String endpoint) async {
        final response = await http.get(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getAuthHeaders(),
        );

        if (response.statusCode == 401) {
            // Handle unauthorized
            throw Exception('Unauthorized');
        }

        return json.decode(response.body);
    }

    static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
        final response = await http.post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getAuthHeaders(),
            body: json.encode(data),
        );

        if (response.statusCode == 401) {
            throw Exception('Unauthorized');
        }

        return json.decode(response.body);
    }
}
```

### 2. Authentication Service

```dart
// lib/services/auth_service.dart
import 'api_service.dart';

class AuthService {
    static Future<Map<String, dynamic>> login(String email, String password) async {
        try {
            final response = await ApiService.post('/auth/login', {
                'email': email,
                'password': password,
            });

            if (response['success']) {
                final token = response['data']['token'];
                // Store token securely
                await _storeToken(token);
            }

            return response;
        } catch (e) {
            return {
                'success': false,
                'message': 'Login failed',
            };
        }
    }

    static Future<void> logout() async {
        // Remove token from secure storage
        await _removeToken();
    }

    static Future<Map<String, dynamic>> getCurrentUser() async {
        try {
            return await ApiService.get('/auth/me');
        } catch (e) {
            return {
                'success': false,
                'message': 'Failed to get user',
            };
        }
    }

    static Future<void> _storeToken(String token) async {
        // Implement secure storage
    }

    static Future<void> _removeToken() async {
        // Implement secure storage
    }
}
```

### 3. Booking Service

```dart
// lib/services/booking_service.dart
import 'api_service.dart';

class BookingService {
    static Future<List<Map<String, dynamic>>> getBookings() async {
        try {
            final response = await ApiService.get('/bookings');
            if (response['success']) {
                return List<Map<String, dynamic>>.from(response['data']['bookings']);
            }
            return [];
        } catch (e) {
            return [];
        }
    }

    static Future<Map<String, dynamic>> createBooking({
        required int sessionId,
        required String bookingDate,
        String? notes,
    }) async {
        try {
            final response = await ApiService.post('/bookings', {
                'session_id': sessionId,
                'booking_date': bookingDate,
                'notes': notes,
            });
            return response;
        } catch (e) {
            return {
                'success': false,
                'message': 'Failed to create booking',
            };
        }
    }

    static Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
        try {
            final response = await ApiService.post('/bookings/$bookingId/cancel', {});
            return response;
        } catch (e) {
            return {
                'success': false,
                'message': 'Failed to cancel booking',
            };
        }
    }
}
```

## Notes

-   Selalu handle error dengan graceful
-   Implementasikan loading states
-   Gunakan secure storage untuk token
-   Implementasikan refresh token mechanism
-   Test integrasi secara menyeluruh
-   Monitor performance dan error rates
-   Dokumentasikan API changes
-   Implementasikan offline support jika diperlukan
