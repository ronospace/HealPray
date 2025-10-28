import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../models/mood_entry.dart';
import '../models/emotion_type.dart';
import '../models/mood_enums.dart';
import '../services/mood_tracking_service.dart';

/// Smart daily mood check-in dialog that appears on app launch
class DailyMoodCheckInDialog extends ConsumerStatefulWidget {
  const DailyMoodCheckInDialog({super.key});

  @override
  ConsumerState<DailyMoodCheckInDialog> createState() =>
      _DailyMoodCheckInDialogState();
}

class _DailyMoodCheckInDialogState
    extends ConsumerState<DailyMoodCheckInDialog>
    with SingleTickerProviderStateMixin {
  int _selectedMood = 5;
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppTheme.getMoodGradient(_selectedMood.toDouble()),
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.getMoodColor(_selectedMood).withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: GlassCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
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
                              _getGreeting(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'How are you feeling today?',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Mood emoji display
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey(_selectedMood),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.getMoodColor(_selectedMood)
                            .withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _getMoodEmoji(_selectedMood),
                          style: const TextStyle(fontSize: 60),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Mood label
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _getMoodLabel(_selectedMood),
                      key: ValueKey(_selectedMood),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Mood slider
                  Column(
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: Colors.white,
                          inactiveTrackColor:
                              Colors.white.withValues(alpha: 0.3),
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withValues(alpha: 0.2),
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 14,
                          ),
                        ),
                        child: Slider(
                          value: _selectedMood.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          onChanged: (value) {
                            setState(() {
                              _selectedMood = value.round();
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '1',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              '10',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitMood,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor:
                                AppTheme.getMoodColor(_selectedMood),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning! ☀️';
    if (hour < 17) return 'Good Afternoon! 🌤️';
    if (hour < 21) return 'Good Evening! 🌆';
    return 'Good Night! 🌙';
  }

  String _getMoodEmoji(int mood) {
    if (mood <= 2) return '😢';
    if (mood <= 4) return '😔';
    if (mood <= 6) return '😐';
    if (mood <= 8) return '🙂';
    return '😄';
  }

  String _getMoodLabel(int mood) {
    if (mood <= 2) return 'Very Low';
    if (mood <= 4) return 'Low';
    if (mood <= 6) return 'Okay';
    if (mood <= 8) return 'Good';
    return 'Excellent';
  }

  Future<void> _submitMood() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final moodService = MoodTrackingService();

      // Create mood entry with proper fields
      final entry = await moodService.createMoodEntry(
        emotions: _getMoodEmotions(_selectedMood),
        intensity: _getMoodIntensity(_selectedMood),
        triggers: [],
        notes: 'Daily check-in',
      );

      if (mounted) {
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getEncouragingMessage(_selectedMood)),
            backgroundColor: AppTheme.getMoodColor(_selectedMood),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.of(context).pop(entry);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save mood. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _getEncouragingMessage(int mood) {
    if (mood <= 2) {
      return 'I\'m here for you. Let\'s find some comfort together. 💙';
    }
    if (mood <= 4) {
      return 'Every moment is a new beginning. You\'ve got this! 🌱';
    }
    if (mood <= 6) {
      return 'Thanks for checking in! Let\'s make today meaningful. ✨';
    }
    if (mood <= 8) {
      return 'Wonderful! Let\'s build on this positive energy! 🌟';
    }
    return 'Amazing! Your joy is a blessing to celebrate! 🎉';
  }

  List<EmotionType> _getMoodEmotions(int mood) {
    if (mood <= 2) return [EmotionType.sad];
    if (mood <= 4) return [EmotionType.anxious];
    if (mood <= 6) return [EmotionType.content];
    if (mood <= 8) return [EmotionType.hopeful];
    return [EmotionType.joyful];
  }

  MoodIntensity _getMoodIntensity(int mood) {
    if (mood <= 3) return MoodIntensity.veryLow;
    if (mood <= 5) return MoodIntensity.low;
    if (mood <= 7) return MoodIntensity.moderate;
    if (mood <= 9) return MoodIntensity.high;
    return MoodIntensity.veryHigh;
  }
}
