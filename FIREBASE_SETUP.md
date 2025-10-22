# 🔥 Firebase Setup cho PDF Reader App

## **📱 Android Configuration**

### **Package Name:**
```
com.highmyx.pdfreaderapp
```

### **App Name:**
```
High PDF Reader
```

---

## **🚀 Step-by-Step Setup**

### **Step 1: Tạo Firebase Project**

1. **Truy cập**: [console.firebase.google.com](https://console.firebase.google.com)
2. **Click "Create a project"**
3. **Project name**: `high-pdf-reader`
4. **Enable Google Analytics**: ✅
5. **Analytics account**: Create new hoặc chọn existing
6. **Click "Create project"**

### **Step 2: Add Android App**

1. **Click "Add app"** → **Android icon**
2. **Android package name**: `com.highmyx.pdfreaderapp`
3. **App nickname**: `High PDF Reader`
4. **Debug signing certificate SHA-1**: (để trống cho development)
5. **Click "Register app"**

### **Step 3: Download Configuration File**

1. **Download `google-services.json`**
2. **Place file in**: `android/app/google-services.json`
3. **Click "Next"**

### **Step 4: Add Firebase SDK**

1. **Click "Next"** (đã được cấu hình trong code)
2. **Click "Next"** (đã được cấu hình trong code)
3. **Click "Continue to console"**

### **Step 5: Enable Services**

#### **Analytics:**
1. **Go to Analytics** → **Events**
2. **Verify events are being tracked**

#### **Crashlytics:**
1. **Go to Crashlytics** → **Get started**
2. **Enable Crashlytics**

#### **Cloud Messaging:**
1. **Go to Cloud Messaging**
2. **Click "Get started"**

#### **Performance:**
1. **Go to Performance** → **Get started**
2. **Enable Performance Monitoring**

---

## **🔧 Configuration Files**

### **android/app/google-services.json**
```json
{
  "project_info": {
    "project_number": "123456789",
    "project_id": "high-pdf-reader",
    "storage_bucket": "high-pdf-reader.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789:android:abcdef123456",
        "android_client_info": {
          "package_name": "com.highmyx.pdfreaderapp"
        }
      },
      "api_key": [
        {
          "current_key": "AIzaSyC123456789abcdef"
        }
      ]
    }
  ]
}
```

### **android/app/build.gradle**
```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services"
    id "com.google.firebase.crashlytics"
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'com.google.firebase:firebase-crashlytics'
    implementation 'com.google.firebase:firebase-messaging'
}
```

### **android/build.gradle**
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
    classpath 'com.google.firebase:firebase-crashlytics-gradle:2.9.9'
}
```

---

## **📊 Analytics Events**

### **Custom Events:**
```dart
// PDF opened
FirebaseService.instance.logEvent('pdf_opened', parameters: {
  'file_size': fileSize,
  'file_type': 'pdf',
  'user_tier': isPremium ? 'premium' : 'free',
});

// PDF uploaded
FirebaseService.instance.logEvent('pdf_uploaded', parameters: {
  'file_size': fileSize,
  'upload_method': 'local',
});

// Premium purchased
FirebaseService.instance.logEvent('premium_purchased', parameters: {
  'product_id': productId,
  'price': price,
});
```

### **User Properties:**
```dart
// Set user tier
FirebaseService.instance.setUserProperty('user_tier', 'premium');

// Set registration date
FirebaseService.instance.setUserProperty('registration_date', DateTime.now().toIso8601String());
```

---

## **🔔 Push Notifications**

### **Send Test Notification:**
1. **Go to Cloud Messaging**
2. **Click "Send your first message"**
3. **Notification title**: `Welcome to PDF Reader!`
4. **Notification text**: `Start reading your PDFs now`
5. **Target**: `Single device` hoặc `Topic`
6. **Click "Review"** → **"Publish"**

### **Notification Topics:**
```dart
// Subscribe to topics
FirebaseService.instance.subscribeToTopic('all_users');
FirebaseService.instance.subscribeToTopic('premium_users');

// Unsubscribe from topics
FirebaseService.instance.unsubscribeFromTopic('all_users');
```

---

## **📈 Performance Monitoring**

### **Custom Traces:**
```dart
// Start trace
final trace = await FirebaseService.instance.startTrace('pdf_processing');

// ... do processing ...

// Stop trace
await FirebaseService.instance.stopTrace(trace);
```

### **Network Requests:**
```dart
// Automatic network monitoring
// No additional code needed
```

---

## **🐛 Crashlytics**

### **Custom Keys:**
```dart
// Set custom keys
FirebaseService.instance.setCustomKey('user_id', userId);
FirebaseService.instance.setCustomKey('app_version', '1.0.0');
```

### **Record Errors:**
```dart
// Record custom error
FirebaseService.instance.recordError(
  exception,
  stackTrace,
  reason: 'PDF processing failed',
);
```

---

## **🔐 Security Rules**

### **Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### **Storage Rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## **📊 Dashboard Monitoring**

### **Analytics Dashboard:**
- **Real-time users**
- **Event tracking**
- **User engagement**
- **Retention rates**

### **Crashlytics Dashboard:**
- **Crash-free users**
- **Crash reports**
- **Error trends**
- **User impact**

### **Performance Dashboard:**
- **App startup time**
- **Screen rendering**
- **Network requests**
- **Custom traces**

---

## **🚀 Testing**

### **Test Analytics:**
```dart
// Test event
FirebaseService.instance.logEvent('test_event', parameters: {
  'test_parameter': 'test_value',
});
```

### **Test Crashlytics:**
```dart
// Test crash
FirebaseService.instance.recordError(
  Exception('Test crash'),
  StackTrace.current,
  reason: 'Testing crashlytics',
);
```

### **Test Notifications:**
1. **Send test notification from console**
2. **Verify received on device**
3. **Test notification tap handling**

---

## **📱 Production Setup**

### **Release Signing:**
1. **Generate release keystore**
2. **Add SHA-1 to Firebase project**
3. **Update google-services.json**

### **App Store:**
1. **Build release APK**
2. **Upload to Play Console**
3. **Monitor Firebase dashboards**

---

## **🎯 Next Steps**

1. **Complete Firebase setup**
2. **Test all services**
3. **Configure production**
4. **Monitor dashboards**
5. **Iterate based on data**

**Firebase setup hoàn tất! 🚀**
