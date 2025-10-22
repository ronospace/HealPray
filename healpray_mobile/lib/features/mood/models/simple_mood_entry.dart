import 'package:equatable/equatable.dart';

/// Simple mood entry model for basic mood tracking
class SimpleMoodEntry extends Equatable {
  final String id;
  final int score; // 1-10 scale
  final String? notes;
  final List<String> emotions;
  final DateTime timestamp;
  final String? location;
  final Map<String, dynamic> metadata;

  const SimpleMoodEntry({
    required this.id,
    required this.score,
    this.notes,
    this.emotions = const [],
    required this.timestamp,
    this.location,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        score,
        notes,
        emotions,
        timestamp,
        location,
        metadata,
      ];

  /// Create a copy with updated values
  SimpleMoodEntry copyWith({
    String? id,
    int? score,
    String? notes,
    List<String>? emotions,
    DateTime? timestamp,
    String? location,
    Map<String, dynamic>? metadata,
  }) {
    return SimpleMoodEntry(
      id: id ?? this.id,
      score: score ?? this.score,
      notes: notes ?? this.notes,
      emotions: emotions ?? this.emotions,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get mood description based on score
  String get description {
    switch (score) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Below Average';
      case 4:
        return 'Slightly Low';
      case 5:
        return 'Neutral';
      case 6:
        return 'Good';
      case 7:
        return 'Very Good';
      case 8:
        return 'Great';
      case 9:
        return 'Excellent';
      case 10:
        return 'Amazing';
      default:
        return 'Unknown';
    }
  }

  /// Get emoji representation
  String get emoji {
    switch (score) {
      case 1:
        return '😢';
      case 2:
        return '😞';
      case 3:
        return '😕';
      case 4:
        return '😐';
      case 5:
        return '🙂';
      case 6:
        return '😊';
      case 7:
        return '😄';
      case 8:
        return '😁';
      case 9:
        return '🤗';
      case 10:
        return '🥳';
      default:
        return '🙂';
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score,
      'notes': notes,
      'emotions': emotions,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory SimpleMoodEntry.fromJson(Map<String, dynamic> json) {
    return SimpleMoodEntry(
      id: json['id'] as String,
      score: json['score'] as int,
      notes: json['notes'] as String?,
      emotions: List<String>.from(json['emotions'] as List<dynamic>? ?? []),
      timestamp: DateTime.parse(json['timestamp'] as String),
      location: json['location'] as String?,
      metadata: Map<String, dynamic>.from(
          json['metadata'] as Map<dynamic, dynamic>? ?? {}),
    );
  }
}
