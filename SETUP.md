# Hướng dẫn cài đặt và chạy ứng dụng PDF Reader

## Yêu cầu hệ thống

- Flutter SDK (phiên bản 3.0.0 trở lên)
- Dart SDK
- Android Studio hoặc VS Code với Flutter extension
- Android SDK (cho Android) hoặc Xcode (cho iOS)

## Cài đặt Flutter

1. Tải Flutter SDK từ [flutter.dev](https://flutter.dev)
2. Giải nén và thêm vào PATH
3. Chạy `flutter doctor` để kiểm tra cài đặt

## Cài đặt dependencies

```bash
# Di chuyển vào thư mục dự án
cd pdf_reader

# Cài đặt dependencies
flutter pub get

# Kiểm tra dependencies
flutter pub deps
```

## Cấu hình Android

1. Mở `android/app/src/main/AndroidManifest.xml`
2. Đảm bảo có các permissions cần thiết:
   - `READ_EXTERNAL_STORAGE`
   - `WRITE_EXTERNAL_STORAGE`
   - `INTERNET`

## Chạy ứng dụng

### Trên Android
```bash
# Kết nối thiết bị Android hoặc khởi động emulator
flutter devices

# Chạy ứng dụng
flutter run
```

### Trên iOS (chỉ trên macOS)
```bash
# Mở iOS Simulator
open -a Simulator

# Chạy ứng dụng
flutter run
```

## Build ứng dụng

### Build APK cho Android
```bash
# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release
```

### Build IPA cho iOS
```bash
# Build cho iOS
flutter build ios --release
```

## Cấu trúc dự án

```
lib/
├── main.dart                 # Entry point
├── models/                   # Data models
│   └── pdf_file.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── pdf_viewer_screen.dart
│   └── settings_screen.dart
├── widgets/                  # Reusable widgets
│   ├── pdf_card.dart
│   ├── floating_action_buttons.dart
│   ├── loading_widget.dart
│   └── empty_state_widget.dart
├── services/                 # Business logic
│   └── pdf_service.dart
└── utils/                    # Utilities
    ├── theme.dart
    ├── constants.dart
    ├── app_colors.dart
    └── app_strings.dart
```

## Tính năng chính

### ✅ Đã hoàn thành
- [x] Splash screen với animation
- [x] Home screen với danh sách PDF
- [x] PDF viewer với navigation
- [x] Night mode toggle
- [x] Convert images to PDF
- [x] Share PDF files
- [x] Settings screen
- [x] Grid/List view toggle
- [x] Search functionality
- [x] Sort by name/date/size
- [x] File management (delete)
- [x] Responsive UI
- [x] Dark/Light theme

### 🔄 Có thể mở rộng
- [ ] PDF annotation
- [ ] Cloud storage integration
- [ ] PDF editing
- [ ] OCR text recognition
- [ ] Bookmark system
- [ ] Print functionality

## Troubleshooting

### Lỗi thường gặp

1. **Dependencies không cài được**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Build failed**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk
   ```

3. **Permission denied**
   - Kiểm tra AndroidManifest.xml
   - Thêm runtime permissions

4. **PDF không hiển thị**
   - Kiểm tra file path
   - Đảm bảo file PDF hợp lệ

### Debug mode
```bash
# Chạy với debug mode
flutter run --debug

# Xem logs
flutter logs
```

## Tùy chỉnh

### Thay đổi theme
- Chỉnh sửa `lib/utils/theme.dart`
- Thay đổi colors trong `lib/utils/app_colors.dart`

### Thêm tính năng mới
- Tạo screen mới trong `lib/screens/`
- Thêm widget trong `lib/widgets/`
- Cập nhật navigation trong `main.dart`

## Deploy

### Google Play Store
1. Build release APK
2. Tạo keystore
3. Sign APK
4. Upload lên Play Console

### App Store
1. Build iOS app
2. Archive trong Xcode
3. Upload lên App Store Connect

## Liên hệ

Nếu có vấn đề gì, hãy tạo issue trên GitHub repository.


