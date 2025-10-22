import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/app_colors.dart';
import '../services/ads_manager_simple.dart';
import 'language_screen.dart';
import 'premium_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = true;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode') ?? true;
      _selectedLanguage = prefs.getString('selected_language') ?? 'English';
    });
  }

  Future<void> _saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.textPrimary,
      ),
      body: ListView(
        children: [
          // Free Trial Banner
          _buildFreeTrialBanner(),

          // General Settings
          _buildSectionHeader('GENERAL'),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: _selectedLanguage,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LanguageScreen()),
              );
              if (result != null) {
                setState(() {
                  _selectedLanguage = result;
                });
              }
            },
          ),
          _buildSettingsTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: _isDarkMode ? 'On' : 'Off',
            trailing: Switch(
              value: _isDarkMode,
              onChanged: _saveDarkMode,
              activeColor: AppColors.primary,
            ),
          ),

          // Premium Features
          _buildSectionHeader('PREMIUM FEATURES'),
          _buildSettingsTile(
            icon: Icons.card_giftcard,
            title: 'Unlock Premium Features',
            subtitle: 'Get premium features and remove ads',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.remove_red_eye,
            title: 'Remove Ads',
            subtitle: 'Remove all ads from the app',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.local_offer,
            title: 'Claim 3-days',
            subtitle: 'Get 3 days free trial',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );
            },
          ),

          // Support & Feedback
          _buildSectionHeader('SUPPORT & FEEDBACK'),
          _buildSettingsTile(
            icon: Icons.feedback,
            title: 'Feedback',
            subtitle: 'Send us your feedback',
            onTap: _sendFeedback,
          ),
          _buildSettingsTile(
            icon: Icons.security,
            title: 'Permission Manager',
            subtitle: 'Manage app permissions',
            onTap: _openPermissionManager,
          ),
          _buildSettingsTile(
            icon: Icons.star_rate,
            title: 'Rate the App',
            subtitle: 'Rate us on Google Play',
            onTap: _rateApp,
          ),

          // Legal & Info
          _buildSectionHeader('LEGAL & INFO'),
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen()),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.share,
            title: 'Invite Friends',
            subtitle: 'Share the app with friends',
            onTap: _shareApp,
          ),
          _buildSettingsTile(
            icon: Icons.facebook,
            title: 'Facebook Page',
            subtitle: 'Follow us on Facebook',
            onTap: _openFacebookPage,
          ),
        ],
      ),
    );
  }

  Widget _buildFreeTrialBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.card_giftcard,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free Trial Available!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Get 3 days free trial and unlock all premium features',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );
            },
            icon: Icon(Icons.arrow_forward, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textSecondary,
            size: 16,
          ),
      onTap: onTap,
    );
  }

  Future<void> _sendFeedback() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'jokerlin135@gmail.com',
      query:
          'subject=PDF Reader Feedback&body=Hi, I would like to share my feedback about the PDF Reader app.',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showSnackBar('No email app found');
      }
    } catch (e) {
      _showSnackBar('Error opening email: $e');
    }
  }

  Future<void> _openPermissionManager() async {
    try {
      await openAppSettings();
    } catch (e) {
      _showSnackBar('Error opening settings: $e');
    }
  }

  Future<void> _rateApp() async {
    // Replace with your actual Google Play Store URL
    final Uri playStoreUri = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.highmyx.pdfreaderapp');

    try {
      if (await canLaunchUrl(playStoreUri)) {
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Cannot open Play Store');
      }
    } catch (e) {
      _showSnackBar('Error opening Play Store: $e');
    }
  }

  Future<void> _shareApp() async {
    try {
      await Share.share(
        'Check out this amazing PDF Reader app! Download it from Google Play Store.',
        subject: 'PDF Reader App',
      );
    } catch (e) {
      _showSnackBar('Error sharing app: $e');
    }
  }

  Future<void> _openFacebookPage() async {
    // Replace with your actual Facebook page URL
    final Uri facebookUri = Uri.parse('https://facebook.com/yourpage');

    try {
      if (await canLaunchUrl(facebookUri)) {
        await launchUrl(facebookUri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Cannot open Facebook');
      }
    } catch (e) {
      _showSnackBar('Error opening Facebook: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
