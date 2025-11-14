import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/theme_switcher_button.dart';

/// Prayer screen for spiritual guidance
class PrayerScreen extends ConsumerStatefulWidget {
  const PrayerScreen({super.key});

  @override
  ConsumerState<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends ConsumerState<PrayerScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.midnightBlue;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prayer & Reflection',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: textColor,
          ),
        ),
        backgroundColor: isDark 
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        foregroundColor: textColor,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          const CompactThemeSwitcher(),
          IconButton(
            onPressed: () {
              // Navigate to prayer history
            },
            icon: Icon(
              Icons.bookmark_outline,
              color: textColor,
            ),
          ),
        ],
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Daily verse or inspiration
              GlassCard(
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: textColor,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Daily Inspiration',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"Be still and know that I am God."',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Psalm 46:10',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: textColor.withValues(alpha: 0.8),
                          ),
                    ),
                  ],
                ),
              ),

              // Prayer options
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildPrayerOptionCard(
                      title: 'Generate Prayer',
                      subtitle: 'AI-guided personalized prayers',
                      icon: Icons.psychology,
                      onTap: () {
                        context.push('/prayer/generate');
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPrayerOptionCard(
                      title: 'Guided Meditation',
                      subtitle: 'Peaceful moments with God',
                      icon: Icons.self_improvement,
                      comingSoon: true,
                      onTap: () {
                        _showComingSoonDialog(context);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPrayerOptionCard(
                      title: 'Scripture Reading',
                      subtitle: 'Daily Bible verses and reflection',
                      icon: Icons.menu_book,
                      comingSoon: true,
                      onTap: () {
                        _showComingSoonDialog(context);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPrayerOptionCard(
                      title: 'Prayer Journal',
                      subtitle: 'Record your prayers and thoughts',
                      icon: Icons.edit_note,
                      comingSoon: true,
                      onTap: () {
                        _showComingSoonDialog(context);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPrayerOptionCard(
                      title: 'Prayer Requests',
                      subtitle: 'Submit and track prayer needs',
                      icon: Icons.favorite,
                      comingSoon: true,
                      onTap: () {
                        _showComingSoonDialog(context);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPrayerOptionCard(
                      title: 'Community Prayers',
                      subtitle: 'Join others in prayer',
                      icon: Icons.people,
                      comingSoon: true,
                      onTap: () {
                        _showComingSoonDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool comingSoon = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.midnightBlue;
    
    return GlassCard(
      onTap: onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.2)
                : AppTheme.primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: textColor,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (comingSoon)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber[100],
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.7),
          ),
        ),
        trailing: Icon(
          comingSoon ? Icons.lock_clock : Icons.chevron_right,
          color: textColor.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.access_time, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Coming Soon',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'This feature is currently under development and will be available in a future update. Stay tuned!',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
