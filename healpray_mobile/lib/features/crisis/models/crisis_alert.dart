import 'package:freezed_annotation/freezed_annotation.dart';
import 'crisis_level.dart';

part 'crisis_alert.freezed.dart';
part 'crisis_alert.g.dart';

/// Model representing a crisis alert with comprehensive intervention data
@freezed
class CrisisAlert with _$CrisisAlert {
  const factory CrisisAlert({
    required String id,
    required DateTime timestamp,
    required CrisisLevel crisisLevel,
    required double riskScore,
    required List<String> triggerFactors,
    required List<String> recommendedActions,
    required List<String> emergencyContacts,
    required List<String> supportResources,
    @Default(false) bool wasAddressed,
    @Default(false) bool emergencyServicesContacted,
    @Default([]) List<String> actionsCompleted,
    String? userResponse,
    String? followUpNotes,
    DateTime? resolvedAt,
    @Default({}) Map<String, dynamic> metadata,
  }) = _CrisisAlert;

  factory CrisisAlert.fromJson(Map<String, dynamic> json) =>
      _$CrisisAlertFromJson(json);
}

extension CrisisAlertExtensions on CrisisAlert {
  /// Get severity color for UI display
  String get severityColor {
    switch (crisisLevel) {
      case CrisisLevel.severe:
        return '#DC2626'; // Red-600
      case CrisisLevel.high:
        return '#EA580C'; // Orange-600
      case CrisisLevel.moderate:
        return '#D97706'; // Amber-600
      case CrisisLevel.low:
        return '#059669'; // Emerald-600
      case CrisisLevel.none:
        return '#6B7280'; // Gray-500
    }
  }

  /// Get priority level as integer (higher = more urgent)
  int get priority {
    switch (crisisLevel) {
      case CrisisLevel.severe:
        return 5;
      case CrisisLevel.high:
        return 4;
      case CrisisLevel.moderate:
        return 3;
      case CrisisLevel.low:
        return 2;
      case CrisisLevel.none:
        return 1;
    }
  }

  /// Check if this is an active emergency requiring immediate intervention
  bool get isEmergency => crisisLevel == CrisisLevel.severe;

  /// Check if this requires professional intervention
  bool get requiresProfessionalHelp =>
      crisisLevel.index >= CrisisLevel.moderate.index;

  /// Get human-readable time since alert
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Get completion percentage of recommended actions
  double get completionPercentage {
    if (recommendedActions.isEmpty) return 0.0;
    return actionsCompleted.length / recommendedActions.length;
  }

  /// Check if alert is resolved
  bool get isResolved => wasAddressed && resolvedAt != null;

  /// Get formatted risk score as percentage
  String get riskScoreFormatted => '${(riskScore * 100).round()}%';
}
