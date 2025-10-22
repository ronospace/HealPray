import '../models/simple_mood_entry.dart';
import '../repositories/simple_mood_repository.dart';

/// Service layer for mood tracking business logic
class MoodService {
  static MoodService? _instance;
  static MoodService get instance => _instance ??= MoodService._internal();

  MoodService._internal();

  final SimpleMoodRepository _repository = SimpleMoodRepository.instance;

  /// Save a mood entry
  Future<void> saveMoodEntry(SimpleMoodEntry entry) async {
    await _repository.saveMoodEntry(entry);
  }

  /// Get mood entry by ID
  SimpleMoodEntry? getMoodEntry(String id) {
    return _repository.getMoodEntryById(id);
  }

  /// Get all mood entries
  List<SimpleMoodEntry> getAllMoodEntries() {
    return _repository.getAllMoodEntries();
  }

  /// Get recent mood entries with optional limit
  List<SimpleMoodEntry> getRecentMoodEntries({int days = 30, int? limit}) {
    final entries = _repository.getRecentMoodEntries(days: days);

    if (limit != null && limit > 0) {
      return entries.take(limit).toList();
    }

    return entries;
  }

  /// Get recent entries (async version for compatibility)
  Future<List<SimpleMoodEntry>> getRecentEntries({int limit = 10}) async {
    return getRecentMoodEntries(limit: limit);
  }

  /// Get mood entries for today
  List<SimpleMoodEntry> getTodaysMoodEntries() {
    return _repository.getMoodEntriesForDate(DateTime.now());
  }

  /// Get mood entries for this week
  List<SimpleMoodEntry> getThisWeeksMoodEntries() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return _repository.getMoodEntriesByDateRange(
      startDate: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      endDate:
          DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59),
    );
  }

  /// Get mood entries for this month
  List<SimpleMoodEntry> getThisMonthsMoodEntries() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return _repository.getMoodEntriesByDateRange(
      startDate: startOfMonth,
      endDate: DateTime(
          endOfMonth.year, endOfMonth.month, endOfMonth.day, 23, 59, 59),
    );
  }

  /// Delete a mood entry
  Future<bool> deleteMoodEntry(String id) async {
    return await _repository.deleteMoodEntry(id);
  }

  /// Search mood entries
  List<SimpleMoodEntry> searchMoodEntries({
    String? query,
    List<String>? emotions,
    int? minScore,
    int? maxScore,
  }) {
    return _repository.searchMoodEntries(
      query: query,
      emotions: emotions,
      minScore: minScore,
      maxScore: maxScore,
    );
  }

  /// Get mood statistics for a date range
  MoodStatistics getMoodStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    List<SimpleMoodEntry> entries;

    if (startDate != null && endDate != null) {
      entries = _repository.getMoodEntriesByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } else {
      entries = _repository.getAllMoodEntries();
    }

    if (entries.isEmpty) {
      return MoodStatistics.empty();
    }

    // Calculate basic statistics
    final scores = entries.map((e) => e.score).toList();
    final averageScore =
        scores.fold<double>(0, (sum, score) => sum + score) / scores.length;

    scores.sort();
    final medianScore = scores.length % 2 == 0
        ? (scores[scores.length ~/ 2 - 1] + scores[scores.length ~/ 2]) / 2.0
        : scores[scores.length ~/ 2].toDouble();

    final minScore = scores.first;
    final maxScore = scores.last;

    // Get emotion frequency
    final emotionFrequency = _repository.getEmotionFrequency(
      startDate: startDate,
      endDate: endDate,
    );

    // Get score distribution
    final scoreDistribution = _repository.getMoodScoreDistribution(
      startDate: startDate,
      endDate: endDate,
    );

    // Calculate trends
    final trend = _calculateMoodTrend(entries);

    return MoodStatistics(
      totalEntries: entries.length,
      averageScore: averageScore,
      medianScore: medianScore,
      minScore: minScore,
      maxScore: maxScore,
      emotionFrequency: emotionFrequency,
      scoreDistribution: scoreDistribution,
      trend: trend,
      dateRange: DateRange(startDate, endDate),
    );
  }

  /// Get mood insights based on patterns
  List<MoodInsight> getMoodInsights({int days = 30}) {
    final entries = _repository.getRecentMoodEntries(days: days);
    final insights = <MoodInsight>[];

    if (entries.isEmpty) return insights;

    // Average mood insight
    final averageScore =
        entries.fold<double>(0, (sum, entry) => sum + entry.score) /
            entries.length;
    insights.add(MoodInsight(
      type: MoodInsightType.average,
      title: 'Your Average Mood',
      description:
          'Over the last $days days, your average mood score is ${averageScore.toStringAsFixed(1)}/10.',
      score: averageScore,
      icon: '📊',
    ));

    // Most common emotion
    final emotionFreq = _repository.getEmotionFrequency(limit: 1);
    if (emotionFreq.isNotEmpty) {
      final topEmotion = emotionFreq.entries.first;
      insights.add(MoodInsight(
        type: MoodInsightType.emotion,
        title: 'Most Common Emotion',
        description:
            'You\'ve been feeling "${topEmotion.key}" most often (${topEmotion.value} times).',
        emotion: topEmotion.key,
        icon: '😊',
      ));
    }

    // Trend analysis
    final trend = _calculateMoodTrend(entries);
    if (trend != MoodTrend.stable) {
      insights.add(MoodInsight(
        type: MoodInsightType.trend,
        title: 'Mood Trend',
        description: trend == MoodTrend.improving
            ? 'Your mood has been improving lately! Keep up the positive momentum.'
            : 'Your mood has been declining. Consider reaching out for support or engaging in activities you enjoy.',
        trend: trend,
        icon: trend == MoodTrend.improving ? '📈' : '📉',
      ));
    }

    // High mood days
    final highMoodEntries = entries.where((e) => e.score >= 8).length;
    if (highMoodEntries > 0) {
      insights.add(MoodInsight(
        type: MoodInsightType.positive,
        title: 'Great Days',
        description:
            'You\'ve had $highMoodEntries great days (8+ mood score) in the last $days days!',
        count: highMoodEntries,
        icon: '🌟',
      ));
    }

    // Low mood pattern detection
    final lowMoodEntries = entries.where((e) => e.score <= 3).length;
    if (lowMoodEntries > days * 0.3) {
      // More than 30% low mood days
      insights.add(MoodInsight(
        type: MoodInsightType.concern,
        title: 'Support Reminder',
        description:
            'You\'ve had several challenging days recently. Remember that it\'s okay to seek support and practice self-care.',
        count: lowMoodEntries,
        icon: '💙',
      ));
    }

    return insights;
  }

  /// Check if user has logged mood today
  bool hasLoggedMoodToday() {
    final todaysEntries = getTodaysMoodEntries();
    return todaysEntries.isNotEmpty;
  }

  /// Get streak of consecutive days with mood entries
  int getMoodLoggingStreak() {
    final entries = _repository.getAllMoodEntries();
    if (entries.isEmpty) return 0;

    // Group entries by date
    final entriesByDate = <String, List<SimpleMoodEntry>>{};
    for (final entry in entries) {
      final dateKey =
          '${entry.timestamp.year}-${entry.timestamp.month}-${entry.timestamp.day}';
      entriesByDate.putIfAbsent(dateKey, () => []).add(entry);
    }

    // Count consecutive days from today backwards
    int streak = 0;
    final today = DateTime.now();

    for (int i = 0; i < 365; i++) {
      // Check up to a year
      final checkDate = today.subtract(Duration(days: i));
      final dateKey = '${checkDate.year}-${checkDate.month}-${checkDate.day}';

      if (entriesByDate.containsKey(dateKey)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Get recommended check-in time based on user patterns
  TimeOfDay? getRecommendedCheckInTime() {
    final entries = _repository.getRecentMoodEntries(days: 30);
    if (entries.isEmpty) return null;

    // Find the most common hour for mood entries
    final hourCounts = <int, int>{};
    for (final entry in entries) {
      final hour = entry.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    final mostCommonHour =
        hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return TimeOfDay(hour: mostCommonHour, minute: 0);
  }

  /// Calculate mood trend from entries
  MoodTrend _calculateMoodTrend(List<SimpleMoodEntry> entries) {
    if (entries.length < 3) return MoodTrend.stable;

    // Sort by timestamp (oldest first)
    final sortedEntries = List<SimpleMoodEntry>.from(entries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate trend using linear regression approach
    final recentEntries = sortedEntries.length > 10
        ? sortedEntries.sublist(sortedEntries.length - 10)
        : sortedEntries;

    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
    final n = recentEntries.length;

    for (int i = 0; i < n; i++) {
      final x = i.toDouble();
      final y = recentEntries[i].score.toDouble();

      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumXX += x * x;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);

    // Determine trend based on slope
    if (slope > 0.1) return MoodTrend.improving;
    if (slope < -0.1) return MoodTrend.declining;
    return MoodTrend.stable;
  }

  /// Export mood data
  String exportMoodData({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _repository.exportToJson(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Import mood data
  Future<int> importMoodData(String jsonData) async {
    return await _repository.importFromJson(jsonData);
  }

  /// Initialize the service
  Future<void> initialize() async {
    await _repository.loadFromStorage();
  }
}

/// Mood statistics data class
class MoodStatistics {
  final int totalEntries;
  final double averageScore;
  final double medianScore;
  final int minScore;
  final int maxScore;
  final Map<String, int> emotionFrequency;
  final Map<int, int> scoreDistribution;
  final MoodTrend trend;
  final DateRange dateRange;

  const MoodStatistics({
    required this.totalEntries,
    required this.averageScore,
    required this.medianScore,
    required this.minScore,
    required this.maxScore,
    required this.emotionFrequency,
    required this.scoreDistribution,
    required this.trend,
    required this.dateRange,
  });

  factory MoodStatistics.empty() {
    return const MoodStatistics(
      totalEntries: 0,
      averageScore: 0.0,
      medianScore: 0.0,
      minScore: 0,
      maxScore: 0,
      emotionFrequency: {},
      scoreDistribution: {},
      trend: MoodTrend.stable,
      dateRange: DateRange(null, null),
    );
  }
}

/// Date range for statistics
class DateRange {
  final DateTime? start;
  final DateTime? end;

  const DateRange(this.start, this.end);
}

/// Mood insight for user guidance
class MoodInsight {
  final MoodInsightType type;
  final String title;
  final String description;
  final String icon;
  final double? score;
  final String? emotion;
  final int? count;
  final MoodTrend? trend;

  const MoodInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    this.score,
    this.emotion,
    this.count,
    this.trend,
  });
}

/// Types of mood insights
enum MoodInsightType {
  average,
  emotion,
  trend,
  positive,
  concern,
  pattern,
  recommendation,
}

/// Mood trend direction
enum MoodTrend {
  improving,
  stable,
  declining,
}

/// Time of day for scheduling
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }
}
