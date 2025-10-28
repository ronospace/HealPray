import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/adaptive_app_bar.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_theme.dart';

/// About screen with app information
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = 'Loading...';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdaptiveAppBar(
        title: Text('About HealPray'),
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // App Logo/Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.spa,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                
                const Text(
                  'HealPray',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version $_version ($_buildNumber)',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 32),
                
                GlassCard(
                  child: Column(
                    children: [
                      _buildInfoTile(
                        icon: Icons.info_outline,
                        title: 'About',
                        subtitle: 'Your daily healing & prayer companion',
                        onTap: null,
                      ),
                      Divider(color: Colors.white.withValues(alpha: 0.2)),
                      _buildInfoTile(
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        subtitle: 'View our terms and conditions',
                        onTap: () => _launchUrl('https://healpray.app/terms'),
                      ),
                      Divider(color: Colors.white.withValues(alpha: 0.2)),
                      _buildInfoTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'How we handle your data',
                        onTap: () => Navigator.pushNamed(context, '/privacy-policy'),
                      ),
                      Divider(color: Colors.white.withValues(alpha: 0.2)),
                      _buildInfoTile(
                        icon: Icons.gavel_outlined,
                        title: 'Open Source Licenses',
                        subtitle: 'View third-party licenses',
                        onTap: () => showLicensePage(
                          context: context,
                          applicationName: 'HealPray',
                          applicationVersion: '$_version+$_buildNumber',
                          applicationIcon: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.healingTeal,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.spa,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact & Support',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildContactItem(
                        icon: Icons.email_outlined,
                        text: 'ronos.icloud@gmail.com',
                        onTap: () => _launchUrl('mailto:ronos.icloud@gmail.com'),
                      ),
                      _buildContactItem(
                        icon: Icons.phone_outlined,
                        text: '+1 (762) 770-2411',
                        onTap: () => _launchUrl('https://wa.me/17627702411'),
                      ),
                      _buildContactItem(
                        icon: Icons.send_outlined,
                        text: '@ronospace',
                        onTap: () => _launchUrl('https://t.me/ronospace'),
                      ),
                      _buildContactItem(
                        icon: Icons.language_outlined,
                        text: 'healpray.app',
                        onTap: () => _launchUrl('https://healpray.app'),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Text(
                  'Made with ❤️ and 🙏',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2025 HealPray Technologies',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
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

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 13,
        ),
      ),
      trailing: onTap != null
          ? Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.7),
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 20),
      title: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.open_in_new,
        color: Colors.white.withValues(alpha: 0.6),
        size: 18,
      ),
      onTap: onTap,
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
