import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';

/// Prayer screen for spiritual guidance
class PrayerScreen extends ConsumerStatefulWidget {
  const PrayerScreen({super.key});

  @override
  ConsumerState<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends ConsumerState<PrayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const GradientText(
          'Prayer & Reflection',
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE5F0FF)],
          ),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to prayer history
            },
            icon: const Icon(
              Icons.bookmark_outline,
              color: Colors.white,
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
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Daily Inspiration',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '"Be still and know that I am God."',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Psalm 46:10',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
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
                      onTap: () {
                        // Navigate to meditation
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPrayerOptionCard(
                      title: 'Scripture Reading',
                      subtitle: 'Daily Bible verses and reflection',
                      icon: Icons.menu_book,
                      onTap: () {
                        // Navigate to scripture
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPrayerOptionCard(
                      title: 'Prayer Journal',
                      subtitle: 'Record your prayers and thoughts',
                      icon: Icons.edit_note,
                      onTap: () {
                        // Navigate to prayer journal
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPrayerOptionCard(
                      title: 'Prayer Requests',
                      subtitle: 'Submit and track prayer needs',
                      icon: Icons.favorite,
                      onTap: () {
                        // Navigate to prayer requests
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPrayerOptionCard(
                      title: 'Community Prayers',
                      subtitle: 'Join others in prayer',
                      icon: Icons.people,
                      onTap: () {
                        // Navigate to community prayers
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
  }) {
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
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }
}
