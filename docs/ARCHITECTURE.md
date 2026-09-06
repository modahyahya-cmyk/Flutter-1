# Architecture

## Backend — Clean Architecture

```
Request → Middleware → Controller → Service (interface) → Repository (interface) → Eloquent
                               ↑ Application/Domain (interfaces)          ↓ Infrastructure (impl)
```

Layers:
- **Domain** — entity contracts, repository + service interfaces. No Laravel/DB
  knowledge. Lives in `app/Core/Domain`.
- **Infrastructure** — Eloquent repositories, concrete services (JWT, order
  processing, payments, notifications, billing), adapters. Lives in
  `app/Core/Infrastructure`.
- **Presentation** — controllers, FormRequests, API resources, middlewares.
  Lives in `app/Core/Presentation`.

Binding: `RepositoryServiceProvider` maps every interface to its implementation.

## White-labeling

All branding, features, payments, maps, notifications, business logic and locale
settings live in **one file per surface**:

| Surface       | File                                           |
|---------------|------------------------------------------------|
| Backend       | `backend/config/app_settings.php`              |
| Customer app  | `mobile/customer_app/lib/config/app_config.dart` |
| Vendor app    | `mobile/vendor_app/lib/config/app_config.dart`  |
| Driver app    | `mobile/driver_app/lib/config/app_config.dart`  |

Rebrand by editing these files; all UI, API keys, currency formatting, map
providers and feature flags resolve from them.

## Hot-swappable providers

- **Maps** — `MapProvider` enum + `app_settings['maps']`: OpenStreetMap is the
  zero-cost default; Google Maps / Mapbox enabled by supplying a key.
- **Payments** — `PaymentGatewayInterface` + adapters; default from
  `app_settings['payment_gateways']['default']`.
- **Notifications** — `NotificationServiceInterface` façade over Firebase /
  OneSignal selected by `app_settings['notifications']['default_channel']`.

## Auth

Multi-guard JWT (customer / vendor / driver / admin). Tokens are stateless
(HS256) with access + refresh claims. Role enforcement happens in the
`AuthenticateJwt` middleware subclasses (`CustomerAuth`, `VendorAuth`,
`DriverAuth`, `AdminAuth`). Token revoke hook exists for a Redis blacklist in a
future phase. Refresh `JWT_REFRESH_TTL` = 14 days.

## Offline-first (driver app)

Planned local persistence via **Isar + Hive** and a `SyncService` that replays
queued mutations when connectivity returns (`connectivity_plus`). `AppConfig`
drives sync intervals and offline queue limits.
