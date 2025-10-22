import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Mood summary card for home dashboard
class MoodSummaryCard extends StatelessWidget {
  const MoodSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - would come from provider in real implementation
    const double averageMood = 7.2;
    const String trend = 'improving';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppTheme.healingTeal.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.healingTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: AppTheme.healingTeal,
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
                color: trend == 'improving'
                    ? Colors.green[400]
                    : trend == 'declining'
                        ? Colors.red[400]
                        : Colors.grey[400],
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
                      color: AppTheme.healingTeal,
                      fontSize: 32,
                    ),
              ),
              const SizedBox(width: 4),
              Text(
                '/10',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Avg Mood',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
