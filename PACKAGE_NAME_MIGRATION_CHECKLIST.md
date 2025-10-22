# 📋 Package Name & App Name Migration Checklist

## 🎯 Khi đổi Package Name và App Name, cần rà soát các files sau:

### **1. Android Configuration Files**

#### **📱 android/app/build.gradle**
```gradle
android {
    namespace "com.highmyx.pdfreaderapp"  // ✅ Package name
    defaultConfig {
        applicationId "com.highmyx.pdfreaderapp"  // ✅ Package name
    }
}
```

#### **📱 android/app/src/main/AndroidManifest.xml**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.highmyx.pdfreaderapp">  <!-- ✅ Package name -->
    
    <application
        android:label="High PDF Reader"  <!-- ✅ App name -->
        android:name="${applicationName}">
```

#### **📱 android/app/src/main/kotlin/com/highmyx/pdfreaderapp/MainActivity.kt**
```kotlin
package com.highmyx.pdfreaderapp  // ✅ Package name

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
}
```

### **2. Firebase Configuration**

#### **🔥 android/app/google-services.json**
```json
{
  "project_info": {
    "project_id": "high-pdfreader",  // ✅ Project ID
    "storage_bucket": "high-pdfreader.firebasestorage.app"  // ✅ Storage bucket
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:563840946041:android:80e8f97b25d0810346e9a8",
        "android_client_info": {
          "package_name": "com.highmyx.pdfreaderapp"  // ✅ Package name
        }
      }
    }
  ]
}
```

#### **🔥 lib/config/firebase_config.dart**
```dart
class FirebaseConfig {
  static const String projectId = 'high-pdfreader';  // ✅ Project ID
  static const String storageBucket = 'high-pdfreader.appspot.com';  // ✅ Storage bucket
}
```

### **3. Flutter Configuration**

#### **📱 pubspec.yaml**
```yaml
name: pdf_reader  # ✅ App name (internal)
description: "High PDF Reader - Advanced PDF management app"  # ✅ Description
version: 1.0.0+1  # ✅ Version
```

#### **📱 lib/main.dart**
```dart
class PDFReaderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'High PDF Reader',  // ✅ App title
      // ...
    );
  }
}
```

### **4. Documentation Files**

#### **📚 FIREBASE_SETUP.md**
```markdown
# Firebase Setup for High PDF Reader

## Package Name: com.highmyx.pdfreaderapp
## App Name: High PDF Reader
## Project ID: high-pdfreader
```

#### **📚 README.md**
```markdown
# High PDF Reader

Advanced PDF management app with cloud sync and AI features.

- Package: com.highmyx.pdfreaderapp
- App Name: High PDF Reader
```

### **5. Files cần XÓA khi đổi package name**

#### **🗑️ Old MainActivity (nếu có)**
```bash
# Xóa MainActivity cũ
rm -rf android/app/src/main/java/com/example/
rm -rf android/app/src/main/kotlin/com/example/
```

#### **🗑️ Old package directories**
```bash
# Xóa các thư mục package cũ
rm -rf android/app/src/main/java/com/oldpackage/
rm -rf android/app/src/main/kotlin/com/oldpackage/
```

---

## 🔄 **Migration Process**

### **Step 1: Backup**
```bash
git add .
git commit -m "Backup before package name change"
```

### **Step 2: Update Files**
1. ✅ Update `android/app/build.gradle`
2. ✅ Update `android/app/src/main/AndroidManifest.xml`
3. ✅ Create new `MainActivity.kt` with correct package
4. ✅ Delete old `MainActivity.java`
5. ✅ Update `android/app/google-services.json`
6. ✅ Update `lib/config/firebase_config.dart`
7. ✅ Update documentation files

### **Step 3: Clean & Rebuild**
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

### **Step 4: Test**
```bash
flutter install
flutter logs  # Check for crashes
```

---

## 🚨 **Common Issues & Solutions**

### **Issue 1: ClassNotFoundException**
```
Error: Didn't find class "com.newpackage.MainActivity"
```
**Solution:** Tạo MainActivity mới với package name đúng

### **Issue 2: Firebase not working**
```
Error: Firebase project not found
```
**Solution:** Update `google-services.json` và `firebase_config.dart`

### **Issue 3: App name not updated**
```
Error: App still shows old name
```
**Solution:** Update `AndroidManifest.xml` và `main.dart`

---

## 📝 **Quick Reference**

| File | What to Change | Example |
|------|----------------|---------|
| `android/app/build.gradle` | `namespace`, `applicationId` | `com.highmyx.pdfreaderapp` |
| `AndroidManifest.xml` | `package`, `android:label` | `High PDF Reader` |
| `MainActivity.kt` | `package` | `com.highmyx.pdfreaderapp` |
| `google-services.json` | `package_name` | `com.highmyx.pdfreaderapp` |
| `firebase_config.dart` | `projectId`, `storageBucket` | `high-pdfreader` |
| `main.dart` | `title` | `High PDF Reader` |

---

## ✅ **Verification Checklist**

- [ ] App launches without crash
- [ ] App name shows correctly
- [ ] Firebase connection works
- [ ] Supabase connection works
- [ ] No old package references
- [ ] All tests pass
- [ ] Documentation updated

---

**💡 Pro Tip:** Luôn chạy `flutter clean` sau khi đổi package name để tránh cache issues!
