# 🚀 PDF Reader Backend Setup Guide

## **📋 Tổng quan Backend Architecture**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Supabase      │    │   Vercel API    │
│                 │◄──►│   Database      │◄──►│   Functions     │
│  - Authentication│    │  - User Data    │    │  - PDF Processing│
│  - Cloud Sync    │    │  - File Metadata│    │  - AI Features  │
│  - IAP           │    │  - Preferences  │    │  - OCR/Text Ext │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Railway       │    │   Firebase      │    │   AI Services   │
│   - File Storage│    │  - Analytics    │    │  - OpenAI API   │
│   - Processing  │    │  - Crashlytics  │    │  - Google Vision│
│   - Background  │    │  - Push Notif   │    │  - Azure OCR    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## **1. 🗄️ SUPABASE Setup**

### **Step 1: Tạo Supabase Project**
1. Truy cập [supabase.com](https://supabase.com)
2. Tạo project mới
3. Lấy URL và API Key

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

### **Step 4: Environment Variables**
```dart
// lib/config/supabase_config.dart
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String serviceRoleKey = 'YOUR_SUPABASE_SERVICE_ROLE_KEY';
}
```

---

## **2. 🚀 VERCEL Setup**

### **Step 1: Tạo Vercel Account**
1. Truy cập [vercel.com](https://vercel.com)
2. Connect GitHub repository
3. Deploy API functions

### **Step 2: Environment Variables**
```bash
# Vercel Dashboard > Project Settings > Environment Variables
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
OPENAI_API_KEY=your_openai_key
GOOGLE_VISION_API_KEY=your_google_vision_key
```

### **Step 3: Deploy Commands**
```bash
# Install Vercel CLI
npm i -g vercel

# Login to Vercel
vercel login

# Deploy
vercel --prod
```

### **Step 4: API Endpoints**
- `POST /api/pdf/extract-text` - Extract text from PDF
- `POST /api/pdf/generate-thumbnail` - Generate thumbnail
- `POST /api/pdf/ocr` - OCR processing
- `POST /api/pdf/compress` - Compress PDF
- `POST /api/ai/summarize` - AI text summarization
- `POST /api/ai/translate` - AI translation

---

## **3. 🚂 RAILWAY Setup**

### **Step 1: Tạo Railway Account**
1. Truy cập [railway.app](https://railway.app)
2. Connect GitHub repository
3. Deploy Node.js service

### **Step 2: Environment Variables**
```bash
# Railway Dashboard > Variables
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

### **Step 3: Deploy Commands**
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Deploy
railway up
```

### **Step 4: Services**
- **PostgreSQL**: Database for file metadata
- **Redis**: Caching and session management
- **File Storage**: Large file storage
- **Background Jobs**: PDF processing queue

---

## **4. 💰 In-App Purchase Setup**

### **Step 1: Google Play Console**
1. Tạo app trong Google Play Console
2. Setup In-App Products:
   - `pdf_reader_premium_monthly` - $4.99/month
   - `pdf_reader_premium_yearly` - $49.99/year
   - `pdf_reader_lifetime` - $99.99 one-time

### **Step 2: App Store Connect**
1. Tạo app trong App Store Connect
2. Setup In-App Purchases:
   - Same product IDs as Google Play

### **Step 3: Flutter IAP Configuration**
```dart
// android/app/src/main/res/values/strings.xml
<resources>
    <string name="app_name">PDF Reader</string>
</resources>

// ios/Runner/Info.plist
<key>CFBundleDisplayName</key>
<string>PDF Reader</string>
```

### **Step 4: Backend Validation**
```dart
// Validate purchases on backend
Future<bool> validatePurchase(String purchaseToken, String productId) async {
  // Implement Google Play/App Store validation
  // Save to Supabase database
}
```

---

## **5. 📊 Firebase Analytics Setup**

### **Step 1: Firebase Project**
1. Truy cập [console.firebase.google.com](https://console.firebase.google.com)
2. Tạo project mới
3. Add Android/iOS apps

### **Step 2: Configuration Files**
```json
// android/app/google-services.json
{
  "project_info": {
    "project_id": "your-project-id"
  }
}

// ios/Runner/GoogleService-Info.plist
<plist>
  <key>PROJECT_ID</key>
  <string>your-project-id</string>
</plist>
```

### **Step 3: Analytics Events**
```dart
// Track user actions
FirebaseAnalytics.instance.logEvent(
  name: 'pdf_opened',
  parameters: {
    'file_size': fileSize,
    'file_type': 'pdf',
  },
);
```

---

## **6. 🔔 Push Notifications Setup**

### **Step 1: Firebase Cloud Messaging**
1. Enable FCM in Firebase Console
2. Generate server key
3. Configure APNs (iOS)

### **Step 2: Notification Service**
```dart
// lib/services/notification_service.dart
class NotificationService {
  static Future<void> initialize() async {
    // Request permission
    // Configure FCM
    // Handle background messages
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

---

## **7. 🤖 AI Features Setup**

### **Step 1: OpenAI Integration**
```dart
// lib/services/ai_service.dart
class AIService {
  static const String openaiApiKey = 'YOUR_OPENAI_API_KEY';
  
  static Future<String> summarizeText(String text) async {
    // Call OpenAI API for text summarization
  }
  
  static Future<String> translateText(String text, String targetLanguage) async {
    // Call OpenAI API for translation
  }
}
```

### **Step 2: Google Vision API**
```dart
// OCR and image recognition
static Future<String> performOCR(String imagePath) async {
  // Call Google Vision API
}
```

### **Step 3: Azure Cognitive Services**
```dart
// Alternative AI services
static Future<Map<String, dynamic>> analyzeDocument(String filePath) async {
  // Call Azure Form Recognizer
}
```

---

## **8. 🔧 Environment Configuration**

### **Step 1: Create .env file**
```bash
# .env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
VERCEL_API_URL=your_vercel_api_url
RAILWAY_API_URL=your_railway_api_url
FIREBASE_PROJECT_ID=your_firebase_project_id
OPENAI_API_KEY=your_openai_api_key
GOOGLE_VISION_API_KEY=your_google_vision_api_key
```

### **Step 2: Update pubspec.yaml**
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.10.3
  in_app_purchase: ^3.2.3
  firebase_core: ^4.2.0
  firebase_analytics: ^12.0.3
  firebase_crashlytics: ^5.0.3
  firebase_messaging: ^16.0.3
  flutter_local_notifications: ^19.5.0
  http: ^1.5.0
  dio: ^5.9.0
```

### **Step 3: Initialize Services**
```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Supabase
  await SupabaseService.instance.initialize();
  
  // Initialize IAP
  await IAPService.instance.initialize();
  
  // Initialize Analytics
  await AnalyticsService.instance.initialize();
  
  runApp(const PDFReaderApp());
}
```

---

## **9. 🚀 Deployment Checklist**

### **Frontend (Flutter)**
- [ ] Configure Supabase connection
- [ ] Setup Firebase Analytics
- [ ] Configure IAP products
- [ ] Test all features
- [ ] Build release APK/IPA

### **Backend (Vercel)**
- [ ] Deploy API functions
- [ ] Configure environment variables
- [ ] Test API endpoints
- [ ] Setup monitoring

### **Backend (Railway)**
- [ ] Deploy Node.js service
- [ ] Configure database
- [ ] Setup Redis cache
- [ ] Test file processing

### **Database (Supabase)**
- [ ] Create tables
- [ ] Setup RLS policies
- [ ] Configure storage buckets
- [ ] Test authentication

---

## **10. 📈 Monitoring & Analytics**

### **Key Metrics to Track**
- User registrations
- PDF uploads/downloads
- Premium conversions
- Feature usage
- Crash reports
- Performance metrics

### **Tools**
- **Firebase Analytics**: User behavior
- **Firebase Crashlytics**: Error tracking
- **Supabase Dashboard**: Database monitoring
- **Vercel Analytics**: API performance
- **Railway Metrics**: Server performance

---

## **🎯 Next Steps**

1. **Setup Supabase** - Database và authentication
2. **Deploy Vercel API** - PDF processing functions
3. **Setup Railway** - File storage và background processing
4. **Configure IAP** - Premium features
5. **Add Analytics** - User tracking
6. **Setup Notifications** - Push notifications
7. **Integrate AI** - Advanced features
8. **Test & Deploy** - Production deployment

Bạn muốn tôi hướng dẫn chi tiết setup từng service nào trước?

