import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'meditation_type.dart';

part 'guided_meditation.freezed.dart';
part 'guided_meditation.g.dart';

/// Model representing a guided meditation session
@freezed
@HiveType(typeId: 75)
class GuidedMeditation with _$GuidedMeditation {
  const factory GuidedMeditation({
    @HiveField(0) required String id,
    @HiveField(1) required String title,
    @HiveField(2) required String description,
    @HiveField(3) required MeditationType type,
    @HiveField(4) required Duration duration,
    @HiveField(5) required String difficulty,
    @HiveField(6) required String instructor,
    @HiveField(7) String? audioUrl,
    @HiveField(8) String? imageUrl,
    @HiveField(9) @Default([]) List<String> tags,
    @HiveField(10) @Default([]) List<String> scriptSteps,
    @HiveField(11) @Default(false) bool isPremium,
    @HiveField(12) @Default(0) double rating,
    @HiveField(13) @Default(0) int completionCount,
    @HiveField(14) @Default(false) bool isDownloaded,
    @HiveField(15) @Default({}) Map<String, dynamic> metadata,
  }) = _GuidedMeditation;

  factory GuidedMeditation.fromJson(Map<String, dynamic> json) =>
      _$GuidedMeditationFromJson(json);
}

extension GuidedMeditationExtensions on GuidedMeditation {
  /// Get formatted duration text
  String get durationText {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours h';
      } else {
        return '$hours h $remainingMinutes min';
      }
    }
  }

  /// Get difficulty level as integer (1-5)
  int get difficultyLevel {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 1;
      case 'easy':
        return 2;
      case 'intermediate':
        return 3;
      case 'advanced':
        return 4;
      case 'expert':
        return 5;
      default:
        return 2;
    }
  }

  /// Get formatted rating text
  String get ratingText {
    if (rating == 0) {
      return 'Not rated';
    } else {
      return '${rating.toStringAsFixed(1)} ⭐';
    }
  }

  /// Get formatted completion count
  String get popularityText {
    if (completionCount == 0) {
      return 'New';
    } else if (completionCount < 100) {
      return '$completionCount completions';
    } else if (completionCount < 1000) {
      return '${(completionCount / 100).floor()}00+ completions';
    } else {
      return '${(completionCount / 1000).floor()}k+ completions';
    }
  }

  /// Check if meditation is suitable for beginners
  bool get isSuitableForBeginners {
    return difficultyLevel <= 2;
  }

  /// Check if meditation is highly rated
  bool get isHighlyRated {
    return rating >= 4.5;
  }

  /// Check if meditation is popular
  bool get isPopular {
    return completionCount >= 500;
  }

  /// Get estimated preparation time in minutes
  int get preparationTime {
    return difficultyLevel <= 2 ? 2 : 5;
  }

  /// Get total session time including preparation
  Duration get totalSessionTime {
    return duration + Duration(minutes: preparationTime);
  }

  /// Check if meditation has audio
  bool get hasAudio {
    return audioUrl != null && audioUrl!.isNotEmpty;
  }

  /// Check if meditation has guided script
  bool get hasScript {
    return scriptSteps.isNotEmpty;
  }

  /// Get meditation format description
  String get formatDescription {
    final parts = <String>[];

    if (hasAudio) {
      parts.add('Audio guided');
    }
    if (hasScript) {
      parts.add('Text script');
    }
    if (parts.isEmpty) {
      parts.add('Self-guided');
    }

    return parts.join(' • ');
  }

  /// Get tags as formatted string
  String get tagsText {
    if (tags.isEmpty) {
      return '';
    } else if (tags.length <= 3) {
      return tags.join(' • ');
    } else {
      return '${tags.take(3).join(' • ')} +${tags.length - 3}';
    }
  }

  /// Check if meditation matches search query
  bool matchesQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
        description.toLowerCase().contains(lowerQuery) ||
        instructor.toLowerCase().contains(lowerQuery) ||
        type.displayName.toLowerCase().contains(lowerQuery) ||
        tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
  }

  /// Get suitability score for current user context
  double getSuitabilityScore({
    double? userMoodLevel,
    String? timeOfDay,
    int? userExperienceLevel,
    List<String>? userPreferredTypes,
  }) {
    double score = 5.0; // Base score

    // Mood suitability
    if (userMoodLevel != null && type.isSuitableForMood(userMoodLevel)) {
      score += 2.0;
    }

    // Time of day suitability
    if (timeOfDay != null && type.bestTimes.contains(timeOfDay)) {
      score += 1.5;
    }

    // Experience level matching
    if (userExperienceLevel != null) {
      final levelDifference = (difficultyLevel - userExperienceLevel).abs();
      if (levelDifference == 0) {
        score += 2.0;
      } else if (levelDifference == 1) {
        score += 1.0;
      } else if (levelDifference >= 3) {
        score -= 1.0;
      }
    }

    // User preferences
    if (userPreferredTypes?.contains(type.toString()) == true) {
      score += 1.5;
    }

    // Quality indicators
    if (isHighlyRated) score += 1.0;
    if (isPopular) score += 0.5;

    // Premium content slight penalty for free users (can be overridden)
    if (isPremium) score -= 0.5;

    return score;
  }

  /// Get step count for progress tracking
  int get stepCount {
    // Base steps for any meditation
    int steps = 3; // Preparation, main meditation, completion

    // Add script steps if available
    if (hasScript) {
      steps += scriptSteps.length;
    }

    return steps;
  }
}
