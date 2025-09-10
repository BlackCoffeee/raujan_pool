# 🔗 Integration Examples - Raujan Pool Syariah

## 📱 Frontend Framework Examples

### React.js Integration

#### 1. Authentication Service

```javascript
// services/authService.js
import axios from "axios";

const API_BASE_URL = "http://localhost:8000/api/v1";

const authService = {
    async login(email, password) {
        try {
            const response = await axios.post(`${API_BASE_URL}/auth/login`, {
                email,
                password,
            });

            const { token, user } = response.data.data;
            localStorage.setItem("auth_token", token);
            localStorage.setItem("user", JSON.stringify(user));

            return { success: true, user, token };
        } catch (error) {
            return {
                success: false,
                message: error.response?.data?.message || "Login failed",
            };
        }
    },

    async register(userData) {
        try {
            const response = await axios.post(
                `${API_BASE_URL}/auth/register`,
                userData
            );
            const { token, user } = response.data.data;

            localStorage.setItem("auth_token", token);
            localStorage.setItem("user", JSON.stringify(user));

            return { success: true, user, token };
        } catch (error) {
            return {
                success: false,
                message: error.response?.data?.message || "Registration failed",
            };
        }
    },

    async logout() {
        try {
            await axios.post(
                `${API_BASE_URL}/auth/logout`,
                {},
                {
                    headers: { Authorization: `Bearer ${this.getToken()}` },
                }
            );
        } catch (error) {
            console.error("Logout error:", error);
        } finally {
            localStorage.removeItem("auth_token");
            localStorage.removeItem("user");
        }
    },

    getToken() {
        return localStorage.getItem("auth_token");
    },

    getCurrentUser() {
        const user = localStorage.getItem("user");
        return user ? JSON.parse(user) : null;
    },

    isAuthenticated() {
        return !!this.getToken();
    },
};

export default authService;
```

#### 2. Booking Service

```javascript
// services/bookingService.js
import axios from "axios";

const API_BASE_URL = "http://localhost:8000/api/v1";

const bookingService = {
    async getAvailability(startDate, endDate, sessionId = null) {
        try {
            const params = new URLSearchParams({
                start_date: startDate,
                end_date: endDate,
            });

            if (sessionId) params.append("session_id", sessionId);

            const response = await axios.get(
                `${API_BASE_URL}/calendar/availability?${params}`,
                { headers: { Authorization: `Bearer ${this.getToken()}` } }
            );

            return { success: true, data: response.data.data };
        } catch (error) {
            return {
                success: false,
                message:
                    error.response?.data?.message ||
                    "Failed to get availability",
            };
        }
    },

    async createBooking(bookingData) {
        try {
            const response = await axios.post(
                `${API_BASE_URL}/bookings`,
                bookingData,
                { headers: { Authorization: `Bearer ${this.getToken()}` } }
            );

            return { success: true, data: response.data.data };
        } catch (error) {
            return {
                success: false,
                message:
                    error.response?.data?.message || "Failed to create booking",
            };
        }
    },

    async getMyBookings() {
        try {
            const response = await axios.get(`${API_BASE_URL}/bookings/my`, {
                headers: { Authorization: `Bearer ${this.getToken()}` },
            });

            return { success: true, data: response.data.data };
        } catch (error) {
            return {
                success: false,
                message:
                    error.response?.data?.message || "Failed to get bookings",
            };
        }
    },

    async cancelBooking(bookingId, reason) {
        try {
            const response = await axios.post(
                `${API_BASE_URL}/bookings/${bookingId}/cancel`,
                { reason },
                { headers: { Authorization: `Bearer ${this.getToken()}` } }
            );

            return { success: true, data: response.data.data };
        } catch (error) {
            return {
                success: false,
                message:
                    error.response?.data?.message || "Failed to cancel booking",
            };
        }
    },

    getToken() {
        return localStorage.getItem("auth_token");
    },
};

export default bookingService;
```

#### 3. React Components

```jsx
// components/LoginForm.jsx
import React, { useState } from "react";
import authService from "../services/authService";

const LoginForm = ({ onLoginSuccess }) => {
    const [formData, setFormData] = useState({ email: "", password: "" });
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError("");

        const result = await authService.login(
            formData.email,
            formData.password
        );

        if (result.success) {
            onLoginSuccess(result.user);
        } else {
            setError(result.message);
        }

        setLoading(false);
    };

    return (
        <form onSubmit={handleSubmit} className="login-form">
            <h2>Login</h2>

            {error && <div className="error-message">{error}</div>}

            <div className="form-group">
                <label>Email</label>
                <input
                    type="email"
                    value={formData.email}
                    onChange={(e) =>
                        setFormData({ ...formData, email: e.target.value })
                    }
                    required
                />
            </div>

            <div className="form-group">
                <label>Password</label>
                <input
                    type="password"
                    value={formData.password}
                    onChange={(e) =>
                        setFormData({ ...formData, password: e.target.value })
                    }
                    required
                />
            </div>

            <button type="submit" disabled={loading}>
                {loading ? "Logging in..." : "Login"}
            </button>
        </form>
    );
};

export default LoginForm;
```

```jsx
// components/BookingCalendar.jsx
import React, { useState, useEffect } from "react";
import bookingService from "../services/bookingService";

const BookingCalendar = () => {
    const [availability, setAvailability] = useState({});
    const [loading, setLoading] = useState(false);
    const [selectedDate, setSelectedDate] = useState("");
    const [selectedSession, setSelectedSession] = useState("");

    useEffect(() => {
        loadAvailability();
    }, []);

    const loadAvailability = async () => {
        setLoading(true);
        const startDate = new Date().toISOString().split("T")[0];
        const endDate = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
            .toISOString()
            .split("T")[0];

        const result = await bookingService.getAvailability(startDate, endDate);

        if (result.success) {
            setAvailability(result.data.availability);
        }

        setLoading(false);
    };

    const handleBooking = async () => {
        if (!selectedDate || !selectedSession) return;

        const bookingData = {
            session_id: selectedSession,
            booking_date: selectedDate,
            adult_count: 1,
            child_count: 0,
        };

        const result = await bookingService.createBooking(bookingData);

        if (result.success) {
            alert("Booking created successfully!");
            loadAvailability(); // Refresh availability
        } else {
            alert(`Booking failed: ${result.message}`);
        }
    };

    if (loading) return <div>Loading availability...</div>;

    return (
        <div className="booking-calendar">
            <h2>Book a Session</h2>

            <div className="date-selection">
                <label>Select Date:</label>
                <input
                    type="date"
                    value={selectedDate}
                    onChange={(e) => setSelectedDate(e.target.value)}
                    min={new Date().toISOString().split("T")[0]}
                />
            </div>

            {selectedDate && availability[selectedDate] && (
                <div className="session-selection">
                    <label>Select Session:</label>
                    {availability[selectedDate].map((slot) => (
                        <div key={slot.session_id} className="session-option">
                            <input
                                type="radio"
                                id={`session-${slot.session_id}`}
                                name="session"
                                value={slot.session_id}
                                onChange={(e) =>
                                    setSelectedSession(e.target.value)
                                }
                            />
                            <label htmlFor={`session-${slot.session_id}`}>
                                {slot.session.name} ({slot.start_time} -{" "}
                                {slot.end_time})
                                <br />
                                Available: {slot.remaining_slots} slots
                            </label>
                        </div>
                    ))}
                </div>
            )}

            <button
                onClick={handleBooking}
                disabled={!selectedDate || !selectedSession}
                className="book-button"
            >
                Book Now
            </button>
        </div>
    );
};

export default BookingCalendar;
```

### Vue.js Integration

#### 1. Vuex Store

```javascript
// store/modules/auth.js
import authService from "@/services/authService";

const state = {
    user: null,
    token: null,
    isAuthenticated: false,
};

const mutations = {
    SET_USER(state, user) {
        state.user = user;
    },
    SET_TOKEN(state, token) {
        state.token = token;
    },
    SET_AUTHENTICATED(state, status) {
        state.isAuthenticated = status;
    },
    CLEAR_AUTH(state) {
        state.user = null;
        state.token = null;
        state.isAuthenticated = false;
    },
};

const actions = {
    async login({ commit }, credentials) {
        try {
            const result = await authService.login(
                credentials.email,
                credentials.password
            );

            if (result.success) {
                commit("SET_USER", result.user);
                commit("SET_TOKEN", result.token);
                commit("SET_AUTHENTICATED", true);
                return { success: true };
            } else {
                return { success: false, message: result.message };
            }
        } catch (error) {
            return { success: false, message: "Login failed" };
        }
    },

    async logout({ commit }) {
        await authService.logout();
        commit("CLEAR_AUTH");
    },

    async checkAuth({ commit }) {
        const token = authService.getToken();
        const user = authService.getCurrentUser();

        if (token && user) {
            commit("SET_USER", user);
            commit("SET_TOKEN", token);
            commit("SET_AUTHENTICATED", true);
        }
    },
};

const getters = {
    user: (state) => state.user,
    token: (state) => state.token,
    isAuthenticated: (state) => state.isAuthenticated,
    userRole: (state) => state.user?.roles?.[0]?.name || "guest",
};

export default {
    namespaced: true,
    state,
    mutations,
    actions,
    getters,
};
```

#### 2. Vue Component

```vue
<!-- components/BookingForm.vue -->
<template>
    <div class="booking-form">
        <h2>Create New Booking</h2>

        <form @submit.prevent="submitBooking">
            <div class="form-group">
                <label>Session</label>
                <select v-model="bookingData.session_id" required>
                    <option value="">Select Session</option>
                    <option
                        v-for="session in sessions"
                        :key="session.id"
                        :value="session.id"
                    >
                        {{ session.name }} ({{ session.start_time }} -
                        {{ session.end_time }})
                    </option>
                </select>
            </div>

            <div class="form-group">
                <label>Date</label>
                <input
                    type="date"
                    v-model="bookingData.booking_date"
                    :min="minDate"
                    required
                />
            </div>

            <div class="form-group">
                <label>Adults</label>
                <input
                    type="number"
                    v-model.number="bookingData.adult_count"
                    min="0"
                    max="10"
                    required
                />
            </div>

            <div class="form-group">
                <label>Children</label>
                <input
                    type="number"
                    v-model.number="bookingData.child_count"
                    min="0"
                    max="10"
                />
            </div>

            <div class="form-group">
                <label>Notes</label>
                <textarea v-model="bookingData.notes" rows="3"></textarea>
            </div>

            <button type="submit" :disabled="loading">
                {{ loading ? "Creating..." : "Create Booking" }}
            </button>

            <div v-if="error" class="error-message">
                {{ error }}
            </div>
        </form>
    </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import bookingService from "@/services/bookingService";

export default {
    name: "BookingForm",
    data() {
        return {
            bookingData: {
                session_id: "",
                booking_date: "",
                adult_count: 1,
                child_count: 0,
                notes: "",
            },
            sessions: [],
            loading: false,
            error: "",
        };
    },
    computed: {
        ...mapGetters("auth", ["isAuthenticated"]),
        minDate() {
            return new Date().toISOString().split("T")[0];
        },
    },
    async mounted() {
        await this.loadSessions();
    },
    methods: {
        ...mapActions("auth", ["checkAuth"]),

        async loadSessions() {
            try {
                const response = await this.$http.get("/calendar/sessions");
                this.sessions = response.data.data;
            } catch (error) {
                console.error("Failed to load sessions:", error);
            }
        },

        async submitBooking() {
            this.loading = true;
            this.error = "";

            try {
                const result = await bookingService.createBooking(
                    this.bookingData
                );

                if (result.success) {
                    this.$emit("booking-created", result.data);
                    this.resetForm();
                } else {
                    this.error = result.message;
                }
            } catch (error) {
                this.error = "Failed to create booking";
            } finally {
                this.loading = false;
            }
        },

        resetForm() {
            this.bookingData = {
                session_id: "",
                booking_date: "",
                adult_count: 1,
                child_count: 0,
                notes: "",
            };
        },
    },
};
</script>
```

### Angular Integration

#### 1. Angular Service

```typescript
// services/api.service.ts
import { Injectable } from "@angular/core";
import { HttpClient, HttpHeaders } from "@angular/common/http";
import { Observable, BehaviorSubject } from "rxjs";
import { tap } from "rxjs/operators";

@Injectable({
    providedIn: "root",
})
export class ApiService {
    private baseUrl = "http://localhost:8000/api/v1";
    private tokenSubject = new BehaviorSubject<string | null>(null);

    constructor(private http: HttpClient) {
        const token = localStorage.getItem("auth_token");
        if (token) {
            this.tokenSubject.next(token);
        }
    }

    private getHeaders(): HttpHeaders {
        const token = this.tokenSubject.value;
        return new HttpHeaders({
            "Content-Type": "application/json",
            Accept: "application/json",
            ...(token && { Authorization: `Bearer ${token}` }),
        });
    }

    login(email: string, password: string): Observable<any> {
        return this.http
            .post(`${this.baseUrl}/auth/login`, { email, password })
            .pipe(
                tap((response: any) => {
                    if (response.success) {
                        const { token, user } = response.data;
                        localStorage.setItem("auth_token", token);
                        localStorage.setItem("user", JSON.stringify(user));
                        this.tokenSubject.next(token);
                    }
                })
            );
    }

    logout(): Observable<any> {
        return this.http
            .post(
                `${this.baseUrl}/auth/logout`,
                {},
                {
                    headers: this.getHeaders(),
                }
            )
            .pipe(
                tap(() => {
                    localStorage.removeItem("auth_token");
                    localStorage.removeItem("user");
                    this.tokenSubject.next(null);
                })
            );
    }

    getCurrentUser(): Observable<any> {
        return this.http.get(`${this.baseUrl}/auth/user`, {
            headers: this.getHeaders(),
        });
    }

    getAvailability(
        startDate: string,
        endDate: string,
        sessionId?: number
    ): Observable<any> {
        let url = `${this.baseUrl}/calendar/availability?start_date=${startDate}&end_date=${endDate}`;
        if (sessionId) {
            url += `&session_id=${sessionId}`;
        }
        return this.http.get(url, { headers: this.getHeaders() });
    }

    createBooking(bookingData: any): Observable<any> {
        return this.http.post(`${this.baseUrl}/bookings`, bookingData, {
            headers: this.getHeaders(),
        });
    }

    getMyBookings(): Observable<any> {
        return this.http.get(`${this.baseUrl}/bookings/my`, {
            headers: this.getHeaders(),
        });
    }

    getMenu(): Observable<any> {
        return this.http.get(`${this.baseUrl}/members/menu`, {
            headers: this.getHeaders(),
        });
    }

    createOrder(orderData: any): Observable<any> {
        return this.http.post(`${this.baseUrl}/members/orders`, orderData, {
            headers: this.getHeaders(),
        });
    }
}
```

#### 2. Angular Component

```typescript
// components/booking/booking.component.ts
import { Component, OnInit } from "@angular/core";
import { FormBuilder, FormGroup, Validators } from "@angular/forms";
import { ApiService } from "../../services/api.service";

@Component({
    selector: "app-booking",
    templateUrl: "./booking.component.html",
    styleUrls: ["./booking.component.css"],
})
export class BookingComponent implements OnInit {
    bookingForm: FormGroup;
    sessions: any[] = [];
    availability: any = {};
    loading = false;
    error = "";

    constructor(private fb: FormBuilder, private apiService: ApiService) {
        this.bookingForm = this.fb.group({
            session_id: ["", Validators.required],
            booking_date: ["", Validators.required],
            adult_count: [1, [Validators.required, Validators.min(1)]],
            child_count: [0, [Validators.min(0)]],
            notes: [""],
        });
    }

    ngOnInit(): void {
        this.loadSessions();
        this.loadAvailability();
    }

    loadSessions(): void {
        this.apiService.getSessions().subscribe({
            next: (response) => {
                if (response.success) {
                    this.sessions = response.data;
                }
            },
            error: (error) => {
                console.error("Failed to load sessions:", error);
            },
        });
    }

    loadAvailability(): void {
        const startDate = new Date().toISOString().split("T")[0];
        const endDate = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
            .toISOString()
            .split("T")[0];

        this.apiService.getAvailability(startDate, endDate).subscribe({
            next: (response) => {
                if (response.success) {
                    this.availability = response.data.availability;
                }
            },
            error: (error) => {
                console.error("Failed to load availability:", error);
            },
        });
    }

    onSubmit(): void {
        if (this.bookingForm.valid) {
            this.loading = true;
            this.error = "";

            this.apiService.createBooking(this.bookingForm.value).subscribe({
                next: (response) => {
                    if (response.success) {
                        alert("Booking created successfully!");
                        this.bookingForm.reset();
                        this.loadAvailability();
                    } else {
                        this.error = response.message;
                    }
                    this.loading = false;
                },
                error: (error) => {
                    this.error = "Failed to create booking";
                    this.loading = false;
                },
            });
        }
    }

    get minDate(): string {
        return new Date().toISOString().split("T")[0];
    }

    getAvailableSlots(date: string): any[] {
        return this.availability[date] || [];
    }
}
```

```html
<!-- components/booking/booking.component.html -->
<div class="booking-container">
    <h2>Create New Booking</h2>

    <form [formGroup]="bookingForm" (ngSubmit)="onSubmit()">
        <div class="form-group">
            <label>Session</label>
            <select formControlName="session_id">
                <option value="">Select Session</option>
                <option *ngFor="let session of sessions" [value]="session.id">
                    {{ session.name }} ({{ session.start_time }} - {{
                    session.end_time }})
                </option>
            </select>
        </div>

        <div class="form-group">
            <label>Date</label>
            <input type="date" formControlName="booking_date" [min]="minDate" />
        </div>

        <div class="form-group">
            <label>Adults</label>
            <input
                type="number"
                formControlName="adult_count"
                min="1"
                max="10"
            />
        </div>

        <div class="form-group">
            <label>Children</label>
            <input
                type="number"
                formControlName="child_count"
                min="0"
                max="10"
            />
        </div>

        <div class="form-group">
            <label>Notes</label>
            <textarea formControlName="notes" rows="3"></textarea>
        </div>

        <button
            type="submit"
            [disabled]="bookingForm.invalid || loading"
            class="submit-btn"
        >
            {{ loading ? 'Creating...' : 'Create Booking' }}
        </button>

        <div *ngIf="error" class="error-message">{{ error }}</div>
    </form>
</div>
```

## 📱 Mobile App Integration

### React Native

```javascript
// services/api.js
import AsyncStorage from "@react-native-async-storage/async-storage";

const API_BASE_URL = "http://localhost:8000/api/v1";

class ApiService {
    async request(endpoint, options = {}) {
        const token = await AsyncStorage.getItem("auth_token");

        const config = {
            headers: {
                "Content-Type": "application/json",
                Accept: "application/json",
                ...(token && { Authorization: `Bearer ${token}` }),
            },
            ...options,
        };

        try {
            const response = await fetch(`${API_BASE_URL}${endpoint}`, config);
            const data = await response.json();

            if (!response.ok) {
                throw new Error(data.message || "Request failed");
            }

            return data;
        } catch (error) {
            throw error;
        }
    }

    async login(email, password) {
        const response = await this.request("/auth/login", {
            method: "POST",
            body: JSON.stringify({ email, password }),
        });

        if (response.success) {
            const { token, user } = response.data;
            await AsyncStorage.setItem("auth_token", token);
            await AsyncStorage.setItem("user", JSON.stringify(user));
        }

        return response;
    }

    async getMenu() {
        return this.request("/members/menu");
    }

    async createOrder(orderData) {
        return this.request("/members/orders", {
            method: "POST",
            body: JSON.stringify(orderData),
        });
    }
}

export default new ApiService();
```

### Flutter

```dart
// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';

  Future<Map<String, dynamic>> request(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final url = Uri.parse('$baseUrl$endpoint');

    http.Response response;

    switch (method.toUpperCase()) {
      case 'POST':
        response = await http.post(url, headers: headers, body: jsonEncode(body));
        break;
      case 'PUT':
        response = await http.put(url, headers: headers, body: jsonEncode(body));
        break;
      case 'DELETE':
        response = await http.delete(url, headers: headers);
        break;
      default:
        response = await http.get(url, headers: headers);
    }

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Request failed');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await request('/auth/login',
      method: 'POST',
      body: {'email': email, 'password': password}
    );

    if (response['success']) {
      final data = response['data'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token']);
      await prefs.setString('user', jsonEncode(data['user']));
    }

    return response;
  }

  Future<Map<String, dynamic>> getMenu() async {
    return request('/members/menu');
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    return request('/members/orders', method: 'POST', body: orderData);
  }
}
```

## 🔧 Testing Integration

### Jest Testing

```javascript
// __tests__/services/authService.test.js
import authService from "../services/authService";
import axios from "axios";

jest.mock("axios");

describe("AuthService", () => {
    beforeEach(() => {
        jest.clearAllMocks();
        localStorage.clear();
    });

    test("should login successfully", async () => {
        const mockResponse = {
            data: {
                success: true,
                data: {
                    token: "mock-token",
                    user: {
                        id: 1,
                        name: "Test User",
                        email: "test@example.com",
                    },
                },
            },
        };

        axios.post.mockResolvedValue(mockResponse);

        const result = await authService.login("test@example.com", "password");

        expect(result.success).toBe(true);
        expect(result.token).toBe("mock-token");
        expect(localStorage.getItem("auth_token")).toBe("mock-token");
    });

    test("should handle login failure", async () => {
        const mockError = {
            response: {
                data: { message: "Invalid credentials" },
            },
        };

        axios.post.mockRejectedValue(mockError);

        const result = await authService.login(
            "test@example.com",
            "wrong-password"
        );

        expect(result.success).toBe(false);
        expect(result.message).toBe("Invalid credentials");
    });
});
```

### Cypress E2E Testing

```javascript
// cypress/integration/booking.spec.js
describe("Booking Flow", () => {
    beforeEach(() => {
        cy.login("test@example.com", "password");
    });

    it("should create a booking successfully", () => {
        cy.visit("/booking");

        cy.get("[data-cy=session-select]").select("Morning Session");
        cy.get("[data-cy=date-input]").type("2024-01-15");
        cy.get("[data-cy=adult-count]").type("2");
        cy.get("[data-cy=child-count]").type("1");

        cy.get("[data-cy=submit-booking]").click();

        cy.get("[data-cy=success-message]").should(
            "contain",
            "Booking created successfully"
        );
    });

    it("should display validation errors", () => {
        cy.visit("/booking");

        cy.get("[data-cy=submit-booking]").click();

        cy.get("[data-cy=error-message]").should(
            "contain",
            "Session is required"
        );
    });
});
```

## 📚 Additional Resources

-   **[Complete API Documentation](./api/README.md)** - Full API documentation
-   **[Frontend Developer Guide](./frontend-developer-guide.md)** - Comprehensive frontend guide
-   **[Quick Reference](./api/quick-reference.md)** - Quick API reference
-   **[Testing Guide](./testing/README.md)** - Testing documentation

---

**Integration Examples Version**: 1.0.0  
**Last Updated**: December 2024
