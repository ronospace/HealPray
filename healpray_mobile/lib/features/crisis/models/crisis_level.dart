import 'package:flutter/material.dart';

/// Enum representing different levels of crisis severity
enum CrisisLevel {
  none,
  low,
  moderate,
  high,
  severe,
}

extension CrisisLevelExtensions on CrisisLevel {
  /// Get human-readable display name
  String get displayName {
    switch (this) {
      case CrisisLevel.none:
        return 'No Crisis';
      case CrisisLevel.low:
        return 'Low Risk';
      case CrisisLevel.moderate:
        return 'Moderate Risk';
      case CrisisLevel.high:
        return 'High Risk';
      case CrisisLevel.severe:
        return 'Severe Crisis';
    }
  }

  /// Get detailed description
  String get description {
    switch (this) {
      case CrisisLevel.none:
        return 'No immediate concerns detected';
      case CrisisLevel.low:
        return 'Some concerning patterns, monitoring recommended';
      case CrisisLevel.moderate:
        return 'Notable risk factors present, professional support recommended';
      case CrisisLevel.high:
        return 'Significant risk factors, immediate professional intervention advised';
      case CrisisLevel.severe:
        return 'Critical emergency situation, immediate action required';
    }
  }

  /// Get urgency level (1-5, with 5 being most urgent)
  int get urgencyLevel {
    switch (this) {
      case CrisisLevel.none:
        return 1;
      case CrisisLevel.low:
        return 2;
      case CrisisLevel.moderate:
        return 3;
      case CrisisLevel.high:
        return 4;
      case CrisisLevel.severe:
        return 5;
    }
  }

  /// Get color representation for UI
  Color get color {
    switch (this) {
      case CrisisLevel.none:
        return Colors.grey;
      case CrisisLevel.low:
        return Colors.green;
      case CrisisLevel.moderate:
        return Colors.amber;
      case CrisisLevel.high:
        return Colors.orange;
      case CrisisLevel.severe:
        return Colors.red;
    }
  }

  /// Get icon representation
  IconData get icon {
    switch (this) {
      case CrisisLevel.none:
        return Icons.check_circle;
      case CrisisLevel.low:
        return Icons.info;
      case CrisisLevel.moderate:
        return Icons.warning_amber;
      case CrisisLevel.high:
        return Icons.warning;
      case CrisisLevel.severe:
        return Icons.emergency;
    }
  }

  /// Check if this level requires immediate attention
  bool get requiresImmediateAction => this == CrisisLevel.severe;

  /// Check if this level requires professional intervention
  bool get requiresProfessionalCare => urgencyLevel >= 3;

  /// Check if this level requires monitoring
  bool get requiresMonitoring => urgencyLevel >= 2;
}
