# Database Schema

This folder contains the **authoritative, versioned database schema** as
Laravel migrations under `migrations/` (18 tables). The schema is applied with:

```bash
php artisan migrate --force
```

A `schema.sql` dump for reference or for importing into an existing server can
be produced at any time from a migrated database:

```bash
mysqldump -u root -p --no-data vendorhub > database/schema.sql
```

A `demo_data.sql` dump (sample records) can be produced after seeding:

```bash
php artisan db:seed --class=DatabaseSeeder
mysqldump -u root -p vendorhub > database/seeders/demo_data.sql
```

## Tables

| # | Table |
|---|-------|
| 1 | `users` |
| 2 | `vendors` |
| 3 | `branches` |
| 4 | `categories` |
| 5 | `drivers` |
| 6 | `videos` |
| 7 | `products` |
| 8 | `product_variants` |
| 9 | `orders` |
| 10 | `order_items` |
| 11 | `deliveries` |
| 12 | `carts` |
| 13 | `cart_items` |
| 14 | `subscription_plans` |
| 15 | `subscriptions` |
| 16 | `payments` |
| 17 | `addresses` |
| 18 | `reviews` |

## Seeders

Production demo data lives in the Laravel seeders under `seeders/`
(`DatabaseSeeder` includes `AdminUserSeeder`, `CategorySeeder` and
`SubscriptionPlanSeeder`).
