# VendorHub — Multi-Vendor E-Commerce & Delivery Platform

Version: **v1.0.0**

## Package Contents

This package contains the complete source code and compiled APKs for the
VendorHub ecosystem — a production-ready, white-label multi-vendor marketplace
with video commerce, real-time delivery tracking and an offline-first driver
app.

### Included Applications

1. **Customer App** — video commerce, catalogue browsing, orders, subscriptions, maps
2. **Vendor App** — product & order management, inventory, branches, ESC/POS thermal printing, earnings
3. **Driver App** — delivery management, background GPS tracking, offline-first sync, earnings ledger
4. **Backend API** — Laravel 11 RESTful API with clean architecture + seeded demo data

## APK Files (Folder `01-APK-Files`)

- `customer-app-production-release-v1.0.0-buildN.apk`
- `vendor-app-production-release-v1.0.0-buildN.apk`
- `driver-app-production-release-v1.0.0-buildN.apk`

## Quick Start

See `INSTALLATION.md` in the Documentation folder for the full step-by-step setup.

## Documentation Set

- `README.md` — this overview
- `INSTALLATION.md` — step-by-step installation & deployment
- `API_DOCUMENTATION.md` — complete REST API reference
- `USER_GUIDE.md` — end-user manuals for all three apps
- `DEVELOPER_GUIDE.md` — technical architecture & customization
- `WHITE_LABEL_GUIDE.md` — rebranding / white-labeling instructions
- `DEPLOYMENT_GUIDE.md` — production infrastructure
- `SECURITY_BEST_PRACTICES.md` — hardening checklist
- `FAQ.md` — frequently asked questions
- `TROUBLESHOOTING.md` — common issues & fixes
- `CHANGELOG.md` — version history

## Key Features

- ✅ Multi-vendor marketplace with commissions & vendor earnings
- ✅ TikTok-style short video commerce with instant purchase
- ✅ Real-time order & delivery tracking
- ✅ ESC/POS thermal receipt printing over Bluetooth
- ✅ Offline-first architecture (Isar local database + sync queue)
- ✅ Background GPS tracking with battery-aware logging
- ✅ Multiple payment gateways (Stripe, Paystack, Razorpay, COD) behind one abstraction
- ✅ Zero-cost OpenStreetMap integration
- ✅ Multi-branch vendor support
- ✅ Subscription plans system
- ✅ Full white-label configuration from a single file
- ✅ CI/CD pipeline (GitHub Actions) with multi-flavor APK builds

## Technical Stack

**Backend:** Laravel 11 · PHP 8.3+ · MySQL 8 / PostgreSQL 13 · Redis · Clean Architecture · JWT

**Mobile:** Flutter 3.24+ · GetX · Isar · Clean Architecture · Dio

## Support

For support please contact: **support@vendorhub.com**

## License

- **Regular License** — single end product
- **Extended License** — multiple end products / SaaS

See `LICENSE.txt` for complete terms.
