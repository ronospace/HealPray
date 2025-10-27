import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'meditation_session.freezed.dart';
part 'meditation_session.g.dart';

/// Meditation session duration options
@HiveType(typeId: 50)
enum MeditationDuration {
  @HiveField(0)
  short, // 5 minutes
  @HiveField(1)
  medium, // 10 minutes
  @HiveField(2)
  long, // 20 minutes
  @HiveField(3)
  custom,
}

/// Meditation types available
@HiveType(typeId: 51)
enum MeditationType {
  @HiveField(0)
  guided,
  @HiveField(1)
  breathing,
  @HiveField(2)
  prayer,
  @HiveField(3)
  scripture,
  @HiveField(4)
  gratitude,
  @HiveField(5)
  healing,
  @HiveField(6)
  peace,
  @HiveField(7)
  silent,
}

/// Meditation session state
@HiveType(typeId: 52)
enum MeditationState {
  @HiveField(0)
  preparing,
  @HiveField(1)
  active,
  @HiveField(2)
  paused,
  @HiveField(3)
  completed,
  @HiveField(4)
  cancelled,
}

/// Meditation phase during a session
@HiveType(typeId: 54)
enum MeditationPhase {
  @HiveField(0)
  preparation,
  @HiveField(1)
  settling,
  @HiveField(2)
  main,
  @HiveField(3)
  integration,
  @HiveField(4)
  completion,
}

/// Data model for a meditation session
@freezed
@HiveType(typeId: 53)
class MeditationSession with _$MeditationSession {
  const factory MeditationSession({
    @HiveField(0) required String id,
    @HiveField(1) required String userId,
    @HiveField(2) required MeditationType type,
    @HiveField(3) required MeditationDuration duration,
    @HiveField(4) required DateTime startedAt,
    @HiveField(5) DateTime? completedAt,
    @HiveField(6) @Default(MeditationState.preparing) MeditationState state,
    @HiveField(7) @Default(0) int targetDurationMinutes,
    @HiveField(8) @Default(0) int actualDurationSeconds,
    @HiveField(9) String? title,
    @HiveField(10) String? description,
    @HiveField(11) String? scriptContent,
    @HiveField(12) String? audioUrl,
    @HiveField(13) @Default([]) List<String> tags,
    @HiveField(14) Map<String, dynamic>? moodBefore,
    @HiveField(15) Map<String, dynamic>? moodAfter,
    @HiveField(16) String? reflection,
    @HiveField(17) @Default(0) int rating, // 1-5 stars
    @HiveField(18) @Default({}) Map<String, dynamic> metadata,
    @HiveField(19) @Default(false) bool isCustom,
    @HiveField(20) @Default(MeditationPhase.preparation) MeditationPhase currentPhase,
    @HiveField(21) Duration? elapsedTime,
    @HiveField(22) DateTime? endTime,
    @HiveField(23) @Default(false) bool isActive,
    @HiveField(24) @Default(0.0) double completionPercentage,
  }) = _MeditationSession;

  factory MeditationSession.fromJson(Map<String, dynamic> json) =>
      _$MeditationSessionFromJson(json);
}

extension MeditationSessionExtensions on MeditationSession {
  /// Get the duration in minutes based on the duration type
  int get durationInMinutes {
    switch (duration) {
      case MeditationDuration.short:
        return 5;
      case MeditationDuration.medium:
        return 10;
      case MeditationDuration.long:
        return 20;
      case MeditationDuration.custom:
        return targetDurationMinutes;
    }
  }

  /// Get a readable duration string
  String get durationString {
    final minutes = durationInMinutes;
    return '$minutes min';
  }

  /// Get target duration as Duration object
  Duration get targetDuration => Duration(minutes: targetDurationMinutes);

  /// Get completion percentage (computed version if not stored)
  double get computedCompletionPercentage {
    if (targetDurationMinutes <= 0) return 0.0;
    final targetSeconds = targetDurationMinutes * 60;
    return (actualDurationSeconds / targetSeconds).clamp(0.0, 1.0);
  }

  /// Check if session is completed
  bool get isCompleted => state == MeditationState.completed;

  /// Check if session is in progress
  bool get isInProgress => [
        MeditationState.preparing,
        MeditationState.active,
        MeditationState.paused,
      ].contains(state);

  /// Get formatted actual duration
  String get formattedActualDuration {
    final minutes = actualDurationSeconds ~/ 60;
    final seconds = actualDurationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get meditation type display name
  String get typeDisplayName {
    switch (type) {
      case MeditationType.guided:
        return 'Guided Meditation';
      case MeditationType.breathing:
        return 'Breathing Exercise';
      case MeditationType.prayer:
        return 'Prayer Meditation';
      case MeditationType.scripture:
        return 'Scripture Meditation';
      case MeditationType.gratitude:
        return 'Gratitude Practice';
      case MeditationType.healing:
        return 'Healing Meditation';
      case MeditationType.peace:
        return 'Peace & Calm';
      case MeditationType.silent:
        return 'Silent Meditation';
    }
  }

  /// Get appropriate icon for meditation type
  String get typeIcon {
    switch (type) {
      case MeditationType.guided:
        return '🧘‍♀️';
      case MeditationType.breathing:
        return '💨';
      case MeditationType.prayer:
        return '🙏';
      case MeditationType.scripture:
        return '📖';
      case MeditationType.gratitude:
        return '🙏';
      case MeditationType.healing:
        return '💚';
      case MeditationType.peace:
        return '☮️';
      case MeditationType.silent:
        return '🤫';
    }
  }
}
