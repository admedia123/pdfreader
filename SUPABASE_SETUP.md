# 🗄️ Supabase Setup cho High PDF Reader App

## **📊 Database Configuration**

### **Project URL:**
```
https://dsoykdntfuumsymjcfkm.supabase.co
```

### **Project ID:**
```
dsoykdntfuumsymjcfkm
```

---

## **🚀 Step-by-Step Setup**

### **Step 1: Database Schema Setup**

1. **Truy cập**: [supabase.com/dashboard](https://supabase.com/dashboard)
2. **Chọn project**: `dsoykdntfuumsymjcfkm`
3. **Go to SQL Editor**
4. **Copy và paste** nội dung file `supabase/schema.sql`
5. **Click "Run"** để tạo database schema

### **Step 2: Storage Buckets Setup**

1. **Go to Storage**
2. **Verify buckets đã được tạo:**
   - `pdf_files` (private)
   - `thumbnails` (public)

### **Step 3: Edge Functions Setup**

1. **Go to Edge Functions**
2. **Create new function**: `pdf-processing`
3. **Copy code** từ `supabase/functions/pdf-processing/index.ts`
4. **Deploy function**

### **Step 4: Authentication Setup**

1. **Go to Authentication** → **Settings**
2. **Enable Email Auth**: ✅
3. **Enable Google Auth**: ✅ (optional)
4. **Enable Apple Auth**: ✅ (optional)
5. **Site URL**: `https://high-pdf-reader.app`
6. **Redirect URLs**: 
   - `https://high-pdf-reader.app/auth/callback`
   - `com.highmyx.pdfreaderapp://auth/callback`

---

## **🔧 Database Schema**

### **Tables Created:**

#### **1. user_profiles**
```sql
- id (UUID, Primary Key)
- user_id (UUID, Foreign Key to auth.users)
- full_name (TEXT)
- avatar_url (TEXT)
- preferences (JSONB)
- is_premium (BOOLEAN)
- premium_expires_at (TIMESTAMP)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

#### **2. pdf_files**
```sql
- id (UUID, Primary Key)
- user_id (UUID, Foreign Key to auth.users)
- file_name (TEXT)
- file_path (TEXT)
- file_size (BIGINT)
- description (TEXT)
- is_favorite (BOOLEAN)
- is_shared (BOOLEAN)
- share_token (TEXT)
- thumbnail_url (TEXT)
- page_count (INTEGER)
- last_accessed_at (TIMESTAMP)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

#### **3. subscriptions**
```sql
- id (UUID, Primary Key)
- user_id (UUID, Foreign Key to auth.users)
- product_id (TEXT)
- purchase_token (TEXT)
- platform (TEXT)
- is_active (BOOLEAN)
- expires_at (TIMESTAMP)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

#### **4. processing_jobs**
```sql
- id (UUID, Primary Key)
- user_id (UUID, Foreign Key to auth.users)
- file_id (UUID, Foreign Key to pdf_files)
- job_type (TEXT)
- status (TEXT)
- result (JSONB)
- error_message (TEXT)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

---

## **🔐 Row Level Security (RLS)**

### **Policies Created:**
- ✅ **Users can only access their own data**
- ✅ **Automatic profile creation on signup**
- ✅ **Secure file uploads**
- ✅ **Public thumbnail access**

### **Storage Policies:**
- ✅ **PDF files**: Private, user-specific
- ✅ **Thumbnails**: Public read, user-specific write

---

## **⚡ Edge Functions**

### **PDF Processing Function:**
- **Function name**: `pdf-processing`
- **Actions supported**:
  - `extract-text` - Extract text from PDF
  - `generate-thumbnail` - Generate thumbnail
  - `ocr-pdf` - OCR processing
  - `compress-pdf` - Compress PDF
  - `analyze-document` - AI document analysis

### **Usage Example:**
```dart
// Call Edge Function
final response = await SupabaseService.instance.client.functions.invoke(
  'pdf-processing',
  body: {
    'action': 'extract-text',
    'fileUrl': fileUrl,
    'userId': userId,
    'fileId': fileId,
  },
);
```

---

## **📊 Real-time Features**

### **Subscriptions:**
```dart
// Subscribe to PDF files updates
final subscription = SupabaseService.instance.client
  .channel('pdf_files')
  .onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'pdf_files',
    filter: PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'user_id',
      value: userId,
    ),
    callback: (payload) {
      // Handle real-time updates
      print('PDF file updated: $payload');
    },
  )
  .subscribe();
```

---

## **🔧 Flutter Integration**

### **Authentication:**
```dart
// Sign up
final response = await SupabaseService.instance.signUp(
  email: email,
  password: password,
  fullName: fullName,
);

// Sign in
final response = await SupabaseService.instance.signIn(
  email: email,
  password: password,
);

// Sign out
await SupabaseService.instance.signOut();
```

### **PDF Files Management:**
```dart
// Get user PDF files
final files = await SupabaseService.instance.getUserPDFFiles();

// Upload PDF file
final pdfFile = await SupabaseService.instance.uploadPDFFile(
  fileName: fileName,
  filePath: filePath,
  fileSize: fileSize,
  description: description,
);

// Update PDF file
await SupabaseService.instance.updatePDFFile(
  fileId: fileId,
  fileName: newFileName,
  isFavorite: true,
);

// Delete PDF file
await SupabaseService.instance.deletePDFFile(fileId);
```

### **Favorites Management:**
```dart
// Get favorite files
final favorites = await SupabaseService.instance.getFavoriteFiles();

// Toggle favorite
await SupabaseService.instance.toggleFavorite(fileId, true);
```

### **Recent Files:**
```dart
// Get recent files
final recentFiles = await SupabaseService.instance.getRecentFiles(limit: 20);

// Update last accessed
await SupabaseService.instance.updateLastAccessed(fileId);
```

---

## **📈 Analytics Integration**

### **Track User Actions:**
```dart
// Track PDF opened
FirebaseService.instance.logEvent('pdf_opened', parameters: {
  'file_size': fileSize,
  'user_tier': isPremium ? 'premium' : 'free',
});

// Track PDF uploaded
FirebaseService.instance.logEvent('pdf_uploaded', parameters: {
  'file_size': fileSize,
  'upload_method': 'supabase',
});
```

---

## **🔔 Push Notifications**

### **Send Notification:**
```dart
// Send notification via Supabase Edge Function
final response = await SupabaseService.instance.client.functions.invoke(
  'send-notification',
  body: {
    'userId': userId,
    'title': 'PDF processed successfully',
    'body': 'Your PDF has been processed and is ready to view',
  },
);
```

---

## **🚀 Production Deployment**

### **Environment Variables:**
```bash
SUPABASE_URL=https://dsoykdntfuumsymjcfkm.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### **Monitoring:**
- **Database performance**: Supabase Dashboard
- **Edge Functions logs**: Supabase Dashboard
- **Storage usage**: Supabase Dashboard
- **Authentication**: Supabase Dashboard

---

## **📊 Expected Performance**

### **Database:**
- **Query time**: <100ms
- **Real-time updates**: <50ms
- **File upload**: <5s (50MB file)

### **Edge Functions:**
- **PDF processing**: <10s
- **Thumbnail generation**: <3s
- **OCR processing**: <15s

---

## **🎯 Next Steps**

1. **Run database schema** trong Supabase SQL Editor
2. **Deploy Edge Functions**
3. **Test authentication**
4. **Test file uploads**
5. **Test real-time updates**
6. **Monitor performance**

**Supabase setup hoàn tất! 🚀**
