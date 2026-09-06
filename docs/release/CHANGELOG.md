# Changelog

All notable changes to VendorHub are documented in this file.

## [1.0.0] - 2026-08-29

### Added
- Complete multi-vendor e-commerce platform (backend + 3 mobile apps)
- TikTok-style short video commerce with instant purchase
- Real-time order & delivery tracking
- ESC/POS thermal receipt printing over Bluetooth
- Offline-first architecture with Isar local database + sync queue
- Background GPS location tracking (battery-aware logging, batch upload)
- Multiple payment gateways behind one abstraction (Stripe, Paystack, Razorpay, COD)
- Zero-cost OpenStreetMap integration with hot-swappable provider
- Multi-branch vendor support (geo-fencing, operating hours)
- Subscription plan management
- Driver earnings ledger with daily/weekly/monthly summaries
- Single-file white-label configuration for all apps
- Clean Architecture across backend and mobile
- Full GitHub Actions CI/CD pipeline with multi-flavor APK builds
- Complete CodeCanyon release packaging workflow

### Technical Highlights
- Laravel 11 backend with JWT multi-guard auth and rate limiting
- Flutter 3.24+ apps using GetX, Isar and Dio
- MySQL/PostgreSQL database, Redis caching and queue workers
- Input sanitization, XSS/SQL-injection/CSRF protection

---
