class AppConstants {
  // App Info
  static const String appName = 'PDF Reader';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Your Ultimate PDF Companion';

  // File Extensions
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'bmp',
    'gif',
    'webp',
  ];

  static const String pdfExtension = 'pdf';

  // Storage
  static const String pdfDirectoryName = 'PDFReader';
  static const String thumbnailDirectoryName = 'Thumbnails';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardRadius = 12.0;
  static const double buttonRadius = 8.0;

  // PDF Viewer
  static const double minZoom = 0.5;
  static const double maxZoom = 3.0;
  static const double defaultZoom = 1.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // File Size Limits
  static const int maxFileSize = 100 * 1024 * 1024; // 100MB
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB

  // Sort Options
  static const List<String> sortOptions = ['name', 'date', 'size'];

  // Theme
  static const String lightThemeKey = 'light';
  static const String darkThemeKey = 'dark';
  static const String systemThemeKey = 'system';

  // Settings Keys
  static const String isDarkModeKey = 'isDarkMode';
  static const String isGridViewKey = 'isGridView';
  static const String sortByKey = 'sortBy';
  static const String autoNightModeKey = 'autoNightMode';
  static const String defaultZoomKey = 'defaultZoom';
}


