import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'prayer_circle.freezed.dart';
part 'prayer_circle.g.dart';

/// Model representing a prayer circle community
@freezed
@HiveType(typeId: 70)
class PrayerCircle with _$PrayerCircle {
  const factory PrayerCircle({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) required String description,
    @HiveField(3) required String creatorId,
    @HiveField(4) required List<String> memberIds,
    @HiveField(5) required int memberCount,
    @HiveField(6) @Default([]) List<String> tags,
    @HiveField(7) required DateTime createdAt,
    @HiveField(8) required DateTime lastActivity,
    @HiveField(9) @Default(false) bool isPrivate,
    @HiveField(10) String? imageUrl,
    @HiveField(11) @Default({}) Map<String, dynamic> settings,
  }) = _PrayerCircle;

  factory PrayerCircle.fromJson(Map<String, dynamic> json) =>
      _$PrayerCircleFromJson(json);
}

/// Enum for prayer urgency levels
@HiveType(typeId: 71)
enum PrayerUrgency {
  @HiveField(0)
  low,
  @HiveField(1)
  normal,
  @HiveField(2)
  high,
  @HiveField(3)
  urgent,
}

extension PrayerCircleExtensions on PrayerCircle {
  /// Get formatted member count
  String get memberCountText {
    if (memberCount == 1) {
      return '1 member';
    } else {
      return '$memberCount members';
    }
  }

  /// Check if circle is active (activity within last 7 days)
  bool get isActive {
    final now = DateTime.now();
    return now.difference(lastActivity).inDays <= 7;
  }

  /// Get activity status
  String get activityStatus {
    final now = DateTime.now();
    final daysSinceActivity = now.difference(lastActivity).inDays;

    if (daysSinceActivity == 0) {
      return 'Active today';
    } else if (daysSinceActivity == 1) {
      return 'Active yesterday';
    } else if (daysSinceActivity <= 7) {
      return 'Active $daysSinceActivity days ago';
    } else {
      return 'Inactive';
    }
  }

  /// Check if user is a member
  bool isMember(String userId) {
    return memberIds.contains(userId);
  }

  /// Check if user is the creator
  bool isCreator(String userId) {
    return creatorId == userId;
  }
}

extension PrayerUrgencyExtensions on PrayerUrgency {
  /// Get display name
  String get displayName {
    switch (this) {
      case PrayerUrgency.low:
        return 'Low Priority';
      case PrayerUrgency.normal:
        return 'Normal';
      case PrayerUrgency.high:
        return 'High Priority';
      case PrayerUrgency.urgent:
        return 'Urgent';
    }
  }

  /// Get color for UI display
  String get colorHex {
    switch (this) {
      case PrayerUrgency.low:
        return '#22C55E'; // Green
      case PrayerUrgency.normal:
        return '#3B82F6'; // Blue
      case PrayerUrgency.high:
        return '#F59E0B'; // Amber
      case PrayerUrgency.urgent:
        return '#EF4444'; // Red
    }
  }

  /// Get priority level as integer
  int get priorityLevel {
    switch (this) {
      case PrayerUrgency.low:
        return 1;
      case PrayerUrgency.normal:
        return 2;
      case PrayerUrgency.high:
        return 3;
      case PrayerUrgency.urgent:
        return 4;
    }
  }
}
