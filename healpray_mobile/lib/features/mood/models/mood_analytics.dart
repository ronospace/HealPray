import 'package:freezed_annotation/freezed_annotation.dart';
import 'mood_entry.dart';
import 'mood_prediction.dart';

part 'mood_analytics.freezed.dart';
part 'mood_analytics.g.dart';

@freezed
class MoodAnalytics with _$MoodAnalytics {
  const factory MoodAnalytics({
    required DateRange period,
    required double averageMood,
    required Map<int, double> moodDistribution,
    required List<MoodTrend> trends,
    required List<MoodPattern> patterns,
    required List<MoodInsight> insights,
    required List<MoodCorrelation> correlations,
    required List<MoodRecommendation> recommendations,
    required List<MoodPrediction> predictions,
    @Default(0) int totalEntries,
    @Default(0.0) double averageMoodScore,
    @Default(0) int currentStreak,
    @Default(0.0) double positivityRate,
    @Default({}) Map<String, int> emotionCategoryCounts,
    @Default({}) Map<String, int> triggerCategoryCounts,
  }) = _MoodAnalytics;

  factory MoodAnalytics.fromJson(Map<String, dynamic> json) => _$MoodAnalyticsFromJson(json);
  
  factory MoodAnalytics.empty() => MoodAnalytics(
    period: DateRange(start: DateTime.now(), end: DateTime.now()),
    averageMood: 0.0,
    moodDistribution: {},
    trends: [],
    patterns: [],
    insights: [],
    correlations: [],
    recommendations: [],
    predictions: [],
  );
}

@freezed
class DateRange with _$DateRange {
  const factory DateRange({
    required DateTime start,
    required DateTime end,
  }) = _DateRange;

  factory DateRange.fromJson(Map<String, dynamic> json) => _$DateRangeFromJson(json);
}

@freezed
class MoodTrend with _$MoodTrend {
  const factory MoodTrend({
    required TrendPeriod period,
    required Map<DateTime, double> values,
    required double slope,
    required double significance,
  }) = _MoodTrend;

  factory MoodTrend.fromJson(Map<String, dynamic> json) => _$MoodTrendFromJson(json);
}

enum TrendPeriod {
  daily,
  weekly,
  monthly,
  yearly,
}

@freezed
class MoodPattern with _$MoodPattern {
  const factory MoodPattern({
    required PatternType type,
    required String description,
    required double strength,
    required Map<dynamic, dynamic> data,
  }) = _MoodPattern;

  factory MoodPattern.fromJson(Map<String, dynamic> json) => _$MoodPatternFromJson(json);
}

enum PatternType {
  timeOfDay,
  dayOfWeek,
  weather,
  activity,
  social,
  sleep,
  exercise,
}

@freezed
class MoodInsight with _$MoodInsight {
  const factory MoodInsight({
    required String title,
    required String description,
    required InsightCategory category,
    required InsightSeverity severity,
    required bool actionable,
    DateTime? timestamp,
    List<String>? tags,
  }) = _MoodInsight;

  factory MoodInsight.fromJson(Map<String, dynamic> json) => _$MoodInsightFromJson(json);
}

enum InsightCategory {
  trend,
  pattern,
  recommendation,
  warning,
  achievement,
}

enum InsightSeverity {
  low,
  medium,
  high,
}

@freezed
class MoodCorrelation with _$MoodCorrelation {
  const factory MoodCorrelation({
    required String factor,
    required double strength,
    required String description,
    required Map<String, double> data,
  }) = _MoodCorrelation;

  factory MoodCorrelation.fromJson(Map<String, dynamic> json) => _$MoodCorrelationFromJson(json);
}

@freezed
class MoodRecommendation with _$MoodRecommendation {
  const factory MoodRecommendation({
    required String title,
    required String description,
    required RecommendationPriority priority,
    required RecommendationCategory category,
    required List<String> actions,
    DateTime? createdAt,
    bool? completed,
  }) = _MoodRecommendation;

  factory MoodRecommendation.fromJson(Map<String, dynamic> json) => _$MoodRecommendationFromJson(json);
}

enum RecommendationPriority {
  low,
  medium,
  high,
  urgent,
}

enum RecommendationCategory {
  activity,
  lifestyle,
  social,
  professional,
  spiritual,
  health,
}
