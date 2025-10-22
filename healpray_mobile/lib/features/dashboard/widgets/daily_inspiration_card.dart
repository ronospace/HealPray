import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

/// Widget displaying daily inspiration with verse or quote
class DailyInspirationCard extends StatelessWidget {
  const DailyInspirationCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample inspirations - in a real app, this would come from a service
    final inspirations = [
      {
        'text': 'Cast all your anxiety on Him because He cares for you.',
        'reference': '1 Peter 5:7',
        'type': 'verse',
      },
      {
        'text': 'Peace I leave with you; my peace I give you.',
        'reference': 'John 14:27',
        'type': 'verse',
      },
      {
        'text': 'The Lord your God is with you, the Mighty Warrior who saves.',
        'reference': 'Zephaniah 3:17',
        'type': 'verse',
      },
    ];

    // Get today's inspiration (simple rotation based on day of year)
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final inspiration = inspirations[dayOfYear % inspirations.length];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.sunriseGold.withValues(alpha: 0.1),
              AppTheme.healingTeal.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: InkWell(
          onTap: () => context.push('/inspiration'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.sunriseGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppTheme.sunriseGold,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Inspiration',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.midnightBlue,
                                  ),
                        ),
                        Text(
                          _getDateString(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Inspiration text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.sunriseGold.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${inspiration['text']}"',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppTheme.midnightBlue,
                              height: 1.4,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Spacer(),
                          Text(
                            '— ${inspiration['reference']}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.healingTeal,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    _buildActionButton(
                      context,
                      icon: Icons.share,
                      label: 'Share',
                      onTap: () => _shareInspiration(inspiration),
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      context,
                      icon: Icons.favorite_border,
                      label: 'Save',
                      onTap: () => _saveInspiration(inspiration),
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      context,
                      icon: Icons.refresh,
                      label: 'More',
                      onTap: () => context.push('/inspiration'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: AppTheme.healingTeal,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.healingTeal,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDateString() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  void _shareInspiration(Map<String, String> inspiration) {
    // TODO: Implement sharing functionality
  }

  void _saveInspiration(Map<String, String> inspiration) {
    // TODO: Implement save to favorites functionality
  }
}
