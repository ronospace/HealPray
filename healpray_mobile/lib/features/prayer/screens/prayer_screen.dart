import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

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
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Prayer & Reflection',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
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
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Daily verse or inspiration
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.spiritualPurple, AppTheme.wisdomGold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.spiritualPurple.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
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
    );
  }

  Widget _buildPrayerOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.spiritualPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.spiritualPurple,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
