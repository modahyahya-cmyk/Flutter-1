# VendorHub — Multi-Vendor E-Commerce & Delivery Ecosystem

A white-label multi-vendor e-commerce platform with delivery logistics, video
commerce, subscriptions, offline-first mobile apps and ESC/POS thermal receipt
printing. This repository is a **monorepo** containing the Laravel API backend
and three Flutter applications sharing a single-source-of-truth white-label
configuration.

---

## Repository Layout

```
vendorhub-ecosystem/
├── backend/                 # Laravel 11 REST API (Clean Architecture)
│   ├── app/
│   │   ├── Core/            # Domain (interfaces/entities) + Infrastructure (impl)
│   │   └── Models/          # Eloquent models
│   ├── config/              # app_settings.php = white-label master config
│   ├── database/
│   │   ├── migrations/      # 18 tables
│   │   ├── seeders/
│   │   └── factories/
│   ├── routes/
│   └── tests/
├── mobile/                  # Flutter monorepo (3 apps)
│   ├── customer_app/
│   ├── vendor_app/
│   └── driver_app/
├── docs/                    # Architecture & ADRs
└── Makefile
```

---

## Tech Stack

| Layer          | Technology                                        |
|----------------|---------------------------------------------------|
| Backend        | Laravel 11, PHP 8.3, MySQL/Postgres, Redis queue  |
| Auth           | JWT (multi-guard: customer / vendor / driver / admin) |
| Mobile         | Flutter / Dart, Clean Architecture (data·domain·presentation) |
| Maps           | OpenStreetMap (zero-cost default), Google/Maps/Mapbox hot-swap |
| Payments       | Stripe / Paystack / Razorpay / PayPal abstraction |
| Notifications  | Firebase FCM / OneSignal / Twilio SMS abstraction |
| Local storage  | Isar + Hive offline-first sync (driver app)         |
| Printing       | ESC/POS Bluetooth thermal receipt printing          |

---

## Quick Start

### Backend

```bash
cd backend
cp .env.example .env
composer install
php artisan key:generate
# IMPORTANT: a signing secret is REQUIRED; the auth layer fails closed (refuses
# to issue/validate tokens) when it is missing. Use a strong random value:
php -r "echo bin2hex(random_bytes(64));"
# -> paste the output as JWT_SECRET in .env
php artisan migrate --seed
php artisan serve
```

### Flutter apps

```bash
cd mobile/customer_app      # vendor_app and driver_app are built the same way
flutter pub get
flutter run
```

### Verification

```bash
# Backend
cd backend && php artisan test && php artisan route:list

# Each app
cd mobile/customer_app && flutter analyze && flutter test && flutter build apk --release
```

> **Honest status:** the codebase is production-oriented and the backend is
> hardened (fail-closed JWT, token typing + session revocation, account
> lockout, rate limiting, transactional role registration, centralized
> authorization, authoritative order/delivery state machines, idempotent
> order/payment/webhook flows). Android projects exist for all three apps.
> **iOS projects are not yet generated** and **no Flutter/Android/iOS/`php
> artisan` build has been executed in a toolchain in this repo's CI**, so the
> apps and APKs should be built and verified locally (or in CI) before
> release. Payment webhooks require a live provider secret to enable.

---

## White-Labelling (Rebrand in One File)

| App                | File                              |
|--------------------|-----------------------------------|
| Backend            | `backend/config/app_settings.php`  |
| Customer app       | `mobile/customer_app/lib/config/app_config.dart` |
| Vendor app         | `mobile/vendor_app/lib/config/app_config.dart`    |
| Driver app         | `mobile/driver_app/lib/config/app_config.dart`    |

Change the app name, colors, currency, map/payment/notification providers and
feature flags in these files and the whole ecosystem rebrands.

---

## Build Status

> See `docs/ROADMAP.md` for the module-by-module status. Core architecture,
> configuration and the authentication / product / order / payment vertical
> slices are implemented. See `docs/INSTALLATION` and the CI workflows for how
> to build and verify the three apps and the backend.

## License

Proprietary / commercial. For licencing terms contact the vendor.
