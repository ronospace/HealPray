import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';
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
    // final moodEntries = ref.watch(recentMoodEntriesProvider); // TODO: Implement provider

    return Scaffold(
      appBar: AppBar(
        title: const GradientText(
          'Mood Tracking',
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
            onPressed: () => context.push('/mood/calendar'),
            tooltip: 'View mood calendar',
            icon: const Icon(
              Icons.calendar_month,
              color: Colors.white,
              semanticLabel: 'Open mood calendar',
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MoodAnalyticsScreen(),
                ),
              );
            },
            tooltip: 'View mood analytics',
            icon: const Icon(
              Icons.analytics,
              color: Colors.white,
              semanticLabel: 'Open mood analytics',
            ),
          ),
        ],
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header card with current mood
              Semantics(
                label: 'Current mood status',
                child: GlassCard(
                  margin: const EdgeInsets.all(16),
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
                      onTap: () => context.push('/mood/entry'),
                    ),
                    const SizedBox(height: 12),
                    _buildMoodOptionCard(
                      title: 'Detailed Entry',
                      subtitle: 'Add notes and context',
                      icon: Icons.edit_note,
                      onTap: () => context.push('/mood/entry'),
                    ),
                    const SizedBox(height: 12),
                    _buildMoodOptionCard(
                      title: 'Calendar View',
                      subtitle: 'See your mood history',
                      icon: Icons.calendar_month,
                      onTap: () => context.push('/mood/calendar'),
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
      ),
    );
  }

  Widget _buildMoodOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: '$title, $subtitle',
      onTap: onTap,
      child: GlassCard(
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
      ),
    );
  }
}
