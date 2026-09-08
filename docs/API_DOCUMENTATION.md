# VendorHub API Documentation

Base URL: `https://api.yourdomain.com/api/v1`

All requests and responses are JSON. Authenticated endpoints use
`Authorization: Bearer <token>`. The API exposes four guards: **customer**,
**vendor**, **driver** and **admin**.

---

## Standard Response Shapes

All responses are wrapped:

```json
{ "success": true, "message": "Success", "data": { } }
```

**Paginated**
```json
{ "success": true, "message": "Success", "data": [ ], "meta": { "current_page": 1, "per_page": 15, "total": 42 } }
```

**Validation error (422)**
```json
{ "message": "The given data was invalid.", "errors": { "email": ["The email field is required."] } }
```

**Error**
```json
{ "message": "Unauthenticated." }
```

**API overview** — `GET /documentation` returns the machine-readable
endpoint map (referenced by the `docs` key in the root web response).

---

## Auth (Customer)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Register a customer |
| POST | `/auth/login` | Login (identifier + password) |
| POST | `/auth/refresh` | Refresh the access token |
| POST | `/auth/logout` | Logout |
| POST | `/auth/forgot-password` | Send a reset link |
| POST | `/auth/reset-password` | Reset the password |

Login body: `{ "identifier": "...", "password": "..." }`
Response: `{ "access_token": "...", "refresh_token": "...", "token_type": "Bearer", "user": { } }`

---

## Auth (Vendor)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/vendor/auth/register` | Register a vendor |
| POST | `/vendor/auth/login` | Login (`{ "identifier", "password", "guard": "vendor" }`) |
| POST | `/vendor/auth/logout` | Logout |
| GET | `/vendor/profile` | Current vendor profile |
| GET | `/vendor/orders` | Vendor orders (`?status=`) |
| PATCH | `/vendor/orders/{id}/status` | Update order status `{ status }` |
| GET | `/vendor/products` | Vendor products |
| POST | `/vendor/products` | Create product |
| PUT | `/vendor/products/{id}` | Update product |
| PATCH | `/vendor/products/{id}/toggle-active` | Toggle active |
| GET | `/vendor/branches` | Vendor branches |
| POST | `/vendor/branches` | Create branch |
| PUT | `/vendor/branches/{id}` | Update branch |
| GET | `/vendor/earnings` | Earnings summary |

---

## Auth (Driver)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/driver/auth/register` | Register a driver |
| POST | `/driver/auth/login` | Login (`{ "phone", "password", "guard": "driver" }`) |
| POST | `/driver/auth/logout` | Logout |
| GET | `/driver/profile` | Driver profile |
| GET | `/driver/deliveries` | Assigned deliveries (`?status=`) |
| POST | `/driver/deliveries/{id}/accept` | Accept delivery |
| PATCH | `/driver/deliveries/{id}/status` | Update delivery status |
| POST | `/driver/deliveries/{id}/complete` | Complete with proof |
| POST | `/driver/deliveries/sync` | Batch sync offline deliveries |
| POST | `/driver/location/batch` | Batch upload location points |
| GET | `/driver/earnings` | Earnings summary |
| POST | `/driver/earnings/sync` | Sync local earnings ledger |

---

## Customer (authenticated)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/customer/auth/logout` | Logout (revokes the current session) |
| GET | `/customer/profile` | Current customer |
| POST | `/customer/profile` | Update profile |
| POST | `/customer/profile/password` | Change password |
| GET | `/customer/cart` | Current cart |
| POST | `/customer/cart/items` | Add item `{ "product_id", "quantity", "product_variant_id"? }` |
| PUT | `/customer/cart/items/{cartItem}` | Update quantity |
| DELETE | `/customer/cart/items/{cartItem}` | Remove item |
| DELETE | `/customer/cart` | Clear cart |
| GET | `/customer/orders` | My orders (`?per_page=`) |
| POST | `/customer/orders` | Place an order (see contract below) |
| GET | `/customer/orders/{id}` | Order detail (own orders only) |
| POST | `/customer/orders/{id}/cancel` | Cancel (pending/confirmed only) |
| POST | `/customer/payments` | Initialize a payment `{ "order_id", "provider" }` |
| GET | `/customer/payments/{reference}` | Payment status |
| GET | `/customer/videos/{id}/like` | Like a video |
| GET | `/customer/subscriptions/plans` | Subscription plans |
| POST | `/customer/subscriptions` | Subscribe `{ "plan_id" }` |
| GET | `/customer/subscriptions/me` | My subscription |
| POST | `/customer/subscriptions/{id}/cancel` | Cancel subscription |

**Order creation contract** (`POST /customer/orders`)

- `vendor_id` (required) — all items must belong to this vendor.
- `items[].product_id`, `items[].quantity` (required),
  `items[].product_variant_id` (optional).
- `payment_method` — one of `stripe`, `paystack`, `razorpay`, `paypal`,
  `cash_on_delivery` (default: the configured gateway). Prices are always
  re-read from the catalogue server-side; client-supplied prices are ignored.
- Only products with status `active` (and active variants) can be ordered;
  anything else is rejected with 422.
- `customer_notes` — free-text note stored on the order and returned in the
  order payload.
- `idempotency_key` (optional) — retrying with the same key returns the
  original order instead of creating a duplicate.

---

## Public

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/documentation` | Machine-readable endpoint overview |
| GET | `/products` | Catalogue |
| GET | `/products/featured` | Featured products |
| GET | `/products/best-sellers` | Best sellers |
| GET | `/products/search` | Search (`?q=`) |
| GET | `/products/{id}` | Product detail |
| GET | `/videos` | Video feed |
| GET | `/videos/{id}` | Video detail |
| POST | `/webhooks/stripe` | Stripe webhook (provider-signed) |

---

## Error Codes

| Code | Meaning |
|------|---------|
| 400 | Bad request |
| 401 | Unauthenticated / token invalid |
| 403 | Forbidden |
| 404 | Not found |
| 422 | Validation failed |
| 429 | Rate limited |
| 500 / 502 / 503 / 504 | Server error |

---

## Postman

A ready-to-import Postman collection can be generated from the routes
(`php artisan route:list`); place it under `06-Assets/postman/`.
