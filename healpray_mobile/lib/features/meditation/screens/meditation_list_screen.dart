import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/enhanced_glass_card.dart';
import '../models/meditation_type.dart';

/// Screen showing list of available guided meditations
class MeditationListScreen extends StatefulWidget {
  const MeditationListScreen({super.key});

  @override
  State<MeditationListScreen> createState() => _MeditationListScreenState();
}

class _MeditationListScreenState extends State<MeditationListScreen> {
  MeditationType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Guided Meditation',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDarkMode 
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        foregroundColor: textColor,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Find Your Inner Peace',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a meditation that speaks to your soul',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 24),

                // Filter chips
                _buildFilterChips(),

                const SizedBox(height: 24),

                // Meditation list
                _buildMeditationList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', null),
          const SizedBox(width: 8),
          ...MeditationType.values.map((type) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(type.displayName, type),
              )),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, MeditationType? type) {
    final isSelected = _selectedType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : null;
        });
      },
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      selectedColor: AppTheme.healingTeal,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.9),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildMeditationList() {
    final meditations = _getFilteredMeditations();
    
    return Column(
      children: meditations.map((meditation) => _buildMeditationCard(meditation)).toList(),
    );
  }

  Widget _buildMeditationCard(Map<String, dynamic> meditation) {
    return EnhancedGlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      onTap: () {
        // TODO: Navigate to meditation detail/player screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Starting ${meditation['title']}...'),
            backgroundColor: AppTheme.healingTeal,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: meditation['color'].withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  meditation['icon'],
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meditation['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meditation['duration'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.play_circle_filled,
                color: AppTheme.healingTeal,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            meditation['description'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredMeditations() {
    final allMeditations = [
      {
        'title': 'Morning Blessing',
        'description': 'Start your day with gratitude and divine connection',
        'duration': '10 min',
        'type': MeditationType.gratitude,
        'icon': Icons.wb_sunny,
        'color': AppTheme.sunriseGold,
      },
      {
        'title': 'Inner Peace',
        'description': 'Find tranquility and calm your mind',
        'duration': '15 min',
        'type': MeditationType.mindfulness,
        'icon': Icons.self_improvement,
        'color': AppTheme.healingTeal,
      },
      {
        'title': 'Healing Light',
        'description': 'Channel divine healing energy through your body',
        'duration': '20 min',
        'type': MeditationType.healing,
        'icon': Icons.healing,
        'color': AppTheme.faithGreen,
      },
      {
        'title': 'Deep Relaxation',
        'description': 'Release tension and stress from your body and mind',
        'duration': '12 min',
        'type': MeditationType.relaxation,
        'icon': Icons.spa,
        'color': AppTheme.sacredBlue,
      },
      {
        'title': 'Restful Sleep',
        'description': 'Prepare your mind and body for peaceful rest',
        'duration': '25 min',
        'type': MeditationType.sleep,
        'icon': Icons.bedtime,
        'color': AppTheme.midnightBlue,
      },
      {
        'title': 'Breath of Life',
        'description': 'Connect with your breath and life force',
        'duration': '8 min',
        'type': MeditationType.breathwork,
        'icon': Icons.air,
        'color': AppTheme.celestialCyan,
      },
      {
        'title': 'Body Scan',
        'description': 'Journey through your body with awareness',
        'duration': '18 min',
        'type': MeditationType.bodyScanning,
        'icon': Icons.accessibility_new,
        'color': AppTheme.hopeOrange,
      },
      {
        'title': 'Sacred Vision',
        'description': 'Visualize your highest spiritual self',
        'duration': '15 min',
        'type': MeditationType.visualization,
        'icon': Icons.visibility,
        'color': AppTheme.mysticalPurple,
      },
      {
        'title': 'Divine Connection',
        'description': 'Deepen your relationship with the divine',
        'duration': '20 min',
        'type': MeditationType.spiritual,
        'icon': Icons.church,
        'color': AppTheme.wisdomGold,
      },
    ];

    if (_selectedType == null) {
      return allMeditations;
    }

    return allMeditations.where((m) => m['type'] == _selectedType).toList();
  }
}
