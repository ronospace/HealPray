import 'package:flutter/material.dart';
import '../../../core/widgets/adaptive_app_bar.dart';
import '../../../core/widgets/animated_gradient_background.dart';

/// Privacy Policy screen
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdaptiveAppBar(
        title: Text('Privacy Policy'),
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  'Last Updated',
                  'October 28, 2025',
                  context,
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Introduction',
                  'HealPray ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
                  context,
                ),
                _buildSection(
                  'Information We Collect',
                  '''We collect information that you provide directly to us, including:

• Account Information: Name, email address, profile photo
• Spiritual Preferences: Denomination, prayer styles, faith traditions
• Mood Data: Emotional state tracking, mood entries, journal reflections
• Usage Data: App interactions, features used, session duration
• Device Information: Device type, OS version, unique identifiers
• Location Data: Approximate location for time-based features (optional)''',
                  context,
                ),
                _buildSection(
                  'How We Use Your Information',
                  '''We use your information to:

• Provide personalized prayer and meditation experiences
• Generate AI-powered prayers based on your mood and needs
• Track your spiritual and emotional journey
• Send relevant notifications and reminders
• Improve our services and develop new features
• Ensure app security and prevent fraud
• Comply with legal obligations''',
                  context,
                ),
                _buildSection(
                  'Data Sharing and Disclosure',
                  '''We do not sell your personal information. We may share your data with:

• Service Providers: AI services (OpenAI, Google Gemini), analytics providers, cloud storage
• Legal Requirements: When required by law or to protect rights
• With Your Consent: For features you explicitly enable

All data sharing is governed by strict confidentiality agreements.''',
                  context,
                ),
                _buildSection(
                  'Data Security',
                  '''We implement industry-standard security measures:

• End-to-end encryption for sensitive data
• Secure cloud storage with Firebase
• Regular security audits and updates
• Limited employee access to user data
• Automatic data backup and recovery''',
                  context,
                ),
                _buildSection(
                  'Your Rights',
                  '''You have the right to:

• Access your personal data
• Correct inaccurate information
• Delete your account and data
• Export your data (data portability)
• Opt-out of marketing communications
• Withdraw consent at any time''',
                  context,
                ),
                _buildSection(
                  'Data Retention',
                  'We retain your data for as long as your account is active or as needed to provide services. You can request deletion at any time through Settings > Export Data > Delete Account.',
                  context,
                ),
                _buildSection(
                  'Children\'s Privacy',
                  'HealPray is not intended for children under 13. We do not knowingly collect information from children under 13. If we discover such data, we will delete it immediately.',
                  context,
                ),
                _buildSection(
                  'Changes to This Policy',
                  'We may update this Privacy Policy periodically. We will notify you of significant changes via email or in-app notification.',
                  context,
                ),
                _buildSection(
                  'Contact Us',
                  '''If you have questions about this Privacy Policy, contact us at:

Email: ronos.icloud@gmail.com
WhatsApp: +1 (762) 770-2411
Telegram: @ronospace''',
                  context,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
