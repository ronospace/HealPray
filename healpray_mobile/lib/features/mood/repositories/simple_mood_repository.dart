import 'dart:convert';

import '../models/simple_mood_entry.dart';
import '../../../core/utils/logger.dart';

/// Repository for managing SimpleMoodEntry persistence
/// Currently uses in-memory storage with JSON file backup
class SimpleMoodRepository {
  static SimpleMoodRepository? _instance;
  static SimpleMoodRepository get instance =>
      _instance ??= SimpleMoodRepository._internal();

  SimpleMoodRepository._internal();

  // In-memory storage for mood entries
  final List<SimpleMoodEntry> _moodEntries = [];

  /// Save a new mood entry
  Future<void> saveMoodEntry(SimpleMoodEntry entry) async {
    // Remove existing entry with same ID if it exists
    _moodEntries.removeWhere((e) => e.id == entry.id);

    // Add the new/updated entry
    _moodEntries.add(entry);

    // Sort by timestamp (most recent first)
    _moodEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Persist to storage
    await _persistToStorage();
  }

  /// Get mood entry by ID
  SimpleMoodEntry? getMoodEntryById(String id) {
    try {
      return _moodEntries.firstWhere((entry) => entry.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all mood entries
  List<SimpleMoodEntry> getAllMoodEntries() {
    return List.from(_moodEntries);
  }

  /// Get mood entries within a date range
  List<SimpleMoodEntry> getMoodEntriesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _moodEntries.where((entry) {
      return entry.timestamp
              .isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          entry.timestamp.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();
  }

  /// Get mood entries for a specific date
  List<SimpleMoodEntry> getMoodEntriesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return getMoodEntriesByDateRange(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  /// Get recent mood entries (last N days)
  List<SimpleMoodEntry> getRecentMoodEntries({int days = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _moodEntries.where((entry) {
      return entry.timestamp.isAfter(cutoffDate);
    }).toList();
  }

  /// Search mood entries by emotions, notes, or metadata
  List<SimpleMoodEntry> searchMoodEntries({
    String? query,
    List<String>? emotions,
    int? minScore,
    int? maxScore,
  }) {
    return _moodEntries.where((entry) {
      // Text search in notes
      if (query != null && query.isNotEmpty) {
        final lowercaseQuery = query.toLowerCase();
        final notesMatch =
            entry.notes?.toLowerCase().contains(lowercaseQuery) ?? false;
        final emotionMatch = entry.emotions
            .any((emotion) => emotion.toLowerCase().contains(lowercaseQuery));

        if (!notesMatch && !emotionMatch) return false;
      }

      // Filter by emotions
      if (emotions != null && emotions.isNotEmpty) {
        final hasMatchingEmotion =
            emotions.any((emotion) => entry.emotions.contains(emotion));
        if (!hasMatchingEmotion) return false;
      }

      // Filter by score range
      if (minScore != null && entry.score < minScore) return false;
      if (maxScore != null && entry.score > maxScore) return false;

      return true;
    }).toList();
  }

  /// Get mood entries with specific emotions
  List<SimpleMoodEntry> getMoodEntriesByEmotions(List<String> emotions) {
    return _moodEntries.where((entry) {
      return emotions.any((emotion) => entry.emotions.contains(emotion));
    }).toList();
  }

  /// Get mood entries by score range
  List<SimpleMoodEntry> getMoodEntriesByScoreRange({
    required int minScore,
    required int maxScore,
  }) {
    return _moodEntries.where((entry) {
      return entry.score >= minScore && entry.score <= maxScore;
    }).toList();
  }

  /// Delete mood entry by ID
  Future<bool> deleteMoodEntry(String id) async {
    final initialLength = _moodEntries.length;
    _moodEntries.removeWhere((entry) => entry.id == id);

    if (_moodEntries.length < initialLength) {
      await _persistToStorage();
      return true;
    }

    return false;
  }

  /// Delete all mood entries
  Future<void> deleteAllMoodEntries() async {
    _moodEntries.clear();
    await _persistToStorage();
  }

  /// Get count of mood entries
  int getMoodEntryCount() {
    return _moodEntries.length;
  }

  /// Get average mood score for a date range
  double getAverageMoodScore({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    List<SimpleMoodEntry> entries;

    if (startDate != null && endDate != null) {
      entries = getMoodEntriesByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } else {
      entries = _moodEntries;
    }

    if (entries.isEmpty) return 0.0;

    final totalScore = entries.fold<int>(0, (sum, entry) => sum + entry.score);
    return totalScore / entries.length;
  }

  /// Get mood score distribution
  Map<int, int> getMoodScoreDistribution({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    List<SimpleMoodEntry> entries;

    if (startDate != null && endDate != null) {
      entries = getMoodEntriesByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } else {
      entries = _moodEntries;
    }

    final distribution = <int, int>{};
    for (int i = 1; i <= 10; i++) {
      distribution[i] = 0;
    }

    for (final entry in entries) {
      distribution[entry.score] = (distribution[entry.score] ?? 0) + 1;
    }

    return distribution;
  }

  /// Get most common emotions
  Map<String, int> getEmotionFrequency({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) {
    List<SimpleMoodEntry> entries;

    if (startDate != null && endDate != null) {
      entries = getMoodEntriesByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } else {
      entries = _moodEntries;
    }

    final emotionCount = <String, int>{};

    for (final entry in entries) {
      for (final emotion in entry.emotions) {
        emotionCount[emotion] = (emotionCount[emotion] ?? 0) + 1;
      }
    }

    // Sort by frequency and optionally limit results
    final sortedEmotions = emotionCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (limit != null && limit > 0) {
      return Map.fromEntries(sortedEmotions.take(limit));
    }

    return Map.fromEntries(sortedEmotions);
  }

  /// Load mood entries from storage
  Future<void> loadFromStorage() async {
    try {
      // TODO: Implement actual file-based persistence
      // For now, this is a placeholder for future Hive implementation
      AppLogger.debug('Loading mood entries from storage...');
    } catch (e) {
      AppLogger.error('Error loading mood entries', e);
    }
  }

  /// Persist mood entries to storage
  Future<void> _persistToStorage() async {
    try {
      // TODO: Implement actual file-based persistence
      // For now, this is a placeholder for future Hive implementation
      AppLogger.debug(
          'Persisting ${_moodEntries.length} mood entries to storage...');
    } catch (e) {
      AppLogger.error('Error persisting mood entries', e);
    }
  }

  /// Export mood entries to JSON
  String exportToJson({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    List<SimpleMoodEntry> entries;

    if (startDate != null && endDate != null) {
      entries = getMoodEntriesByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } else {
      entries = _moodEntries;
    }

    final exportData = {
      'export_timestamp': DateTime.now().toIso8601String(),
      'total_entries': entries.length,
      'date_range': {
        'start': startDate?.toIso8601String(),
        'end': endDate?.toIso8601String(),
      },
      'mood_entries': entries.map((entry) => entry.toJson()).toList(),
    };

    return jsonEncode(exportData);
  }

  /// Import mood entries from JSON
  Future<int> importFromJson(String jsonData) async {
    try {
      final data = jsonDecode(jsonData);
      final entries = data['mood_entries'] as List;

      int importedCount = 0;
      for (final entryData in entries) {
        try {
          final entry = SimpleMoodEntry.fromJson(entryData);
          await saveMoodEntry(entry);
          importedCount++;
        } catch (e) {
          AppLogger.error('Error importing mood entry', e);
        }
      }

      return importedCount;
    } catch (e) {
      AppLogger.error('Error importing mood entries', e);
      return 0;
    }
  }

  /// Clear cache and reload from storage
  Future<void> refresh() async {
    _moodEntries.clear();
    await loadFromStorage();
  }
}
