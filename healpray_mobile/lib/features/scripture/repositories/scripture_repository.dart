import '../models/scripture.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/utils/logger.dart';

/// Repository for managing scripture verses and daily verse selections
class ScriptureRepository {
  static ScriptureRepository? _instance;
  static ScriptureRepository get instance =>
      _instance ??= ScriptureRepository._();

  ScriptureRepository._();

  final HiveService _hive = HiveService.instance;

  // In-memory cache for quick access
  List<Scripture>? _cachedScriptures;
  Map<String, String>? _dailyVerses; // date -> scriptureId
  Map<String, ScriptureReadingEntry>? _readingEntries;

  /// Initialize the repository
  Future<void> initialize() async {
    try {
      await _hive.initialize();
      await _loadCachedData();
      AppLogger.info('ScriptureRepository initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize ScriptureRepository', e);
      rethrow;
    }
  }

  // ============= SCRIPTURE MANAGEMENT =============

  /// Get all scriptures
  Future<List<Scripture>> getAllScriptures() async {
    if (_cachedScriptures == null) {
      await _loadScriptures();
    }
    return _cachedScriptures ?? [];
  }

  /// Get scripture by ID
  Future<Scripture?> getScripture(String id) async {
    final scriptures = await getAllScriptures();
    try {
      return scriptures.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get scriptures by themes
  Future<List<Scripture>> getScripturesByThemes(
      List<ScriptureTheme> themes) async {
    final scriptures = await getAllScriptures();
    return scriptures.where((scripture) {
      return scripture.themes.any((theme) => themes.contains(theme));
    }).toList();
  }

  /// Get scriptures by category
  Future<List<Scripture>> getScripturesByCategory(
      ScriptureCategory category) async {
    final scriptures = await getAllScriptures();
    return scriptures.where((s) => s.category == category).toList();
  }

  /// Search scriptures by keyword
  Future<List<Scripture>> searchScriptures(String keyword) async {
    final scriptures = await getAllScriptures();
    final lowerKeyword = keyword.toLowerCase();

    return scriptures.where((scripture) {
      return scripture.text.toLowerCase().contains(lowerKeyword) ||
          scripture.keywords
              .any((k) => k.toLowerCase().contains(lowerKeyword)) ||
          scripture.book.toLowerCase().contains(lowerKeyword);
    }).toList();
  }

  /// Add custom scripture
  Future<void> addScripture(Scripture scripture) async {
    _cachedScriptures ??= [];
    _cachedScriptures!.add(scripture);
    await _saveScriptures();
  }

  // ============= DAILY VERSES =============

  /// Get daily verse for a specific date
  Future<Scripture?> getDailyVerse(String dateKey) async {
    await _loadDailyVerses();
    final scriptureId = _dailyVerses?[dateKey];
    if (scriptureId != null) {
      return await getScripture(scriptureId);
    }
    return null;
  }

  /// Save daily verse selection
  Future<void> saveDailyVerse(String dateKey, String scriptureId) async {
    _dailyVerses ??= {};
    _dailyVerses![dateKey] = scriptureId;
    await _saveDailyVerses();
  }

  /// Get recent daily verses
  Future<Map<String, Scripture>> getRecentDailyVerses({int days = 7}) async {
    final result = <String, Scripture>{};
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final verse = await getDailyVerse(dateKey);
      if (verse != null) {
        result[dateKey] = verse;
      }
    }

    return result;
  }

  // ============= READING HISTORY =============

  /// Record scripture reading
  Future<void> recordReading(ScriptureReadingEntry entry) async {
    _readingEntries ??= {};
    _readingEntries![entry.id] = entry;
    await _saveReadingEntries();
  }

  /// Get reading entries for a date range
  Future<List<ScriptureReadingEntry>> getReadingEntries({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _loadReadingEntries();
    final entries = _readingEntries?.values.toList() ?? [];

    if (startDate == null && endDate == null) {
      return entries;
    }

    return entries.where((entry) {
      if (startDate != null && entry.timestamp.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && entry.timestamp.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Get reading statistics
  Future<Map<String, dynamic>> getReadingStats() async {
    final entries = await getReadingEntries();

    if (entries.isEmpty) {
      return {
        'totalReadings': 0,
        'uniqueScriptures': 0,
        'averageRating': 0.0,
        'currentStreak': 0,
        'favoriteThemes': <String>[],
      };
    }

    final uniqueScriptures = entries.map((e) => e.scriptureId).toSet();
    final ratingsWithValue = entries.where((e) => e.rating > 0);
    final averageRating = ratingsWithValue.isEmpty
        ? 0.0
        : ratingsWithValue.map((e) => e.rating).reduce((a, b) => a + b) /
            ratingsWithValue.length;

    // Calculate current streak
    final sortedEntries = entries.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    int streak = 0;
    DateTime? lastDate;

    for (final entry in sortedEntries) {
      final entryDate = DateTime(
          entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);

      if (lastDate == null) {
        // First entry
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);

        if (entryDate.isAtSameMomentAs(todayDate) ||
            entryDate.isAtSameMomentAs(
                todayDate.subtract(const Duration(days: 1)))) {
          streak = 1;
          lastDate = entryDate;
        } else {
          break; // No recent activity
        }
      } else {
        final expectedDate = lastDate.subtract(const Duration(days: 1));
        if (entryDate.isAtSameMomentAs(expectedDate)) {
          streak++;
          lastDate = expectedDate;
        } else {
          break;
        }
      }
    }

    return {
      'totalReadings': entries.length,
      'uniqueScriptures': uniqueScriptures.length,
      'averageRating': averageRating,
      'currentStreak': streak,
      'favoriteThemes': [], // TODO: Calculate most common themes
    };
  }

  // ============= FAVORITES =============

  /// Toggle scripture favorite status
  Future<void> toggleFavorite(String scriptureId, bool isFavorite) async {
    final scripture = await getScripture(scriptureId);
    if (scripture != null) {
      // In a real implementation, this would update the scripture's favorite status
      // For now, we'll just log it
      AppLogger.info('Scripture $scriptureId favorite status: $isFavorite');
    }
  }

  /// Get favorite scriptures
  Future<List<Scripture>> getFavoriteScriptures() async {
    // TODO: Implement favorites tracking
    return [];
  }

  /// Get scriptures by single theme
  Future<List<Scripture>> getScripturesByTheme(ScriptureTheme theme) async {
    return getScripturesByThemes([theme]);
  }

  /// Save scripture reading entry
  Future<void> saveReadingEntry(ScriptureReadingEntry entry) async {
    await recordReading(entry);
  }

  /// Save/update scripture
  Future<void> saveScripture(Scripture scripture) async {
    _cachedScriptures ??= [];
    // Remove existing scripture with same ID if present
    _cachedScriptures!.removeWhere((s) => s.id == scripture.id);
    _cachedScriptures!.add(scripture);
    await _saveScriptures();
  }

  /// Get all reading entries
  Future<List<ScriptureReadingEntry>> getAllReadingEntries() async {
    await _loadReadingEntries();
    return _readingEntries?.values.toList() ?? [];
  }

  /// Get scripture count
  Future<int> getScriptureCount() async {
    final scriptures = await getAllScriptures();
    return scriptures.length;
  }

  // ============= PRIVATE METHODS =============

  Future<void> _loadCachedData() async {
    await _loadScriptures();
    await _loadDailyVerses();
    await _loadReadingEntries();
  }

  Future<void> _loadScriptures() async {
    try {
      // TODO: Load from Hive when properly implemented
      // For now, return empty list - scriptures will be populated by service
      _cachedScriptures = [];
    } catch (e) {
      AppLogger.error('Failed to load scriptures', e);
      _cachedScriptures = [];
    }
  }

  Future<void> _saveScriptures() async {
    try {
      // TODO: Save to Hive when properly implemented
      AppLogger.debug('Scriptures saved (placeholder)');
    } catch (e) {
      AppLogger.error('Failed to save scriptures', e);
    }
  }

  Future<void> _loadDailyVerses() async {
    try {
      // TODO: Load from Hive when properly implemented
      _dailyVerses = {};
    } catch (e) {
      AppLogger.error('Failed to load daily verses', e);
      _dailyVerses = {};
    }
  }

  Future<void> _saveDailyVerses() async {
    try {
      // TODO: Save to Hive when properly implemented
      AppLogger.debug('Daily verses saved (placeholder)');
    } catch (e) {
      AppLogger.error('Failed to save daily verses', e);
    }
  }

  Future<void> _loadReadingEntries() async {
    try {
      // TODO: Load from Hive when properly implemented
      _readingEntries = {};
    } catch (e) {
      AppLogger.error('Failed to load reading entries', e);
      _readingEntries = {};
    }
  }

  Future<void> _saveReadingEntries() async {
    try {
      // TODO: Save to Hive when properly implemented
      AppLogger.debug('Reading entries saved (placeholder)');
    } catch (e) {
      AppLogger.error('Failed to save reading entries', e);
    }
  }
}
