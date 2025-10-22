import 'package:freezed_annotation/freezed_annotation.dart';
import 'mood_enums.dart';

part 'mood_analytics_models.freezed.dart';
part 'mood_analytics_models.g.dart';

/// Represents a mood trend over time
@freezed
class MoodTrend with _$MoodTrend {
  const factory MoodTrend({
    required TrendPeriod period,
    required DateTime startDate,
    required DateTime endDate,
    required double slope,
    required double strength,
    required String description,
    required List<double> values,
  }) = _MoodTrend;

  factory MoodTrend.fromJson(Map<String, Object?> json) =>
      _$MoodTrendFromJson(json);
}

/// Represents a mood pattern
@freezed
class MoodPattern with _$MoodPattern {
  const factory MoodPattern({
    required PatternType type,
    required String description,
    required double strength,
    required String timeFrame,
    Map<String, dynamic>? data,
  }) = _MoodPattern;

  factory MoodPattern.fromJson(Map<String, Object?> json) =>
      _$MoodPatternFromJson(json);
}

/// Represents a mood insight
@freezed
class MoodInsight with _$MoodInsight {
  const factory MoodInsight({
    required String title,
    required String description,
    required InsightCategory category,
    required InsightSeverity severity,
    required DateTime timestamp,
    List<String>? actions,
    Map<String, dynamic>? metadata,
  }) = _MoodInsight;

  factory MoodInsight.fromJson(Map<String, Object?> json) =>
      _$MoodInsightFromJson(json);
}

/// Represents a mood correlation
@freezed
class MoodCorrelation with _$MoodCorrelation {
  const factory MoodCorrelation({
    required String factorName,
    required double correlation,
    required int sampleSize,
    required String description,
    String? interpretation,
  }) = _MoodCorrelation;

  factory MoodCorrelation.fromJson(Map<String, Object?> json) =>
      _$MoodCorrelationFromJson(json);
}

/// Represents a mood recommendation
@freezed
class MoodRecommendation with _$MoodRecommendation {
  const factory MoodRecommendation({
    required String title,
    required String description,
    required RecommendationPriority priority,
    required RecommendationCategory category,
    List<String>? actions,
    String? reasoning,
    Map<String, dynamic>? metadata,
  }) = _MoodRecommendation;

  factory MoodRecommendation.fromJson(Map<String, Object?> json) =>
      _$MoodRecommendationFromJson(json);
}
