import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/floating_particles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';
import 'mood_analytics_screen.dart';

/// Mood tracking main screen
class MoodTrackingScreen extends ConsumerStatefulWidget {
  const MoodTrackingScreen({super.key});

  @override
  ConsumerState<MoodTrackingScreen> createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends ConsumerState<MoodTrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Create staggered animations for cards (header + 5 option cards)
    _cardAnimations = List.generate(
      6,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.4 + (index * 0.1),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedCard({
    required Animation<double> animation,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

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
        child: Stack(
          children: [
            // Floating particles background
            const Positioned.fill(
              child: FloatingParticles(
                numberOfParticles: 20,
                minSize: 4.0,
                maxSize: 12.0,
              ),
            ),
            
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Header card with current mood
                  _buildAnimatedCard(
                    animation: _cardAnimations[0],
                    child: Semantics(
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
                  ),

                  // Mood entry options
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildAnimatedCard(
                          animation: _cardAnimations[1],
                          child: _buildMoodOptionCard(
                            title: 'Quick Mood Check',
                            subtitle: 'Record your current mood',
                            icon: Icons.mood,
                            onTap: () => context.push('/mood/entry'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAnimatedCard(
                          animation: _cardAnimations[2],
                          child: _buildMoodOptionCard(
                            title: 'Detailed Entry',
                            subtitle: 'Add notes and context',
                            icon: Icons.edit_note,
                            onTap: () => context.push('/mood/entry'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAnimatedCard(
                          animation: _cardAnimations[3],
                          child: _buildMoodOptionCard(
                            title: 'Calendar View',
                            subtitle: 'See your mood history',
                            icon: Icons.calendar_month,
                            onTap: () => context.push('/mood/calendar'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAnimatedCard(
                          animation: _cardAnimations[4],
                          child: _buildMoodOptionCard(
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
                        ),
                        const SizedBox(height: 12),
                        _buildAnimatedCard(
                          animation: _cardAnimations[5],
                          child: _buildMoodOptionCard(
                            title: 'Reflection Journal',
                            subtitle: 'Daily thoughts and prayers',
                            icon: Icons.book,
                            onTap: () {
                              // Navigate to journal
                            },
                          ),
                        ),
                      ],
                    ),
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
