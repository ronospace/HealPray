import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/auth_provider.dart';

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
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            // Profile Section
            if (user != null) ...[
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.healingTeal.withOpacity(0.1),
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
                              color: AppTheme.healingTeal,
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
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Navigate to profile edit
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: AppTheme.textSecondary,
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
                  title: 'Push Notifications',
                  subtitle: 'Daily reminders and updates',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      // Toggle notifications
                    },
                    activeColor: AppTheme.healingTeal,
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.schedule,
                  title: 'Prayer Reminders',
                  subtitle: 'Set daily prayer times',
                  onTap: () {
                    // Navigate to prayer reminders
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.favorite_outline,
                  title: 'Mood Check Reminders',
                  subtitle: 'Daily mood tracking prompts',
                  onTap: () {
                    // Navigate to mood reminders
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
                    // Navigate to privacy policy
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.security,
                  title: 'Data Security',
                  subtitle: 'Encryption and security info',
                  onTap: () {
                    // Navigate to security info
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.download,
                  title: 'Export Data',
                  subtitle: 'Download your data',
                  onTap: () {
                    // Export user data
                  },
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
                _buildSettingsTile(
                  icon: Icons.palette_outlined,
                  title: 'Theme Settings',
                  subtitle: 'Appearance and colors',
                  onTap: () {
                    // Navigate to theme settings
                  },
                ),
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
                    // Navigate to feedback
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.contact_support_outlined,
                  title: 'Contact Us',
                  subtitle: 'Get in touch',
                  onTap: () {
                    // Navigate to contact
                  },
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
                  onTap: () {
                    // Open app store rating
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
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children.map((child) {
              final isLast = child == children.last;
              return Column(
                children: [
                  child,
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: Colors.grey.shade200,
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
          color: AppTheme.healingTeal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppTheme.healingTeal,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondary,
                )
              : null),
      onTap: onTap,
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
