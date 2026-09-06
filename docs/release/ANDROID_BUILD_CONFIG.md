# Android Build Configuration (Flavors & Signing)

The CI `build-apk.yml` builds each app with `--flavor production`,
`--flavor staging` and `--flavor development`. Those flavors must exist in each
app's `android/app/build.gradle`.

The `android/` platform folder is generated with:

```bash
flutter create --platforms=android .
```

(The CI workflow bootstraps it automatically if it is missing.)

## Add productFlavors

Inside `android/app/build.gradle`, under `android { ... }`, add:

```gradle
flavorDimensions += 'env'

productFlavors {
    production {
        dimension 'env'
        resValue "string", "app_name", "VendorHub"
        buildConfigField "String", "ENV", "\"production\""
    }
    staging {
        dimension 'env'
        resValue "string", "app_name", "VendorHub Staging"
        buildConfigField "String", "ENV", "\"staging\""
    }
    development {
        dimension 'env'
        resValue "string", "app_name", "VendorHub Dev"
        buildConfigField "String", "ENV", "\"development\""
    }
}
```

Set the `applicationId` per flavor (optional):

```gradle
productFlavors {
    production { applicationId "com.vendorhub.customer"; dimension 'env' }
    staging    { applicationId "com.vendorhub.customer.staging"; dimension 'env' }
    development{ applicationId "com.vendorhub.customer.dev"; dimension 'env' }
}
```

## Release signing

The workflow decodes a base64 keystore into `android/app/keystore.jks` and
creates `android/app/key.properties` for `release` builds. Reference it in
`android/app/build.gradle`:

```gradle
android {
    signingConfigs {
        release {
            storeFile file(System.getenv("STORE_FILE") ?: "keystore.jks")
            storePassword keystoreProperties['storePassword']
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled false
        }
    }
}
```

And load `key.properties` at the top of the file:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

## Required Android permissions (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION"/>
```

## Package identifiers

- Customer: `applicationId "com.vendorhub.customer"`
- Vendor: `applicationId "com.vendorhub.vendor"`
- Driver: `applicationId "com.vendorhub.driver"`
