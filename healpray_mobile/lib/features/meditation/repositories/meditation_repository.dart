import 'package:hive/hive.dart';

import '../models/meditation_session.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/utils/logger.dart';

/// Repository for managing meditation session persistence
class MeditationRepository {
  static MeditationRepository? _instance;
  static MeditationRepository get instance =>
      _instance ??= MeditationRepository._();

  MeditationRepository._();

  static const String _boxName = 'meditation_sessions';
  Box<MeditationSession>? _meditationBox;

  /// Initialize the meditation repository
  Future<void> initialize() async {
    try {
      await HiveService.ensureInitialized();

      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(50)) {
        Hive.registerAdapter(MeditationDurationAdapter());
      }
      if (!Hive.isAdapterRegistered(51)) {
        Hive.registerAdapter(MeditationTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(52)) {
        Hive.registerAdapter(MeditationStateAdapter());
      }
      if (!Hive.isAdapterRegistered(53)) {
        Hive.registerAdapter(MeditationSessionAdapter());
      }

      _meditationBox = await Hive.openBox<MeditationSession>(_boxName);
      AppLogger.info('MeditationRepository initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize MeditationRepository', e);
      rethrow;
    }
  }

  void _ensureInitialized() {
    if (_meditationBox == null) {
      throw Exception(
          'MeditationRepository not initialized. Call initialize() first.');
    }
  }

  // ============= SESSION MANAGEMENT =============

  /// Save a meditation session
  Future<void> saveMeditationSession(MeditationSession session) async {
    _ensureInitialized();

    try {
      await _meditationBox!.put(session.id, session);
      AppLogger.debug('Saved meditation session: ${session.id}');
    } catch (e) {
      AppLogger.error('Failed to save meditation session: ${session.id}', e);
      rethrow;
    }
  }

  /// Get a meditation session by ID
  MeditationSession? getMeditationSession(String sessionId) {
    _ensureInitialized();

    try {
      return _meditationBox!.get(sessionId);
    } catch (e) {
      AppLogger.error('Failed to get meditation session: $sessionId', e);
      return null;
    }
  }

  /// Delete a meditation session
  Future<void> deleteMeditationSession(String sessionId) async {
    _ensureInitialized();

    try {
      await _meditationBox!.delete(sessionId);
      AppLogger.debug('Deleted meditation session: $sessionId');
    } catch (e) {
      AppLogger.error('Failed to delete meditation session: $sessionId', e);
      rethrow;
    }
  }

  /// Update a meditation session
  Future<void> updateMeditationSession(MeditationSession session) async {
    await saveMeditationSession(session); // Same as save in Hive
  }

  // ============= SESSION QUERIES =============

  /// Get all meditation sessions
  Future<List<MeditationSession>> getAllSessions() async {
    _ensureInitialized();

    try {
      final sessions = _meditationBox!.values.toList();
      sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return sessions;
    } catch (e) {
      AppLogger.error('Failed to get all meditation sessions', e);
      return [];
    }
  }

  /// Get recent meditation sessions
  Future<List<MeditationSession>> getRecentSessions({int limit = 10}) async {
    _ensureInitialized();

    try {
      final allSessions = await getAllSessions();
      return allSessions.take(limit).toList();
    } catch (e) {
      AppLogger.error('Failed to get recent meditation sessions', e);
      return [];
    }
  }

  /// Get sessions by meditation type
  Future<List<MeditationSession>> getSessionsByType(MeditationType type) async {
    _ensureInitialized();

    try {
      final sessions = _meditationBox!.values
          .where((session) => session.type == type)
          .toList();
      sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return sessions;
    } catch (e) {
      AppLogger.error('Failed to get sessions by type: $type', e);
      return [];
    }
  }

  /// Get completed sessions only
  Future<List<MeditationSession>> getCompletedSessions() async {
    _ensureInitialized();

    try {
      final sessions = _meditationBox!.values
          .where((session) => session.isCompleted)
          .toList();
      sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return sessions;
    } catch (e) {
      AppLogger.error('Failed to get completed sessions', e);
      return [];
    }
  }

  /// Get sessions by date range
  Future<List<MeditationSession>> getSessionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _ensureInitialized();

    try {
      final sessions = _meditationBox!.values.where((session) {
        final sessionDate = session.startedAt;
        return sessionDate
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            sessionDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
      sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return sessions;
    } catch (e) {
      AppLogger.error('Failed to get sessions by date range', e);
      return [];
    }
  }

  /// Get sessions for today
  Future<List<MeditationSession>> getTodaySessions() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1));

    return await getSessionsByDateRange(startOfDay, endOfDay);
  }

  /// Get sessions for this week
  Future<List<MeditationSession>> getThisWeekSessions() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return await getSessionsByDateRange(startOfWeek, endOfWeek);
  }

  /// Get sessions for this month
  Future<List<MeditationSession>> getThisMonthSessions() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return await getSessionsByDateRange(startOfMonth, endOfMonth);
  }

  // ============= STATISTICS =============

  /// Get meditation statistics for a date range
  Future<Map<String, dynamic>> getSessionStats(
      DateTime startDate, DateTime endDate) async {
    final sessions = await getSessionsByDateRange(startDate, endDate);
    final completedSessions = sessions.where((s) => s.isCompleted).toList();

    if (completedSessions.isEmpty) {
      return {
        'totalSessions': 0,
        'completedSessions': 0,
        'totalMinutes': 0,
        'averageDuration': 0.0,
        'averageRating': 0.0,
        'completionRate': 0.0,
        'typeDistribution': <String, int>{},
      };
    }

    final totalMinutes = completedSessions.fold<int>(
      0,
      (sum, session) => sum + (session.actualDurationSeconds ~/ 60),
    );

    final averageDuration = totalMinutes / completedSessions.length;

    final ratedSessions = completedSessions.where((s) => s.rating > 0).toList();
    final averageRating = ratedSessions.isNotEmpty
        ? ratedSessions.fold<double>(0, (sum, s) => sum + s.rating) /
            ratedSessions.length
        : 0.0;

    // Calculate type distribution
    final typeDistribution = <String, int>{};
    for (final session in completedSessions) {
      final typeName = session.type.name;
      typeDistribution[typeName] = (typeDistribution[typeName] ?? 0) + 1;
    }

    return {
      'totalSessions': sessions.length,
      'completedSessions': completedSessions.length,
      'totalMinutes': totalMinutes,
      'averageDuration': averageDuration,
      'averageRating': averageRating,
      'completionRate': completedSessions.length / sessions.length,
      'typeDistribution': typeDistribution,
    };
  }

  /// Get current streak of consecutive meditation days
  Future<int> getCurrentMeditationStreak() async {
    final sessions = await getCompletedSessions();

    if (sessions.isEmpty) return 0;

    // Group sessions by date
    final sessionsByDate = <DateTime, List<MeditationSession>>{};
    for (final session in sessions) {
      final date = DateTime(
        session.startedAt.year,
        session.startedAt.month,
        session.startedAt.day,
      );
      sessionsByDate[date] = (sessionsByDate[date] ?? [])..add(session);
    }

    final uniqueDates = sessionsByDate.keys.toList();
    uniqueDates.sort((a, b) => b.compareTo(a)); // Most recent first

    if (uniqueDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));

    // Check if we have a session today or yesterday to start the streak
    if (uniqueDates.first != todayDate && uniqueDates.first != yesterday) {
      return 0;
    }

    int streak = 1;
    DateTime expectedDate = uniqueDates.first.subtract(const Duration(days: 1));

    for (int i = 1; i < uniqueDates.length; i++) {
      if (uniqueDates[i] == expectedDate) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  // ============= FAVORITES & PREFERENCES =============

  /// Get favorite meditation types based on frequency and ratings
  Future<List<MeditationType>> getFavoriteMeditationTypes(
      {int limit = 3}) async {
    final sessions = await getCompletedSessions();

    if (sessions.isEmpty) return [];

    // Calculate weighted scores (frequency + average rating)
    final typeScores = <MeditationType, double>{};
    final typeCounts = <MeditationType, int>{};
    final typeRatingTotals = <MeditationType, double>{};

    for (final session in sessions) {
      final type = session.type;
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
      if (session.rating > 0) {
        typeRatingTotals[type] = (typeRatingTotals[type] ?? 0) + session.rating;
      }
    }

    for (final type in typeCounts.keys) {
      final count = typeCounts[type]!;
      final avgRating = typeRatingTotals[type] != null
          ? (typeRatingTotals[type]! / count)
          : 3.0; // Default rating if no ratings

      // Weighted score: frequency (40%) + average rating (60%)
      typeScores[type] = (count * 0.4) + (avgRating * 0.6);
    }

    final sortedTypes = typeScores.entries.toList();
    sortedTypes.sort((a, b) => b.value.compareTo(a.value));

    return sortedTypes.take(limit).map((e) => e.key).toList();
  }

  /// Get recommended meditation duration based on history
  Future<MeditationDuration> getRecommendedDuration() async {
    final recentSessions = await getRecentSessions(limit: 20);
    final completedSessions =
        recentSessions.where((s) => s.isCompleted).toList();

    if (completedSessions.isEmpty) {
      return MeditationDuration.short; // Default for beginners
    }

    // Calculate average completion rate for each duration
    final durationStats = <MeditationDuration, Map<String, double>>{};

    for (final session in completedSessions) {
      final duration = session.duration;
      durationStats[duration] ??= {'count': 0, 'completionSum': 0};
      durationStats[duration]!['count'] =
          durationStats[duration]!['count']! + 1;
      durationStats[duration]!['completionSum'] =
          durationStats[duration]!['completionSum']! +
              session.completionPercentage;
    }

    // Find duration with best completion rate
    MeditationDuration? bestDuration;
    double bestScore = 0;

    for (final entry in durationStats.entries) {
      final stats = entry.value;
      final count = stats['count']!;
      final avgCompletion = stats['completionSum']! / count;

      // Score based on completion rate and frequency
      final score = avgCompletion * (1 + (count / completedSessions.length));

      if (score > bestScore) {
        bestScore = score;
        bestDuration = entry.key;
      }
    }

    return bestDuration ?? MeditationDuration.short;
  }

  // ============= CLEANUP =============

  /// Clear all meditation data (use with caution)
  Future<void> clearAllData() async {
    _ensureInitialized();

    try {
      await _meditationBox!.clear();
      AppLogger.warning('Cleared all meditation data');
    } catch (e) {
      AppLogger.error('Failed to clear meditation data', e);
      rethrow;
    }
  }

  /// Get total storage count
  int getTotalSessionCount() {
    _ensureInitialized();
    return _meditationBox!.length;
  }

  /// Export meditation data for backup
  Future<Map<String, dynamic>> exportMeditationData() async {
    final sessions = await getAllSessions();

    return {
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'totalSessions': sessions.length,
    };
  }

  /// Import meditation data from backup
  Future<void> importMeditationData(Map<String, dynamic> data) async {
    _ensureInitialized();

    try {
      final sessionData = data['sessions'] as List<dynamic>;

      for (final sessionJson in sessionData) {
        final session =
            MeditationSession.fromJson(sessionJson as Map<String, dynamic>);
        await saveMeditationSession(session);
      }

      AppLogger.info('Imported ${sessionData.length} meditation sessions');
    } catch (e) {
      AppLogger.error('Failed to import meditation data', e);
      rethrow;
    }
  }
}
