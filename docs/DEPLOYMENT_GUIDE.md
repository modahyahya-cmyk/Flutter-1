# Deployment Guide

## CI/CD (GitHub Actions)

The `.github/workflows/` directory contains:

- **`build-apk.yml`** — on push to `main`/`develop`/`release/*` or a `v*` tag:
  - runs `flutter analyze` + `dart format` + unit tests for all three apps
  - generates the Isar schemas for the driver app
  - builds multi-flavor (`production`/`staging`/`development`) APKs for all apps
  - runs the Laravel backend test suite against MySQL + Redis
  - assembles and uploads the CodeCanyon release package on tags
- **`pr-checks.yml`** — semantic PR titles + secret scanning on PRs
- **`release-drafter.yml`** — drafts a GitHub release from conventional commits

### Required secrets

```
CUSTOMER_KEYSTORE_BASE64 / _PASSWORD / _KEY_PASSWORD / _KEY_ALIAS
VENDOR_KEYSTORE_BASE64 / _PASSWORD / _KEY_PASSWORD / _KEY_ALIAS
DRIVER_KEYSTORE_BASE64 / _PASSWORD / _KEY_PASSWORD / _KEY_ALIAS
SLACK_WEBHOOK_URL
CODECOV_TOKEN            (optional)
```

### Generating a signing keystore

```bash
keytool -genkey -v -keystore customer-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias customer-key

base64 customer-keystore.jks | tr -d '\n' > customer-keystore.txt
```

## Releasing a version

```bash
git tag v1.0.0 && git push origin v1.0.0
```

The tag build compiles APKs, runs backend tests and assembles
`VendorHub-<version>-CodeCanyon.zip` automatically.

### Android flavors & signing

The CI builds the `production` / `staging` / `development` flavors and signs
release builds from `key.properties`. The exact `productFlavors`,
`signingConfig`, package IDs and required `AndroidManifest` permissions are in
`docs/release/ANDROID_BUILD_CONFIG.md`. The workflow bootstraps a missing
`android/` platform folder via `flutter create --platforms=android .`.

## Backend production checklist

See `docs/release/INSTALLATION.md` → "Production Deployment Checklist" for the
full list (app key, queue worker, supervisor, nginx, SSL, cron for scheduler).
