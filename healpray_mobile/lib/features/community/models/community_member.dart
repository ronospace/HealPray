import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'community_member.freezed.dart';
part 'community_member.g.dart';

/// Model representing a community member
@freezed
@HiveType(typeId: 74)
class CommunityMember with _$CommunityMember {
  const factory CommunityMember({
    @HiveField(0) required String id,
    @HiveField(1) required String displayName,
    @HiveField(2) String? avatarUrl,
    @HiveField(3) String? bio,
    @HiveField(4) required DateTime joinedAt,
    @HiveField(5) required DateTime lastSeen,
    @HiveField(6) @Default(0) int prayersOffered,
    @HiveField(7) @Default(0) int requestsSubmitted,
    @HiveField(8) @Default(0) int circlesJoined,
    @HiveField(9) @Default(0) int responsesGiven,
    @HiveField(10) @Default(0) int likesReceived,
    @HiveField(11) @Default(false) bool isVerified,
    @HiveField(12) @Default(false) bool isPastor,
    @HiveField(13) @Default(false) bool isModerator,
    @HiveField(14) @Default([]) List<String> badges,
    @HiveField(15) @Default({}) Map<String, dynamic> preferences,
  }) = _CommunityMember;

  factory CommunityMember.fromJson(Map<String, dynamic> json) =>
      _$CommunityMemberFromJson(json);
}

/// Enum for member activity levels
enum ActivityLevel {
  inactive,
  casual,
  regular,
  active,
  veryActive,
}

/// Enum for member reputation levels
enum ReputationLevel {
  newcomer,
  member,
  contributor,
  guardian,
  elder,
}

extension CommunityMemberExtensions on CommunityMember {
  /// Get formatted time since member joined
  String get memberSince {
    final now = DateTime.now();
    final difference = now.difference(joinedAt);

    if (difference.inDays < 30) {
      return 'Joined ${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'Joined 1 month ago' : 'Joined $months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? 'Joined 1 year ago' : 'Joined $years years ago';
    }
  }

  /// Get formatted time since last seen
  String get lastSeenText {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 5) {
      return 'Active now';
    } else if (difference.inMinutes < 60) {
      return 'Active ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Active ${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return 'Active ${difference.inDays}d ago';
    } else {
      return 'Last seen ${(difference.inDays / 7).floor()}w ago';
    }
  }

  /// Check if member is currently active (within 15 minutes)
  bool get isCurrentlyActive {
    return DateTime.now().difference(lastSeen).inMinutes <= 15;
  }

  /// Get activity level based on engagement
  ActivityLevel get activityLevel {
    final totalEngagement = prayersOffered + requestsSubmitted + responsesGiven;
    final daysSinceJoined = DateTime.now().difference(joinedAt).inDays;
    final engagementPerDay =
        daysSinceJoined > 0 ? totalEngagement / daysSinceJoined : 0;

    if (engagementPerDay >= 5.0) {
      return ActivityLevel.veryActive;
    } else if (engagementPerDay >= 2.0) {
      return ActivityLevel.active;
    } else if (engagementPerDay >= 0.5) {
      return ActivityLevel.regular;
    } else if (engagementPerDay > 0) {
      return ActivityLevel.casual;
    } else {
      return ActivityLevel.inactive;
    }
  }

  /// Get reputation level based on contributions and recognition
  ReputationLevel get reputationLevel {
    final totalContributions = prayersOffered + responsesGiven;
    final likesPerContribution =
        totalContributions > 0 ? likesReceived / totalContributions : 0;
    final qualityScore = totalContributions + (likesPerContribution * 10);

    if (qualityScore >= 200) {
      return ReputationLevel.elder;
    } else if (qualityScore >= 100) {
      return ReputationLevel.guardian;
    } else if (qualityScore >= 50) {
      return ReputationLevel.contributor;
    } else if (qualityScore >= 10) {
      return ReputationLevel.member;
    } else {
      return ReputationLevel.newcomer;
    }
  }

  /// Get member role display text
  String get roleDisplayText {
    if (isPastor) {
      return '✟ Pastor';
    } else if (isModerator) {
      return '🛡️ Moderator';
    } else if (isVerified) {
      return '✓ Verified';
    } else {
      return reputationLevel.displayName;
    }
  }

  /// Get engagement summary
  String get engagementSummary {
    final parts = <String>[];

    if (prayersOffered > 0) {
      parts.add('$prayersOffered prayers');
    }
    if (responsesGiven > 0) {
      parts.add('$responsesGiven responses');
    }
    if (circlesJoined > 0) {
      parts.add('$circlesJoined circles');
    }

    return parts.isEmpty ? 'New member' : parts.join(' • ');
  }

  /// Get display name with title
  String get displayNameWithTitle {
    if (isPastor) {
      return 'Pastor $displayName';
    } else {
      return displayName;
    }
  }

  /// Check if member is a community leader
  bool get isCommunityLeader {
    return isPastor ||
        isModerator ||
        reputationLevel.index >= ReputationLevel.guardian.index;
  }

  /// Get member's contribution score
  int get contributionScore {
    return (prayersOffered * 2) + (responsesGiven * 3) + (likesReceived * 1);
  }
}

extension ActivityLevelExtensions on ActivityLevel {
  /// Get display name for activity level
  String get displayName {
    switch (this) {
      case ActivityLevel.inactive:
        return 'Inactive';
      case ActivityLevel.casual:
        return 'Casual';
      case ActivityLevel.regular:
        return 'Regular';
      case ActivityLevel.active:
        return 'Active';
      case ActivityLevel.veryActive:
        return 'Very Active';
    }
  }

  /// Get color for activity indicator
  String get colorHex {
    switch (this) {
      case ActivityLevel.inactive:
        return '#9CA3AF'; // Gray
      case ActivityLevel.casual:
        return '#10B981'; // Green
      case ActivityLevel.regular:
        return '#3B82F6'; // Blue
      case ActivityLevel.active:
        return '#F59E0B'; // Amber
      case ActivityLevel.veryActive:
        return '#EF4444'; // Red
    }
  }
}

extension ReputationLevelExtensions on ReputationLevel {
  /// Get display name for reputation level
  String get displayName {
    switch (this) {
      case ReputationLevel.newcomer:
        return 'Newcomer';
      case ReputationLevel.member:
        return 'Member';
      case ReputationLevel.contributor:
        return 'Contributor';
      case ReputationLevel.guardian:
        return 'Guardian';
      case ReputationLevel.elder:
        return 'Elder';
    }
  }

  /// Get icon for reputation level
  String get icon {
    switch (this) {
      case ReputationLevel.newcomer:
        return '🌱';
      case ReputationLevel.member:
        return '🙏';
      case ReputationLevel.contributor:
        return '💫';
      case ReputationLevel.guardian:
        return '🛡️';
      case ReputationLevel.elder:
        return '👑';
    }
  }
}
