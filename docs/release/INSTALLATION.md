# Installation Guide — VendorHub Platform

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Backend Installation](#backend-installation)
3. [Database Setup](#database-setup)
4. [Mobile App Configuration](#mobile-app-configuration)
5. [Production Deployment](#production-deployment)
6. [Troubleshooting](#troubleshooting)

---

## System Requirements

### Backend Server

- **OS:** Ubuntu 20.04+ / CentOS 8+ / Windows Server 2019+
- **Web Server:** Nginx 1.18+ or Apache 2.4+
- **PHP:** 8.3 or higher
- **Database:** MySQL 8.0+ or PostgreSQL 13+
- **Cache:** Redis 6.0+
- **Memory:** Minimum 2GB RAM (4GB recommended)
- **Storage:** 10GB available space

### Development Machine (for building APKs)

- **Flutter SDK:** 3.24.0 or higher
- **Android Studio:** Latest version
- **Java JDK:** 17 or higher
- **RAM:** 8GB minimum (16GB recommended)

---

## Backend Installation

### Step 1: Extract Files

```bash
cd /var/www
mkdir vendorhub && cd vendorhub
# Extract 02-Backend-Source folder contents here
```

### Step 2: Install Dependencies

```bash
composer install --optimize-autoloader --no-dev
```

### Step 3: Environment Configuration

```bash
cp .env.example .env
php artisan key:generate
```

Edit `.env` with your settings:

```ini
APP_NAME=VendorHub
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.yourdomain.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=vendorhub
DB_USERNAME=your_db_user
DB_PASSWORD=your_db_password

# REQUIRED: JWT signing secret (no fallback exists; auth fails closed if empty)
# Generate with: php -r "echo bin2hex(random_bytes(64));"
JWT_SECRET=

REDIS_HOST=127.0.0.1
REDIS_PORT=6379

STRIPE_PUBLIC_KEY=pk_live_xxxxx
STRIPE_SECRET_KEY=sk_live_xxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxx

MAP_PROVIDER=openstreetmap
# GOOGLE_MAPS_API_KEY=your_key (optional)
```

### Step 4: Database Migration

The preferred way to build the schema is the included migrations:

```bash
php artisan migrate --force
php artisan db:seed --class=DatabaseSeeder
```

If you instead have `05-Database/schema.sql` you may import it directly, then
run the seeders listed under [Database Setup](#database-setup).

### Step 5: Storage & Permissions

```bash
php artisan storage:link
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
```

### Step 6: Optimize for Production

```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache
```

### Step 7: Queue Worker Setup (Supervisor)

```ini
[program:vendorhub-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/vendorhub/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=4
redirect_stderr=true
stdout_logfile=/var/www/vendorhub/storage/logs/worker.log
stopwaitsecs=3600
```

```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start vendorhub-worker:*
```

### Step 8: Nginx Configuration

```nginx
server {
    listen 80;
    server_name api.yourdomain.com;
    root /var/www/vendorhub/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;
    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

```bash
sudo nginx -t && sudo systemctl reload nginx
```

### Step 9: SSL Certificate

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d api.yourdomain.com
```

---

## Database Setup

### Import the Schema (alternative to migrations)

```bash
mysql -u root -p vendorhub < 05-Database/schema.sql
```

### Seed Demo Data (optional)

```bash
mysql -u root -p vendorhub < 05-Database/demo_data.sql
# or, if using Laravel seeders:
php artisan db:seed --class=DatabaseSeeder
```

### Default Admin Login

After seeding, change the default credentials immediately:

- **URL:** `https://api.yourdomain.com/api/v1/admin/login`
- **Email:** `admin@vendorhub.com`
- **Password:** `Admin@123456`

---

## Mobile App Configuration

### Step 1: Update the API URL

Edit `app_config.dart` in each app:

```dart
// mobile/<app>/lib/config/app_config.dart
static const String BASE_API_URL = 'https://api.yourdomain.com/api/v1';
```

### Step 2: White-Label Branding

```dart
static const String APP_NAME = 'YourAppName';
static const Color PRIMARY_COLOR = Color(0xFF6366F1);
static const String COMPANY_NAME = 'Your Company Name';
```

### Step 3: Update Package Names

**Android (`android/app/build.gradle`):**

```gradle
applicationId "com.yourcompany.customer"
```

> **Note:** iOS projects are **not yet generated** for the three apps. The
> bundles above are provided for reference; build the Android APKs (all three
> apps ship an `android/` project) and add `flutter create --platforms ios .`
> under Xcode/macOS when you are ready to target iOS.

### Step 4: Build APKs

```bash
cd mobile/customer_app && flutter build apk --release
cd ../vendor_app     && flutter build apk --release
cd ../driver_app     && flutter build apk --release
```

APKs land in `build/app/outputs/flutter-apk/`.

> The driver app requires the Isar codegen step first:
> `cd mobile/driver_app && dart run build_runner build --delete-conflicting-outputs`

---

## Production Deployment Checklist

### Backend
- [ ] Change default admin password
- [ ] Configure payment gateway credentials
- [ ] Set up email SMTP settings
- [ ] Configure Firebase/OneSignal for push notifications
- [ ] Set up automatic database backups
- [ ] Configure queue workers
- [ ] Enable SSL
- [ ] Set `APP_DEBUG=false`
- [ ] Configure CORS
- [ ] Set up monitoring (optional: Sentry)

### Mobile
- [ ] Update API URL to production
- [ ] Change app name and branding
- [ ] Update package names
- [ ] Configure signing keys
- [ ] Test all payment gateways
- [ ] Test push notifications
- [ ] Upload to Google Play / Apple App Store

---

## Troubleshooting

Quick remediation for the most common issues:

- **500 errors:** `tail -f storage/logs/laravel.log`
- **Permissions:** `sudo chown -R www-data:www-data /var/www/vendorhub`
- **DB connection:** verify `.env` credentials, then `php artisan config:clear`
- **API unreachable from the app:** check `BASE_API_URL`, SSL, and `GET /api/v1/health`
- **Build failures:** `flutter clean && flutter pub get && flutter build apk --release`
- **GPS not working:** grant location permissions + background location (Android 10+)

See `TROUBLESHOOTING.md` for the full guide.

---

## Next Steps

1. Read `USER_GUIDE.md` for end-user instructions
2. Read `API_DOCUMENTATION.md` for API integration
3. Read `DEVELOPER_GUIDE.md` for customization

## Support

For technical support, contact **support@vendorhub.com**.
