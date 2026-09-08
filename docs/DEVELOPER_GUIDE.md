# VendorHub Developer Guide

## Repository Layout

```
vendorhub-ecosystem/
├── backend/          Laravel 12 API (clean architecture)
│   ├── app/Domain            repo + service interfaces, entities
│   ├── app/Infrastructure    Eloquent repos, auth/order/payment services
│   ├── app/Presentation      controllers, requests, resources, middleware
│   └── database/             migrations, factories, seeders
├── mobile/
│   ├── customer_app/  Flutter customer app
│   ├── vendor_app/    Flutter vendor & POS app
│   └── driver_app/    Flutter offline-first driver app
├── docs/             Architecture, API & release documentation
└── .github/workflows/ CI/CD pipelines
```

## Architecture

Every Flutter app follows **Clean Architecture**:

```
Presentation (controllers / pages)
      ↓
Domain       (entities, repository contracts, use cases)
      ↓
Data         (models, datasources, repository implementations)
```

The backend layers are `Presentation` → `Infrastructure` → `Domain`.

### Dependency Injection

Each app bootstraps its object graph in `lib/config/dependency_injection.dart`
using GetIt (`getIt`). `main()` calls `setupDependencyInjection()` before
`runApp`.

### Offline-first (Driver app)

Isar collections (`delivery_local_model`, `location_log_model`,
`earnings_local_model`, `sync_queue_model`) back the offline cache behind
`IsarService`. After adding/editing a model, regenerate the schemas:

```bash
cd mobile/driver_app
dart run build_runner build --delete-conflicting-outputs
```

### Error handling

The `core/errors/` layer maps HTTP failures to a typed `AppException` hierarchy
and, in the driver app, to an `Either<Failure, T>` returned by use cases.

### White-labeling

All branding lives in a single file per app:
`lib/config/app_config.dart`. Edit colors, name, API URL and feature flags there.

## Adding a feature

1. Define the domain entity + repository contract + use cases.
2. Implement data models, datasources and the repository implementation.
3. Register everything in `dependency_injection.dart`.
4. Build the presentation controller + page and wire the route.
