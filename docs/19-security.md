# VisionNote AI — Security Design Document

**Version:** 1.0  
**Date:** 2026-07-25  
**Author:** Staff Flutter Architect

---

## 1. Security Principles

1. **Data sovereignty:** All user data remains on-device by default. No telemetry, no analytics, no cloud storage unless explicitly opted in.
2. **Least privilege:** Only request permissions when needed, at the point of use.
3. **Defense in depth:** Multiple layers of protection for sensitive data.
4. **No hardcoded secrets:** API keys are user-provided and stored securely.

---

## 2. Permission Model

### 2.1 Android Permissions

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Android 13+ (API 33) granular media permissions -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<!-- Android 12 and below -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="29" />
```

### 2.2 iOS Permissions

```xml
<!-- Info.plist -->
<key>NSCameraUsageDescription</key>
<string>VisionNote AI needs camera access to scan documents</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>VisionNote AI needs photo library access to import images</string>
```

### 2.3 Runtime Permission Request

```dart
// Permission requests happen contextually, not at app startup
// Camera permission: requested when user taps Camera FAB
// Storage permission: requested when user exports a file

Future<bool> requestCameraPermission() async {
  final status = await Permission.camera.request();
  if (status.isGranted) return true;
  if (status.isPermanentlyDenied) {
    openAppSettings(); // Navigate user to system settings
  }
  return false;
}
```

---

## 3. API Key Security

### 3.1 Storage

```dart
// API keys NEVER stored in:
// - Hive (unencrypted)
// - SharedPreferences
// - Plain text files
// - Source code / environment variables in release builds

// ALWAYS stored in:
// - flutter_secure_storage (iOS Keychain / Android EncryptedSharedPreferences)
```

### 3.2 Usage

```dart
class SecureStorageService {
  static const _keyPrefix = 'visionnote_ai_key_';

  Future<void> saveApiKey(String provider, String key) async {
    await _storage.write(key: '$_keyPrefix$provider', value: key);
  }

  Future<String?> getApiKey(String provider) async {
    return _storage.read(key: '$_keyPrefix$provider');
  }

  Future<void> clearApiKey(String provider) async {
    await _storage.delete(key: '$_keyPrefix$provider');
  }
}
```

---

## 4. Network Security

### 4.1 TLS Configuration

```dart
// All AI API calls use HTTPS only
// Android: network_security_config.xml
// iOS: ATS (App Transport Security) enabled by default

// network_security_config.xml (Android)
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>

    <!-- Debug builds only: allow localhost for testing -->
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">10.0.2.2</domain>
        <domain includeSubdomains="true">localhost</domain>
    </domain-config>
</network-security-config>
```

### 4.2 No Telemetry

```dart
// VisionNote AI does NOT include:
// - Firebase Analytics
// - Crashlytics (MVP)
// - Sentry
// - Any analytics SDK

// All error reporting is opt-in, post-MVP
```

---

## 5. Data at Rest

### 5.1 Database Encryption

```dart
// MVP: Drift SQLite is unencrypted (local-only data)
// Post-MVP: Consider sqlcipher for encrypted database

// Drift connection with encryption (future):
Future<QueryExecutor> _openEncryptedDb() async {
  final file = File(join(await getDatabasesPath(), 'visionnote.db'));
  return NativeDatabase(file, setup: (db) {
    db.execute("PRAGMA key = '${_getDbKey()}'");
  });
}
```

### 5.2 Image Storage

```dart
// Images are stored in app-specific directory (not accessible by other apps)
// Android: Context.getFilesDir() → /data/data/com.visionnote.ai/files/
// iOS: NSDocumentDirectory

// Export files go to app cache, then shared via share sheet
// Files in cache can be cleared by system
```

---

## 6. Input Validation

### 6.1 OCR Text

```dart
// OCR output is user-editable text — sanitize before storage
class Sanitizer {
  static String sanitizeOcrText(String text) {
    return text
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '') // Strip control chars
        .trim();
  }
}
```

### 6.2 API Key Validation

```dart
class ApiKeyValidator {
  static String? validateGeminiKey(String key) {
    if (key.isEmpty) return 'API key is required';
    if (!key.startsWith('AIza')) return 'Invalid Gemini key format';
    if (key.length < 30) return 'Key is too short';
    return null; // Valid
  }

  static String? validateOpenAIKey(String key) {
    if (key.isEmpty) return 'API key is required';
    if (!key.startsWith('sk-')) return 'Invalid OpenAI key format';
    if (key.length < 40) return 'Key is too short';
    return null; // Valid
  }
}
```

---

## 7. Secure Coding Practices

| Practice | Application |
|---|---|
| No hardcoded secrets | API keys are user-provided |
| Input sanitization | OCR text sanitized before storage |
| Exception handling | All FFI calls wrapped in try-catch |
| Logging | No logging of PII or API keys |
| Dependency scanning | `flutter pub audit` before release |
| Code obfuscation | `--obfuscate` flag for release builds |
| ProGuard (Android) | ProGuard rules to strip unused code |

---

## 8. Privacy Considerations

### 8.1 Data Collection

```dart
// No data is collected by default in MVP
// Future analytics require:
// 1. Explicit consent dialog
// 2. Privacy policy link in Settings > About
// 3. Ability to delete all analytics data
```

### 8.2 Data Deletion

```dart
// User can delete all their data:
Future<void> deleteAllUserData() async {
  // 1. Delete database
  await _db.close();
  await deleteDatabase(await getDatabasesPath());

  // 2. Delete all files
  final dir = Directory(await getApplicationDocumentsDirectory());
  await dir.delete(recursive: true);

  // 3. Clear secure storage
  await _secureStorage.deleteAll();

  // 4. Clear Hive
  await Hive.deleteFromDisk();
}
```

---

## 9. Secure Build Configuration

```gradle
// android/app/build.gradle
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'),
                          'proguard-rules.pro'
        }
    }
}
```

```ruby
# ios/Podfile
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BITCODE_GENERATION_MODE'] = 'bitcode'
    end
  end
end
```
