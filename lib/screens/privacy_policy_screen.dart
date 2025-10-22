import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Information We Collect',
              [
                'We collect information you provide directly to us, such as when you create an account, use our services, or contact us for support.',
                'We automatically collect certain information about your device and how you use our app, including your IP address, device information, and usage patterns.',
                'We may collect information from third-party sources, such as social media platforms, if you choose to connect your account.',
              ],
            ),
            _buildSection(
              'How We Use Your Information',
              [
                'To provide, maintain, and improve our services',
                'To process transactions and send related information',
                'To send technical notices, updates, and support messages',
                'To respond to your comments and questions',
                'To personalize your experience and provide relevant content',
              ],
            ),
            _buildSection(
              'Information Sharing',
              [
                'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent.',
                'We may share your information with service providers who assist us in operating our app and conducting our business.',
                'We may disclose your information if required by law or to protect our rights and safety.',
              ],
            ),
            _buildSection(
              'Data Security',
              [
                'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
                'We use encryption and other security technologies to protect your data.',
                'However, no method of transmission over the internet is 100% secure.',
              ],
            ),
            _buildSection(
              'Your Rights',
              [
                'You have the right to access, update, or delete your personal information.',
                'You can opt out of certain communications from us.',
                'You can request a copy of your data or ask us to delete it.',
                'You can contact us at any time to exercise these rights.',
              ],
            ),
            _buildSection(
              'Children\'s Privacy',
              [
                'Our services are not intended for children under 13 years of age.',
                'We do not knowingly collect personal information from children under 13.',
                'If we become aware that we have collected personal information from a child under 13, we will take steps to delete such information.',
              ],
            ),
            _buildSection(
              'Changes to This Policy',
              [
                'We may update this Privacy Policy from time to time.',
                'We will notify you of any changes by posting the new Privacy Policy on this page.',
                'You are advised to review this Privacy Policy periodically for any changes.',
              ],
            ),
            _buildSection(
              'Contact Us',
              [
                'If you have any questions about this Privacy Policy, please contact us at:',
                'Email: jokerlin135@gmail.com',
                'We will respond to your inquiry within 48 hours.',
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Last updated: ${DateTime.now().toString().split(' ')[0]}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...content.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 8, right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
