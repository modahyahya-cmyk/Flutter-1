VendorHub — APK Installation Instructions
==========================================

This folder contains the production-ready APK files for all three mobile applications.

APK FILES:
----------

1. customer-app-production-release.apk
   - For end customers
   - Browse products, watch videos, place orders
   - Track deliveries in real-time

2. vendor-app-production-release.apk
   - For vendors/restaurant owners
   - Manage products, orders, inventory
   - Print thermal receipts
   - Multi-branch support

3. driver-app-production-release.apk
   - For delivery drivers
   - Accept deliveries, GPS tracking
   - Offline-first architecture
   - Earnings ledger

INSTALLATION:
------------

Method 1: Direct Installation
1. Transfer APK to an Android device
2. Enable "Install from Unknown Sources" in Settings
3. Tap the APK file to install
4. Grant the required permissions

Method 2: ADB Installation
1. Enable USB Debugging on the device
2. Connect the device to the computer
3. Run: adb install <apk-name>.apk

REQUIREMENTS:
------------
- Android 7.0 (API 24) or higher
- Minimum 2GB RAM
- 200MB available storage
- Active internet connection

FIRST TIME SETUP:
----------------
1. Install the appropriate APK
2. Launch the app
3. The app will prompt for the API URL (if not pre-configured)
4. Create an account or log in
5. Grant the necessary permissions (Location, Camera, Storage)

TROUBLESHOOTING:
---------------
- If installation fails, ensure "Unknown Sources" is enabled
- If the app crashes, check Android version compatibility
- For API connection issues, verify the server URL in app settings

For complete documentation, see: 04-Documentation/
