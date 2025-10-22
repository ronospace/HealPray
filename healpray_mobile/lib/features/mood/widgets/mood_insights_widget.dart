import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../services/mood_service.dart';

/// Widget for displaying personalized mood insights
class MoodInsightsWidget extends StatelessWidget {
  final List<MoodInsight> insights;

  const MoodInsightsWidget({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 48,
                color: AppTheme.textSecondary,
              ),
              SizedBox(height: 12),
              Text(
                'No insights available yet',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Add more mood entries to get personalized insights',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: insights
          .take(3)
          .map((insight) => _buildInsightCard(insight))
          .toList(),
    );
  }

  Widget _buildInsightCard(MoodInsight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getInsightColor(insight.type).withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getInsightColor(insight.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    insight.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getInsightColor(insight.type)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getInsightTypeText(insight.type),
                        style: TextStyle(
                          color: _getInsightColor(insight.type),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight.description,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (insight.score != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Score: ${insight.score!.toStringAsFixed(1)}/10',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getInsightColor(MoodInsightType type) {
    switch (type) {
      case MoodInsightType.positive:
        return AppTheme.sunriseGold;
      case MoodInsightType.concern:
        return Colors.orange;
      case MoodInsightType.pattern:
        return AppTheme.healingTeal;
      case MoodInsightType.trend:
        return AppTheme.midnightBlue;
      case MoodInsightType.recommendation:
        return Colors.purple;
      case MoodInsightType.average:
        return AppTheme.healingTeal;
      case MoodInsightType.emotion:
        return Colors.pink;
    }
  }

  String _getInsightTypeText(MoodInsightType type) {
    switch (type) {
      case MoodInsightType.positive:
        return 'POSITIVE';
      case MoodInsightType.concern:
        return 'CONCERN';
      case MoodInsightType.pattern:
        return 'PATTERN';
      case MoodInsightType.trend:
        return 'TREND';
      case MoodInsightType.recommendation:
        return 'TIP';
      case MoodInsightType.average:
        return 'STATS';
      case MoodInsightType.emotion:
        return 'EMOTION';
    }
  }
}
