import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

/// Widget displaying quick action buttons in a grid layout
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.access_time, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Coming Soon',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          '$feature is currently under development and will be available in a future update. Stay tuned!',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 22,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
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
              comingSoon: true,
              onTap: () => _showComingSoonDialog(context, 'Meditation'),
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
              comingSoon: true,
              onTap: () => _showComingSoonDialog(context, 'Scripture Reading'),
            ),
            _buildActionCard(
              context,
              icon: Icons.psychology,
              iconColor: Colors.purple[400]!,
              label: 'Chat',
              subtitle: 'Ask Sophia',
              onTap: () => context.push('/ai-chat'),
            ),
            _buildActionCard(
              context,
              icon: Icons.support,
              iconColor: Colors.orange[600]!,
              label: 'Support',
              subtitle: 'Get help',
              comingSoon: true,
              onTap: () => _showComingSoonDialog(context, 'Crisis Support'),
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
    bool comingSoon = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          InkWell(
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
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
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
          if (comingSoon)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Soon',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
