import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'prayer_response.freezed.dart';
part 'prayer_response.g.dart';

/// Model representing a response to a prayer request
@freezed
@HiveType(typeId: 73)
class PrayerResponse with _$PrayerResponse {
  const factory PrayerResponse({
    @HiveField(0) required String id,
    @HiveField(1) required String requestId,
    @HiveField(2) required String responderId,
    @HiveField(3) required String message,
    @HiveField(4) String? verseReference,
    @HiveField(5) String? verseText,
    @HiveField(6) required DateTime createdAt,
    @HiveField(7) @Default(0) int likesCount,
    @HiveField(8) @Default([]) List<String> likedByUserIds,
    @HiveField(9) @Default(false) bool isPinned,
    @HiveField(10) @Default(false) bool isFromPastor,
    @HiveField(11) @Default({}) Map<String, dynamic> metadata,
  }) = _PrayerResponse;

  factory PrayerResponse.fromJson(Map<String, dynamic> json) =>
      _$PrayerResponseFromJson(json);
}

extension PrayerResponseExtensions on PrayerResponse {
  /// Get formatted time since response was created
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

  /// Check if response includes a Bible verse
  bool get includesVerse {
    return verseReference != null && verseText != null;
  }

  /// Get formatted verse display
  String get verseDisplay {
    if (!includesVerse) return '';
    return '"$verseText"\n\n— $verseReference';
  }

  /// Check if user has liked this response
  bool hasUserLiked(String userId) {
    return likedByUserIds.contains(userId);
  }

  /// Get formatted likes count
  String get likesText {
    if (likesCount == 0) {
      return '';
    } else if (likesCount == 1) {
      return '1 like';
    } else {
      return '$likesCount likes';
    }
  }

  /// Get responder display name
  String get responderDisplayName {
    if (isFromPastor) {
      return 'Pastor • Verified';
    } else {
      // In a real app, this would lookup the actual user name
      return 'Community Member';
    }
  }

  /// Check if response is recent (within 24 hours)
  bool get isRecent {
    return DateTime.now().difference(createdAt).inHours <= 24;
  }

  /// Get response type indicator
  String get responseTypeIndicator {
    if (isPinned) {
      return '📌 Pinned';
    } else if (isFromPastor) {
      return '✟ Pastor';
    } else if (includesVerse) {
      return '📖 Scripture';
    } else {
      return '💬 Encouragement';
    }
  }

  /// Get full message with verse if included
  String get fullMessage {
    if (!includesVerse) {
      return message;
    } else {
      return '$message\n\n$verseDisplay';
    }
  }

  /// Check if this is a high-quality response (has verse or from pastor or many likes)
  bool get isHighQuality {
    return isFromPastor || includesVerse || likesCount >= 5;
  }

  /// Get response priority for sorting
  int get sortPriority {
    int priority = 0;

    if (isPinned) priority += 1000;
    if (isFromPastor) priority += 500;
    if (includesVerse) priority += 200;

    priority += likesCount * 10;

    // Newer responses get slight boost
    final hoursSinceCreated = DateTime.now().difference(createdAt).inHours;
    if (hoursSinceCreated <= 24) {
      priority += 50;
    }

    return priority;
  }
}
