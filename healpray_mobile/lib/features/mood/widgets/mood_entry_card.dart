import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/simple_mood_entry.dart';

/// A card widget for displaying a mood entry
class MoodEntryCard extends StatelessWidget {
  final SimpleMoodEntry entry;
  final VoidCallback? onTap;
  final bool showDate;
  final bool compact;

  const MoodEntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.showDate = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Mood indicator
                  Container(
                    width: compact ? 32 : 40,
                    height: compact ? 32 : 40,
                    decoration: BoxDecoration(
                      color: _getMoodColor(entry.score.toDouble()).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _getMoodEmoji(entry.score),
                        style: TextStyle(
                          fontSize: compact ? 16 : 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Mood details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${entry.score}/10',
                              style: TextStyle(
                                fontSize: compact ? 14 : 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: AppTheme.textSecondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getMoodDescription(entry.score),
                              style: TextStyle(
                                fontSize: compact ? 12 : 14,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          showDate 
                              ? _formatDateTime(entry.timestamp)
                              : _formatTime(entry.timestamp),
                          style: TextStyle(
                            fontSize: compact ? 11 : 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Entry count badge
                  if (!compact && entry.emotions.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.healingTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.psychology_outlined,
                            size: 12,
                            color: AppTheme.healingTeal,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.emotions.length}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.healingTeal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              if (!compact) ...[
                // Emotions preview
                if (entry.emotions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: entry.emotions.take(3).map((emotion) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.healingTeal.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        emotion,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.healingTeal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                  if (entry.emotions.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+${entry.emotions.length - 3} more',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
                
                // Notes preview
                if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    entry.notes!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getMoodColor(double score) {
    if (score >= 8) return AppTheme.sunriseGold;
    if (score >= 6) return AppTheme.healingTeal;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }

  String _getMoodEmoji(int score) {
    switch (score) {
      case 1: return '😢';
      case 2: return '😞';
      case 3: return '😕';
      case 4: return '😐';
      case 5: return '🙂';
      case 6: return '😊';
      case 7: return '😄';
      case 8: return '😁';
      case 9: return '🤗';
      case 10: return '🥳';
      default: return '🙂';
    }
  }

  String _getMoodDescription(int score) {
    switch (score) {
      case 1: return 'Very Low';
      case 2: return 'Low';
      case 3: return 'Below Average';
      case 4: return 'Slightly Low';
      case 5: return 'Neutral';
      case 6: return 'Good';
      case 7: return 'Very Good';
      case 8: return 'Great';
      case 9: return 'Excellent';
      case 10: return 'Amazing';
      default: return 'Neutral';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    if (hour == 0) {
      return '12:${minute} AM';
    } else if (hour < 12) {
      return '$hour:$minute AM';
    } else if (hour == 12) {
      return '12:$minute PM';
    } else {
      return '${hour - 12}:$minute PM';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    String dateStr;
    if (date == today) {
      dateStr = 'Today';
    } else if (date == yesterday) {
      dateStr = 'Yesterday';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      dateStr = '${months[dateTime.month - 1]} ${dateTime.day}';
    }
    
    return '$dateStr at ${_formatTime(dateTime)}';
  }
}
