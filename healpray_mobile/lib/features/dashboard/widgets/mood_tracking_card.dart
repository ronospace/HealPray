import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';

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
    return GlassCard(
      onTap: () => context.push('/mood-tracking'),
      borderRadius: 16,
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
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getMoodIcon(),
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mood',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
                    color: Colors.white,
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
                              color: Colors.white,
                            ),
                      ),
                      Text(
                        'Current feeling',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.7),
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
                  color: AppTheme.sunriseGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  streak > 0 ? '$streak day streak 🔥' : 'Start your streak',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.sunriseGold,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
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
