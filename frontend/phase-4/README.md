# Phase 4: Payment Interface & Manual Payment

## 📋 Overview

Implementasi interface pembayaran manual dengan upload bukti pembayaran, tracking status, dan konfirmasi pembayaran.

## 🎯 Objectives

- Payment form interface
- Manual payment upload interface
- Payment status tracking
- Receipt generation
- Payment history display
- Payment confirmation interface

## 📁 Files Structure

```
phase-4/
├── 01-payment-form.md
├── 02-payment-upload.md
├── 03-payment-tracking.md
├── 04-payment-history.md
└── 05-receipt-generation.md
```

## 🔧 Implementation Points

### Point 1: Payment Form Interface

**Subpoints:**

- Payment form component
- Payment method selection
- Amount calculation
- Form validation
- Error handling
- Loading states

**Files:**

- `components/payment/PaymentForm.tsx`
- `components/payment/PaymentMethodSelector.tsx`
- `components/payment/AmountCalculator.tsx`
- `hooks/usePayment.ts`
- `lib/payment-utils.ts`

### Point 2: Manual Payment Upload Interface

**Subpoints:**

- File upload component
- Image preview
- Upload validation
- Progress indicator
- Upload confirmation
- Error handling

**Files:**

- `components/payment/PaymentUpload.tsx`
- `components/payment/ImagePreview.tsx`
- `components/payment/UploadProgress.tsx`
- `hooks/useFileUpload.ts`
- `lib/upload-utils.ts`

### Point 3: Payment Status Tracking

**Subpoints:**

- Status indicator component
- Timeline component
- Real-time updates
- Status notifications
- Progress tracking
- Completion confirmation

**Files:**

- `components/payment/StatusIndicator.tsx`
- `components/payment/PaymentTimeline.tsx`
- `components/payment/StatusNotification.tsx`
- `hooks/usePaymentStatus.ts`
- `lib/status-utils.ts`

### Point 4: Payment History Display

**Subpoints:**

- Payment history list
- Payment details modal
- Filter and search
- Pagination
- Export functionality
- Analytics display

**Files:**

- `components/payment/PaymentHistory.tsx`
- `components/payment/PaymentDetails.tsx`
- `components/payment/PaymentFilter.tsx`
- `hooks/usePaymentHistory.ts`
- `lib/history-utils.ts`

### Point 5: Receipt Generation

**Subpoints:**

- Receipt component
- PDF generation
- Print functionality
- Email receipt
- Receipt sharing
- Receipt storage

**Files:**

- `components/payment/Receipt.tsx`
- `components/payment/PDFGenerator.tsx`
- `components/payment/PrintReceipt.tsx`
- `hooks/useReceipt.ts`
- `lib/receipt-utils.ts`

## 📦 Dependencies

### Payment Dependencies

```json
{
  "react-hook-form": "^7.48.0",
  "zod": "^3.22.0",
  "@hookform/resolvers": "^3.3.0",
  "react-dropzone": "^14.2.0",
  "jsPDF": "^2.5.0",
  "react-to-print": "^2.14.0"
}
```

### UI Dependencies

```json
{
  "@headlessui/react": "^1.7.0",
  "@heroicons/react": "^2.0.0",
  "clsx": "^2.0.0",
  "tailwind-merge": "^2.0.0",
  "lucide-react": "^0.294.0"
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

### Payment Form Component

```typescript
import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { paymentSchema } from "@/lib/validations/payment";

interface PaymentFormProps {
  booking: Booking;
  onSuccess: (payment: Payment) => void;
}

export const PaymentForm = ({ booking, onSuccess }: PaymentFormProps) => {
  const [isLoading, setIsLoading] = useState(false);
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm({
    resolver: zodResolver(paymentSchema),
  });

  const onSubmit = async (data: PaymentFormData) => {
    setIsLoading(true);
    try {
      const payment = await createPayment({
        ...data,
        booking_id: booking.id,
        amount: booking.total_amount,
      });

      onSuccess(payment);
    } catch (error) {
      toast.error("Payment creation failed");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
      <div className="payment-summary bg-gray-50 p-4 rounded-lg">
        <h3 className="font-semibold text-lg mb-3">Payment Summary</h3>
        <div className="space-y-2">
          <div className="flex justify-between">
            <span>Booking Reference:</span>
            <span className="font-mono">{booking.booking_reference}</span>
          </div>
          <div className="flex justify-between">
            <span>Total Amount:</span>
            <span className="font-semibold">
              Rp {booking.total_amount.toLocaleString()}
            </span>
          </div>
        </div>
      </div>

      <div className="payment-method">
        <h3 className="text-lg font-semibold mb-4">Payment Method</h3>
        <div className="space-y-3">
          <label className="flex items-center p-3 border rounded-lg hover:bg-gray-50">
            <input
              type="radio"
              {...register("payment_method")}
              value="manual_transfer"
              className="mr-3"
            />
            <div>
              <div className="font-medium">Manual Transfer</div>
              <div className="text-sm text-gray-600">
                Transfer to our bank account and upload proof
              </div>
            </div>
          </label>
        </div>
      </div>

      <div className="bank-details">
        <h3 className="text-lg font-semibold mb-4">Bank Account Details</h3>
        <div className="bg-blue-50 p-4 rounded-lg space-y-2">
          <div className="flex justify-between">
            <span>Bank:</span>
            <span className="font-mono">Bank Central Asia (BCA)</span>
          </div>
          <div className="flex justify-between">
            <span>Account Number:</span>
            <span className="font-mono">1234567890</span>
          </div>
          <div className="flex justify-between">
            <span>Account Holder:</span>
            <span className="font-mono">Kolam Renang Syariah</span>
          </div>
        </div>
      </div>

      <button
        type="submit"
        disabled={isLoading}
        className="w-full bg-blue-600 text-white py-3 px-4 rounded-md hover:bg-blue-700 disabled:opacity-50"
      >
        {isLoading ? "Creating Payment..." : "Create Payment"}
      </button>
    </form>
  );
};
```

### Payment Upload Component

```typescript
import { useCallback } from "react";
import { useDropzone } from "react-dropzone";
import { Upload, X, CheckCircle } from "lucide-react";

interface PaymentUploadProps {
  paymentId: string;
  onUploadSuccess: (file: File) => void;
}

export const PaymentUpload = ({
  paymentId,
  onUploadSuccess,
}: PaymentUploadProps) => {
  const [uploadedFile, setUploadedFile] = useState<File | null>(null);
  const [isUploading, setIsUploading] = useState(false);

  const onDrop = useCallback(
    async (acceptedFiles: File[]) => {
      const file = acceptedFiles[0];
      setUploadedFile(file);
      setIsUploading(true);

      try {
        const formData = new FormData();
        formData.append("payment_proof", file);
        formData.append("payment_id", paymentId);

        await uploadPaymentProof(formData);
        onUploadSuccess(file);
        toast.success("Payment proof uploaded successfully");
      } catch (error) {
        toast.error("Upload failed");
        setUploadedFile(null);
      } finally {
        setIsUploading(false);
      }
    },
    [paymentId, onUploadSuccess]
  );

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      "image/*": [".jpeg", ".jpg", ".png", ".gif"],
    },
    maxFiles: 1,
    maxSize: 5 * 1024 * 1024, // 5MB
  });

  const removeFile = () => {
    setUploadedFile(null);
  };

  return (
    <div className="space-y-4">
      <div className="text-center">
        <h3 className="text-lg font-semibold mb-2">Upload Payment Proof</h3>
        <p className="text-gray-600">
          Upload a screenshot or photo of your transfer receipt
        </p>
      </div>

      {!uploadedFile ? (
        <div
          {...getRootProps()}
          className={`border-2 border-dashed rounded-lg p-8 text-center cursor-pointer transition-colors ${
            isDragActive
              ? "border-blue-500 bg-blue-50"
              : "border-gray-300 hover:border-blue-400"
          }`}
        >
          <input {...getInputProps()} />
          <Upload className="mx-auto h-12 w-12 text-gray-400 mb-4" />
          {isDragActive ? (
            <p className="text-blue-600">Drop the file here...</p>
          ) : (
            <div>
              <p className="text-gray-600 mb-2">
                Drag and drop your payment proof, or click to select
              </p>
              <p className="text-sm text-gray-500">
                Supports: JPG, PNG, GIF (Max 5MB)
              </p>
            </div>
          )}
        </div>
      ) : (
        <div className="border rounded-lg p-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <CheckCircle className="h-5 w-5 text-green-500" />
              <span className="font-medium">{uploadedFile.name}</span>
            </div>
            <button
              onClick={removeFile}
              className="text-red-500 hover:text-red-700"
            >
              <X className="h-5 w-5" />
            </button>
          </div>
        </div>
      )}

      {isUploading && (
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-2 text-gray-600">Uploading...</p>
        </div>
      )}
    </div>
  );
};
```

### Payment Status Tracking Component

```typescript
import { useEffect, useState } from "react";
import { usePaymentStatus } from "@/hooks/usePaymentStatus";

interface PaymentStatusProps {
  paymentId: string;
}

export const PaymentStatus = ({ paymentId }: PaymentStatusProps) => {
  const { status, timeline, isLoading } = usePaymentStatus(paymentId);

  const getStatusColor = (status: string) => {
    switch (status) {
      case "pending":
        return "bg-yellow-500";
      case "verified":
        return "bg-green-500";
      case "rejected":
        return "bg-red-500";
      case "expired":
        return "bg-gray-500";
      default:
        return "bg-gray-500";
    }
  };

  const getStatusText = (status: string) => {
    switch (status) {
      case "pending":
        return "Pending Verification";
      case "verified":
        return "Payment Verified";
      case "rejected":
        return "Payment Rejected";
      case "expired":
        return "Payment Expired";
      default:
        return "Unknown Status";
    }
  };

  if (isLoading) {
    return (
      <div className="animate-pulse">
        <div className="h-4 bg-gray-200 rounded w-1/2 mb-2"></div>
        <div className="h-4 bg-gray-200 rounded w-3/4"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-3">
        <div className={`w-4 h-4 rounded-full ${getStatusColor(status)}`}></div>
        <span className="font-semibold">{getStatusText(status)}</span>
      </div>

      <div className="payment-timeline">
        <h4 className="font-semibold mb-4">Payment Timeline</h4>
        <div className="space-y-4">
          {timeline.map((event, index) => (
            <div key={index} className="flex items-start space-x-3">
              <div className="w-3 h-3 rounded-full bg-blue-500 mt-2"></div>
              <div className="flex-1">
                <div className="font-medium">{event.action}</div>
                <div className="text-sm text-gray-600">{event.timestamp}</div>
                {event.notes && (
                  <div className="text-sm text-gray-500 mt-1">
                    {event.notes}
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
```

### Payment History Component

```typescript
import { useState } from "react";
import { usePaymentHistory } from "@/hooks/usePaymentHistory";

export const PaymentHistory = () => {
  const [filter, setFilter] = useState("all");
  const [search, setSearch] = useState("");

  const { payments, isLoading, pagination } = usePaymentHistory({
    filter,
    search,
  });

  const formatAmount = (amount: number) => {
    return new Intl.NumberFormat("id-ID", {
      style: "currency",
      currency: "IDR",
    }).format(amount);
  };

  const getStatusBadge = (status: string) => {
    const statusConfig = {
      pending: { color: "bg-yellow-100 text-yellow-800", text: "Pending" },
      verified: { color: "bg-green-100 text-green-800", text: "Verified" },
      rejected: { color: "bg-red-100 text-red-800", text: "Rejected" },
      expired: { color: "bg-gray-100 text-gray-800", text: "Expired" },
    };

    const config = statusConfig[status] || statusConfig.pending;

    return (
      <span
        className={`px-2 py-1 rounded-full text-xs font-medium ${config.color}`}
      >
        {config.text}
      </span>
    );
  };

  if (isLoading) {
    return <div className="animate-pulse space-y-4">Loading...</div>;
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row gap-4">
        <div className="flex-1">
          <input
            type="text"
            placeholder="Search payments..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full px-3 py-2 border rounded-md"
          />
        </div>
        <select
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
          className="px-3 py-2 border rounded-md"
        >
          <option value="all">All Payments</option>
          <option value="pending">Pending</option>
          <option value="verified">Verified</option>
          <option value="rejected">Rejected</option>
          <option value="expired">Expired</option>
        </select>
      </div>

      <div className="space-y-4">
        {payments.map((payment) => (
          <div
            key={payment.id}
            className="border rounded-lg p-4 hover:bg-gray-50"
          >
            <div className="flex items-center justify-between">
              <div>
                <div className="font-medium">{payment.booking_reference}</div>
                <div className="text-sm text-gray-600">
                  {new Date(payment.created_at).toLocaleDateString()}
                </div>
              </div>
              <div className="text-right">
                <div className="font-semibold">
                  {formatAmount(payment.amount)}
                </div>
                {getStatusBadge(payment.status)}
              </div>
            </div>

            <div className="mt-3 flex gap-2">
              <button
                onClick={() => viewPaymentDetails(payment.id)}
                className="text-blue-600 hover:text-blue-800 text-sm"
              >
                View Details
              </button>
              {payment.status === "verified" && (
                <button
                  onClick={() => downloadReceipt(payment.id)}
                  className="text-green-600 hover:text-green-800 text-sm"
                >
                  Download Receipt
                </button>
              )}
            </div>
          </div>
        ))}
      </div>

      {pagination && (
        <div className="flex justify-center">
          <Pagination
            currentPage={pagination.current_page}
            totalPages={pagination.last_page}
            onPageChange={(page) => pagination.setPage(page)}
          />
        </div>
      )}
    </div>
  );
};
```

## 📱 Mobile Optimization

### Responsive Payment Form

```typescript
export const ResponsivePaymentForm = ({
  booking,
  onSuccess,
}: PaymentFormProps) => {
  const isMobile = useMediaQuery("(max-width: 768px)");

  return (
    <div className={`payment-container ${isMobile ? "mobile" : "desktop"}`}>
      {isMobile ? (
        <MobilePaymentForm booking={booking} onSuccess={onSuccess} />
      ) : (
        <DesktopPaymentForm booking={booking} onSuccess={onSuccess} />
      )}
    </div>
  );
};
```

## 🔄 State Management

### Payment Store (Zustand)

```typescript
import { create } from "zustand";

interface PaymentState {
  payments: Payment[];
  currentPayment: Payment | null;
  isLoading: boolean;

  fetchPayments: () => Promise<void>;
  createPayment: (paymentData: PaymentFormData) => Promise<Payment>;
  updatePayment: (id: string, data: Partial<Payment>) => Promise<void>;
  setCurrentPayment: (payment: Payment | null) => void;
}

export const usePaymentStore = create<PaymentState>((set, get) => ({
  payments: [],
  currentPayment: null,
  isLoading: false,

  fetchPayments: async () => {
    set({ isLoading: true });
    try {
      const response = await fetch("/api/payments");
      const payments = await response.json();
      set({ payments });
    } catch (error) {
      console.error("Failed to fetch payments:", error);
    } finally {
      set({ isLoading: false });
    }
  },

  createPayment: async (paymentData) => {
    const response = await fetch("/api/payments", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(paymentData),
    });

    const payment = await response.json();
    set((state) => ({ payments: [payment, ...state.payments] }));
    return payment;
  },

  updatePayment: async (id, data) => {
    const response = await fetch(`/api/payments/${id}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });

    const updatedPayment = await response.json();
    set((state) => ({
      payments: state.payments.map((p) => (p.id === id ? updatedPayment : p)),
    }));
  },

  setCurrentPayment: (payment) => set({ currentPayment: payment }),
}));
```

## 🧪 Testing

### Payment Component Testing

```typescript
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { PaymentForm } from "@/components/payment/PaymentForm";

describe("PaymentForm", () => {
  it("renders payment form with booking details", () => {
    const mockBooking = {
      id: "1",
      booking_reference: "BK001",
      total_amount: 150000,
    };

    render(<PaymentForm booking={mockBooking} onSuccess={() => {}} />);

    expect(screen.getByText("Booking Reference:")).toBeInTheDocument();
    expect(screen.getByText("BK001")).toBeInTheDocument();
    expect(screen.getByText("Rp 150,000")).toBeInTheDocument();
  });

  it("submits payment form successfully", async () => {
    const mockOnSuccess = jest.fn();
    const mockBooking = {
      id: "1",
      booking_reference: "BK001",
      total_amount: 150000,
    };

    render(<PaymentForm booking={mockBooking} onSuccess={mockOnSuccess} />);

    const submitButton = screen.getByRole("button", {
      name: /create payment/i,
    });
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockOnSuccess).toHaveBeenCalled();
    });
  });
});
```

## ✅ Success Criteria

- [ ] Payment form berfungsi dengan baik
- [ ] File upload interface responsif
- [ ] Payment status tracking real-time
- [ ] Payment history terdisplay
- [ ] Receipt generation berjalan
- [ ] Mobile optimization terpasang
- [ ] Error handling terimplementasi
- [ ] Loading states terpasang
- [ ] Testing coverage > 85%

## 📚 Documentation

- Payment Interface Guide
- File Upload Implementation
- Status Tracking Guide
- Receipt Generation Guide
- Mobile Optimization Guide
