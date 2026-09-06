# Troubleshooting

## Backend

**500 Internal Server Error**
```bash
tail -f storage/logs/laravel.log        # Laravel
tail -f /var/log/php8.3-fpm.log         # PHP-FPM
tail -f /var/log/nginx/error.log        # Nginx
```

**Permission denied**
```bash
sudo chown -R www-data:www-data /var/www/vendorhub
sudo chmod -R 775 storage bootstrap/cache
```

**Database connection failed**
```bash
mysql -u your_user -p -h 127.0.0.1     # test connectivity
php artisan config:clear               # clear cached config
```

**Migrations fail** — ensure `DB_*` env vars are correct and the database exists,
then `php artisan migrate --force`.

**Queues not processed** — confirm supervisor is running:
`sudo supervisorctl status vendorhub-worker:*`.

## Mobile apps

**API connection failed**
- Verify `BASE_API_URL` in the app config
- Check the SSL certificate is valid
- Hit the health endpoint in a browser: `https://api.yourdomain.com/api/v1/health`

**Build failures**
```bash
flutter clean && flutter pub get && flutter build apk --release --flavor production
```

**Driver app fails to compile / Isar errors**
```bash
cd mobile/driver_app
dart run build_runner build --delete-conflicting-outputs
```

**GPS not working**
- Grant foreground + background location permission (Android 10+)
- Ensure location services are enabled
- Verify Google Play Services installed

**Bluetooth printer not found**
- Enable Bluetooth and pair the printer
- Grant the app location permission (required for BLE scanning on Android)

**Offline changes not appearing on the server**
- Wait for the automatic sync interval or tap the manual Sync button
- Confirm the device has internet and the API is reachable

## CI/CD

**APK build fails on flavor** — ensure each app has `productFlavors` configured
in `android/app/build.gradle` for production/staging/development.

**Release signing fails** — verify all keystore secrets are set in
`Settings → Secrets and variables → Actions`.
