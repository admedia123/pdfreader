import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = true; // Default to dark mode
  String _language = 'English';
  bool _autoNightMode = false;
  double _defaultZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      _language = prefs.getString('language') ?? 'English';
      _autoNightMode = prefs.getBool('autoNightMode') ?? false;
      _defaultZoom = prefs.getDouble('defaultZoom') ?? 1.0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setString('language', _language);
    await prefs.setBool('autoNightMode', _autoNightMode);
    await prefs.setDouble('defaultZoom', _defaultZoom);
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
      body: Column(
        children: [
          // Free Trial Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.star, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '✨ Claim 3-day free trial ✨',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'GENERAL',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildSettingsTile(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: _language,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.darkCard,
                        title: const Text(
                          'Select Language',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile<String>(
                              title: const Text('English',
                                  style:
                                      TextStyle(color: AppColors.textPrimary)),
                              value: 'English',
                              groupValue: _language,
                              onChanged: (value) {
                                setState(() {
                                  _language = value!;
                                });
                                _saveSettings();
                                Navigator.pop(context);
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('Tiếng Việt',
                                  style:
                                      TextStyle(color: AppColors.textPrimary)),
                              value: 'Tiếng Việt',
                              groupValue: _language,
                              onChanged: (value) {
                                setState(() {
                                  _language = value!;
                                });
                                _saveSettings();
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.dark_mode,
                  title: 'Dark mode',
                  subtitle: _isDarkMode ? 'On' : 'Off',
                  trailing: Switch(
                    value: _isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value;
                      });
                      _saveSettings();
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.feedback,
                  title: 'Feedback',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Feedback feature coming soon'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.key,
                  title: 'Permission manager',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Permission manager coming soon'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.star_outline,
                  title: 'Rate the app',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rate the app feature coming soon'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'OTHER',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildSettingsTile(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy Policy coming soon'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.share,
                  title: 'Invite friends to the app',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share feature coming soon'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.facebook,
                  title: 'Facebook Fanpage',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Facebook page coming soon'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textPrimary),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(color: AppColors.textSecondary),
              )
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
