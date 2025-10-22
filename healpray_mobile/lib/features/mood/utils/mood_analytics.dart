import 'dart:math' as math;

import '../models/simple_mood_entry.dart';
import '../services/mood_service.dart';

/// Utility class for mood analytics and pattern recognition
class MoodAnalytics {
  /// Calculate weekly mood patterns
  static WeeklyMoodPattern calculateWeeklyPattern(
      List<SimpleMoodEntry> entries) {
    final dayOfWeekScores = <int, List<int>>{
      1: [], // Monday
      2: [], // Tuesday
      3: [], // Wednesday
      4: [], // Thursday
      5: [], // Friday
      6: [], // Saturday
      7: [], // Sunday
    };

    // Group scores by day of week
    for (final entry in entries) {
      final dayOfWeek = entry.timestamp.weekday;
      dayOfWeekScores[dayOfWeek]!.add(entry.score);
    }

    // Calculate averages for each day
    final dailyAverages = <int, double>{};
    final dailyCounts = <int, int>{};

    for (int day = 1; day <= 7; day++) {
      final scores = dayOfWeekScores[day]!;
      if (scores.isNotEmpty) {
        dailyAverages[day] =
            scores.fold<double>(0, (sum, score) => sum + score) / scores.length;
        dailyCounts[day] = scores.length;
      } else {
        dailyAverages[day] = 0.0;
        dailyCounts[day] = 0;
      }
    }

    // Find best and worst days
    final sortedDays = dailyAverages.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final bestDay = sortedDays.isNotEmpty ? sortedDays.first.key : null;
    final worstDay = sortedDays.isNotEmpty ? sortedDays.last.key : null;

    return WeeklyMoodPattern(
      dailyAverages: dailyAverages,
      dailyCounts: dailyCounts,
      bestDay: bestDay,
      worstDay: worstDay,
    );
  }

  /// Calculate hourly mood patterns
  static HourlyMoodPattern calculateHourlyPattern(
      List<SimpleMoodEntry> entries) {
    final hourlyScores = <int, List<int>>{};

    // Initialize all hours
    for (int hour = 0; hour < 24; hour++) {
      hourlyScores[hour] = [];
    }

    // Group scores by hour
    for (final entry in entries) {
      final hour = entry.timestamp.hour;
      hourlyScores[hour]!.add(entry.score);
    }

    // Calculate averages for each hour
    final hourlyAverages = <int, double>{};
    for (int hour = 0; hour < 24; hour++) {
      final scores = hourlyScores[hour]!;
      if (scores.isNotEmpty) {
        hourlyAverages[hour] =
            scores.fold<double>(0, (sum, score) => sum + score) / scores.length;
      } else {
        hourlyAverages[hour] = 0.0;
      }
    }

    // Find peak hours
    final peakHours = hourlyAverages.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return HourlyMoodPattern(
      hourlyAverages: hourlyAverages,
      peakHours: peakHours.take(3).map((e) => e.key).toList(),
      lowHours: peakHours.reversed.take(3).map((e) => e.key).toList(),
    );
  }

  /// Analyze emotion co-occurrence patterns
  static EmotionCorrelation analyzeEmotionCorrelations(
      List<SimpleMoodEntry> entries) {
    final emotionPairs = <String, Map<String, int>>{};
    final emotionScores = <String, List<int>>{};

    // Analyze co-occurring emotions and their scores
    for (final entry in entries) {
      final emotions = entry.emotions;

      // Track emotion scores
      for (final emotion in emotions) {
        emotionScores.putIfAbsent(emotion, () => []).add(entry.score);
      }

      // Track emotion pairs
      for (int i = 0; i < emotions.length; i++) {
        for (int j = i + 1; j < emotions.length; j++) {
          final emotion1 = emotions[i];
          final emotion2 = emotions[j];

          emotionPairs.putIfAbsent(emotion1, () => {});
          emotionPairs.putIfAbsent(emotion2, () => {});

          emotionPairs[emotion1]![emotion2] =
              (emotionPairs[emotion1]![emotion2] ?? 0) + 1;
          emotionPairs[emotion2]![emotion1] =
              (emotionPairs[emotion2]![emotion1] ?? 0) + 1;
        }
      }
    }

    // Calculate emotion average scores
    final emotionAverages = <String, double>{};
    for (final entry in emotionScores.entries) {
      final emotion = entry.key;
      final scores = entry.value;
      emotionAverages[emotion] =
          scores.fold<double>(0, (sum, score) => sum + score) / scores.length;
    }

    // Find most common emotion pairs
    final commonPairs = <EmotionPair>[];
    for (final entry in emotionPairs.entries) {
      final emotion1 = entry.key;
      for (final pairEntry in entry.value.entries) {
        final emotion2 = pairEntry.key;
        final count = pairEntry.value;

        // Avoid duplicates by only adding pairs where emotion1 < emotion2 alphabetically
        if (emotion1.compareTo(emotion2) < 0) {
          commonPairs.add(EmotionPair(emotion1, emotion2, count));
        }
      }
    }

    commonPairs.sort((a, b) => b.count.compareTo(a.count));

    return EmotionCorrelation(
      emotionAverages: emotionAverages,
      commonPairs: commonPairs.take(5).toList(),
    );
  }

  /// Calculate mood volatility (how much mood varies)
  static MoodVolatility calculateMoodVolatility(List<SimpleMoodEntry> entries,
      {int days = 30}) {
    if (entries.length < 2) {
      return MoodVolatility(
        standardDeviation: 0.0,
        volatilityLevel: VolatilityLevel.stable,
        largestChange: 0,
        averageChange: 0.0,
      );
    }

    // Sort entries by timestamp
    final sortedEntries = List<SimpleMoodEntry>.from(entries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final scores = sortedEntries.map((e) => e.score).toList();

    // Calculate standard deviation
    final mean =
        scores.fold<double>(0, (sum, score) => sum + score) / scores.length;
    final squaredDiffs = scores.map((score) => (score - mean) * (score - mean));
    final variance =
        squaredDiffs.fold<double>(0, (sum, diff) => sum + diff) / scores.length;
    final standardDeviation = variance > 0 ? math.sqrt(variance) : 0.0;

    // Calculate day-to-day changes
    final changes = <int>[];
    for (int i = 1; i < scores.length; i++) {
      changes.add((scores[i] - scores[i - 1]).abs());
    }

    final largestChange = changes.isNotEmpty ? changes.reduce(math.max) : 0;
    final averageChange = changes.isNotEmpty
        ? changes.fold<double>(0, (sum, change) => sum + change) /
            changes.length
        : 0.0;

    // Determine volatility level
    VolatilityLevel level;
    if (standardDeviation < 1.0) {
      level = VolatilityLevel.stable;
    } else if (standardDeviation < 2.0) {
      level = VolatilityLevel.moderate;
    } else {
      level = VolatilityLevel.high;
    }

    return MoodVolatility(
      standardDeviation: standardDeviation,
      volatilityLevel: level,
      largestChange: largestChange,
      averageChange: averageChange,
    );
  }

  /// Identify mood patterns and triggers
  static List<MoodPattern> identifyPatterns(List<SimpleMoodEntry> entries) {
    final patterns = <MoodPattern>[];

    if (entries.length < 5) return patterns;

    // Analyze trigger patterns
    final triggerMoodScores = <String, List<int>>{};
    for (final entry in entries) {
      final triggers = entry.metadata['triggers'] as List<dynamic>? ?? [];
      for (final trigger in triggers) {
        final triggerStr = trigger.toString();
        triggerMoodScores.putIfAbsent(triggerStr, () => []).add(entry.score);
      }
    }

    // Find triggers that correlate with high/low moods
    for (final entry in triggerMoodScores.entries) {
      final trigger = entry.key;
      final scores = entry.value;

      if (scores.length < 3) continue;

      final averageScore =
          scores.fold<double>(0, (sum, score) => sum + score) / scores.length;
      final overallAverage =
          entries.fold<double>(0, (sum, entry) => sum + entry.score) /
              entries.length;

      if (averageScore > overallAverage + 1.0) {
        patterns.add(MoodPattern(
          type: PatternType.positiveCorrelation,
          description: 'You tend to feel better when dealing with "$trigger"',
          trigger: trigger,
          averageScore: averageScore,
          confidence: _calculateConfidence(scores.length, entries.length),
        ));
      } else if (averageScore < overallAverage - 1.0) {
        patterns.add(MoodPattern(
          type: PatternType.negativeCorrelation,
          description: 'You tend to feel worse when dealing with "$trigger"',
          trigger: trigger,
          averageScore: averageScore,
          confidence: _calculateConfidence(scores.length, entries.length),
        ));
      }
    }

    // Sort by confidence
    patterns.sort((a, b) => b.confidence.compareTo(a.confidence));

    return patterns.take(5).toList();
  }

  /// Generate mood insights based on analytics
  static List<MoodInsight> generateInsights(List<SimpleMoodEntry> entries) {
    final insights = <MoodInsight>[];

    if (entries.isEmpty) return insights;

    // Weekly pattern insights
    final weeklyPattern = calculateWeeklyPattern(entries);
    if (weeklyPattern.bestDay != null && weeklyPattern.worstDay != null) {
      insights.add(MoodInsight(
        type: MoodInsightType.pattern,
        title: 'Weekly Pattern',
        description:
            'You tend to feel best on ${_getDayName(weeklyPattern.bestDay!)}s and lowest on ${_getDayName(weeklyPattern.worstDay!)}s.',
        icon: '📅',
      ));
    }

    // Volatility insights
    final volatility = calculateMoodVolatility(entries);
    if (volatility.volatilityLevel == VolatilityLevel.high) {
      insights.add(MoodInsight(
        type: MoodInsightType.concern,
        title: 'Mood Variability',
        description:
            'Your mood has been quite variable lately. Consider tracking what might be causing these changes.',
        icon: '🌊',
      ));
    } else if (volatility.volatilityLevel == VolatilityLevel.stable) {
      insights.add(MoodInsight(
        type: MoodInsightType.positive,
        title: 'Emotional Stability',
        description:
            'Your mood has been quite stable recently. That\'s a great sign of emotional well-being!',
        icon: '⚖️',
      ));
    }

    // Pattern-based insights
    final patterns = identifyPatterns(entries);
    for (final pattern in patterns.take(2)) {
      insights.add(MoodInsight(
        type: pattern.type == PatternType.positiveCorrelation
            ? MoodInsightType.positive
            : MoodInsightType.recommendation,
        title: 'Pattern Insight',
        description: pattern.description,
        icon: pattern.type == PatternType.positiveCorrelation ? '✨' : '💡',
      ));
    }

    return insights;
  }

  static double _calculateConfidence(int sampleSize, int totalSize) {
    final ratio = sampleSize / totalSize;
    if (ratio > 0.3 && sampleSize > 5) return 0.9;
    if (ratio > 0.2 && sampleSize > 3) return 0.7;
    if (ratio > 0.1 && sampleSize > 2) return 0.5;
    return 0.3;
  }

  static String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }
}

/// Weekly mood pattern data
class WeeklyMoodPattern {
  final Map<int, double> dailyAverages;
  final Map<int, int> dailyCounts;
  final int? bestDay;
  final int? worstDay;

  const WeeklyMoodPattern({
    required this.dailyAverages,
    required this.dailyCounts,
    this.bestDay,
    this.worstDay,
  });
}

/// Hourly mood pattern data
class HourlyMoodPattern {
  final Map<int, double> hourlyAverages;
  final List<int> peakHours;
  final List<int> lowHours;

  const HourlyMoodPattern({
    required this.hourlyAverages,
    required this.peakHours,
    required this.lowHours,
  });
}

/// Emotion correlation analysis
class EmotionCorrelation {
  final Map<String, double> emotionAverages;
  final List<EmotionPair> commonPairs;

  const EmotionCorrelation({
    required this.emotionAverages,
    required this.commonPairs,
  });
}

/// Emotion pair data
class EmotionPair {
  final String emotion1;
  final String emotion2;
  final int count;

  const EmotionPair(this.emotion1, this.emotion2, this.count);
}

/// Mood volatility analysis
class MoodVolatility {
  final double standardDeviation;
  final VolatilityLevel volatilityLevel;
  final int largestChange;
  final double averageChange;

  const MoodVolatility({
    required this.standardDeviation,
    required this.volatilityLevel,
    required this.largestChange,
    required this.averageChange,
  });
}

/// Volatility levels
enum VolatilityLevel {
  stable,
  moderate,
  high,
}

/// Mood pattern identification
class MoodPattern {
  final PatternType type;
  final String description;
  final String? trigger;
  final double averageScore;
  final double confidence;

  const MoodPattern({
    required this.type,
    required this.description,
    this.trigger,
    required this.averageScore,
    required this.confidence,
  });
}

/// Pattern types
enum PatternType {
  positiveCorrelation,
  negativeCorrelation,
  weeklyPattern,
  timePattern,
}
