import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

/// Widget displaying quick action buttons in a grid layout
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: [
            _buildActionCard(
              context,
              icon: Icons.favorite,
              iconColor: Colors.red[400]!,
              label: 'Pray Now',
              subtitle: 'Start prayer',
              onTap: () => context.push('/prayer'),
            ),
            _buildActionCard(
              context,
              icon: Icons.self_improvement,
              iconColor: AppTheme.healingTeal,
              label: 'Meditate',
              subtitle: 'Find peace',
              onTap: () => context.push('/meditation'),
            ),
            _buildActionCard(
              context,
              icon: Icons.sentiment_satisfied_alt,
              iconColor: AppTheme.sunriseGold,
              label: 'Mood',
              subtitle: 'Check-in',
              onTap: () => context.push('/mood-tracking'),
            ),
            _buildActionCard(
              context,
              icon: Icons.menu_book,
              iconColor: Colors.indigo[400]!,
              label: 'Scripture',
              subtitle: 'Daily reading',
              onTap: () => context.push('/scripture'),
            ),
            _buildActionCard(
              context,
              icon: Icons.psychology,
              iconColor: Colors.purple[400]!,
              label: 'AI Chat',
              subtitle: 'Spiritual guide',
              onTap: () => context.push('/ai-chat'),
            ),
            _buildActionCard(
              context,
              icon: Icons.support,
              iconColor: Colors.orange[600]!,
              label: 'Support',
              subtitle: 'Get help',
              onTap: () => context.push('/crisis-support'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
