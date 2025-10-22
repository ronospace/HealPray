import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

/// Widget displaying current mood and mood tracking streak
class MoodTrackingCard extends StatelessWidget {
  final double currentMood;
  final int streak;

  const MoodTrackingCard({
    super.key,
    required this.currentMood,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.push('/mood-tracking'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getMoodColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getMoodIcon(),
                      color: _getMoodColor(),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mood',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Current mood display
              Row(
                children: [
                  Icon(
                    _getMoodIcon(),
                    color: _getMoodColor(),
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getMoodText(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getMoodColor(),
                            ),
                      ),
                      Text(
                        'Current feeling',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Streak info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.sunriseGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  streak > 0 ? '$streak day streak 🔥' : 'Start your streak',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.sunriseGold.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMoodColor() {
    if (currentMood >= 8) return Colors.green[400]!;
    if (currentMood >= 6) return AppTheme.sunriseGold;
    if (currentMood >= 4) return Colors.orange[400]!;
    if (currentMood >= 2) return Colors.red[400]!;
    return Colors.red[600]!;
  }

  IconData _getMoodIcon() {
    if (currentMood >= 8) return Icons.sentiment_very_satisfied;
    if (currentMood >= 6) return Icons.sentiment_satisfied_alt;
    if (currentMood >= 4) return Icons.sentiment_neutral;
    if (currentMood >= 2) return Icons.sentiment_dissatisfied;
    return Icons.sentiment_very_dissatisfied;
  }

  String _getMoodText() {
    if (currentMood >= 8) return 'Joyful';
    if (currentMood >= 6) return 'Peaceful';
    if (currentMood >= 4) return 'Okay';
    if (currentMood >= 2) return 'Struggling';
    return 'Need Support';
  }
}
