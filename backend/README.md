# VendorHub Backend (Laravel 11)

REST API for the VendorHub multi-vendor e-commerce ecosystem, built with Clean
Architecture (Domain / Infrastructure / Presentation).

## Setup

```bash
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

Queue worker (Redis): `php artisan queue:work`

## Test

```bash
php artisan test
```

## Key directories

- `config/app_settings.php` — white-label master config (rebrand here).
- `app/Core/Domain` — repository & service interfaces (no DB/Framework logic).
- `app/Core/Infrastructure` — Eloquent repos + concrete services/adapters.
- `app/Core/Presentation/API/V1` — controllers, requests, resources, middleware.
- `database/migrations` — 18 tables.

## API

All endpoints are under `/api/v1`. See `routes/api.php`. Authentication is
multi-guard JWT (customer/vendor/driver/admin); send `Authorization: Bearer <token>`.

> Note: `Stripe`, `Paystack`, `Razorpay` adapters require their API keys in `.env`.
> OpenStreetMap is the zero-cost map default. Firebase credentials are loaded from
> `FIREBASE_CREDENTIALS` (see `app_settings.notifications`).
