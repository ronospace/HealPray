import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'prayer.g.dart';

/// Simple Prayer model for AI-generated prayers
@HiveType(typeId: 0)
class Prayer extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String tone;

  @HiveField(5)
  final String length;

  @HiveField(6)
  final String? customIntention;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? updatedAt;

  @HiveField(9)
  final bool isFavorite;

  @HiveField(10)
  final List<String> tags;

  const Prayer({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.tone,
    required this.length,
    this.customIntention,
    required this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        category,
        tone,
        length,
        customIntention,
        createdAt,
        updatedAt,
        isFavorite,
        tags,
      ];

  /// Create a copy with updated values
  Prayer copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    String? tone,
    String? length,
    String? customIntention,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    List<String>? tags,
  }) {
    return Prayer(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tone: tone ?? this.tone,
      length: length ?? this.length,
      customIntention: customIntention ?? this.customIntention,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'tone': tone,
      'length': length,
      'customIntention': customIntention,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isFavorite': isFavorite,
      'tags': tags,
    };
  }

  /// Create from JSON
  factory Prayer.fromJson(Map<String, dynamic> json) {
    return Prayer(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      tone: json['tone'] as String,
      length: json['length'] as String,
      customIntention: json['customIntention'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isFavorite: json['isFavorite'] as bool? ?? false,
      tags: List<String>.from(json['tags'] as List<dynamic>? ?? []),
    );
  }
}
