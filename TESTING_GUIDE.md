# 🧪 Testing Guide - High PDF Reader App

## **📱 App Testing Checklist**

### **Step 1: Test Backend Connections**

1. **Mở app** và navigate đến tab **"Test"**
2. **Click "Run All Tests"**
3. **Kiểm tra kết quả:**
   - ✅ Firebase Analytics: Event logged
   - ✅ Firebase Crashlytics: Custom key set
   - ✅ Firebase Messaging: FCM token received
   - ✅ Firebase Performance: Trace completed
   - ✅ Supabase Connection: Connected
   - ✅ Database Access: Tables accessible
   - ✅ Storage Access: Buckets accessible
   - ✅ Edge Functions: Function invoked

### **Step 2: Test Authentication**

#### **Sign Up Test:**
```dart
// Test trong app
1. Navigate to Settings
2. Click "Sign Up" (nếu có)
3. Enter email: test@example.com
4. Enter password: password123
5. Enter full name: Test User
6. Click "Sign Up"
7. Verify success message
```

#### **Sign In Test:**
```dart
// Test trong app
1. Click "Sign In"
2. Enter email: test@example.com
3. Enter password: password123
4. Click "Sign In"
5. Verify user logged in
```

### **Step 3: Test File Operations**

#### **Upload PDF Test:**
```dart
// Test trong app
1. Go to Files tab
2. Click "+" button
3. Select PDF file
4. Verify file uploaded
5. Check file appears in list
```

#### **Download PDF Test:**
```dart
// Test trong app
1. Click on PDF file
2. Verify PDF opens
3. Check file metadata
4. Test zoom, scroll
```

#### **Delete PDF Test:**
```dart
// Test trong app
1. Long press on PDF file
2. Click "Delete"
3. Confirm deletion
4. Verify file removed
```

### **Step 4: Test Favorites**

#### **Add to Favorites:**
```dart
// Test trong app
1. Click star icon on PDF file
2. Verify star becomes filled
3. Go to Favorites tab
4. Verify file appears
```

#### **Remove from Favorites:**
```dart
// Test trong app
1. Go to Favorites tab
2. Click star icon
3. Verify star becomes empty
4. Go back to Files tab
5. Verify star is empty
```

### **Step 5: Test Recent Files**

#### **Access Recent:**
```dart
// Test trong app
1. Open a PDF file
2. Close PDF viewer
3. Go to Recent tab
4. Verify file appears in recent
```

### **Step 6: Test Search**

#### **Search Files:**
```dart
// Test trong app
1. Go to Files tab
2. Click search icon
3. Type file name
4. Verify results filtered
```

### **Step 7: Test Settings**

#### **Dark Mode Toggle:**
```dart
// Test trong app
1. Go to Settings tab
2. Toggle Dark Mode
3. Verify theme changes
4. Restart app
5. Verify theme persists
```

#### **Language Selection:**
```dart
// Test trong app
1. Go to Settings tab
2. Click Language
3. Select different language
4. Verify UI changes
```

### **Step 8: Test Analytics**

#### **Check Firebase Analytics:**
1. **Go to Firebase Console**
2. **Navigate to Analytics**
3. **Check Events:**
   - `pdf_opened`
   - `pdf_uploaded`
   - `user_registered`
   - `premium_purchased`

#### **Check Crashlytics:**
1. **Go to Firebase Console**
2. **Navigate to Crashlytics**
3. **Check for crashes**
4. **Verify custom keys**

### **Step 9: Test Real-time Updates**

#### **Test Real-time Sync:**
```dart
// Test trong app
1. Upload file on device A
2. Check device B (if available)
3. Verify file appears
4. Test favorite toggle
5. Verify sync across devices
```

### **Step 10: Test Performance**

#### **Check Performance Metrics:**
1. **Go to Firebase Console**
2. **Navigate to Performance**
3. **Check traces:**
   - `pdf_processing`
   - `file_upload`
   - `app_startup`

---

## **🐛 Debugging Guide**

### **Common Issues:**

#### **1. Firebase Connection Failed:**
```dart
// Check:
- google-services.json file exists
- Package name matches
- Firebase project configured
- Internet connection
```

#### **2. Supabase Connection Failed:**
```dart
// Check:
- Supabase URL correct
- API keys valid
- Database schema created
- RLS policies enabled
```

#### **3. File Upload Failed:**
```dart
// Check:
- Storage permissions
- File size limits
- Network connection
- Supabase storage bucket
```

#### **4. Authentication Failed:**
```dart
// Check:
- Email format valid
- Password requirements
- Supabase auth enabled
- Network connection
```

---

## **📊 Performance Testing**

### **Load Testing:**
```dart
// Test scenarios:
1. Upload 10 PDF files simultaneously
2. Open large PDF (50MB+)
3. Search through 100+ files
4. Switch between tabs rapidly
5. Background/foreground app
```

### **Memory Testing:**
```dart
// Monitor:
- Memory usage during file operations
- Memory leaks in PDF viewer
- Background memory usage
- Cache management
```

### **Network Testing:**
```dart
// Test scenarios:
- Slow network (2G)
- Intermittent connection
- No network (offline mode)
- Network switching (WiFi to mobile)
```

---

## **🔧 Production Testing**

### **Pre-release Checklist:**
- [ ] All backend connections working
- [ ] Authentication flow complete
- [ ] File operations working
- [ ] Real-time sync working
- [ ] Analytics tracking
- [ ] Performance optimized
- [ ] Error handling complete
- [ ] Offline mode working
- [ ] Security policies enforced
- [ ] User experience smooth

### **Release Testing:**
- [ ] Build release APK
- [ ] Test on different devices
- [ ] Test on different Android versions
- [ ] Test with different screen sizes
- [ ] Test with different network conditions
- [ ] Monitor crash reports
- [ ] Monitor performance metrics
- [ ] Monitor user feedback

---

## **📈 Monitoring Dashboard**

### **Firebase Console:**
- **Analytics**: User behavior, events
- **Crashlytics**: Error reports, stability
- **Performance**: App performance, speed
- **Messaging**: Push notification delivery

### **Supabase Dashboard:**
- **Database**: Query performance, usage
- **Storage**: File uploads, downloads
- **Edge Functions**: Function execution, errors
- **Authentication**: User signups, logins

---

## **🎯 Success Criteria**

### **Technical:**
- ✅ All tests pass
- ✅ No crashes
- ✅ Fast response times
- ✅ Reliable sync
- ✅ Secure data

### **User Experience:**
- ✅ Intuitive navigation
- ✅ Smooth animations
- ✅ Clear error messages
- ✅ Offline functionality
- ✅ Cross-device sync

**App testing hoàn tất! 🚀**
