import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../shared/providers/auth_provider.dart';
import '../widgets/spiritual_quote_card.dart';
import '../widgets/daily_streak_card.dart';
import '../widgets/mood_summary_card.dart';
import '../widgets/quick_action_card.dart';

/// Home dashboard screen
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
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

                // Daily quote
                const SpiritualQuoteCard(),

                const SizedBox(height: 20),

                // Stats row
                Row(
                  children: [
                    Expanded(
                        child: DailyStreakCard(
                            streak: user?.analytics.currentStreak ?? 0)),
                    const SizedBox(width: 12),
                    const Expanded(child: MoodSummaryCard()),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick actions
                _buildQuickActions(context),

                const SizedBox(height: 24),

                // Recent activities
                _buildRecentActivities(context),

                const SizedBox(height: 20),
              ],
            ),
            ),
          ),
        ),
      ),
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
                    color: Colors.grey[600],
                    size: 24,
                  ),
                  // Notification badge
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.sunriseNova,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.push('/settings'),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.healingTeal.withValues(alpha: 0.2),
                child: Text(
                  displayName?.isNotEmpty == true
                      ? displayName![0].toUpperCase()
                      : '👤',
                  style: const TextStyle(
                    color: AppTheme.healingTeal,
                    fontWeight: FontWeight.w600,
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
                color: AppTheme.midnightBlue,
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
                    color: AppTheme.midnightBlue,
                  ),
            ),
            TextButton(
              onPressed: () => context.push('/analytics'),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
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
                        color: AppTheme.midnightBlue,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey[400],
            size: 14,
          ),
        ],
      ),
    );
  }
}
