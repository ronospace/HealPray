import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'scripture.freezed.dart';
part 'scripture.g.dart';

/// Bible book categories
@HiveType(typeId: 60)
enum ScriptureCategory {
  @HiveField(0)
  oldTestament,
  @HiveField(1)
  newTestament,
  @HiveField(2)
  psalms,
  @HiveField(3)
  proverbs,
  @HiveField(4)
  gospels,
  @HiveField(5)
  epistles,
}

/// Scripture themes/topics
@HiveType(typeId: 61)
enum ScriptureTheme {
  @HiveField(0)
  hope,
  @HiveField(1)
  peace,
  @HiveField(2)
  love,
  @HiveField(3)
  faith,
  @HiveField(4)
  strength,
  @HiveField(5)
  comfort,
  @HiveField(6)
  guidance,
  @HiveField(7)
  forgiveness,
  @HiveField(8)
  gratitude,
  @HiveField(9)
  healing,
  @HiveField(10)
  protection,
  @HiveField(11)
  wisdom,
  @HiveField(12)
  anxiety,
  @HiveField(13)
  fear,
  @HiveField(14)
  doubt,
  @HiveField(15)
  grief,
  @HiveField(16)
  anger,
  @HiveField(17)
  joy,
  @HiveField(18)
  prayer,
  @HiveField(19)
  trust,
  @HiveField(20)
  perseverance,
  @HiveField(21)
  courage,
}

/// Scripture data model
@freezed
@HiveType(typeId: 62)
class Scripture with _$Scripture {
  const factory Scripture({
    @HiveField(0) required String id,
    @HiveField(1) required String book,
    @HiveField(2) required int chapter,
    @HiveField(3) required String verse,
    @HiveField(4) required String text,
    @HiveField(5) required String version,
    @HiveField(6)
    @Default(ScriptureCategory.newTestament)
    ScriptureCategory category,
    @HiveField(7) @Default([]) List<ScriptureTheme> themes,
    @HiveField(8) @Default([]) List<String> keywords,
    @HiveField(9) String? context,
    @HiveField(10) String? reflection,
    @HiveField(11) @Default([]) List<String> relatedVerses,
    @HiveField(12) @Default(false) bool isFavorite,
    @HiveField(13) @Default(0) int readCount,
    @HiveField(14) DateTime? lastRead,
    @HiveField(15) @Default({}) Map<String, dynamic> metadata,
  }) = _Scripture;

  factory Scripture.fromJson(Map<String, dynamic> json) =>
      _$ScriptureFromJson(json);
}

/// User's scripture reading entry
@freezed
@HiveType(typeId: 63)
class ScriptureReadingEntry with _$ScriptureReadingEntry {
  const factory ScriptureReadingEntry({
    @HiveField(0) required String id,
    @HiveField(1) required String scriptureId,
    @HiveField(2) required String userId,
    @HiveField(3) required DateTime timestamp,
    @HiveField(4) @Default(0) int moodBefore,
    @HiveField(5) @Default(0) int moodAfter,
    @HiveField(6) String? personalReflection,
    @HiveField(7) String? prayer,
    @HiveField(8) @Default([]) List<String> insights,
    @HiveField(9) @Default([]) List<String> applications,
    @HiveField(10) @Default(0) int rating,
    @HiveField(11) @Default(false) bool shared,
    @HiveField(12) @Default({}) Map<String, dynamic> metadata,
  }) = _ScriptureReadingEntry;

  factory ScriptureReadingEntry.fromJson(Map<String, dynamic> json) =>
      _$ScriptureReadingEntryFromJson(json);
}

extension ScriptureExtensions on Scripture {
  /// Get full reference (e.g., "John 3:16")
  String get reference => '$book $chapter:$verse';

  /// Get formatted reference with version
  String get fullReference => '$reference ($version)';

  /// Get display name for category
  String get categoryDisplayName {
    switch (category) {
      case ScriptureCategory.oldTestament:
        return 'Old Testament';
      case ScriptureCategory.newTestament:
        return 'New Testament';
      case ScriptureCategory.psalms:
        return 'Psalms';
      case ScriptureCategory.proverbs:
        return 'Proverbs';
      case ScriptureCategory.gospels:
        return 'Gospels';
      case ScriptureCategory.epistles:
        return 'Epistles';
    }
  }

  /// Get primary theme display name
  String get primaryThemeDisplayName {
    if (themes.isEmpty) return 'General';
    return themes.first.displayName;
  }

  /// Check if scripture matches search query
  bool matchesQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return reference.toLowerCase().contains(lowerQuery) ||
        text.toLowerCase().contains(lowerQuery) ||
        keywords.any((keyword) => keyword.toLowerCase().contains(lowerQuery)) ||
        themes.any(
            (theme) => theme.displayName.toLowerCase().contains(lowerQuery));
  }

  /// Get shareable text
  String get shareableText {
    return '"$text"\n\n$fullReference';
  }

  /// Check if this verse is suitable for the given mood themes
  bool isSuitableForThemes(List<ScriptureTheme> targetThemes) {
    return themes.any((theme) => targetThemes.contains(theme));
  }

  /// Get estimated reading time in seconds
  int get estimatedReadingTimeSeconds {
    final wordCount = text.split(' ').length;
    const averageWordsPerSecond = 3; // Slow, contemplative reading
    return (wordCount / averageWordsPerSecond).ceil();
  }
}

extension ScriptureThemeExtensions on ScriptureTheme {
  /// Get display name for theme
  String get displayName {
    switch (this) {
      case ScriptureTheme.hope:
        return 'Hope';
      case ScriptureTheme.peace:
        return 'Peace';
      case ScriptureTheme.love:
        return 'Love';
      case ScriptureTheme.faith:
        return 'Faith';
      case ScriptureTheme.strength:
        return 'Strength';
      case ScriptureTheme.comfort:
        return 'Comfort';
      case ScriptureTheme.guidance:
        return 'Guidance';
      case ScriptureTheme.forgiveness:
        return 'Forgiveness';
      case ScriptureTheme.gratitude:
        return 'Gratitude';
      case ScriptureTheme.healing:
        return 'Healing';
      case ScriptureTheme.protection:
        return 'Protection';
      case ScriptureTheme.wisdom:
        return 'Wisdom';
      case ScriptureTheme.anxiety:
        return 'Anxiety';
      case ScriptureTheme.fear:
        return 'Fear';
      case ScriptureTheme.doubt:
        return 'Doubt';
      case ScriptureTheme.grief:
        return 'Grief';
      case ScriptureTheme.anger:
        return 'Anger';
      case ScriptureTheme.joy:
        return 'Joy';
      case ScriptureTheme.prayer:
        return 'Prayer';
      case ScriptureTheme.trust:
        return 'Trust';
      case ScriptureTheme.perseverance:
        return 'Perseverance';
      case ScriptureTheme.courage:
        return 'Courage';
    }
  }

  /// Get emoji icon for theme
  String get icon {
    switch (this) {
      case ScriptureTheme.hope:
        return '🌟';
      case ScriptureTheme.peace:
        return '☮️';
      case ScriptureTheme.love:
        return '💖';
      case ScriptureTheme.faith:
        return '🙏';
      case ScriptureTheme.strength:
        return '💪';
      case ScriptureTheme.comfort:
        return '🤗';
      case ScriptureTheme.guidance:
        return '🧭';
      case ScriptureTheme.forgiveness:
        return '🕊️';
      case ScriptureTheme.gratitude:
        return '🙏';
      case ScriptureTheme.healing:
        return '💚';
      case ScriptureTheme.protection:
        return '🛡️';
      case ScriptureTheme.wisdom:
        return '📚';
      case ScriptureTheme.anxiety:
        return '😰';
      case ScriptureTheme.fear:
        return '😱';
      case ScriptureTheme.doubt:
        return '🤔';
      case ScriptureTheme.grief:
        return '😢';
      case ScriptureTheme.anger:
        return '😠';
      case ScriptureTheme.joy:
        return '😊';
      case ScriptureTheme.prayer:
        return '🙏';
      case ScriptureTheme.trust:
        return '🤝';
      case ScriptureTheme.perseverance:
        return '⛰️';
      case ScriptureTheme.courage:
        return '🦁';
    }
  }

  /// Get description of the theme
  String get description {
    switch (this) {
      case ScriptureTheme.hope:
        return 'Verses about hope and future promises';
      case ScriptureTheme.peace:
        return 'Finding peace and tranquility in God';
      case ScriptureTheme.love:
        return 'God\'s love and loving others';
      case ScriptureTheme.faith:
        return 'Building and strengthening faith';
      case ScriptureTheme.strength:
        return 'Finding strength in difficult times';
      case ScriptureTheme.comfort:
        return 'Comfort in times of distress';
      case ScriptureTheme.guidance:
        return 'Seeking God\'s direction and wisdom';
      case ScriptureTheme.forgiveness:
        return 'God\'s forgiveness and forgiving others';
      case ScriptureTheme.gratitude:
        return 'Being thankful and expressing gratitude';
      case ScriptureTheme.healing:
        return 'Physical, emotional, and spiritual healing';
      case ScriptureTheme.protection:
        return 'God\'s protection and safety';
      case ScriptureTheme.wisdom:
        return 'Gaining wisdom and understanding';
      case ScriptureTheme.anxiety:
        return 'Overcoming anxiety and worry';
      case ScriptureTheme.fear:
        return 'Conquering fear with faith';
      case ScriptureTheme.doubt:
        return 'Addressing doubt and uncertainty';
      case ScriptureTheme.grief:
        return 'Comfort in times of loss and grief';
      case ScriptureTheme.anger:
        return 'Managing anger and finding peace';
      case ScriptureTheme.joy:
        return 'Finding joy in all circumstances';
      case ScriptureTheme.prayer:
        return 'The power and importance of prayer';
      case ScriptureTheme.trust:
        return 'Trusting in God\'s plan';
      case ScriptureTheme.perseverance:
        return 'Enduring through challenges';
      case ScriptureTheme.courage:
        return 'Finding courage and boldness in faith';
    }
  }

  /// Get related themes
  List<ScriptureTheme> get relatedThemes {
    switch (this) {
      case ScriptureTheme.hope:
        return [
          ScriptureTheme.faith,
          ScriptureTheme.trust,
          ScriptureTheme.peace
        ];
      case ScriptureTheme.peace:
        return [
          ScriptureTheme.comfort,
          ScriptureTheme.hope,
          ScriptureTheme.trust
        ];
      case ScriptureTheme.love:
        return [
          ScriptureTheme.forgiveness,
          ScriptureTheme.comfort,
          ScriptureTheme.joy
        ];
      case ScriptureTheme.faith:
        return [
          ScriptureTheme.trust,
          ScriptureTheme.hope,
          ScriptureTheme.strength
        ];
      case ScriptureTheme.anxiety:
        return [
          ScriptureTheme.peace,
          ScriptureTheme.comfort,
          ScriptureTheme.strength
        ];
      case ScriptureTheme.fear:
        return [
          ScriptureTheme.courage,
          ScriptureTheme.protection,
          ScriptureTheme.faith
        ];
      case ScriptureTheme.grief:
        return [
          ScriptureTheme.comfort,
          ScriptureTheme.healing,
          ScriptureTheme.hope
        ];
      default:
        return [];
    }
  }
}

extension ScriptureReadingEntryExtensions on ScriptureReadingEntry {
  /// Check if mood improved after reading
  bool get moodImproved => moodAfter > moodBefore;

  /// Get mood change amount
  int get moodChange => moodAfter - moodBefore;

  /// Check if entry has personal reflection
  bool get hasReflection => personalReflection?.isNotEmpty == true;

  /// Check if entry has prayer
  bool get hasPrayer => prayer?.isNotEmpty == true;

  /// Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
