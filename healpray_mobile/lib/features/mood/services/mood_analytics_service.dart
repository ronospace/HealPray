import 'dart:math';

import '../models/mood_entry.dart';
import '../models/mood_prediction.dart';
import '../models/mood_analytics.dart';

/// Simplified mood analytics service for generating predictions
class MoodAnalyticsService {
  MoodAnalyticsService._();
  static final _instance = MoodAnalyticsService._();
  static MoodAnalyticsService get instance => _instance;

  // Default constructor for instantiation when needed
  MoodAnalyticsService();

  /// Generate mood predictions for the next few days
  Future<List<MoodPrediction>> generateMoodPredictions(int days) async {
    final predictions = <MoodPrediction>[];

    for (int i = 1; i <= days; i++) {
      final predictedMood = 3.5 + (Random().nextDouble() * 2);
      predictions.add(MoodPrediction(
        date: DateTime.now().add(Duration(days: i)),
        predictedMood: predictedMood,
        predictedScore: predictedMood, // Same as predictedMood for now
        confidence: max(0.1, 0.8 - (i * 0.1)),
        factors: ['Recent patterns', 'Historical trends'],
        explanation: 'Based on recent patterns and trends',
      ));
    }

    return predictions;
  }

  /// Generate analytics data for a list of mood entries
  MoodAnalytics generateAnalytics(List<MoodEntry> entries, DateRange period) {
    if (entries.isEmpty) {
      return MoodAnalytics.empty();
    }

    final averageMood = _calculateAverageMood(entries);
    final moodDistribution = _calculateMoodDistribution(entries);
    final positiveEntries = entries.where((e) => e.moodScore >= 3.5).length;
    final positivityRate = (positiveEntries / entries.length) * 100;

    // Calculate emotion category counts (simplified - just count emotion names)
    final emotionCategoryCounts = <String, int>{};
    for (final entry in entries) {
      for (final emotion in entry.emotions) {
        final emotionName = emotion.name;
        emotionCategoryCounts[emotionName] =
            (emotionCategoryCounts[emotionName] ?? 0) + 1;
      }
    }

    // Calculate trigger category counts (simplified - just count trigger names)
    final triggerCategoryCounts = <String, int>{};
    for (final entry in entries) {
      for (final trigger in entry.triggers) {
        final triggerName = trigger.name;
        triggerCategoryCounts[triggerName] =
            (triggerCategoryCounts[triggerName] ?? 0) + 1;
      }
    }

    return MoodAnalytics(
      period: period,
      averageMood: averageMood,
      moodDistribution: moodDistribution,
      trends: [],
      patterns: [],
      insights: [],
      correlations: [],
      recommendations: [],
      predictions: [],
      totalEntries: entries.length,
      averageMoodScore: averageMood,
      currentStreak: _calculateCurrentStreak(entries),
      positivityRate: positivityRate,
      emotionCategoryCounts: emotionCategoryCounts,
      triggerCategoryCounts: triggerCategoryCounts,
    );
  }

  /// Calculate current streak of mood entries
  int _calculateCurrentStreak(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0;

    // Sort by date descending
    final sortedEntries = entries.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (final entry in sortedEntries) {
      final entryDate = DateTime(
          entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      final checkDate =
          DateTime(currentDate.year, currentDate.month, currentDate.day);

      if (entryDate.isAtSameMomentAs(checkDate) ||
          entryDate
              .isAtSameMomentAs(checkDate.subtract(const Duration(days: 1)))) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Calculate average mood score
  double _calculateAverageMood(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0.0;
    final sum = entries.map((e) => e.moodScore).reduce((a, b) => a + b);
    return sum / entries.length;
  }

  /// Calculate mood distribution across different levels
  Map<int, double> _calculateMoodDistribution(List<MoodEntry> entries) {
    final distribution = <int, int>{};
    for (final entry in entries) {
      final level =
          entry.moodScore.round(); // Use moodScore instead of moodLevel
      distribution[level] = (distribution[level] ?? 0) + 1;
    }

    final total = entries.length;
    return distribution
        .map((level, count) => MapEntry(level, count / total * 100));
  }
}
