import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/enhanced_glass_card.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/admob_banner.dart';
import '../../../core/widgets/floating_particles.dart';
import '../../../shared/providers/auth_provider.dart';
import '../widgets/spiritual_quote_card.dart';
import '../widgets/daily_streak_card.dart';
import '../widgets/mood_summary_card.dart';
import '../widgets/quick_action_card.dart';

/// Home dashboard screen
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

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
            SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  // TODO: Refresh user data
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(context, user?.displayName),

                      const SizedBox(height: 24),

                      // Daily quote with animation
                      _buildAnimatedCard(
                        animation: _cardAnimations[0],
                        child: const SpiritualQuoteCard(),
                      ),

                      const SizedBox(height: 20),

                      // Stats row with animation
                      _buildAnimatedCard(
                        animation: _cardAnimations[1],
                        child: Row(
                          children: [
                            Expanded(
                                child: DailyStreakCard(
                                    streak: user?.analytics.currentStreak ?? 0)),
                            const SizedBox(width: 12),
                            const Expanded(child: MoodSummaryCard()),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Quick actions with animation
                      _buildAnimatedCard(
                        animation: _cardAnimations[2],
                        child: _buildQuickActions(context),
                      ),

                      const SizedBox(height: 24),

                      // Recent activities with animation
                      _buildAnimatedCard(
                        animation: _cardAnimations[3],
                        child: _buildRecentActivities(context),
                      ),

                      const SizedBox(height: 20),
                      
                      // AdMob Banner with animation
                      _buildAnimatedCard(
                        animation: _cardAnimations[4],
                        child: const AdMobBanner(),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildHeader(BuildContext context, String? displayName) {
    final hour = DateTime.now().hour;
    String greeting = 'Good morning';

    if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon';
    } else if (hour >= 17) {
      greeting = 'Good evening';
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting,',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              AnimatedGradientText(
                displayName ?? 'Friend',
                colors: const [
                  Colors.white,
                  Color(0xFFFFE5E5),
                  Colors.white,
                ],
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),

        // Profile/notifications
        Row(
          children: [
            IconButton(
              onPressed: () {
                // TODO: Show notifications
              },
              icon: Stack(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: Colors.white.withOpacity(0.9),
                    size: 24,
                  ),
                  // Notification badge
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.push('/settings'),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    displayName?.isNotEmpty == true
                        ? displayName![0].toUpperCase()
                        : '👤',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: Icons.psychology,
                label: 'Generate Prayer',
                color: AppTheme.healingTeal,
                onTap: () => context.push('/prayer'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                icon: Icons.favorite,
                label: 'Log Mood',
                color: AppTheme.sunriseGold,
                onTap: () => context.push('/mood'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: Icons.chat_bubble,
                label: 'Spiritual Chat',
                color: AppTheme.midnightBlue,
                onTap: () => context.push('/chat'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                icon: Icons.analytics,
                label: 'View Analytics',
                color: AppTheme.healingBlue,
                onTap: () => context.push('/analytics'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activities',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
            ),
            TextButton(
              onPressed: () => context.push('/analytics'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: const Text('View All'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Recent activities list
        _buildActivityItem(
          context,
          Icons.psychology,
          'Morning Prayer Generated',
          '2 hours ago',
          AppTheme.healingTeal,
        ),

        _buildActivityItem(
          context,
          Icons.favorite,
          'Mood Logged (7/10)',
          '5 hours ago',
          AppTheme.sunriseGold,
        ),

        _buildActivityItem(
          context,
          Icons.chat_bubble,
          'Spiritual Guidance Session',
          'Yesterday',
          AppTheme.midnightBlue,
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    IconData icon,
    String title,
    String time,
    Color color,
  ) {
    return EnhancedGlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderRadius: 12,
      enableShimmer: false,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withOpacity(0.6),
            size: 14,
          ),
        ],
      ),
    );
  }
}
