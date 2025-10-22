import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/supabase_service.dart';
import '../utils/app_colors.dart';

class TestConnectionScreen extends StatefulWidget {
  const TestConnectionScreen({super.key});

  @override
  State<TestConnectionScreen> createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends State<TestConnectionScreen> {
  bool _isTesting = false;
  Map<String, bool> _testResults = {};
  Map<String, String> _testMessages = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Test Connections'),
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Backend Connections',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Firebase Tests
            _buildTestSection(
              title: 'Firebase Services',
              tests: [
                'Firebase Analytics',
                'Firebase Crashlytics',
                'Firebase Messaging',
                'Firebase Performance',
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Supabase Tests
            _buildTestSection(
              title: 'Supabase Services',
              tests: [
                'Supabase Connection',
                'Database Access',
                'Storage Access',
                'Edge Functions',
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Test Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isTesting ? null : _runAllTests,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isTesting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Testing...'),
                        ],
                      )
                    : const Text(
                        'Run All Tests',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection({required String title, required List<String> tests}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...tests.map((test) => _buildTestItem(test)),
      ],
    );
  }

  Widget _buildTestItem(String testName) {
    final isSuccess = _testResults[testName] ?? false;
    final message = _testMessages[testName] ?? '';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSuccess ? AppColors.success : AppColors.error,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  testName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isTesting = true;
      _testResults.clear();
      _testMessages.clear();
    });

    // Test Firebase Services
    await _testFirebaseAnalytics();
    await _testFirebaseCrashlytics();
    await _testFirebaseMessaging();
    await _testFirebasePerformance();

    // Test Supabase Services
    await _testSupabaseConnection();
    await _testSupabaseDatabase();
    await _testSupabaseStorage();
    await _testSupabaseEdgeFunctions();

    setState(() {
      _isTesting = false;
    });

    // Show results
    _showTestResults();
  }

  Future<void> _testFirebaseAnalytics() async {
    try {
      await FirebaseService.instance.logEvent('test_connection');
      _testResults['Firebase Analytics'] = true;
      _testMessages['Firebase Analytics'] = 'Analytics event logged successfully';
    } catch (e) {
      _testResults['Firebase Analytics'] = false;
      _testMessages['Firebase Analytics'] = 'Error: $e';
    }
    setState(() {});
  }

  Future<void> _testFirebaseCrashlytics() async {
    try {
      await FirebaseService.instance.setCustomKey('test_key', 'test_value');
      _testResults['Firebase Crashlytics'] = true;
      _testMessages['Firebase Crashlytics'] = 'Custom key set successfully';
    } catch (e) {
      _testResults['Firebase Crashlytics'] = false;
      _testMessages['Firebase Crashlytics'] = 'Error: $e';
    }
    setState(() {});
  }

  Future<void> _testFirebaseMessaging() async {
    try {
      final token = await FirebaseService.instance.getFCMToken();
      _testResults['Firebase Messaging'] = token != null;
      _testMessages['Firebase Messaging'] = token != null 
          ? 'FCM Token: ${token.substring(0, 20)}...'
          : 'FCM Token not available';
    } catch (e) {
      _testResults['Firebase Messaging'] = false;
      _testMessages['Firebase Messaging'] = 'Error: $e';
    }
    setState(() {});
  }

  Future<void> _testFirebasePerformance() async {
    try {
      final trace = await FirebaseService.instance.startTrace('test_trace');
      await FirebaseService.instance.stopTrace(trace);
      _testResults['Firebase Performance'] = true;
      _testMessages['Firebase Performance'] = 'Performance trace completed';
    } catch (e) {
      _testResults['Firebase Performance'] = false;
      _testMessages['Firebase Performance'] = 'Error: $e';
    }
    setState(() {});
  }

  Future<void> _testSupabaseConnection() async {
    try {
      final client = SupabaseService.instance.client;
      final response = await client.from('user_profiles').select('count').limit(1);
      _testResults['Supabase Connection'] = true;
      _testMessages['Supabase Connection'] = 'Connected to Supabase successfully';
    } catch (e) {
      _testResults['Supabase Connection'] = false;
      _testMessages['Supabase Connection'] = 'Error: $e';
    }
    setState(() {});
  }

  Future<void> _testSupabaseDatabase() async {
    try {
      final client = SupabaseService.instance.client;
      final response = await client.from('pdf_files').select('count').limit(1);
      _testResults['Database Access'] = true;
      _testMessages['Database Access'] = 'Database tables accessible';
    } catch (e) {
      _testResults['Database Access'] = false;
      _testMessages['Database Access'] = 'Error: $e';
    }
    setState(() {});
  }

  Future<void> _testSupabaseStorage() async {
    try {
      final client = SupabaseService.instance.client;
      final response = await client.storage.from('pdf_files').list();
      _testResults['Storage Access'] = true;
      _testMessages['Storage Access'] = 'Storage buckets accessible';
    } catch (e) {
      _testResults['Storage Access'] = false;
      _testMessages['Storage Access'] = 'Error: $e';
    }
    setState(() {});
  }

  Future<void> _testSupabaseEdgeFunctions() async {
    try {
      final client = SupabaseService.instance.client;
      final response = await client.functions.invoke('pdf-processing', body: {
        'action': 'extract-text',
        'fileUrl': 'https://example.com/test.pdf',
      });
      _testResults['Edge Functions'] = true;
      _testMessages['Edge Functions'] = 'Edge function invoked successfully';
    } catch (e) {
      _testResults['Edge Functions'] = false;
      _testMessages['Edge Functions'] = 'Error: $e';
    }
    setState(() {});
  }

  void _showTestResults() {
    final successCount = _testResults.values.where((v) => v).length;
    final totalCount = _testResults.length;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: Text(
          'Test Results',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Tests passed: $successCount/$totalCount\n\n'
          'Firebase: ${_getFirebaseResults()}\n'
          'Supabase: ${_getSupabaseResults()}',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  String _getFirebaseResults() {
    final firebaseTests = ['Firebase Analytics', 'Firebase Crashlytics', 'Firebase Messaging', 'Firebase Performance'];
    final successCount = firebaseTests.where((test) => _testResults[test] == true).length;
    return '$successCount/${firebaseTests.length}';
  }

  String _getSupabaseResults() {
    final supabaseTests = ['Supabase Connection', 'Database Access', 'Storage Access', 'Edge Functions'];
    final successCount = supabaseTests.where((test) => _testResults[test] == true).length;
    return '$successCount/${supabaseTests.length}';
  }
}
