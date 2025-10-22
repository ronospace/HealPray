import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Prayer data model
class PrayerModel extends Equatable {
  final String id;
  final String userId;
  final String content;
  final String? title;
  final List<String> tags;
  final PrayerType type;
  final String? mood;
  final double? moodScore;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isFavorite;
  final bool isShared;
  final int shareCount;
  final Map<String, dynamic> metadata;

  const PrayerModel({
    required this.id,
    required this.userId,
    required this.content,
    this.title,
    required this.tags,
    required this.type,
    this.mood,
    this.moodScore,
    required this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
    this.isShared = false,
    this.shareCount = 0,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        content,
        title,
        tags,
        type,
        mood,
        moodScore,
        createdAt,
        updatedAt,
        isFavorite,
        isShared,
        shareCount,
        metadata,
      ];

  /// Create PrayerModel from Firestore document
  factory PrayerModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return PrayerModel(
      id: doc.id,
      userId: data['userId'] as String,
      content: data['content'] as String,
      title: data['title'] as String?,
      tags: List<String>.from(data['tags'] as List<dynamic>? ?? []),
      type: PrayerType.values.byName(data['type'] as String? ?? 'personal'),
      mood: data['mood'] as String?,
      moodScore: (data['moodScore'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      isFavorite: data['isFavorite'] as bool? ?? false,
      isShared: data['isShared'] as bool? ?? false,
      shareCount: data['shareCount'] as int? ?? 0,
      metadata: Map<String, dynamic>.from(
          data['metadata'] as Map<dynamic, dynamic>? ?? {}),
    );
  }

  /// Convert PrayerModel to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'content': content,
      'title': title,
      'tags': tags,
      'type': type.name,
      'mood': mood,
      'moodScore': moodScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isFavorite': isFavorite,
      'isShared': isShared,
      'shareCount': shareCount,
      'metadata': metadata,
    };
  }

  /// Create a copy with updated values
  PrayerModel copyWith({
    String? id,
    String? userId,
    String? content,
    String? title,
    List<String>? tags,
    PrayerType? type,
    String? mood,
    double? moodScore,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    bool? isShared,
    int? shareCount,
    Map<String, dynamic>? metadata,
  }) {
    return PrayerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      title: title ?? this.title,
      tags: tags ?? this.tags,
      type: type ?? this.type,
      mood: mood ?? this.mood,
      moodScore: moodScore ?? this.moodScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isShared: isShared ?? this.isShared,
      shareCount: shareCount ?? this.shareCount,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Prayer types
enum PrayerType {
  personal,
  thanksgiving,
  intercession,
  confession,
  petition,
  praise,
  meditation,
  emergency,
}

/// Mood entry data model
class MoodEntryModel extends Equatable {
  final String id;
  final String userId;
  final int score; // 1-10 scale
  final String? description;
  final String? emotion;
  final List<String> triggers;
  final List<String> activities;
  final String? notes;
  final DateTime createdAt;
  final Map<String, dynamic> context;

  const MoodEntryModel({
    required this.id,
    required this.userId,
    required this.score,
    this.description,
    this.emotion,
    required this.triggers,
    required this.activities,
    this.notes,
    required this.createdAt,
    this.context = const {},
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        score,
        description,
        emotion,
        triggers,
        activities,
        notes,
        createdAt,
        context,
      ];

  /// Create MoodEntryModel from Firestore document
  factory MoodEntryModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return MoodEntryModel(
      id: doc.id,
      userId: data['userId'] as String,
      score: data['score'] as int,
      description: data['description'] as String?,
      emotion: data['emotion'] as String?,
      triggers: List<String>.from(data['triggers'] as List<dynamic>? ?? []),
      activities: List<String>.from(data['activities'] as List<dynamic>? ?? []),
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      context: Map<String, dynamic>.from(
          data['context'] as Map<dynamic, dynamic>? ?? {}),
    );
  }

  /// Convert MoodEntryModel to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'score': score,
      'description': description,
      'emotion': emotion,
      'triggers': triggers,
      'activities': activities,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'context': context,
    };
  }

  /// Create a copy with updated values
  MoodEntryModel copyWith({
    String? id,
    String? userId,
    int? score,
    String? description,
    String? emotion,
    List<String>? triggers,
    List<String>? activities,
    String? notes,
    DateTime? createdAt,
    Map<String, dynamic>? context,
  }) {
    return MoodEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      score: score ?? this.score,
      description: description ?? this.description,
      emotion: emotion ?? this.emotion,
      triggers: triggers ?? this.triggers,
      activities: activities ?? this.activities,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      context: context ?? this.context,
    );
  }

  /// Get mood category based on score
  MoodCategory get category {
    if (score <= 3) return MoodCategory.low;
    if (score <= 6) return MoodCategory.neutral;
    return MoodCategory.high;
  }

  /// Get mood description based on score
  String get moodDescription {
    switch (score) {
      case 1:
        return 'Extremely Low';
      case 2:
        return 'Very Low';
      case 3:
        return 'Low';
      case 4:
        return 'Below Average';
      case 5:
        return 'Neutral';
      case 6:
        return 'Above Average';
      case 7:
        return 'Good';
      case 8:
        return 'Very Good';
      case 9:
        return 'Excellent';
      case 10:
        return 'Amazing';
      default:
        return 'Unknown';
    }
  }
}

/// Mood categories
enum MoodCategory {
  low,
  neutral,
  high,
}

/// Conversation data model for AI chat
class ConversationModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final List<ChatMessage> messages;
  final ConversationType type;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final Map<String, dynamic> metadata;

  const ConversationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.messages,
    required this.type,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        messages,
        type,
        createdAt,
        updatedAt,
        isActive,
        metadata,
      ];

  /// Create ConversationModel from Firestore document
  factory ConversationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return ConversationModel(
      id: doc.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      messages: (data['messages'] as List<dynamic>? ?? [])
          .map((msg) => ChatMessage.fromMap(msg as Map<String, dynamic>))
          .toList(),
      type: ConversationType.values
          .byName(data['type'] as String? ?? 'spiritual'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] as bool? ?? true,
      metadata: Map<String, dynamic>.from(
          data['metadata'] as Map<dynamic, dynamic>? ?? {}),
    );
  }

  /// Convert ConversationModel to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'messages': messages.map((msg) => msg.toMap()).toList(),
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  /// Create a copy with updated values
  ConversationModel copyWith({
    String? id,
    String? userId,
    String? title,
    List<ChatMessage>? messages,
    ConversationType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Conversation types
enum ConversationType {
  spiritual,
  counseling,
  prayer,
  crisis,
}

/// Chat message data model
class ChatMessage extends Equatable {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.metadata = const {},
  });

  @override
  List<Object> get props => [id, content, role, timestamp, metadata];

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      content: map['content'] as String,
      role: MessageRole.values.byName(map['role'] as String),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(
          map['metadata'] as Map<dynamic, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'role': role.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Message roles
enum MessageRole {
  user,
  assistant,
  system,
}
