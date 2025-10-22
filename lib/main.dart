import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/pdf_viewer_screen.dart';
import 'screens/permission_screen.dart';
import 'services/firebase_service.dart';
import 'services/supabase_service.dart';
import 'services/remote_config_service.dart';
import 'services/ads_manager_simple.dart';
import 'utils/theme.dart';
import 'models/pdf_file.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase first
    await FirebaseService.instance.initialize();

    // Initialize RemoteConfig second
    await RemoteConfigService.instance.initialize();

    // Initialize Supabase in parallel
    await SupabaseService.instance.initialize();

    // Initialize Ads Manager after RemoteConfig is ready
    await AdsManager.instance.initialize();

    runApp(const PDFReaderApp());
  } catch (e) {
    print('App initialization error: $e');
    // Still run app even if some services fail
    runApp(const PDFReaderApp());
  }
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
