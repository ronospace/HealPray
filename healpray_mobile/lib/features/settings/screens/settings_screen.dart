import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/adaptive_app_bar.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../core/providers/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

/// Settings screen for app configuration
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: const AdaptiveAppBar(
        title: Text('Settings'),
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: ListView(
          children: [
              // Profile Section
              if (user != null) ...[
                GlassCard(
                  margin: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: user.photoURL != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(
                                  user.photoURL!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 30,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName ?? 'User',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Navigate to profile edit
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

            // Settings Sections
            _buildSettingsSection(
              title: 'Notifications',
              children: [
                _buildSettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notification Settings',
                  subtitle: 'Manage all your reminders and alerts',
                  onTap: () {
                    context.push('/settings/notifications');
                  },
                ),
              ],
            ),

            _buildSettingsSection(
              title: 'Privacy & Data',
              children: [
                _buildSettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  onTap: () {
                    context.push('/settings/privacy-policy');
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.security,
                  title: 'Data Security',
                  subtitle: 'Encryption and security info',
                  onTap: () {
                    context.push('/settings/data-security');
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.analytics_outlined,
                  title: 'Analytics Dashboard',
                  subtitle: 'View app usage insights',
                  onTap: () {
                    context.push('/analytics-dashboard');
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.download,
                  title: 'Export Data',
                  subtitle: 'Download your data',
                  onTap: () => _showExportDataDialog(context),
                ),
              ],
            ),

            _buildSettingsSection(
              title: 'Personalization',
              children: [
                _buildSettingsTile(
                  icon: Icons.church_outlined,
                  title: 'Spiritual Preferences',
                  subtitle: 'Customize your faith journey',
                  onTap: () {
                    // Navigate to spiritual preferences
                  },
                ),
                _buildThemeModeTile(),
                _buildSettingsTile(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'English',
                  onTap: () {
                    // Navigate to language settings
                  },
                ),
              ],
            ),

            _buildSettingsSection(
              title: 'Support',
              children: [
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  subtitle: 'FAQ and guides',
                  onTap: () {
                    // Navigate to help center
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  subtitle: 'Share your thoughts',
                  onTap: () {
                    context.push('/feedback');
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.help_center_outlined,
                  title: 'Contact Us',
                  subtitle: 'Get in touch',
                  onTap: () => _showContactOptions(context),
                ),
              ],
            ),

            _buildSettingsSection(
              title: 'About',
              children: [
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: 'App Version',
                  subtitle: '1.0.0',
                ),
                _buildSettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  subtitle: 'Usage terms and conditions',
                  onTap: () {
                    // Navigate to terms
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.star_outline,
                  title: 'Rate App',
                  subtitle: 'Share your experience',
                  onTap: () => _requestRateApp(context),
                ),
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App version and info',
                  onTap: () {
                    context.push('/settings/about');
                  },
                ),
              ],
            ),

            // Sign Out Section
            if (user != null) ...[
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => _showSignOutDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        GlassCard(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: children.map((child) {
              final isLast = child == children.last;
              return Column(
                children: [
                  child,
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.2),
                      indent: 60,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.7),
                )
              : null),
      onTap: onTap,
    );
  }

  Widget _buildThemeModeTile() {
    final themeMode = ref.watch(themeModeProvider);
    
    return _buildSettingsTile(
      icon: Icons.brightness_6_outlined,
      title: 'Theme',
      subtitle: _getThemeModeLabel(themeMode),
      onTap: () => _showThemeModeDialog(context),
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
      case ThemeMode.system:
        return 'System default';
    }
  }

  void _showThemeModeDialog(BuildContext context) {
    final currentMode = ref.read(themeModeProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeModeOption(
              mode: ThemeMode.system,
              label: 'System Default',
              icon: Icons.brightness_auto,
              isSelected: currentMode == ThemeMode.system,
            ),
            _buildThemeModeOption(
              mode: ThemeMode.light,
              label: 'Light Mode',
              icon: Icons.light_mode,
              isSelected: currentMode == ThemeMode.light,
            ),
            _buildThemeModeOption(
              mode: ThemeMode.dark,
              label: 'Dark Mode',
              icon: Icons.dark_mode,
              isSelected: currentMode == ThemeMode.dark,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeOption({
    required ThemeMode mode,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.healingTeal : null),
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppTheme.healingTeal)
          : null,
      selected: isSelected,
      onTap: () {
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
        Navigator.of(context).pop();
      },
    );
  }

  void _showExportDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'This will export all your data including mood entries, prayers, and settings to a JSON file.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportData();
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    // TODO: Implement actual data export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exporting your data...'),
        backgroundColor: AppTheme.healingTeal,
      ),
    );
    
    // Simulate export
    await Future.delayed(const Duration(seconds: 1));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data exported successfully!'),
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildContactOption(
              icon: Icons.email,
              title: 'Email',
              subtitle: 'ronos.icloud@gmail.com',
              onTap: () => _launchUrl('mailto:ronos.icloud@gmail.com'),
            ),
            _buildContactOption(
              icon: Icons.phone,
              title: 'WhatsApp',
              subtitle: '+1 (762) 770-2411',
              onTap: () => _launchUrl('https://wa.me/17627702411'),
            ),
            _buildContactOption(
              icon: Icons.send,
              title: 'Telegram',
              subtitle: '@ronospace',
              onTap: () => _launchUrl('https://t.me/ronospace'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.healingTeal),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _requestRateApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate HealPray'),
        content: const Text(
          'Thank you for using HealPray! Your feedback helps us improve. Would you like to rate us on the App Store?',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement in_app_review
              _launchUrl('https://apps.apple.com/app/healpray');
            },
            child: const Text('Rate'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Perform sign out
              ref.read(authProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
