import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Widget for selecting prayer categories
class PrayerCategorySelector extends StatelessWidget {
  const PrayerCategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final String selectedCategory;
  final Function(String) onCategoryChanged;

  static const List<Map<String, dynamic>> _categories = [
    {
      'id': 'gratitude',
      'name': 'Gratitude',
      'icon': Icons.favorite,
      'color': AppTheme.joyColor,
      'description': 'Prayers of thankfulness and appreciation',
    },
    {
      'id': 'healing',
      'name': 'Healing',
      'icon': Icons.healing,
      'color': AppTheme.peaceColor,
      'description': 'Prayers for physical, emotional, and spiritual healing',
    },
    {
      'id': 'strength',
      'name': 'Strength',
      'icon': Icons.fitness_center,
      'color': AppTheme.hopeColor,
      'description': 'Prayers for inner strength and courage',
    },
    {
      'id': 'peace',
      'name': 'Peace',
      'icon': Icons.self_improvement,
      'color': AppTheme.healingTeal,
      'description': 'Prayers for inner peace and tranquility',
    },
    {
      'id': 'guidance',
      'name': 'Guidance',
      'icon': Icons.explore,
      'color': AppTheme.midnightBlue,
      'description': 'Prayers for divine guidance and wisdom',
    },
    {
      'id': 'forgiveness',
      'name': 'Forgiveness',
      'icon': Icons.volunteer_activism,
      'color': AppTheme.wisdomGold,
      'description': 'Prayers about forgiveness and mercy',
    },
    {
      'id': 'protection',
      'name': 'Protection',
      'icon': Icons.shield,
      'color': AppTheme.spiritualPurple,
      'description': 'Prayers for safety and divine protection',
    },
    {
      'id': 'hope',
      'name': 'Hope',
      'icon': Icons.light_mode,
      'color': AppTheme.sunriseGold,
      'description': 'Prayers for hope during difficult times',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((category) {
        final isSelected = selectedCategory == category['id'];
        final color = category['color'] as Color;

        return GestureDetector(
          onTap: () => onCategoryChanged(category['id']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.2) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : color.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category['icon'] as IconData,
                  color: isSelected ? color : color.withValues(alpha: 0.7),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  category['name'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? color : AppTheme.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
