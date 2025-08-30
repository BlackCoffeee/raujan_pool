# Phase 6: Cafe Interface & Barcode Integration

## 📋 Overview

Implementasi interface cafe dengan barcode scanning, menu browsing, order management, dan inventory tracking.

## 🎯 Objectives

- Menu browsing interface
- Barcode scanning interface
- Order management interface
- Inventory tracking display
- Order status tracking
- Receipt generation

## 📁 Files Structure

```
phase-6/
├── 01-menu-browsing.md
├── 02-barcode-scanning.md
├── 03-order-management.md
├── 04-inventory-tracking.md
└── 05-order-tracking.md
```

## 🔧 Implementation Points

### Point 1: Menu Browsing Interface

**Subpoints:**

- Menu list component
- Menu categories
- Menu search and filter
- Menu details modal
- Menu recommendations
- Menu favorites

**Files:**

- `components/cafe/MenuList.tsx`
- `components/cafe/MenuCategories.tsx`
- `components/cafe/MenuSearch.tsx`
- `components/cafe/MenuDetails.tsx`
- `hooks/useMenu.ts`
- `lib/menu-utils.ts`

### Point 2: Barcode Scanning Interface

**Subpoints:**

- QR code scanner
- Barcode display
- Scan history
- Manual entry
- Scan validation
- Scan analytics

**Files:**

- `components/cafe/BarcodeScanner.tsx`
- `components/cafe/QRCodeDisplay.tsx`
- `components/cafe/ScanHistory.tsx`
- `components/cafe/ManualEntry.tsx`
- `hooks/useBarcode.ts`
- `lib/barcode-utils.ts`

### Point 3: Order Management Interface

**Subpoints:**

- Cart management
- Order form
- Order confirmation
- Order editing
- Order cancellation
- Order history

**Files:**

- `components/cafe/Cart.tsx`
- `components/cafe/OrderForm.tsx`
- `components/cafe/OrderConfirmation.tsx`
- `components/cafe/OrderHistory.tsx`
- `hooks/useOrder.ts`
- `lib/order-utils.ts`

### Point 4: Inventory Tracking Display

**Subpoints:**

- Stock levels display
- Low stock alerts
- Stock history
- Stock analytics
- Stock notifications
- Stock updates

**Files:**

- `components/cafe/InventoryDisplay.tsx`
- `components/cafe/StockAlerts.tsx`
- `components/cafe/InventoryHistory.tsx`
- `components/cafe/InventoryAnalytics.tsx`
- `hooks/useInventory.ts`
- `lib/inventory-utils.ts`

### Point 5: Order Status Tracking

**Subpoints:**

- Order status display
- Order timeline
- Order notifications
- Order completion
- Order feedback
- Order analytics

**Files:**

- `components/cafe/OrderStatus.tsx`
- `components/cafe/OrderTimeline.tsx`
- `components/cafe/OrderNotification.tsx`
- `components/cafe/OrderFeedback.tsx`
- `hooks/useOrderStatus.ts`
- `lib/order-status-utils.ts`

## 📦 Dependencies

### Cafe Interface Dependencies

```json
{
  "react-qr-reader": "^3.0.0",
  "html5-qrcode": "^2.3.0",
  "react-hook-form": "^7.48.0",
  "zod": "^3.22.0",
  "@hookform/resolvers": "^3.3.0",
  "react-hot-toast": "^2.4.0"
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
  "react-image-magnify": "^3.0.0"
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

### Menu List Component

```typescript
import { useState, useEffect } from "react";
import { useMenu } from "@/hooks/useMenu";
import { MenuCard } from "./MenuCard";
import { MenuFilter } from "./MenuFilter";

export const MenuList = () => {
  const [category, setCategory] = useState("all");
  const [search, setSearch] = useState("");
  const [sortBy, setSortBy] = useState("name");

  const { menuItems, categories, isLoading } = useMenu({
    category,
    search,
    sortBy,
  });

  if (isLoading) {
    return (
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {[1, 2, 3, 4, 5, 6].map((i) => (
          <div
            key={i}
            className="animate-pulse bg-gray-200 rounded-lg h-64"
          ></div>
        ))}
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Menu Filter */}
      <MenuFilter
        categories={categories}
        selectedCategory={category}
        onCategoryChange={setCategory}
        search={search}
        onSearchChange={setSearch}
        sortBy={sortBy}
        onSortChange={setSortBy}
      />

      {/* Menu Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {menuItems.map((item) => (
          <MenuCard key={item.id} item={item} />
        ))}
      </div>

      {menuItems.length === 0 && (
        <div className="text-center py-12">
          <div className="text-gray-500 text-lg">No menu items found</div>
          <p className="text-gray-400 mt-2">Try adjusting your filters</p>
        </div>
      )}
    </div>
  );
};
```

### Menu Card Component

```typescript
import { useState } from "react";
import { MenuItem } from "@/types/menu";
import { useCart } from "@/hooks/useCart";

interface MenuCardProps {
  item: MenuItem;
}

export const MenuCard = ({ item }: MenuCardProps) => {
  const [isAdding, setIsAdding] = useState(false);
  const { addToCart } = useCart();

  const handleAddToCart = async () => {
    setIsAdding(true);
    try {
      await addToCart({
        menu_item_id: item.id,
        quantity: 1,
        unit_price: item.price,
      });
      toast.success(`${item.name} added to cart`);
    } catch (error) {
      toast.error("Failed to add item to cart");
    } finally {
      setIsAdding(false);
    }
  };

  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow">
      {/* Menu Image */}
      <div className="relative h-48 bg-gray-200">
        {item.image_path ? (
          <img
            src={item.image_path}
            alt={item.name}
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center">
            <svg
              className="w-12 h-12 text-gray-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
              />
            </svg>
          </div>
        )}

        {!item.is_available && (
          <div className="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center">
            <span className="text-white font-semibold">Out of Stock</span>
          </div>
        )}
      </div>

      {/* Menu Details */}
      <div className="p-4">
        <div className="flex justify-between items-start mb-2">
          <h3 className="font-semibold text-lg text-gray-900">{item.name}</h3>
          <span className="text-lg font-bold text-blue-600">
            Rp {item.price.toLocaleString()}
          </span>
        </div>

        <p className="text-gray-600 text-sm mb-3 line-clamp-2">
          {item.description}
        </p>

        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-2">
            {item.calories && (
              <span className="text-xs text-gray-500">{item.calories} cal</span>
            )}
            {item.preparation_time && (
              <span className="text-xs text-gray-500">
                {item.preparation_time} min
              </span>
            )}
          </div>

          <button
            onClick={handleAddToCart}
            disabled={!item.is_available || isAdding}
            className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isAdding ? "Adding..." : "Add to Cart"}
          </button>
        </div>
      </div>
    </div>
  );
};
```

### Barcode Scanner Component

```typescript
import { useState, useRef } from "react";
import { Html5QrcodeScanner } from "html5-qrcode";
import { useBarcode } from "@/hooks/useBarcode";

export const BarcodeScanner = () => {
  const [scanning, setScanning] = useState(false);
  const [scannedCode, setScannedCode] = useState("");
  const scannerRef = useRef<Html5QrcodeScanner | null>(null);

  const { scanBarcode, isLoading } = useBarcode();

  const startScanning = () => {
    setScanning(true);
    scannerRef.current = new Html5QrcodeScanner(
      "qr-reader",
      { fps: 10, qrbox: { width: 250, height: 250 } },
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
    setScannedCode(decodedText);
    stopScanning();

    try {
      const result = await scanBarcode(decodedText);
      toast.success(`Found menu: ${result.menu_item.name}`);
    } catch (error) {
      toast.error("Invalid barcode or menu not found");
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
        <h2 className="text-xl font-semibold mb-2">Scan Menu QR Code</h2>
        <p className="text-gray-600">
          Point your camera at the QR code to view menu details
        </p>
      </div>

      {!scanning ? (
        <div className="text-center">
          <button
            onClick={startScanning}
            className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700"
          >
            Start Scanning
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

      {scannedCode && (
        <div className="bg-green-50 border border-green-200 rounded-lg p-4">
          <div className="text-center">
            <div className="text-green-800 font-medium">Scanned Code:</div>
            <div className="text-green-600 font-mono">{scannedCode}</div>
          </div>
        </div>
      )}
    </div>
  );
};
```

### Cart Component

```typescript
import { useState } from "react";
import { useCart } from "@/hooks/useCart";
import { CartItem } from "./CartItem";

export const Cart = () => {
  const { items, total, updateQuantity, removeItem, clearCart } = useCart();
  const [isCheckingOut, setIsCheckingOut] = useState(false);

  const handleCheckout = async () => {
    setIsCheckingOut(true);
    try {
      const order = await createOrder({
        items: items.map((item) => ({
          menu_item_id: item.menu_item_id,
          quantity: item.quantity,
          unit_price: item.unit_price,
        })),
        total_amount: total,
      });

      clearCart();
      router.push(`/orders/${order.id}/confirmation`);
    } catch (error) {
      toast.error("Failed to create order");
    } finally {
      setIsCheckingOut(false);
    }
  };

  if (items.length === 0) {
    return (
      <div className="text-center py-12">
        <div className="text-gray-500 text-lg mb-4">Your cart is empty</div>
        <p className="text-gray-400">
          Add some delicious items to get started!
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="text-xl font-semibold">Your Cart</h2>
        <button
          onClick={clearCart}
          className="text-red-600 hover:text-red-700 text-sm"
        >
          Clear Cart
        </button>
      </div>

      {/* Cart Items */}
      <div className="space-y-4">
        {items.map((item) => (
          <CartItem
            key={item.id}
            item={item}
            onUpdateQuantity={updateQuantity}
            onRemove={removeItem}
          />
        ))}
      </div>

      {/* Cart Summary */}
      <div className="border-t pt-4 space-y-3">
        <div className="flex justify-between text-sm">
          <span>Subtotal:</span>
          <span>Rp {total.toLocaleString()}</span>
        </div>
        <div className="flex justify-between text-sm">
          <span>Tax:</span>
          <span>Rp {(total * 0.1).toLocaleString()}</span>
        </div>
        <div className="flex justify-between font-semibold text-lg">
          <span>Total:</span>
          <span>Rp {(total * 1.1).toLocaleString()}</span>
        </div>
      </div>

      {/* Checkout Button */}
      <button
        onClick={handleCheckout}
        disabled={isCheckingOut}
        className="w-full bg-blue-600 text-white py-3 px-4 rounded-lg hover:bg-blue-700 disabled:opacity-50"
      >
        {isCheckingOut ? "Processing..." : "Checkout"}
      </button>
    </div>
  );
};
```

### Order Status Component

```typescript
import { useEffect, useState } from "react";
import { useOrderStatus } from "@/hooks/useOrderStatus";

interface OrderStatusProps {
  orderId: string;
}

export const OrderStatus = ({ orderId }: OrderStatusProps) => {
  const { order, status, timeline, isLoading } = useOrderStatus(orderId);

  const getStatusColor = (status: string) => {
    switch (status) {
      case "pending":
        return "bg-yellow-500";
      case "confirmed":
        return "bg-blue-500";
      case "preparing":
        return "bg-orange-500";
      case "ready":
        return "bg-green-500";
      case "delivered":
        return "bg-purple-500";
      case "cancelled":
        return "bg-red-500";
      default:
        return "bg-gray-500";
    }
  };

  const getStatusText = (status: string) => {
    switch (status) {
      case "pending":
        return "Pending Confirmation";
      case "confirmed":
        return "Order Confirmed";
      case "preparing":
        return "Preparing Your Order";
      case "ready":
        return "Order Ready for Pickup";
      case "delivered":
        return "Order Delivered";
      case "cancelled":
        return "Order Cancelled";
      default:
        return "Unknown Status";
    }
  };

  if (isLoading) {
    return <div className="animate-pulse h-32 bg-gray-200 rounded-lg"></div>;
  }

  return (
    <div className="space-y-6">
      {/* Order Status */}
      <div className="bg-white rounded-lg p-6 border">
        <h3 className="text-lg font-semibold mb-4">Order Status</h3>

        <div className="flex items-center space-x-3 mb-4">
          <div
            className={`w-4 h-4 rounded-full ${getStatusColor(status)}`}
          ></div>
          <span className="font-semibold">{getStatusText(status)}</span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="text-sm font-medium text-gray-600">
              Order Number
            </label>
            <p className="font-mono">{order?.order_number}</p>
          </div>
          <div>
            <label className="text-sm font-medium text-gray-600">
              Order Date
            </label>
            <p>{new Date(order?.created_at).toLocaleDateString()}</p>
          </div>
          <div>
            <label className="text-sm font-medium text-gray-600">
              Total Amount
            </label>
            <p className="font-semibold">
              Rp {order?.final_amount?.toLocaleString()}
            </p>
          </div>
          <div>
            <label className="text-sm font-medium text-gray-600">
              Estimated Ready Time
            </label>
            <p>
              {order?.estimated_ready_time
                ? new Date(order.estimated_ready_time).toLocaleTimeString()
                : "TBD"}
            </p>
          </div>
        </div>
      </div>

      {/* Order Timeline */}
      <div className="bg-white rounded-lg p-6 border">
        <h3 className="text-lg font-semibold mb-4">Order Timeline</h3>

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

      {/* Order Items */}
      <div className="bg-white rounded-lg p-6 border">
        <h3 className="text-lg font-semibold mb-4">Order Items</h3>

        <div className="space-y-3">
          {order?.order_items?.map((item) => (
            <div
              key={item.id}
              className="flex items-center justify-between p-3 border rounded-lg"
            >
              <div className="flex items-center space-x-3">
                <img
                  src={item.menu_item.image_path}
                  alt={item.menu_item.name}
                  className="w-12 h-12 rounded-lg object-cover"
                />
                <div>
                  <div className="font-medium">{item.menu_item.name}</div>
                  <div className="text-sm text-gray-600">
                    Qty: {item.quantity}
                  </div>
                </div>
              </div>
              <div className="text-right">
                <div className="font-semibold">
                  Rp {item.total_price.toLocaleString()}
                </div>
                <div className="text-sm text-gray-600">{item.status}</div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
```

## 📱 Mobile Optimization

### Responsive Cafe Interface

```typescript
export const ResponsiveCafeInterface = () => {
  const isMobile = useMediaQuery("(max-width: 768px)");

  return (
    <div className={`cafe-interface ${isMobile ? "mobile" : "desktop"}`}>
      {isMobile ? <MobileCafeInterface /> : <DesktopCafeInterface />}
    </div>
  );
};
```

## 🔄 State Management

### Cafe Store (Zustand)

```typescript
import { create } from "zustand";

interface CafeState {
  menuItems: MenuItem[];
  cart: CartItem[];
  orders: Order[];
  currentOrder: Order | null;
  isLoading: boolean;

  fetchMenu: () => Promise<void>;
  addToCart: (item: CartItem) => void;
  removeFromCart: (itemId: string) => void;
  updateCartQuantity: (itemId: string, quantity: number) => void;
  clearCart: () => void;
  createOrder: (orderData: OrderData) => Promise<Order>;
  fetchOrders: () => Promise<void>;
}

export const useCafeStore = create<CafeState>((set, get) => ({
  menuItems: [],
  cart: [],
  orders: [],
  currentOrder: null,
  isLoading: false,

  fetchMenu: async () => {
    set({ isLoading: true });
    try {
      const response = await fetch("/api/menu");
      const menuItems = await response.json();
      set({ menuItems });
    } catch (error) {
      console.error("Failed to fetch menu:", error);
    } finally {
      set({ isLoading: false });
    }
  },

  addToCart: (item) => {
    set((state) => {
      const existingItem = state.cart.find(
        (cartItem) => cartItem.menu_item_id === item.menu_item_id
      );

      if (existingItem) {
        return {
          cart: state.cart.map((cartItem) =>
            cartItem.menu_item_id === item.menu_item_id
              ? { ...cartItem, quantity: cartItem.quantity + item.quantity }
              : cartItem
          ),
        };
      }

      return { cart: [...state.cart, item] };
    });
  },

  removeFromCart: (itemId) => {
    set((state) => ({
      cart: state.cart.filter((item) => item.id !== itemId),
    }));
  },

  updateCartQuantity: (itemId, quantity) => {
    set((state) => ({
      cart: state.cart.map((item) =>
        item.id === itemId ? { ...item, quantity } : item
      ),
    }));
  },

  clearCart: () => set({ cart: [] }),

  createOrder: async (orderData) => {
    const response = await fetch("/api/orders", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(orderData),
    });

    const order = await response.json();
    set((state) => ({ orders: [order, ...state.orders] }));
    return order;
  },

  fetchOrders: async () => {
    const response = await fetch("/api/orders");
    const orders = await response.json();
    set({ orders });
  },
}));
```

## 🧪 Testing

### Cafe Component Testing

```typescript
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { MenuList } from "@/components/cafe/MenuList";
import { Cart } from "@/components/cafe/Cart";

describe("Cafe Interface", () => {
  it("renders menu list with items", () => {
    const mockMenuItems = [
      {
        id: "1",
        name: "Coffee",
        price: 25000,
        description: "Hot coffee",
        image_path: null,
        is_available: true,
      },
    ];

    render(<MenuList menuItems={mockMenuItems} />);

    expect(screen.getByText("Coffee")).toBeInTheDocument();
    expect(screen.getByText("Rp 25,000")).toBeInTheDocument();
  });

  it("allows adding items to cart", async () => {
    const mockAddToCart = jest.fn();
    const mockMenuItem = {
      id: "1",
      name: "Coffee",
      price: 25000,
    };

    render(<MenuCard item={mockMenuItem} onAddToCart={mockAddToCart} />);

    const addButton = screen.getByRole("button", { name: /add to cart/i });
    fireEvent.click(addButton);

    await waitFor(() => {
      expect(mockAddToCart).toHaveBeenCalledWith(mockMenuItem);
    });
  });

  it("displays cart total correctly", () => {
    const mockCartItems = [
      {
        id: "1",
        name: "Coffee",
        quantity: 2,
        unit_price: 25000,
        total_price: 50000,
      },
    ];

    render(<Cart items={mockCartItems} total={50000} />);

    expect(screen.getByText("Rp 50,000")).toBeInTheDocument();
  });
});
```

## ✅ Success Criteria

- [ ] Menu browsing interface berfungsi dengan baik
- [ ] Barcode scanning interface responsif
- [ ] Order management berjalan
- [ ] Inventory tracking terdisplay
- [ ] Order status tracking real-time
- [ ] Receipt generation berjalan
- [ ] Mobile optimization terpasang
- [ ] QR code scanning berfungsi
- [ ] Testing coverage > 85%

## 📚 Documentation

- Cafe Interface Guide
- Barcode Integration Guide
- Order Management Guide
- Inventory Tracking Guide
- Mobile Optimization Guide
