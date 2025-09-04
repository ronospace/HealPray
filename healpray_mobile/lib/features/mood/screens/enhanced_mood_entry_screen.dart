import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../models/simple_mood_entry.dart';
import '../services/mood_service.dart';

/// Enhanced mood entry screen with detailed mood tracking
class EnhancedMoodEntryScreen extends ConsumerStatefulWidget {
  const EnhancedMoodEntryScreen({super.key});

  @override
  ConsumerState<EnhancedMoodEntryScreen> createState() => _EnhancedMoodEntryScreenState();
}

class _EnhancedMoodEntryScreenState extends ConsumerState<EnhancedMoodEntryScreen> {
  final _uuid = const Uuid();
  final _notesController = TextEditingController();
  
  double _moodScore = 5.0;
  final Set<String> _selectedEmotions = {};
  final Set<String> _selectedTriggers = {};
  final Set<String> _selectedActivities = {};
  String? _notes;

  // Available emotions (simplified)
  final List<Map<String, String>> _availableEmotions = [
    {'name': 'Happy', 'emoji': '😄'},
    {'name': 'Grateful', 'emoji': '🙏'},
    {'name': 'Peaceful', 'emoji': '😌'},
    {'name': 'Anxious', 'emoji': '😰'},
    {'name': 'Sad', 'emoji': '😢'},
    {'name': 'Angry', 'emoji': '😠'},
    {'name': 'Excited', 'emoji': '🤗'},
    {'name': 'Tired', 'emoji': '😴'},
    {'name': 'Hopeful', 'emoji': '🌟'},
    {'name': 'Lonely', 'emoji': '😔'},
    {'name': 'Stressed', 'emoji': '😵'},
    {'name': 'Content', 'emoji': '😊'},
  ];

  // Common triggers
  final List<String> _commonTriggers = [
    'Work/School',
    'Relationships',
    'Health',
    'Family',
    'Money',
    'Weather',
    'Sleep',
    'Exercise',
    'Social Media',
    'News',
    'Prayer/Worship',
    'Spiritual Growth',
  ];

  // Common activities
  final List<String> _commonActivities = [
    'Prayer',
    'Reading Scripture',
    'Exercise',
    'Work',
    'Social Time',
    'Rest',
    'Meditation',
    'Creative Activities',
    'Learning',
    'Helping Others',
    'Nature Time',
    'Music/Worship',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Log Your Mood',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood Score Section
            _buildMoodScoreSection(),
            
            const SizedBox(height: 32),
            
            // Emotions Section
            _buildEmotionsSection(),
            
            const SizedBox(height: 32),
            
            // Triggers Section
            _buildTriggersSection(),
            
            const SizedBox(height: 32),
            
            // Activities Section  
            _buildActivitiesSection(),
            
            const SizedBox(height: 32),
            
            // Notes Section
            _buildNotesSection(),
            
            const SizedBox(height: 40),
            
            // Save Button
            _buildSaveButton(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodScoreSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.morningGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.healingTeal.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'How are you feeling?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Mood visual indicator
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getMoodEmoji(_moodScore.round()),
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            '${_moodScore.round()}/10 - ${_getMoodDescription(_moodScore.round())}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Mood slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: AppTheme.sunriseGold,
              overlayColor: AppTheme.sunriseGold.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: _moodScore,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  _moodScore = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What emotions are you experiencing?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableEmotions.map((emotion) {
            final isSelected = _selectedEmotions.contains(emotion['name']);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedEmotions.remove(emotion['name']);
                  } else {
                    _selectedEmotions.add(emotion['name']!);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.healingTeal.withOpacity(0.2)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.healingTeal
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                  boxShadow: [
                    if (!isSelected)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      emotion['emoji']!,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      emotion['name']!,
                      style: TextStyle(
                        color: isSelected 
                            ? AppTheme.healingTeal
                            : AppTheme.textPrimary,
                        fontWeight: isSelected 
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTriggersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What influenced your mood?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonTriggers.map((trigger) {
            final isSelected = _selectedTriggers.contains(trigger);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTriggers.remove(trigger);
                  } else {
                    _selectedTriggers.add(trigger);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.sunriseGold.withOpacity(0.2)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.sunriseGold
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  trigger,
                  style: TextStyle(
                    color: isSelected 
                        ? AppTheme.sunriseGold
                        : AppTheme.textSecondary,
                    fontWeight: isSelected 
                        ? FontWeight.w600
                        : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What activities were you doing?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonActivities.map((activity) {
            final isSelected = _selectedActivities.contains(activity);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedActivities.remove(activity);
                  } else {
                    _selectedActivities.add(activity);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.midnightBlue.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.midnightBlue
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  activity,
                  style: TextStyle(
                    color: isSelected 
                        ? AppTheme.midnightBlue
                        : AppTheme.textSecondary,
                    fontWeight: isSelected 
                        ? FontWeight.w600
                        : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional notes (optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'How are you feeling? What\'s on your heart today?',
              hintStyle: TextStyle(color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (value) {
              setState(() {
                _notes = value.isEmpty ? null : value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _saveMoodEntry,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.healingTeal,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppTheme.healingTeal.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Save Mood Entry',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _saveMoodEntry() async {
    final moodEntry = SimpleMoodEntry(
      id: _uuid.v4(),
      score: _moodScore.round(),
      notes: _notes,
      emotions: _selectedEmotions.toList(),
      timestamp: DateTime.now(),
      metadata: {
        'triggers': _selectedTriggers.toList(),
        'activities': _selectedActivities.toList(),
      },
    );

    try {
      // Save to mood service
      await MoodService.instance.saveMoodEntry(moodEntry);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mood entry saved successfully! 🎉'),
            backgroundColor: AppTheme.healingTeal,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back
        context.pop();
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving mood entry: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _getMoodEmoji(int mood) {
    switch (mood) {
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

  String _getMoodDescription(int mood) {
    switch (mood) {
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
}
