# VendorHub API Documentation

Base URL: `https://api.yourdomain.com/api/v1`

All requests and responses are JSON. Authenticated endpoints use
`Authorization: Bearer <token>`. The API exposes four guards: **customer**,
**vendor**, **driver** and **admin**.

---

## Standard Response Shapes

**Success**
```json
{ "data": { } }
```

**Paginated**
```json
{ "data": [ ], "links": { }, "meta": { "current_page": 1, "per_page": 15, "total": 42 } }
```

**Validation error (422)**
```json
{ "message": "The given data was invalid.", "errors": { "email": ["The email field is required."] } }
```

**Error**
```json
{ "message": "Unauthenticated." }
```

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

## Public

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/products` | Catalogue (`?category=&featured=`) |
| GET | `/products/{id}` | Product detail |
| GET | `/categories` | Categories |
| GET | `/videos` | Video feed |
| GET | `/vendors/{id}` | Vendor storefront |
| GET | `/branches` | Branches |

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
