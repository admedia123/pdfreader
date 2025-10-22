import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/pdf_viewer_screen.dart';
import 'screens/permission_screen.dart';
import 'utils/theme.dart';
import 'models/pdf_file.dart';

void main() {
  runApp(const PDFReaderApp());
}

class PDFReaderApp extends StatelessWidget {
  const PDFReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Reader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Force dark mode to match design
      home: const SplashScreen(),
      routes: {
        '/permission': (context) => const PermissionScreen(),
        '/main': (context) => const MainScreen(),
        '/pdf-viewer': (context) {
          final pdfFile =
              ModalRoute.of(context)?.settings.arguments as PDFFile?;
          if (pdfFile != null) {
            return PDFViewerScreen(pdfFile: pdfFile);
          }
          return const MainScreen();
        },
      },
    );
  }
}
