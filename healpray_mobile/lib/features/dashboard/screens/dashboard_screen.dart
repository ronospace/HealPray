import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/floating_particles.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../shared/providers/auth_provider.dart';
import '../widgets/mood_tracking_card.dart';
import '../widgets/prayer_streak_card.dart';
import '../widgets/daily_inspiration_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/crisis_support_banner.dart';

/// Main dashboard screen - the heart of the HealPray app
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
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

    // Create staggered animations for cards
    _cardAnimations = List.generate(
      5,
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
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
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
            CustomScrollView(
        slivers: [
          // App bar with gradient background
          _buildSliverAppBar(context, user?.displayName ?? 'Friend'),

          // Main content
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Crisis support banner (if needed) with animation
                _buildAnimatedCard(
                  animation: _cardAnimations[0],
                  child: const CrisisSupportBanner(),
                ),
                const SizedBox(height: 16),

                // Daily inspiration with animation
                _buildAnimatedCard(
                  animation: _cardAnimations[1],
                  child: const DailyInspirationCard(),
                ),
                const SizedBox(height: 20),

                // Mood and prayer streak row with animation
                _buildAnimatedCard(
                  animation: _cardAnimations[2],
                  child: Row(
                    children: [
                      Expanded(
                        child: MoodTrackingCard(
                          currentMood: (user?.analytics.averageMood) ?? 5.0,
                          streak: (user?.analytics.currentStreak) ?? 0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrayerStreakCard(
                          currentStreak: (user?.analytics.currentStreak) ?? 0,
                          totalPrayers: (user?.analytics.totalPrayers) ?? 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quick actions with animation
                _buildAnimatedCard(
                  animation: _cardAnimations[3],
                  child: const QuickActionsGrid(),
                ),
                const SizedBox(height: 20),

                // Recent activity section with animation
                _buildAnimatedCard(
                  animation: _cardAnimations[4],
                  child: _buildRecentActivity(context),
                ),
                const SizedBox(height: 100), // Bottom padding for navigation
              ]),
            ),
          ),
        ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String displayName) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.healingTeal,
                AppTheme.healingTeal.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _getGreeting(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.push('/profile'),
          icon: const Icon(
            Icons.account_circle,
            color: Colors.white,
            size: 28,
          ),
        ),
        IconButton(
          onPressed: () => context.push('/notifications'),
          icon: const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 22,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActivityItem(
                context,
                icon: Icons.favorite,
                iconColor: Colors.red[300]!,
                title: 'Morning Prayer',
                subtitle: 'Started your day with gratitude',
                time: 'Today, 7:30 AM',
              ),
              Divider(height: 24, color: Colors.white.withOpacity(0.2)),
              _buildActivityItem(
                context,
                icon: Icons.sentiment_satisfied_alt,
                iconColor: AppTheme.sunriseGold,
                title: 'Mood Check-in',
                subtitle: 'Feeling peaceful and hopeful',
                time: 'Yesterday, 8:15 PM',
              ),
              Divider(height: 24, color: Colors.white.withOpacity(0.2)),
              _buildActivityItem(
                context,
                icon: Icons.self_improvement,
                iconColor: Colors.lightGreenAccent,
                title: 'Meditation Session',
                subtitle: '10 minutes of mindful breathing',
                time: 'Yesterday, 6:00 PM',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.6),
              ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}
