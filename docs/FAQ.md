# FAQ

**Q: What PHP version is required?**
A: PHP 8.3 or higher.

**Q: Which databases are supported?**
A: MySQL 8.0+ and PostgreSQL 13+.

**Q: Is video commerce included?**
A: Yes — the customer app ships a TikTok-style vertical video feed with instant
product purchase.

**Q: Are the maps free?**
A: Yes. The default provider is OpenStreetMap (zero cost). Google Maps can be
enabled by setting a key in the config.

**Q: Does thermal printing require special hardware?**
A: It requires an ESC/POS-capable Bluetooth printer. The vendor app discovers,
connects and prints receipts over Bluetooth.

**Q: Do the mobile apps work offline?**
A: The driver app is fully offline-first (Isar DB + sync queue). The vendor app
caches inventory. Designed changes sync automatically when connectivity returns.

**Q: Which payment gateways are supported?**
A: Stripe (default), Paystack, Razorpay and cash-on-delivery — all behind one
payment abstraction so more can be added.

**Q: Can I white-label / rebrand it?**
A: Yes. Edit the single `lib/config/app_config.dart` file in each app. See the
White-Label Guide.

**Q: How do I build the APKs for release?**
A: `flutter build apk --release --flavor production` in each app (run the Isar
codegen for the driver app first). The CI pipeline automates this.

**Q: Where do I change the default admin account?**
A: It is seeded as `admin@vendorhub.com` / `Admin@123456`. Change it immediately
after the first deploy.

**Q: Is support included?**
A: 6 months of support is included with purchase (see the license).
