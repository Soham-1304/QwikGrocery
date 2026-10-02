# QuickGrocery

QuickGrocery is split into two independent projects:

- `QuickGroceryApp` is the Flutter customer app for Android, iOS, and web.
- `QuickGroceryAPI` is the Express API. Flutter uses Firebase Authentication directly; Express verifies Firebase ID tokens with the Admin SDK and is the only application service that accesses Firestore.

The Firestore `products` collection is seeded with 56 sourced Indian grocery listings across 13 categories, including vegetables, fruits, 15 biscuit/snack choices, instant noodles and soup, pulses and lentils, dahi, milk, bread, and eggs, with large product photos, brands, pack sizes, retailer source links, and regional search aliases. Prices are retailer listing snapshots checked on 2026-10-02 and may vary by date and location. Starting stock counts are explicitly demo inventory and must be replaced with live inventory before accepting real orders. The catalog seed does not create customer accounts, orders, or delivery events.

## Project layout

```text
QuickGroceryAPI/
  data/catalog.seed.json
  scripts/seedProducts.js
  src/
    config/db.js
    middleware/auth.js
    models/{Order,Product,Subscription}.js
    router/{orderRouter,productRouter,subscriptionRouter}.js
    utils/http.js
    app.js
    server.js
QuickGroceryApp/lib/
  models/
  screens/{auth,cart,catalog,checkout,home,orders,products,store,subscriptions}/
  services/
  widgets/
```

Flutter screen files share the app's UI library so the existing navigation and private shared components stay consistent, while each screen now lives in a feature folder. Models are separated by data type.

## Setup

1. Create a Firebase project, enable Email/Password sign-in, and create a Firestore database.
2. The supplied service account has been copied to `QuickGroceryAPI/secrets/ServiceAccountKey.json`; `QuickGroceryAPI/src/config/db.js` loads it with Firebase Admin `cert()` and initializes Firestore. The original Downloads file is unchanged. `.env` sets project ID `qwikgrocery-22631`. Both the key file and `.env` are ignored by Git.
3. Flutter initializes Firebase from `QuickGroceryApp/lib/firebase_options.dart` using the supplied QuickGrocery web app configuration. Enable Email/Password and Google under Firebase Authentication sign-in providers if using both sign-in methods. Firebase client configuration is public app configuration; the service-account key remains backend-only.
4. Deploy `QuickGroceryAPI/firestore.rules`; the app accesses Firestore only through the Admin SDK in Express. Firebase Auth signs users in from Flutter and sends ID tokens to Express, which verifies them with Admin SDK.
5. Seed the catalog (stable document IDs; rerunning safely adds missing records and leaves existing inventory untouched):

   ```sh
   cd QuickGroceryAPI
   npm run seed:products
   ```

   Rerunning with `npm run seed:products -- --overwrite` refreshes sourced fields on those seed IDs. This also deactivates the original generic Unsplash starter records while retaining their Firestore documents for historical references. Catalog records include `brand`, `unit`, `aliases`, and `sourceUrl` alongside `name`, `category`, `priceCents` (integer paise), `imageUrl`, `description`, and `stock`. Search accepts regional names such as `batata`, `dhaniya`, and `aata`, plus common typing errors. There is no product-admin screen in this phase.
6. Start the API:

   ```sh
   cd QuickGroceryAPI
   npm install
   npm run dev
   ```

7. Resolve Flutter packages, then start the app with an API URL appropriate for the target device. Example for a local web session:

   ```sh
   cd QuickGroceryApp
   flutter pub get
   flutter run -d chrome \
     --dart-define=API_BASE_URL=http://localhost:4000/api
   ```

   Firebase Auth handles email/password and Google sign-in, persistence, and token refresh in Flutter. Protected API requests send a Firebase ID token to Express. Use a host-reachable API URL instead of `localhost` on a physical device. The provided Firebase options are for the web app; register/configure Android and iOS apps in Firebase before releasing native builds.

8. Delivery status changes are accepted only from Firebase users with the `staff: true` custom claim. The API exposes `PATCH /api/orders/:id/status`; no staff interface is part of the customer app. Tracking refreshes the persisted status on demand. No location or map is fabricated.

Use HTTPS for deployed API traffic. The web API origin must also be allowed by `ALLOWED_ORIGINS`.

## API contract

All API routes use the `/api` prefix. Errors have the shape `{ "error": "..." }`. Protected routes require `Authorization: Bearer <Firebase ID token>`.

| Route | Access | Request / response |
|---|---|---|
| `GET /health` | Public | Service health. |
| `GET /products?search=&category=&available=` | Public | List of active products; filters are optional. |
| `GET /products/:id` | Public | One active product, or `404`. |
| `GET /orders` | Signed in | Current customer’s orders. |
| `POST /orders` | Signed in | `{items:[{productId,quantity}],customerName,phone,address}` → created order. Prices and stock are read from Firestore in a transaction. |
| `GET /orders/:id` | Order owner | Order and persisted delivery status. |
| `PATCH /orders/:id/status` | Staff claim | `{status}` with `placed`, `confirmed`, `preparing`, `out_for_delivery`, `delivered`, or `cancelled`. Status cannot move backwards. |
| `GET /subscriptions` | Signed in | Current customer’s recurring orders. |
| `POST /subscriptions` | Signed in | `{productId,quantity,frequency,startDate,deliveryTime}`. |
| `PATCH /subscriptions/:id` | Owner | Update schedule/product/quantity or `{active:boolean}` to pause/reactivate. |

Order and subscription records are owned by the authenticated Firebase UID. Order creation checks current stock and decrements inventory atomically; the server calculates totals from Firestore prices.
