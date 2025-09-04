import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../models/mood_entry.dart';
import '../providers/mood_providers.dart';
import 'mood_analytics_screen.dart';

/// Mood tracking main screen
class MoodTrackingScreen extends ConsumerStatefulWidget {
  const MoodTrackingScreen({super.key});

  @override
  ConsumerState<MoodTrackingScreen> createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends ConsumerState<MoodTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final moodEntries = ref.watch(recentMoodEntriesProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Mood Tracking',
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
              // Navigate to mood history
            },
            icon: const Icon(
              Icons.history,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header card with current mood
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.healingTeal, AppTheme.calmBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.healingTeal.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'How are you feeling today?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '😊',
                    style: TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Good',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Mood entry options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildMoodOptionCard(
                    title: 'Quick Mood Check',
                    subtitle: 'Record your current mood',
                    icon: Icons.mood,
                    onTap: () {
                      // Show quick mood entry
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMoodOptionCard(
                    title: 'Detailed Entry',
                    subtitle: 'Add notes and context',
                    icon: Icons.edit_note,
                    onTap: () {
                      // Navigate to detailed mood entry
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMoodOptionCard(
                    title: 'Mood Patterns',
                    subtitle: 'View your mood trends',
                    icon: Icons.show_chart,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MoodAnalyticsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMoodOptionCard(
                    title: 'Reflection Journal',
                    subtitle: 'Daily thoughts and prayers',
                    icon: Icons.book,
                    onTap: () {
                      // Navigate to journal
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

  Widget _buildMoodOptionCard({
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
            color: AppTheme.healingTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.healingTeal,
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
