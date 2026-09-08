# VendorHub — Build & Delivery Roadmap

This document tracks the state of each module of the ecosystem. The repository is
built as a monorepo and delivered in milestones; each milestone exposes a working
vertical slice before mass-producing the remaining modules.

Legend: ✅ implemented · 🔄 following pattern (pending) · ⏳ planned

---

## Backend (`backend/`)

### ✅ Implemented
- **White-label config** — `config/app_settings.php` (single source of truth).
- **Database** — all migrations (19 tables + 3 alterations: users, vendors,
  branches, categories, products, product_variants, orders, order_items,
  drivers, deliveries, carts, cart_items, videos, subscription_plans,
  subscriptions, payments, addresses, reviews, location_history).
- **Eloquent models** — full relationships & casts for all tables.
- **Clean Architecture** — Domain (8 repo interfaces + 6 service interfaces),
  Infrastructure (8 Eloquent repos + auth/order/payment/notification/subscription
  services), Presentation (controllers, requests, resources, middleware).
- **Auth** — multi-guard JWT (customer/vendor/driver/admin) via `JwtAuthService`
  + role middleware; register/login/refresh/logout/forgot-reset.
- **Vertical slice end-to-end** — register → login → products → cart → order →
  payment-orchestration. Real HTTP paths, FormRequests, API Resources.
- **Payment abstraction** — `PaymentGatewayInterface` + Stripe / Paystack /
  Razorpay / Cash-on-Delivery adapters.
- **Notification abstraction** — Firebase FCM & OneSignal adapters behind a
  façade.
- **Middleware** — JWT role auth, API rate limiting, input sanitization (XSS).
- **Exception handling** — unified JSON API error contract.
- **Seeders, factories, PHPUnit tests, console command** (subscription expiring).

### 🔄 Following the established pattern (pending)
- Vendor: Inventory management, Earnings/settlement ledger.
- Driver: full Isar offline sync service, background location service.
- Video encoding pipeline, coupon engine, loyalty points (feature-flagged).
- Web admin panel (`app/Presentation/Web/Admin`).

---

## Mobile (`mobile/`)

### Customer app
- ✅ White-label `app_config.dart`, theme, GoRouter, full GetIt DI registry,
  Dio client + Auth/Logging/Error interceptors, `ApiClient` with typed
  `AppException` mapping, `NetworkInfo` (connectivity + internet checker),
  secure/local storage (impl pattern).
- ✅ Full Clean Architecture features: Auth, Products, Cart (remote + local
  cache), Orders, Subscriptions, Video feed, Map — each with
  entity → model → datasource → repository → use case → controller → UI.
- ✅ UI pages: login, register, home (featured products), products + detail
  sheet, cart with quantity controls + totals, video feed (vertical),
  subscription plans, orders, OSM map page.
- 🔄 Checkout → payment flow, deep linking, analytics, push notification
  token registration.

### Vendor app
- ✅ White-label config, theme, full GetIt DI registry, Dio client +
  Auth/Logging/Error interceptors, `ApiClient` with typed `AppException`
  mapping, `NetworkInfo`, secure/local storage, typed exceptions & failures.
- ✅ Full Clean Architecture features: Auth, Orders, Products, Inventory
  (offline-first with local cache + sync), Branches, Thermal Printing
  (Bluetooth ESC/POS via `flutter_bluetooth_serial`), Earnings — each with
  entity → model → datasource → repository → use case → controller → UI.
- ✅ UI pages: login, dashboard shell (bottom nav), orders list/detail with
  accept/reject/status flow, products CRUD + form, inventory with stock
  adjust/sync + offline badge, branches CRUD + form, earnings dashboard, and a
  thermal printer page (discover/connect/test-print).
- 🔄 Live POS order auto-refresh, analytics, push notification token
  registration.

### Driver app
- ✅ White-label config, theme, full GetIt DI registry, Dio client +
  Auth/Logging/Error interceptors, typed `ApiClient` exception mapping,
  `NetworkInfo` (connectivity + internet checker), secure/local storage.
- ✅ **Offline-first Isar local database** (4 collections: deliveries,
  location logs, earnings, sync queue) behind an `IsarService`.
- ✅ Full Clean Architecture features: Auth, Deliveries, Location Tracking,
  Earnings — each with entity → model → datasource → repository → use case →
  GetX controller → UI.
- ✅ Background GPS tracking (geolocator foreground service) with battery-aware
  logging, batch upload (100/cycle), 7-day retention and retry on reconnect.
- ✅ Delivery lifecycle (accept → pickup → in-transit → complete) with
  proof-of-delivery camera capture, optimistic local-first sync queue.
- ✅ Earnings ledger with daily/weekly/monthly/all summaries and offline
  fallback.
- ✅ UI: login, driver shell (Deliveries / Earnings / Tracking tabs), delivery
  list + detail with accept/pickup/complete actions, earnings dashboard,
  tracking control & DB stats page.

> **Codegen note:** the four Isar `*.g.dart` schema files are produced by
> `dart run build_runner build --delete-conflicting-outputs` (run from
> `driver_app/` after `flutter pub get`). They could not be generated in the
> authoring sandbox (no Flutter/Dart toolchain) and the models/`IsarService`
> rely on that single codegen step. `isar_generator` + `build_runner` are
> already declared in `dev_dependencies`.

---

## How to verify / run

Toolchains are not installed in the authoring sandbox, so code was authored to
standard Laravel 12 / Flutter conventions. To verify locally:

```bash
# Backend
cd backend && composer install && cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan test
php artisan serve

# Flutter (each app)
cd mobile/customer_app && flutter pub get && flutter analyze && flutter run
```

## Milestone plan

1. ✅ M1 — Repo foundation, white-label configs, migrations, models.
2. ✅ M2 — Clean Architecture layering, auth, product/cart/order slice, tests.
3. 🔄 M3 — Payments & webhook flows, notifications wiring, admin approval UX.
4. 🔄 M4 — Customer app checkout + video commerce + subscriptions UI.
5. ✅ M5 — Vendor app orders + inventory + thermal printing.
6. ✅ M6 — Driver app offline-first delivery + background GPS tracking.
7. ✅ M7 — CI/CD pipeline (multi-flavor APK builds, tests, security checks),
   CodeCanyon release packaging, docs & deployment configs.

---

## 6.x — CI/CD & CodeCanyon Release

- GitHub Actions workflows: `build-apk.yml` (analyze → format → test →
  multi-flavor APK builds → backend tests → CodeCanyon package on tags),
  `pr-checks.yml` (semantic PR + secret scan), `release-drafter.yml`.
- `.github/release-drafter.yml` config for conventional-commit release drafts.
- Release docs & templates under `docs/release/` and `docs/` (installation,
  API, user/developer/white-label/deployment/security guides, FAQ,
  troubleshooting, changelog, LICENSE, requirements, quick start, item
  description, submission checklist).
- DB schema is versioned in Laravel migrations (authoritative) and packaged
  into `05-Database/migrations`; see `backend/database/SCHEMA_README.md`.
