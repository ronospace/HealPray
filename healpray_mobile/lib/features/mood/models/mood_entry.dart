import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'emotion_type.dart';
import 'mood_enums.dart';

part 'mood_entry.freezed.dart';
part 'mood_entry.g.dart';

/// Comprehensive mood entry model for tracking emotional states
@freezed
class MoodEntry with _$MoodEntry {
  const factory MoodEntry({
    required String id,
    required String userId,
    required DateTime timestamp,
    required List<EmotionType> emotions,
    required MoodIntensity intensity,
    required List<MoodTrigger> triggers,
    String? notes,
    String? location,
    List<String>? tags,
    MoodContext? context,
    List<String>? gratitudeList,
    List<String>? prayerRequests,
    String? verse,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MoodEntry;

  const MoodEntry._();

  /// Create from Firestore document
  factory MoodEntry.fromJson(Map<String, Object?> json) =>
      _$MoodEntryFromJson(json);

  /// Create from Firestore DocumentSnapshot
  factory MoodEntry.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Document data is null');
    }

    return MoodEntry.fromJson({
      ...data,
      'id': snapshot.id,
      // Convert Firestore Timestamps to DateTime
      'timestamp': (data['timestamp'] as Timestamp).toDate().toIso8601String(),
      'createdAt': data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
          : null,
      'updatedAt': data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate().toIso8601String()
          : null,
    });
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    final json = toJson();

    // Remove the id field as it's the document ID
    json.remove('id');

    // Convert DateTime to Timestamp for Firestore
    json['timestamp'] = Timestamp.fromDate(timestamp);
    if (createdAt != null) {
      json['createdAt'] = Timestamp.fromDate(createdAt!);
    }
    if (updatedAt != null) {
      json['updatedAt'] = Timestamp.fromDate(updatedAt!);
    }

    return json;
  }

  /// Get the primary emotion (first emotion in the list)
  EmotionType get primaryEmotion => emotions.first;

  /// Get the overall mood score based on emotions and intensity
  double get moodScore {
    if (emotions.isEmpty) return 0.0;

    // Calculate weighted score based on emotion categories and intensity
    double emotionScore = 0.0;
    for (final emotion in emotions) {
      switch (emotion.category) {
        case EmotionCategory.positive:
          emotionScore += 4.0;
          break;
        case EmotionCategory.spiritual:
          emotionScore += 3.5;
          break;
        case EmotionCategory.physical:
          emotionScore += 3.0;
          break;
        case EmotionCategory.anxiety:
          emotionScore += 2.0;
          break;
        case EmotionCategory.sadness:
          emotionScore += 1.5;
          break;
        case EmotionCategory.anger:
          emotionScore += 1.0;
          break;
      }
    }

    // Average emotion score
    emotionScore /= emotions.length;

    // Apply intensity multiplier
    final intensityMultiplier =
        intensity.value / 3.0; // Normalize around 3 (moderate)

    return (emotionScore * intensityMultiplier).clamp(0.0, 5.0);
  }

  /// Check if this is a positive mood entry
  bool get isPositive => moodScore >= 3.5;

  /// Check if this entry indicates distress
  bool get indicatesDistress {
    return moodScore <= 2.0 ||
        emotions.any((e) =>
                e.category == EmotionCategory.anger ||
                e.category == EmotionCategory.sadness) &&
            intensity.value >= 4;
  }

  /// Get spiritual practices suggested for this mood
  List<String> get suggestedPractices {
    final practices = <String>{};

    for (final emotion in emotions) {
      practices.addAll(emotion.suggestedPractices);
    }

    // Add trigger-specific practices
    for (final trigger in triggers) {
      switch (trigger.category) {
        case MoodTriggerCategory.spiritual:
          practices.addAll(['Deep Prayer', 'Scripture Meditation', 'Worship']);
          break;
        case MoodTriggerCategory.crisisSupport:
          practices.addAll(
              ['Crisis Prayer', 'Comfort Scriptures', 'Community Support']);
          break;
        case MoodTriggerCategory.relationships:
          practices.addAll([
            'Forgiveness Prayer',
            'Relationship Blessing',
            'Love Meditation'
          ]);
          break;
        default:
          break;
      }
    }

    return practices.toList();
  }

  /// Get mood entry summary text
  String get summary {
    final emotionNames = emotions.map((e) => e.displayName).join(', ');
    final intensityText = intensity.displayName.toLowerCase();

    if (emotions.length == 1) {
      return 'Feeling $intensityText ${emotionNames.toLowerCase()}';
    } else {
      return 'Feeling $intensityText - $emotionNames';
    }
  }

  /// Copy with updated timestamp
  MoodEntry copyWithUpdatedAt() {
    return copyWith(updatedAt: DateTime.now());
  }
}

/// Context information for mood entries
@freezed
class MoodContext with _$MoodContext {
  const factory MoodContext({
    String? weather,
    String? activity,
    String? location,
    int? energyLevel, // 1-5 scale
    int? stressLevel, // 1-5 scale
    int? socialLevel, // 1-5 scale (alone to with many people)
    bool? atHome,
    bool? atWork,
    bool? traveling,
    String? additionalContext,
  }) = _MoodContext;

  factory MoodContext.fromJson(Map<String, Object?> json) =>
      _$MoodContextFromJson(json);
}
