import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/enhanced_glass_card.dart';

/// Daily streak tracking card
class DailyStreakCard extends StatelessWidget {
  const DailyStreakCard({
    super.key,
    required this.streak,
  });

  final int streak;

  @override
  Widget build(BuildContext context) {
    return EnhancedGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      enableShimmer: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up,
                color: Colors.white.withValues(alpha: 0.7),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$streak',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 32,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Day Streak',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
