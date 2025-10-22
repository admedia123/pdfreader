# Giải pháp sửa lỗi Android Embedding

## Tóm tắt lỗi
Dự án gặp lỗi "Build failed due to use of deleted Android v1 embedding" và các lỗi liên quan đến dependencies không tương thích.

## Các lỗi chính:
1. Android v1 embedding đã bị xóa
2. Dependencies không tương thích với Flutter mới
3. Thiếu resources (ic_launcher, styles)
4. File picker plugin có vấn đề với v1 embedding

## Giải pháp được đề xuất:

### 1. Tạo project Flutter mới
Thay vì sửa project hiện tại, hãy tạo project mới:

```bash
# Tạo project mới
flutter create pdf_reader_new

# Di chuyển vào thư mục
cd pdf_reader_new

# Copy code từ project cũ
# - Copy lib/ folder
# - Copy pubspec.yaml (cập nhật dependencies)
```

### 2. Cập nhật pubspec.yaml với dependencies tương thích
```yaml
name: pdf_reader
description: A Flutter PDF Reader app
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # PDF handling - sử dụng packages mới hơn
  flutter_pdfview: ^1.3.2
  pdf: ^3.10.7
  path_provider: ^2.1.1
  file_picker: ^8.0.0+1  # Version mới hơn
  
  # UI and navigation
  cupertino_icons: ^1.0.2
  shared_preferences: ^2.2.2
  
  # Image handling
  image_picker: ^1.0.4
  image: ^4.1.3
  
  # Sharing and permissions
  share_plus: ^7.2.1
  permission_handler: ^11.0.1
  
  # UI components
  shimmer: ^3.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

### 3. Cập nhật dependencies
```bash
flutter pub get
flutter pub upgrade
```

### 4. Sửa lỗi code
Một số lỗi cần sửa trong code:

#### a. Sửa PDFViewerScreen route
```dart
// Trong main.dart
'/pdf-viewer': (context) {
  final pdfFile = ModalRoute.of(context)?.settings.arguments as PDFFile?;
  if (pdfFile != null) {
    return PDFViewerScreen(pdfFile: pdfFile);
  }
  return const HomeScreen();
},
```

#### b. Sửa theme.dart
```dart
// Thay CardTheme bằng CardThemeData
cardTheme: CardThemeData(
  color: cardColor,
  elevation: 2,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
),
```

### 5. Test build
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

## Nếu vẫn gặp lỗi:

### Option 1: Sử dụng Flutter version cũ hơn
```bash
flutter downgrade
flutter clean
flutter pub get
flutter build apk --debug
```

### Option 2: Tạo project từ template mới
```bash
flutter create --template=app pdf_reader_fixed
cd pdf_reader_fixed
# Copy code từ project cũ
```

### Option 3: Sử dụng dependencies cũ hơn
```yaml
dependencies:
  flutter:
    sdk: flutter
  file_picker: ^5.5.0  # Version cũ hơn
  flutter_pdfview: ^1.2.2  # Version cũ hơn
```

## Lưu ý quan trọng:
1. Luôn backup code trước khi thay đổi
2. Test trên device thật thay vì chỉ build
3. Kiểm tra Flutter doctor trước khi build
4. Sử dụng Flutter version ổn định

## Kết luận:
Lỗi này rất phổ biến khi upgrade Flutter. Cách tốt nhất là tạo project mới và copy code, hoặc downgrade Flutter version.



