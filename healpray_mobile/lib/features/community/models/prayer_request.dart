import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'prayer_circle.dart';

part 'prayer_request.freezed.dart';
part 'prayer_request.g.dart';

/// Model representing a prayer request in a community circle
@freezed
@HiveType(typeId: 72)
class PrayerRequest with _$PrayerRequest {
  const factory PrayerRequest({
    @HiveField(0) required String id,
    @HiveField(1) required String circleId,
    @HiveField(2) required String requesterId,
    @HiveField(3) required String title,
    @HiveField(4) required String description,
    @HiveField(5) @Default(PrayerUrgency.normal) PrayerUrgency urgency,
    @HiveField(6) @Default([]) List<String> tags,
    @HiveField(7) @Default(false) bool isAnonymous,
    @HiveField(8) required DateTime createdAt,
    @HiveField(9) @Default(0) int prayerCount,
    @HiveField(10) @Default(0) int responseCount,
    @HiveField(11) DateTime? updatedAt,
    @HiveField(12) @Default(false) bool isFulfilled,
    @HiveField(13) String? fulfillmentNote,
    @HiveField(14) @Default([]) List<String> prayedByUserIds,
    @HiveField(15) @Default({}) Map<String, dynamic> metadata,
  }) = _PrayerRequest;

  factory PrayerRequest.fromJson(Map<String, dynamic> json) =>
      _$PrayerRequestFromJson(json);
}

extension PrayerRequestExtensions on PrayerRequest {
  /// Get formatted time since request was created
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  /// Get display name for requester (anonymous or real name)
  String get requesterDisplayName {
    if (isAnonymous) {
      return 'Anonymous';
    } else {
      // In a real app, this would lookup the actual user name
      return 'Community Member';
    }
  }

  /// Check if request is recent (within 24 hours)
  bool get isRecent {
    return DateTime.now().difference(createdAt).inHours <= 24;
  }

  /// Check if request needs urgent attention
  bool get needsUrgentAttention {
    return urgency == PrayerUrgency.urgent || urgency == PrayerUrgency.high;
  }

  /// Get priority score for sorting
  int get priorityScore {
    final urgencyScore = urgency.priorityLevel * 100;
    final timeScore = DateTime.now().difference(createdAt).inHours;
    final engagementScore = (prayerCount + responseCount) * 5;

    return urgencyScore - timeScore + engagementScore;
  }

  /// Check if user has already prayed for this request
  bool hasUserPrayed(String userId) {
    return prayedByUserIds.contains(userId);
  }

  /// Get formatted prayer count
  String get prayerCountText {
    if (prayerCount == 0) {
      return 'No prayers yet';
    } else if (prayerCount == 1) {
      return '1 prayer';
    } else {
      return '$prayerCount prayers';
    }
  }

  /// Get formatted response count
  String get responseCountText {
    if (responseCount == 0) {
      return 'No responses';
    } else if (responseCount == 1) {
      return '1 response';
    } else {
      return '$responseCount responses';
    }
  }

  /// Get status text
  String get statusText {
    if (isFulfilled) {
      return 'Answered Prayer ✨';
    } else if (needsUrgentAttention) {
      return 'Urgent Request 🙏';
    } else if (isRecent) {
      return 'New Request';
    } else {
      return 'Open Request';
    }
  }

  /// Get engagement summary
  String get engagementSummary {
    final prayers = prayerCountText;
    final responses = responseCountText;
    return '$prayers • $responses';
  }
}
