import 'dart:convert';

import '../models/simple_mood_entry.dart';
import '../services/mood_service.dart';
import '../utils/mood_analytics.dart';

/// Utility class for exporting mood data in various formats
class MoodExporter {
  
  /// Export mood entries to JSON format
  static String exportToJson({
    required List<SimpleMoodEntry> entries,
    DateTime? startDate,
    DateTime? endDate,
    bool includeAnalytics = true,
  }) {
    final exportData = <String, dynamic>{
      'export_info': {
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0',
        'format': 'json',
        'total_entries': entries.length,
        'date_range': {
          'start': startDate?.toIso8601String(),
          'end': endDate?.toIso8601String(),
        },
      },
      'mood_entries': entries.map((entry) => entry.toJson()).toList(),
    };
    
    if (includeAnalytics && entries.isNotEmpty) {
      exportData['analytics'] = _generateAnalyticsData(entries);
    }
    
    return jsonEncode(exportData);
  }
  
  /// Export mood entries to CSV format
  static String exportToCSV({
    required List<SimpleMoodEntry> entries,
    bool includeMetadata = true,
  }) {
    if (entries.isEmpty) {
      return 'No data to export';
    }
    
    final buffer = StringBuffer();
    
    // CSV Header
    final headers = [
      'ID',
      'Date',
      'Time',
      'Score',
      'Emotions',
      'Notes',
    ];
    
    if (includeMetadata) {
      headers.addAll(['Triggers', 'Activities']);
    }
    
    buffer.writeln(headers.join(','));
    
    // CSV Rows
    for (final entry in entries) {
      final row = <String>[];
      
      row.add(_escapeCsvField(entry.id));
      row.add(_formatDate(entry.timestamp));
      row.add(_formatTime(entry.timestamp));
      row.add(entry.score.toString());
      row.add(_escapeCsvField(entry.emotions.join('; ')));
      row.add(_escapeCsvField(entry.notes ?? ''));
      
      if (includeMetadata) {
        final triggers = entry.metadata['triggers'] as List<dynamic>? ?? [];
        final activities = entry.metadata['activities'] as List<dynamic>? ?? [];
        
        row.add(_escapeCsvField(triggers.join('; ')));
        row.add(_escapeCsvField(activities.join('; ')));
      }
      
      buffer.writeln(row.join(','));
    }
    
    return buffer.toString();
  }
  
  /// Export detailed analytics report
  static String exportAnalyticsReport({
    required List<SimpleMoodEntry> entries,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (entries.isEmpty) {
      return 'No data available for analytics report';
    }
    
    final buffer = StringBuffer();
    final dateRangeStr = _formatDateRange(startDate, endDate);
    
    buffer.writeln('HEALPRAY MOOD ANALYTICS REPORT');
    buffer.writeln('=' * 50);
    buffer.writeln('Generated: ${DateTime.now().toString()}');
    buffer.writeln('Period: $dateRangeStr');
    buffer.writeln('Total Entries: ${entries.length}');
    buffer.writeln();
    
    // Basic Statistics
    final stats = MoodService.instance.getMoodStatistics(
      startDate: startDate,
      endDate: endDate,
    );
    
    buffer.writeln('OVERALL STATISTICS');
    buffer.writeln('-' * 20);
    buffer.writeln('Average Mood Score: ${stats.averageScore.toStringAsFixed(1)}/10');
    buffer.writeln('Median Mood Score: ${stats.medianScore.toStringAsFixed(1)}/10');
    buffer.writeln('Highest Score: ${stats.maxScore}/10');
    buffer.writeln('Lowest Score: ${stats.minScore}/10');
    buffer.writeln();
    
    // Mood Distribution
    buffer.writeln('MOOD SCORE DISTRIBUTION');
    buffer.writeln('-' * 25);
    for (int score = 10; score >= 1; score--) {
      final count = stats.scoreDistribution[score] ?? 0;
      final percentage = entries.isNotEmpty ? (count / entries.length * 100) : 0;
      final bar = '█' * (percentage ~/ 2);
      buffer.writeln('$score/10: ${count.toString().padLeft(3)} entries (${percentage.toStringAsFixed(1)}%) $bar');
    }
    buffer.writeln();
    
    // Top Emotions
    buffer.writeln('TOP EMOTIONS');
    buffer.writeln('-' * 15);
    final topEmotions = stats.emotionFrequency.entries.take(10).toList();
    for (final entry in topEmotions) {
      final percentage = entries.isNotEmpty ? (entry.value / entries.length * 100) : 0;
      buffer.writeln('${entry.key}: ${entry.value} times (${percentage.toStringAsFixed(1)}%)');
    }
    buffer.writeln();
    
    // Weekly Pattern
    final weeklyPattern = MoodAnalytics.calculateWeeklyPattern(entries);
    buffer.writeln('WEEKLY PATTERNS');
    buffer.writeln('-' * 15);
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    for (int day = 1; day <= 7; day++) {
      final average = weeklyPattern.dailyAverages[day] ?? 0.0;
      final count = weeklyPattern.dailyCounts[day] ?? 0;
      if (count > 0) {
        buffer.writeln('${dayNames[day - 1]}: ${average.toStringAsFixed(1)}/10 (${count} entries)');
      }
    }
    buffer.writeln();
    
    // Volatility Analysis
    final volatility = MoodAnalytics.calculateMoodVolatility(entries);
    buffer.writeln('MOOD STABILITY');
    buffer.writeln('-' * 15);
    buffer.writeln('Volatility Level: ${volatility.volatilityLevel.name.toUpperCase()}');
    buffer.writeln('Standard Deviation: ${volatility.standardDeviation.toStringAsFixed(2)}');
    buffer.writeln('Average Daily Change: ${volatility.averageChange.toStringAsFixed(1)} points');
    buffer.writeln('Largest Daily Change: ${volatility.largestChange} points');
    buffer.writeln();
    
    // Insights
    final insights = MoodService.instance.getMoodInsights(days: 30);
    if (insights.isNotEmpty) {
      buffer.writeln('KEY INSIGHTS');
      buffer.writeln('-' * 12);
      for (final insight in insights.take(5)) {
        buffer.writeln('• ${insight.title}: ${insight.description}');
      }
      buffer.writeln();
    }
    
    // Patterns
    final patterns = MoodAnalytics.identifyPatterns(entries);
    if (patterns.isNotEmpty) {
      buffer.writeln('IDENTIFIED PATTERNS');
      buffer.writeln('-' * 19);
      for (final pattern in patterns.take(5)) {
        buffer.writeln('• ${pattern.description} (Confidence: ${(pattern.confidence * 100).toStringAsFixed(0)}%)');
      }
      buffer.writeln();
    }
    
    buffer.writeln('=' * 50);
    buffer.writeln('Report generated by HealPray - Your Spiritual Wellness Companion');
    
    return buffer.toString();
  }
  
  /// Create a comprehensive export package with multiple formats
  static Map<String, String> createExportPackage({
    required List<SimpleMoodEntry> entries,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return {
      'mood_data.json': exportToJson(
        entries: entries,
        startDate: startDate,
        endDate: endDate,
        includeAnalytics: true,
      ),
      'mood_data.csv': exportToCSV(
        entries: entries,
        includeMetadata: true,
      ),
      'analytics_report.txt': exportAnalyticsReport(
        entries: entries,
        startDate: startDate,
        endDate: endDate,
      ),
    };
  }
  
  /// Export specific time period data
  static Map<String, String> exportTimePeriod({
    required TimePeriod period,
    required List<SimpleMoodEntry> allEntries,
  }) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;
    String periodName;
    
    switch (period) {
      case TimePeriod.thisWeek:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        periodName = 'This Week';
        break;
      case TimePeriod.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        periodName = 'This Month';
        break;
      case TimePeriod.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        startDate = lastMonth;
        endDate = DateTime(now.year, now.month, 0);
        periodName = 'Last Month';
        break;
      case TimePeriod.last30Days:
        startDate = now.subtract(const Duration(days: 30));
        periodName = 'Last 30 Days';
        break;
      case TimePeriod.last90Days:
        startDate = now.subtract(const Duration(days: 90));
        periodName = 'Last 90 Days';
        break;
      case TimePeriod.thisYear:
        startDate = DateTime(now.year, 1, 1);
        periodName = 'This Year';
        break;
    }
    
    // Filter entries for the time period
    final filteredEntries = allEntries.where((entry) {
      return entry.timestamp.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
             entry.timestamp.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();
    
    return {
      'mood_${period.name}.json': exportToJson(
        entries: filteredEntries,
        startDate: startDate,
        endDate: endDate,
        includeAnalytics: true,
      ),
      'mood_${period.name}.csv': exportToCSV(
        entries: filteredEntries,
        includeMetadata: true,
      ),
      'analytics_${period.name}.txt': exportAnalyticsReport(
        entries: filteredEntries,
        startDate: startDate,
        endDate: endDate,
      ),
    };
  }
  
  /// Generate analytics data for JSON export
  static Map<String, dynamic> _generateAnalyticsData(List<SimpleMoodEntry> entries) {
    final stats = MoodService.instance.getMoodStatistics();
    final weeklyPattern = MoodAnalytics.calculateWeeklyPattern(entries);
    final hourlyPattern = MoodAnalytics.calculateHourlyPattern(entries);
    final emotionCorrelation = MoodAnalytics.analyzeEmotionCorrelations(entries);
    final volatility = MoodAnalytics.calculateMoodVolatility(entries);
    final patterns = MoodAnalytics.identifyPatterns(entries);
    final insights = MoodService.instance.getMoodInsights();
    
    return {
      'basic_statistics': {
        'total_entries': stats.totalEntries,
        'average_score': stats.averageScore,
        'median_score': stats.medianScore,
        'min_score': stats.minScore,
        'max_score': stats.maxScore,
        'score_distribution': stats.scoreDistribution,
      },
      'emotion_analysis': {
        'frequency': stats.emotionFrequency,
        'averages': emotionCorrelation.emotionAverages,
        'common_pairs': emotionCorrelation.commonPairs.map((pair) => {
          'emotion1': pair.emotion1,
          'emotion2': pair.emotion2,
          'count': pair.count,
        }).toList(),
      },
      'temporal_patterns': {
        'weekly': {
          'daily_averages': weeklyPattern.dailyAverages,
          'best_day': weeklyPattern.bestDay,
          'worst_day': weeklyPattern.worstDay,
        },
        'hourly': {
          'hourly_averages': hourlyPattern.hourlyAverages,
          'peak_hours': hourlyPattern.peakHours,
          'low_hours': hourlyPattern.lowHours,
        },
      },
      'volatility': {
        'standard_deviation': volatility.standardDeviation,
        'level': volatility.volatilityLevel.name,
        'largest_change': volatility.largestChange,
        'average_change': volatility.averageChange,
      },
      'patterns': patterns.map((pattern) => {
        'type': pattern.type.name,
        'description': pattern.description,
        'trigger': pattern.trigger,
        'average_score': pattern.averageScore,
        'confidence': pattern.confidence,
      }).toList(),
      'insights': insights.map((insight) => {
        'type': insight.type.name,
        'title': insight.title,
        'description': insight.description,
        'icon': insight.icon,
      }).toList(),
    };
  }
  
  /// Escape CSV field to handle commas and quotes
  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      // Escape quotes by doubling them and wrap in quotes
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
  
  /// Format date for CSV export
  static String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
  
  /// Format time for CSV export
  static String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  /// Format date range for reports
  static String _formatDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null && endDate == null) {
      return 'All Time';
    } else if (startDate == null) {
      return 'Up to ${_formatDate(endDate!)}';
    } else if (endDate == null) {
      return 'From ${_formatDate(startDate)}';
    } else {
      return '${_formatDate(startDate)} to ${_formatDate(endDate)}';
    }
  }
}

/// Time periods for export
enum TimePeriod {
  thisWeek,
  thisMonth,
  lastMonth,
  last30Days,
  last90Days,
  thisYear,
}

/// Export format options
enum ExportFormat {
  json,
  csv,
  report,
  all,
}

/// Export configuration
class ExportConfig {
  final ExportFormat format;
  final bool includeAnalytics;
  final bool includeMetadata;
  final TimePeriod? timePeriod;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  
  const ExportConfig({
    required this.format,
    this.includeAnalytics = true,
    this.includeMetadata = true,
    this.timePeriod,
    this.customStartDate,
    this.customEndDate,
  });
}

/// Export result
class ExportResult {
  final Map<String, String> files;
  final int totalEntries;
  final DateTime exportTimestamp;
  final String? errorMessage;
  
  const ExportResult({
    required this.files,
    required this.totalEntries,
    required this.exportTimestamp,
    this.errorMessage,
  });
  
  bool get isSuccess => errorMessage == null;
}
