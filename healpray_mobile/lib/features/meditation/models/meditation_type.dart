import 'package:flutter/material.dart';

/// Enumeration of meditation types available in the app
enum MeditationType {
  mindfulness,
  healing,
  relaxation,
  gratitude,
  sleep,
  breathwork,
  bodyScanning,
  visualization,
  spiritual,
}

extension MeditationTypeExtensions on MeditationType {
  /// Get display name for meditation type
  String get displayName {
    switch (this) {
      case MeditationType.mindfulness:
        return 'Mindfulness';
      case MeditationType.healing:
        return 'Healing';
      case MeditationType.relaxation:
        return 'Relaxation';
      case MeditationType.gratitude:
        return 'Gratitude';
      case MeditationType.sleep:
        return 'Sleep';
      case MeditationType.breathwork:
        return 'Breathwork';
      case MeditationType.bodyScanning:
        return 'Body Scan';
      case MeditationType.visualization:
        return 'Visualization';
      case MeditationType.spiritual:
        return 'Spiritual';
    }
  }

  /// Get description for meditation type
  String get description {
    switch (this) {
      case MeditationType.mindfulness:
        return 'Present moment awareness and mindful observation';
      case MeditationType.healing:
        return 'Meditations focused on physical and emotional healing';
      case MeditationType.relaxation:
        return 'Deep relaxation and stress relief practices';
      case MeditationType.gratitude:
        return 'Cultivating thankfulness and appreciation';
      case MeditationType.sleep:
        return 'Gentle meditations to prepare for restful sleep';
      case MeditationType.breathwork:
        return 'Breathing techniques for calm and focus';
      case MeditationType.bodyScanning:
        return 'Progressive body awareness and tension release';
      case MeditationType.visualization:
        return 'Guided imagery and creative visualization';
      case MeditationType.spiritual:
        return 'Connecting with your spiritual essence and divine';
    }
  }

  /// Get icon for meditation type
  IconData get icon {
    switch (this) {
      case MeditationType.mindfulness:
        return Icons.psychology;
      case MeditationType.healing:
        return Icons.healing;
      case MeditationType.relaxation:
        return Icons.spa;
      case MeditationType.gratitude:
        return Icons.favorite;
      case MeditationType.sleep:
        return Icons.bedtime;
      case MeditationType.breathwork:
        return Icons.air;
      case MeditationType.bodyScanning:
        return Icons.accessibility_new;
      case MeditationType.visualization:
        return Icons.visibility;
      case MeditationType.spiritual:
        return Icons.church;
    }
  }

  /// Get color for meditation type
  Color get color {
    switch (this) {
      case MeditationType.mindfulness:
        return Colors.blue;
      case MeditationType.healing:
        return Colors.green;
      case MeditationType.relaxation:
        return Colors.purple;
      case MeditationType.gratitude:
        return Colors.pink;
      case MeditationType.sleep:
        return Colors.indigo;
      case MeditationType.breathwork:
        return Colors.cyan;
      case MeditationType.bodyScanning:
        return Colors.orange;
      case MeditationType.visualization:
        return Colors.teal;
      case MeditationType.spiritual:
        return Colors.amber;
    }
  }

  /// Get emoji representation
  String get emoji {
    switch (this) {
      case MeditationType.mindfulness:
        return '🧠';
      case MeditationType.healing:
        return '💚';
      case MeditationType.relaxation:
        return '🌸';
      case MeditationType.gratitude:
        return '🙏';
      case MeditationType.sleep:
        return '😴';
      case MeditationType.breathwork:
        return '💨';
      case MeditationType.bodyScanning:
        return '🔍';
      case MeditationType.visualization:
        return '✨';
      case MeditationType.spiritual:
        return '🕊️';
    }
  }

  /// Get recommended duration range in minutes
  List<int> get recommendedDurations {
    switch (this) {
      case MeditationType.mindfulness:
        return [5, 10, 15, 20, 30];
      case MeditationType.healing:
        return [10, 15, 20, 30, 45];
      case MeditationType.relaxation:
        return [10, 15, 20, 25, 30];
      case MeditationType.gratitude:
        return [5, 10, 15, 20];
      case MeditationType.sleep:
        return [15, 20, 30, 45, 60];
      case MeditationType.breathwork:
        return [5, 10, 15, 20];
      case MeditationType.bodyScanning:
        return [15, 20, 25, 30, 45];
      case MeditationType.visualization:
        return [10, 15, 20, 25, 30];
      case MeditationType.spiritual:
        return [10, 15, 20, 30, 45];
    }
  }

  /// Get difficulty level (1-5, where 1 is easiest)
  int get difficultyLevel {
    switch (this) {
      case MeditationType.mindfulness:
        return 2;
      case MeditationType.healing:
        return 3;
      case MeditationType.relaxation:
        return 1;
      case MeditationType.gratitude:
        return 1;
      case MeditationType.sleep:
        return 1;
      case MeditationType.breathwork:
        return 2;
      case MeditationType.bodyScanning:
        return 2;
      case MeditationType.visualization:
        return 3;
      case MeditationType.spiritual:
        return 4;
    }
  }

  /// Get best times of day for this meditation type
  List<String> get bestTimes {
    switch (this) {
      case MeditationType.mindfulness:
        return ['morning', 'afternoon', 'evening'];
      case MeditationType.healing:
        return ['morning', 'evening'];
      case MeditationType.relaxation:
        return ['afternoon', 'evening'];
      case MeditationType.gratitude:
        return ['morning', 'evening'];
      case MeditationType.sleep:
        return ['evening', 'night'];
      case MeditationType.breathwork:
        return ['morning', 'afternoon'];
      case MeditationType.bodyScanning:
        return ['evening', 'night'];
      case MeditationType.visualization:
        return ['morning', 'afternoon'];
      case MeditationType.spiritual:
        return ['morning', 'evening'];
    }
  }

  /// Check if this meditation type is suitable for beginners
  bool get isBeginner {
    return difficultyLevel <= 2;
  }

  /// Check if this meditation type is suitable for the given mood level
  bool isSuitableForMood(double moodLevel) {
    switch (this) {
      case MeditationType.healing:
        return moodLevel <= 6.0; // Good for low to moderate moods
      case MeditationType.relaxation:
        return moodLevel >= 4.0 && moodLevel <= 8.0; // Good for moderate moods
      case MeditationType.gratitude:
        return moodLevel >= 6.0; // Good for moderate to high moods
      case MeditationType.sleep:
        return true; // Suitable for all moods
      default:
        return true; // Other types are generally suitable for all moods
    }
  }
}
