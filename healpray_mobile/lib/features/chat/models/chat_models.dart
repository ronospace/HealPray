import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'chat_models.g.dart';

/// Chat message model for AI conversations
@HiveType(typeId: 2)
class ChatMessage extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String content;
  
  @HiveField(2)
  final MessageType type;
  
  @HiveField(3)
  final MessageStatus status;
  
  @HiveField(4)
  final DateTime timestamp;
  
  @HiveField(5)
  final String? conversationId;
  
  @HiveField(6)
  final Map<String, dynamic> metadata;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    this.status = MessageStatus.sent,
    required this.timestamp,
    this.conversationId,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        content,
        type,
        status,
        timestamp,
        conversationId,
        metadata,
      ];

  /// Create a copy with updated values
  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    String? conversationId,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      conversationId: conversationId ?? this.conversationId,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'conversationId': conversationId,
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      type: MessageType.values.byName(json['type'] as String),
      status: MessageStatus.values.byName(json['status'] as String? ?? 'sent'),
      timestamp: DateTime.parse(json['timestamp'] as String),
      conversationId: json['conversationId'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map<dynamic, dynamic>? ?? {}),
    );
  }
}

/// Conversation model for AI spiritual guidance
@HiveType(typeId: 3)
class Conversation extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String? summary;
  
  @HiveField(3)
  final DateTime createdAt;
  
  @HiveField(4)
  final DateTime updatedAt;
  
  @HiveField(5)
  final bool isActive;
  
  @HiveField(6)
  final List<String> messageIds;
  
  @HiveField(7)
  final ConversationType type;
  
  @HiveField(8)
  final Map<String, dynamic> metadata;

  const Conversation({
    required this.id,
    required this.title,
    this.summary,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.messageIds = const [],
    this.type = ConversationType.spiritual,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        title,
        summary,
        createdAt,
        updatedAt,
        isActive,
        messageIds,
        type,
        metadata,
      ];

  /// Create a copy with updated values
  Conversation copyWith({
    String? id,
    String? title,
    String? summary,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<String>? messageIds,
    ConversationType? type,
    Map<String, dynamic>? metadata,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      messageIds: messageIds ?? this.messageIds,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'messageIds': messageIds,
      'type': type.name,
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      messageIds: List<String>.from(json['messageIds'] as List<dynamic>? ?? []),
      type: ConversationType.values.byName(json['type'] as String? ?? 'spiritual'),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map<dynamic, dynamic>? ?? {}),
    );
  }
}

/// Message type enum
@HiveType(typeId: 9)
enum MessageType {
  @HiveField(0)
  user,
  
  @HiveField(1)
  assistant,
  
  @HiveField(2)
  system,
}

/// Message status enum
@HiveType(typeId: 10)
enum MessageStatus {
  @HiveField(0)
  sending,
  
  @HiveField(1)
  sent,
  
  @HiveField(2)
  failed,
  
  @HiveField(3)
  received,
}

/// Conversation type enum
@HiveType(typeId: 13)
enum ConversationType {
  @HiveField(0)
  spiritual,
  
  @HiveField(1)
  prayer,
  
  @HiveField(2)
  guidance,
  
  @HiveField(3)
  crisis,
}
