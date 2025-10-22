# Sửa lỗi Android Embedding

## Lỗi gặp phải
```
Build failed due to use of deleted Android v1 embedding.
```

## Nguyên nhân
Flutter đã ngừng hỗ trợ Android v1 embedding từ phiên bản 2.0. Dự án cần sử dụng Android v2 embedding.

## Các bước sửa lỗi

### 1. Cập nhật MainActivity.java
Đã tạo file `android/app/src/main/java/com/example/pdf_reader/MainActivity.java` với nội dung:
```java
package com.example.pdf_reader;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
}
```

### 2. Cập nhật AndroidManifest.xml
Đã cập nhật file `android/app/src/main/AndroidManifest.xml` với:
- `android:exported="true"` cho activity
- `flutterEmbedding` meta-data với value="2"

### 3. Cập nhật build.gradle files
Đã tạo các file:
- `android/app/build.gradle`
- `android/build.gradle`
- `android/settings.gradle`
- `android/gradle.properties`

### 4. Cập nhật dependencies
Đã loại bỏ một số dependencies không cần thiết trong `pubspec.yaml`.

## Các lệnh để chạy lại

### 1. Clean project
```bash
flutter clean
```

### 2. Get dependencies
```bash
flutter pub get
```

### 3. Build lại
```bash
flutter build apk --debug
```

### 4. Hoặc chạy trực tiếp
```bash
flutter run
```

## Lưu ý quan trọng

### Cấu hình Android SDK
Đảm bảo bạn đã cài đặt:
- Android SDK
- Android Studio
- Flutter SDK

### Cập nhật local.properties
Sửa file `android/local.properties` với đường dẫn SDK thực tế:
```
sdk.dir=C\:\\Users\\YourUsername\\AppData\\Local\\Android\\Sdk
flutter.sdk=C\:\\flutter
```

### Kiểm tra Flutter doctor
```bash
flutter doctor
```

Đảm bảo tất cả các mục đều có dấu ✓.

## Nếu vẫn gặp lỗi

### 1. Kiểm tra Flutter version
```bash
flutter --version
```

### 2. Upgrade Flutter
```bash
flutter upgrade
```

### 3. Kiểm tra Android SDK
Mở Android Studio → SDK Manager → đảm bảo đã cài:
- Android SDK Platform 33
- Android SDK Build-Tools 33.0.0
- Android SDK Command-line Tools

### 4. Tạo project mới và copy code
Nếu vẫn lỗi, có thể tạo project Flutter mới:
```bash
flutter create new_pdf_reader
```
Sau đó copy code từ project cũ sang project mới.

## Test ứng dụng

Sau khi sửa lỗi, test các tính năng:
1. Mở ứng dụng
2. Thêm PDF file
3. Xem PDF
4. Chuyển đổi hình ảnh thành PDF
5. Chia sẻ PDF
6. Cài đặt dark mode



