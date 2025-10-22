# 🚀 PDF Reader - Optimized Backend Setup

## **🎯 Tối ưu Architecture - Chỉ dùng 2 services chính**

### **📊 Architecture Overview:**
```
┌─────────────────┐    ┌─────────────────┐
│   SUPABASE      │    │   FIREBASE      │
│                 │    │                 │
│ ✅ Database     │    │ ✅ Analytics    │
│ ✅ Auth         │    │ ✅ Crashlytics  │
│ ✅ Storage      │    │ ✅ Push Notif   │
│ ✅ Edge Functions│   │ ✅ IAP          │
│ ✅ Real-time    │    │ ✅ Hosting      │
└─────────────────┘    └─────────────────┘
```

---

## **🔧 Setup GitHub Repository**

### **Step 1: Tạo GitHub Repository**
1. Truy cập [github.com](https://github.com)
2. Tạo repository mới: `pdf-reader-app`
3. Copy repository URL

### **Step 2: Push code lên GitHub**
```bash
# Add remote origin
git remote add origin https://github.com/yourusername/pdf-reader-app.git

# Push to GitHub
git branch -M main
git push -u origin main
```

---

## **🗄️ SUPABASE Setup (Primary Backend)**

### **Step 1: Tạo Supabase Project**
1. Truy cập [supabase.com](https://supabase.com)
2. Tạo project mới: `pdf-reader-db`
3. Chọn region gần nhất (Singapore cho VN)
4. Lấy credentials:
   - Project URL: `https://xxx.supabase.co`
   - Anon Key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
   - Service Role Key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

### **Step 2: Database Schema**
```sql
-- Users table (extends auth.users)
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  avatar_url TEXT,
  preferences JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- PDF Files table
CREATE TABLE pdf_files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  file_name TEXT NOT NULL,
  file_path TEXT NOT NULL,
  file_size BIGINT NOT NULL,
  description TEXT,
  is_favorite BOOLEAN DEFAULT FALSE,
  last_accessed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Premium subscriptions
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  purchase_token TEXT NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  expires_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Storage buckets
INSERT INTO storage.buckets (id, name, public) VALUES 
('pdf_files', 'pdf_files', false),
('thumbnails', 'thumbnails', true);
```

### **Step 3: Row Level Security (RLS)**
```sql
-- Enable RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE pdf_files ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own files" ON pdf_files
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own files" ON pdf_files
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own files" ON pdf_files
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own files" ON pdf_files
  FOR DELETE USING (auth.uid() = user_id);
```

### **Step 4: Edge Functions (PDF Processing)**
```typescript
// supabase/functions/pdf-processing/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { action, fileUrl, userId } = await req.json()
  
  switch (action) {
    case 'extract-text':
      const text = await extractTextFromPDF(fileUrl)
      return new Response(JSON.stringify({ success: true, text }))
    
    case 'generate-thumbnail':
      const thumbnail = await generateThumbnail(fileUrl)
      return new Response(JSON.stringify({ success: true, thumbnail }))
    
    case 'ocr-pdf':
      const ocrText = await performOCR(fileUrl)
      return new Response(JSON.stringify({ success: true, text: ocrText }))
    
    default:
      return new Response(JSON.stringify({ error: 'Invalid action' }), { status: 400 })
  }
})
```

---

## **🔥 FIREBASE Setup (Analytics & Notifications)**

### **Step 1: Tạo Firebase Project**
1. Truy cập [console.firebase.google.com](https://console.firebase.google.com)
2. Tạo project mới: `pdf-reader-app`
3. Enable Analytics, Crashlytics, Cloud Messaging
4. Lấy credentials:
   - Project ID: `pdf-reader-app`
   - Web API Key: `AIzaSyC...`
   - Server Key: `AAAA...`

### **Step 2: Android Configuration**
```json
// android/app/google-services.json
{
  "project_info": {
    "project_id": "pdf-reader-app",
    "project_number": "123456789",
    "firebase_url": "https://pdf-reader-app.firebaseio.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789:android:abcdef",
        "android_client_info": {
          "package_name": "com.example.pdf_reader"
        }
      }
    }
  ]
}
```

### **Step 3: iOS Configuration**
```xml
<!-- ios/Runner/GoogleService-Info.plist -->
<plist>
  <key>PROJECT_ID</key>
  <string>pdf-reader-app</string>
  <key>BUNDLE_ID</key>
  <string>com.example.pdfReader</string>
</plist>
```

---

## **🔧 Flutter App Configuration**

### **Step 1: Environment Variables**
```dart
// lib/config/app_config.dart
class AppConfig {
  // Supabase
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // Firebase
  static const String firebaseProjectId = 'pdf-reader-app';
  static const String firebaseWebApiKey = 'YOUR_FIREBASE_WEB_API_KEY';
  
  // API Endpoints
  static const String supabaseApiUrl = 'YOUR_SUPABASE_URL/functions/v1';
}
```

### **Step 2: Initialize Services**
```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Supabase
  await SupabaseService.instance.initialize();
  
  // Initialize Analytics
  await AnalyticsService.instance.initialize();
  
  // Initialize IAP
  await IAPService.instance.initialize();
  
  runApp(const PDFReaderApp());
}
```

---

## **💰 In-App Purchase Setup**

### **Step 1: Google Play Console**
1. Tạo app trong Google Play Console
2. Setup In-App Products:
   - `pdf_reader_premium_monthly` - $4.99/month
   - `pdf_reader_premium_yearly` - $49.99/year
   - `pdf_reader_lifetime` - $99.99 one-time

### **Step 2: App Store Connect**
1. Tạo app trong App Store Connect
2. Setup In-App Purchases với cùng product IDs

### **Step 3: Backend Validation**
```dart
// lib/services/iap_service.dart
class IAPService {
  static Future<bool> validatePurchase(String purchaseToken, String productId) async {
    // Validate with Google Play/App Store
    // Save to Supabase database
    // Sync across devices
  }
}
```

---

## **📊 Analytics & Monitoring**

### **Step 1: Firebase Analytics Events**
```dart
// Track user actions
FirebaseAnalytics.instance.logEvent(
  name: 'pdf_opened',
  parameters: {
    'file_size': fileSize,
    'file_type': 'pdf',
    'user_tier': isPremium ? 'premium' : 'free',
  },
);
```

### **Step 2: Crashlytics**
```dart
// Automatic crash reporting
FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'PDF processing failed',
);
```

### **Step 3: Performance Monitoring**
```dart
// Track app performance
FirebasePerformance.instance.trace('pdf_processing').start();
// ... processing ...
FirebasePerformance.instance.trace('pdf_processing').stop();
```

---

## **🔔 Push Notifications**

### **Step 1: Firebase Cloud Messaging**
```dart
// lib/services/notification_service.dart
class NotificationService {
  static Future<void> initialize() async {
    // Request permission
    await FirebaseMessaging.instance.requestPermission();
    
    // Configure FCM
    await FirebaseMessaging.instance.getToken();
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  
  static Future<void> sendNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Send notification via FCM
  }
}
```

### **Step 2: Notification Types**
- **Feature Updates**: New features announcements
- **Premium Promotions**: Marketing campaigns
- **File Sync**: Cloud sync notifications
- **Security Alerts**: Account security

---

## **🚀 Deployment Strategy**

### **Phase 1: Development (Week 1-2)**
1. ✅ Setup GitHub repository
2. ✅ Configure Supabase database
3. ✅ Setup Firebase project
4. ✅ Test basic functionality

### **Phase 2: Testing (Week 3-4)**
1. ✅ Implement IAP
2. ✅ Add analytics
3. ✅ Test cloud sync
4. ✅ Performance optimization

### **Phase 3: Production (Week 5-6)**
1. ✅ Deploy to app stores
2. ✅ Monitor analytics
3. ✅ User feedback
4. ✅ Iterate and improve

---

## **💰 Cost Estimation**

### **Supabase (Free Tier)**
- Database: 500MB (Free)
- Storage: 1GB (Free)
- Edge Functions: 500,000 requests/month (Free)
- Auth: Unlimited (Free)

### **Firebase (Free Tier)**
- Analytics: Unlimited (Free)
- Crashlytics: Unlimited (Free)
- Cloud Messaging: Unlimited (Free)
- Hosting: 10GB (Free)

### **Total Monthly Cost: $0 (Free Tier)**

---

## **📈 Expected Metrics**

### **User Acquisition**
- **Target**: 10,000 users/month
- **Conversion**: 5% premium users
- **Revenue**: $2,500/month

### **Technical Metrics**
- **Uptime**: 99.9%
- **Response Time**: <200ms
- **File Processing**: <5 seconds

---

## **🎯 Next Steps**

1. **Tạo GitHub repository** và push code
2. **Setup Supabase** project và database
3. **Configure Firebase** project
4. **Update Flutter app** với credentials
5. **Test tất cả features**
6. **Deploy to production**

Bạn muốn tôi hướng dẫn chi tiết setup service nào trước?
