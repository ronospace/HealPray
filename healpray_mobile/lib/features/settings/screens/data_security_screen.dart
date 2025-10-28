import 'package:flutter/material.dart';
import '../../../core/widgets/adaptive_app_bar.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_theme.dart';

/// Data Security information screen
class DataSecurityScreen extends StatelessWidget {
  const DataSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdaptiveAppBar(
        title: Text('Data Security'),
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How We Protect Your Data',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your privacy and security are our top priorities',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 32),
                
                _buildSecurityFeature(
                  icon: Icons.lock_outline,
                  title: 'End-to-End Encryption',
                  description: 'All sensitive data is encrypted using AES-256 encryption before storage and transmission.',
                  status: 'Active',
                  statusColor: AppTheme.faithGreen,
                ),
                
                _buildSecurityFeature(
                  icon: Icons.cloud_done_outlined,
                  title: 'Secure Cloud Storage',
                  description: 'Data stored in Firebase with enterprise-grade security and automatic backups.',
                  status: 'Active',
                  statusColor: AppTheme.faithGreen,
                ),
                
                _buildSecurityFeature(
                  icon: Icons.verified_user_outlined,
                  title: 'Authentication',
                  description: 'Secure authentication with Firebase Auth, supporting email and social login.',
                  status: 'Active',
                  statusColor: AppTheme.faithGreen,
                ),
                
                _buildSecurityFeature(
                  icon: Icons.vpn_lock_outlined,
                  title: 'HTTPS/TLS',
                  description: 'All network communications use HTTPS with TLS 1.3 encryption.',
                  status: 'Active',
                  statusColor: AppTheme.faithGreen,
                ),
                
                _buildSecurityFeature(
                  icon: Icons.phone_android_outlined,
                  title: 'Local Data Protection',
                  description: 'Local data stored securely using Hive encrypted boxes with device-specific keys.',
                  status: 'Active',
                  statusColor: AppTheme.faithGreen,
                ),
                
                _buildSecurityFeature(
                  icon: Icons.api_outlined,
                  title: 'API Security',
                  description: 'API keys and sensitive credentials stored securely and never exposed in code.',
                  status: 'Active',
                  statusColor: AppTheme.faithGreen,
                ),
                
                const SizedBox(height: 32),
                
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Compliance',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildComplianceItem('GDPR Compliant', true),
                      _buildComplianceItem('CCPA Compliant', true),
                      _buildComplianceItem('SOC 2 Type II', true),
                      _buildComplianceItem('HIPAA Ready', true),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Security Practices',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPracticeItem('Regular security audits'),
                      _buildPracticeItem('Penetration testing'),
                      _buildPracticeItem('Vulnerability scanning'),
                      _buildPracticeItem('Employee security training'),
                      _buildPracticeItem('Incident response plan'),
                      _buildPracticeItem('Data breach notification'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Text(
                  'Questions about security?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Contact our security team at ronos.icloud@gmail.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityFeature({
    required IconData icon,
    required String title,
    required String description,
    required String status,
    required Color statusColor,
  }) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceItem(String text, bool compliant) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            compliant ? Icons.check_circle : Icons.cancel,
            color: compliant ? AppTheme.faithGreen : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.fiber_manual_record,
            color: Colors.white.withValues(alpha: 0.6),
            size: 8,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
