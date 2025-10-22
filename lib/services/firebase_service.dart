import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_performance/firebase_performance.dart';
import '../config/firebase_config.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();
  
  FirebaseService._();
  
  late FirebaseAnalytics _analytics;
  late FirebaseCrashlytics _crashlytics;
  late FirebaseMessaging _messaging;
  late FirebasePerformance _performance;
  
  FirebaseAnalytics get analytics => _analytics;
  FirebaseCrashlytics get crashlytics => _crashlytics;
  FirebaseMessaging get messaging => _messaging;
  FirebasePerformance get performance => _performance;
  
  Future<void> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      
      // Initialize services
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;
      _messaging = FirebaseMessaging.instance;
      _performance = FirebasePerformance.instance;
      
      // Configure analytics
      await _analytics.setAnalyticsCollectionEnabled(FirebaseConfig.enableAnalytics);
      
      // Configure crashlytics
      await _crashlytics.setCrashlyticsCollectionEnabled(FirebaseConfig.enableCrashlytics);
      
      // Configure messaging
      if (FirebaseConfig.enableMessaging) {
        await _setupMessaging();
      }
      
      print('Firebase initialized successfully');
    } catch (e) {
      print('Firebase initialization failed: $e');
      rethrow;
    }
  }
  
  Future<void> _setupMessaging() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    // Get FCM token
    final token = await _messaging.getToken();
    print('FCM Token: $token');
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      // Handle foreground notification
    });
    
    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped: ${message.notification?.title}');
      // Handle notification tap
    });
  }
  
  // Analytics methods
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      print('Analytics error: $e');
    }
  }
  
  Future<void> setUserProperty(String name, String? value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      print('User property error: $e');
    }
  }
  
  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      print('User ID error: $e');
    }
  }
  
  // Crashlytics methods
  Future<void> recordError(dynamic exception, StackTrace? stackTrace, {String? reason}) async {
    try {
      await _crashlytics.recordError(exception, stackTrace, reason: reason);
    } catch (e) {
      print('Crashlytics error: $e');
    }
  }
  
  Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      print('Custom key error: $e');
    }
  }
  
  Future<void> setUserId(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
    } catch (e) {
      print('Crashlytics user ID error: $e');
    }
  }
  
  // Performance methods
  Future<Trace> startTrace(String traceName) async {
    return _performance.newTrace(traceName);
  }
  
  Future<void> stopTrace(Trace trace) async {
    await trace.stop();
  }
  
  // Messaging methods
  Future<String?> getFCMToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('FCM token error: $e');
      return null;
    }
  }
  
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      print('Topic subscription error: $e');
    }
  }
  
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      print('Topic unsubscription error: $e');
    }
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}
