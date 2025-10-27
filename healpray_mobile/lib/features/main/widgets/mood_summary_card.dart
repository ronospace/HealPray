import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/enhanced_glass_card.dart';

/// Mood summary card for home dashboard
class MoodSummaryCard extends StatelessWidget {
  const MoodSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - would come from provider in real implementation
    const double averageMood = 7.2;
    const String trend = 'improving';

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
                  Icons.favorite,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const Spacer(),
              Icon(
                trend == 'improving'
                    ? Icons.trending_up
                    : trend == 'declining'
                        ? Icons.trending_down
                        : Icons.trending_flat,
                color: Colors.white.withValues(alpha: 0.7),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                averageMood.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 32,
                    ),
              ),
              const SizedBox(width: 4),
              Text(
                '/10',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Avg Mood',
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
