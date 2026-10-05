# QwikGrocery (Problem Statement 85)

[![Flutter](https://img.shields.io/badge/Flutter-3.35+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Material 3](https://img.shields.io/badge/Material_3-Supported-green)](https://m3.material.io)
[![Express.js](https://img.shields.io/badge/Express-4.x-black?logo=express)](https://expressjs.com)
[![Firebase](https://img.shields.io/badge/Firebase-Auth_%26_Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)

**QwikGrocery** is a comprehensive, production-grade quick-commerce grocery delivery system built in accordance with **Problem Statement 85**. It provides a centralized interface for instant product discovery, shopping cart management, real-time animated delivery route tracking, wallet auto-debits, and recurring scheduled orders.

---

## Architecture Overview

The system is organized into two independent sub-projects:

1. **`QuickGroceryApp/`**: Responsive client application built with **Flutter (Material 3)** targeting Android, iOS, and Web.
   - Clean state management using `CartController` / `CartScope` with zero mock data on the frontend.
   - Direct Firebase Authentication (Email/Password & Google Sign-in) with automatic session recovery.
   - Live stream polling and reactive lifecycle updates.
2. **`QuickGroceryAPI/`**: REST API built with **Node.js, Express, and Firebase Admin SDK**.
   - Verified bearer authentication via Firebase ID tokens.
   - Atomic Firestore transactions for stock validation, cart checkout, wallet debits, and scheduled orders.
   - Background lifecycle runner advancing orders through:
     $$\text{placed} \xrightarrow{\text{4s}} \text{confirmed} \xrightarrow{\text{6s}} \text{preparing} \xrightarrow{\text{6s}} \text{out\_for\_delivery} \xrightarrow{\text{12s}} \text{delivered}$$
   - Background scheduler processing active recurring subscriptions every 30 seconds.

---

## Features & Problem Statement Alignment

| PS 85 Objective | Implemented Solution |
|---|---|
| **Grocery Dashboard** | Blinkit-style dashboard with dynamic 10-minute delivery ETA pill, saved address selector, clickable deals carousel, shop-by-category rail, and responsive product grid. |
| **Product Discovery & Search** | Full-text search with regional Hindi/Marathi aliases (e.g., *batata*, *dhaniya*, *aata*) and typo tolerance, category filters, and product details with image gallery and pack sizes. |
| **Cart & Checkout** | Global cart badge, interactive quantity steppers, bill tally (subtotal, delivery fee, platform fee), address selector, and dual payment support (**QwikWallet** demo balance and Cash on Delivery). |
| **Delivery Tracking** | Live step-by-step order progression (`placed` $\rightarrow$ `delivered`), color-coded status badges, compact order IDs, order itemization cards, and interactive OpenStreetMap with route highlight following Kharghar’s street grid. |
| **Schedule / Recurring Orders** | Complete recurring subscription management: daily/weekly/biweekly/monthly intervals, time-of-day selection, wallet auto-pay, pause/reactivate toggle with greyed-out visual indicator, and deletion confirmation dialog. |
| **QwikWallet Ledger** | In-app demo digital wallet supporting simulated instant top-ups, transaction ledger history, and automatic scheduled order deductions. |
| **Staff Order Management** | Dedicated role-based staff dashboard accessible only to users with the `staff: true` custom claim to monitor and advance live orders across the hub. |

---

## Project Structure

```text
Flutter_Sem_Project/
├── PS.md                             # Problem Statement 85 specifications
├── README.md                         # Project documentation and setup guide
├── QuickGroceryAPI/                  # Backend Express REST API
│   ├── data/catalog.seed.json        # 56 authentic Indian grocery listings
│   ├── scripts/
│   │   ├── seedProducts.js           # Firestore catalog seeder
│   │   ├── createStaffUser.js        # Dedicated staff account provisioning
│   │   └── setStaffClaim.js          # Admin custom claim manager
│   ├── src/
│   │   ├── config/db.js              # Firebase Admin SDK & Firestore initialization
│   │   ├── middleware/auth.js        # Token verification & staff guard
│   │   ├── models/                   # Schema references (Order, Product, Subscription, Wallet)
│   │   ├── router/                   # Express routes (orders, products, profile, subscriptions, wallet)
│   │   ├── services/                 # Order lifecycle runner & subscription scheduler
│   │   ├── app.js                    # Express app configuration & CORS
│   │   └── server.js                 # Server entry point & startup reconciler
│   └── package.json
└── QuickGroceryApp/                  # Frontend Flutter Application
    ├── lib/
    │   ├── components/               # Reusable UI widgets (ProductCard, DealsCarousel, CategoryRail, etc.)
    │   ├── core/theme/               # Material 3 colors, typography, and styling
    │   ├── models/                   # Dart data models with JSON serialization
    │   ├── screens/
    │   │   ├── auth/                 # Sign-in & registration
    │   │   ├── cart/                 # Shopping cart view & quantity adjustments
    │   │   ├── catalog/              # Search & category browsing
    │   │   ├── checkout/             # Order confirmation & payment
    │   │   ├── home/                 # Grocery dashboard
    │   │   ├── orders/               # Order history & live delivery tracking
    │   │   ├── products/             # Product detail pages
    │   │   ├── profile/              # Customer profile & saved addresses
    │   │   ├── staff/                # Staff-only fulfillment dashboard
    │   │   ├── store/                # Responsive root shell (Rail & BottomNav)
    │   │   ├── subscriptions/        # Schedule recurring orders
    │   │   └── wallet/               # QwikWallet top-up & ledger
    │   ├── services/                 # API client & session manager
    │   └── main.dart                 # Application entry point
    └── pubspec.yaml
```

---

## Setup & Running Locally

### 1. Prerequisites
- **Flutter SDK**: 3.35.x or higher
- **Node.js**: v18.x or higher
- **Firebase Account**: with Firestore & Authentication enabled

### 2. Backend API Setup
```bash
cd QuickGroceryAPI

# Install dependencies
npm install

# Seed the 56 authentic catalog products into Firestore
npm run seed:products

# (Optional) Provision demo staff user
npm run staff:setup

# Start API server on http://localhost:4000
npm run dev
```

### 3. Frontend App Setup
```bash
cd QuickGroceryApp

# Get Flutter packages
flutter pub get

# Run on Web (Chrome)
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:4000/api

# Or build release for Web
flutter build web --no-tree-shake-icons
```

---

## API Specification

All routes are prefixed with `/api`. Protected routes require `Authorization: Bearer <Firebase_ID_Token>`.

| Method | Endpoint | Access | Description |
|---|---|---|---|
| `GET` | `/health` | Public | Health check (`{"status":"ok"}`). |
| `GET` | `/products` | Public | Catalog listing with optional `search`, `category`, and `available` filters. |
| `GET` | `/products/:id` | Public | Product details. |
| `GET` | `/orders` | Customer | Order history for current authenticated user. |
| `POST` | `/orders` | Customer | Places a new order with atomic stock verification and wallet debit. |
| `GET` | `/orders/:id` | Owner | Order details and live delivery status. |
| `PATCH` | `/orders/:id/status` | Staff | Updates status (`confirmed`, `preparing`, `out_for_delivery`, `delivered`, `cancelled`). |
| `GET` | `/orders/staff` | Staff | Latest orders for fulfillment dashboard. |
| `GET` | `/wallet` | Customer | Current wallet balance and transaction ledger. |
| `POST` | `/wallet/topups` | Customer | Simulated top-up of demo credits. |
| `GET` | `/subscriptions` | Customer | List of scheduled/recurring orders. |
| `POST` | `/subscriptions` | Customer | Creates a new recurring schedule with frequency and start time. |
| `PATCH` | `/subscriptions/:id` | Owner | Edits schedule or toggles `{active: boolean}` to pause/reactivate. |
| `DELETE`| `/subscriptions/:id` | Owner | Permanently deletes a scheduled recurring order. |

---

## License & Attribution
- OpenStreetMap map tiles are used for demo delivery routing under the Open Database License.
- Sourced Indian grocery imagery and metadata are used for educational academic demonstration purposes.
