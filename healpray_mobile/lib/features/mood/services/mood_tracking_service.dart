import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/logger.dart';
import '../../../shared/services/firebase_service.dart';
import '../../../core/services/advanced_analytics_service.dart';
import '../models/mood_entry.dart';
import '../models/emotion_type.dart';
import '../models/mood_enums.dart';
import '../models/mood_analytics.dart';
import '../models/simple_mood_entry.dart';

/// Service for managing mood tracking with Firestore integration
class MoodTrackingService {
  static const String _collectionName = 'mood_entries';
  static const String _hiveBoxName = 'mood_entries_local';

  final FirebaseFirestore? _firestore;
  final _uuid = const Uuid();
  
  MoodTrackingService() : _firestore = _getFirestoreInstance();
  
  /// Safely get Firestore instance, returns null if Firebase not initialized
  static FirebaseFirestore? _getFirestoreInstance() {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      AppLogger.warning('Firebase not initialized, using local storage');
      return null;
    }
  }
  
  /// Check if Firebase is available
  bool get _isFirebaseAvailable => _firestore != null;
  
  /// Get or create local Hive box for offline storage
  Future<Box<Map>> _getLocalBox() async {
    if (!Hive.isBoxOpen(_hiveBoxName)) {
      return await Hive.openBox<Map>(_hiveBoxName);
    }
    return Hive.box<Map>(_hiveBoxName);
  }

  /// Create a new mood entry
  Future<MoodEntry> createMoodEntry({
    required List<EmotionType> emotions,
    required MoodIntensity intensity,
    required List<MoodTrigger> triggers,
    String? notes,
    String? location,
    List<String>? tags,
    MoodContext? context,
    List<String>? gratitudeList,
    List<String>? prayerRequests,
    String? verse,
    bool? isPrivate,
  }) async {
    try {
      final userId = _isFirebaseAvailable ? (FirebaseService.currentUser?.uid ?? 'local_user') : 'local_user';
      final now = DateTime.now();
      final entryId = _uuid.v4();
      
      final entry = MoodEntry(
        id: entryId,
        userId: userId,
        timestamp: now,
        emotions: emotions,
        intensity: intensity,
        triggers: triggers,
        notes: notes,
        location: location,
        tags: tags,
        context: context,
        gratitudeList: gratitudeList,
        prayerRequests: prayerRequests,
        verse: verse,
        isPrivate: isPrivate ?? false,
        createdAt: now,
        updatedAt: now,
      );

      if (_isFirebaseAvailable) {
        // Save to Firestore
        final docRef = await _firestore!.collection(_collectionName).add(entry.toFirestore());
        AppLogger.info('Created mood entry in Firestore: ${docRef.id}');
        return entry.copyWith(id: docRef.id);
      } else {
        // Save to local Hive storage
        final box = await _getLocalBox();
        await box.put(entryId, entry.toJson());
        AppLogger.info('Created mood entry locally: $entryId');
      }
      
      // Track mood entry analytics
      final simpleMoodEntry = SimpleMoodEntry(
        id: entryId,
        score: _calculateMoodScore(emotions, intensity),
        emotions: emotions.map((e) => e.name).toList(),
        notes: notes,
        timestamp: now,
        metadata: {
          'triggers': triggers.map((t) => t.name).toList(),
          'intensity': intensity.name,
        },
      );
      
      AdvancedAnalyticsService.instance.trackMoodEntry(
        moodEntry: simpleMoodEntry,
        entryMethod: 'manual',
      );

      return entry;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to create mood entry', error, stackTrace);
      rethrow;
    }
  }

  /// Update an existing mood entry
  Future<MoodEntry> updateMoodEntry(MoodEntry entry) async {
    try {
      final updatedEntry = entry.copyWithUpdatedAt();

      if (_isFirebaseAvailable) {
        await _firestore!
            .collection(_collectionName)
            .doc(entry.id)
            .update(updatedEntry.toFirestore());
        AppLogger.info('Updated mood entry in Firestore: ${entry.id}');
      } else {
        final box = await _getLocalBox();
        await box.put(entry.id, updatedEntry.toJson());
        AppLogger.info('Updated mood entry locally: ${entry.id}');
      }

      return updatedEntry;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to update mood entry', error, stackTrace);
      rethrow;
    }
  }

  /// Delete a mood entry
  Future<void> deleteMoodEntry(String entryId) async {
    try {
      if (_isFirebaseAvailable) {
        await _firestore!.collection(_collectionName).doc(entryId).delete();
        AppLogger.info('Deleted mood entry from Firestore: $entryId');
      } else {
        final box = await _getLocalBox();
        await box.delete(entryId);
        AppLogger.info('Deleted mood entry locally: $entryId');
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to delete mood entry', error, stackTrace);
      rethrow;
    }
  }

  /// Get mood entry by ID
  Future<MoodEntry?> getMoodEntry(String entryId) async {
    try {
      if (_isFirebaseAvailable) {
        final doc = await _firestore!.collection(_collectionName).doc(entryId).get();
        if (!doc.exists) return null;
        return MoodEntry.fromFirestore(doc);
      } else {
        final box = await _getLocalBox();
        final data = box.get(entryId);
        if (data == null) return null;
        return MoodEntry.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get mood entry', error, stackTrace);
      rethrow;
    }
  }

  /// Get mood entries for the current user
  Stream<List<MoodEntry>> getMoodEntriesStream({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    try {
      final userId = _isFirebaseAvailable ? (FirebaseService.currentUser?.uid ?? 'local_user') : 'local_user';

      if (_isFirebaseAvailable) {
        Query<Map<String, dynamic>> query = _firestore!
            .collection(_collectionName)
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true);

        // Apply date filters
        if (startDate != null) {
          query = query.where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
        }
        if (endDate != null) {
          query = query.where('timestamp',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate));
        }

        // Apply limit
        if (limit != null) {
          query = query.limit(limit);
        }

        return query.snapshots().map((snapshot) {
          return snapshot.docs
              .map((doc) => MoodEntry.fromFirestore(doc))
              .toList();
        });
      } else {
        // For local storage, return a stream that emits data from Hive
        return Stream.periodic(const Duration(seconds: 1)).asyncMap((_) async {
          return await getMoodEntries(
            limit: limit,
            startDate: startDate,
            endDate: endDate,
          );
        });
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get mood entries stream', error, stackTrace);
      return Stream.error(error);
    }
  }

  /// Get mood entries for a specific date range
  Future<List<MoodEntry>> getMoodEntries({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = _isFirebaseAvailable ? (FirebaseService.currentUser?.uid ?? 'local_user') : 'local_user';

      if (_isFirebaseAvailable) {
        Query<Map<String, dynamic>> query = _firestore!
            .collection(_collectionName)
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true);

        // Apply date filters
        if (startDate != null) {
          query = query.where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
        }
        if (endDate != null) {
          query = query.where('timestamp',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate));
        }

        // Apply limit
        if (limit != null) {
          query = query.limit(limit);
        }

        final snapshot = await query.get();
        return snapshot.docs.map((doc) => MoodEntry.fromFirestore(doc)).toList();
      } else {
        // Get from local storage
        final box = await _getLocalBox();
        var entries = box.values
            .map((data) => MoodEntry.fromJson(Map<String, dynamic>.from(data)))
            .where((entry) => entry.userId == userId)
            .toList();
        
        // Sort by timestamp descending
        entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        // Apply date filters
        if (startDate != null) {
          entries = entries.where((e) => e.timestamp.isAfter(startDate) || e.timestamp.isAtSameMomentAs(startDate)).toList();
        }
        if (endDate != null) {
          entries = entries.where((e) => e.timestamp.isBefore(endDate) || e.timestamp.isAtSameMomentAs(endDate)).toList();
        }
        
        // Apply limit
        if (limit != null && entries.length > limit) {
          entries = entries.sublist(0, limit);
        }
        
        return entries;
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get mood entries', error, stackTrace);
      rethrow;
    }
  }

  /// Get today's mood entry (if exists)
  Future<MoodEntry?> getTodaysMoodEntry() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final entries = await getMoodEntries(
        limit: 1,
        startDate: startOfDay,
        endDate: endOfDay,
      );

      return entries.isNotEmpty ? entries.first : null;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get today\'s mood entry', error, stackTrace);
      rethrow;
    }
  }

  /// Check if user has entry for today
  Future<bool> hasEntryToday() async {
    final todaysEntry = await getTodaysMoodEntry();
    return todaysEntry != null;
  }

  /// Get current mood tracking streak
  Future<int> getCurrentStreak() async {
    try {
      final userId = _isFirebaseAvailable ? FirebaseService.currentUser?.uid : 'local_user';
      if (userId == null) return 0;

      // Get entries for the last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final entries = await getMoodEntries(startDate: thirtyDaysAgo);

      if (entries.isEmpty) return 0;

      // Group entries by date
      final entriesByDate = <String, List<MoodEntry>>{};
      for (final entry in entries) {
        final dateKey = _formatDateKey(entry.timestamp);
        entriesByDate.putIfAbsent(dateKey, () => []).add(entry);
      }

      // Calculate streak from today backwards
      int streak = 0;
      final today = DateTime.now();

      for (int i = 0; i < 30; i++) {
        final checkDate = today.subtract(Duration(days: i));
        final dateKey = _formatDateKey(checkDate);

        if (entriesByDate.containsKey(dateKey)) {
          streak++;
        } else {
          break; // Streak broken
        }
      }

      return streak;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get current streak', error, stackTrace);
      return 0;
    }
  }

  /// Get longest mood tracking streak
  Future<int> getLongestStreak() async {
    try {
      final userId = _isFirebaseAvailable ? FirebaseService.currentUser?.uid : 'local_user';
      if (userId == null) return 0;

      // Get all entries for the user
      final entries = await getMoodEntries();

      if (entries.isEmpty) return 0;

      // Group entries by date
      final entriesByDate = <String, List<MoodEntry>>{};
      for (final entry in entries) {
        final dateKey = _formatDateKey(entry.timestamp);
        entriesByDate.putIfAbsent(dateKey, () => []).add(entry);
      }

      // Sort dates
      final sortedDates = entriesByDate.keys.toList()..sort();

      int longestStreak = 0;
      int currentStreak = 1;

      for (int i = 1; i < sortedDates.length; i++) {
        final currentDate = DateTime.parse(sortedDates[i]);
        final previousDate = DateTime.parse(sortedDates[i - 1]);

        if (currentDate.difference(previousDate).inDays == 1) {
          currentStreak++;
        } else {
          longestStreak =
              longestStreak > currentStreak ? longestStreak : currentStreak;
          currentStreak = 1;
        }
      }

      return longestStreak > currentStreak ? longestStreak : currentStreak;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get longest streak', error, stackTrace);
      return 0;
    }
  }

  /// Generate mood analytics for a date range
  Future<MoodAnalytics> getMoodAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Default to last 30 days
      endDate ??= DateTime.now();
      startDate ??= endDate.subtract(const Duration(days: 30));

      final entries = await getMoodEntries(
        startDate: startDate,
        endDate: endDate,
      );

      if (entries.isEmpty) {
        return MoodAnalytics(
          period: DateRange(start: startDate, end: endDate),
          averageMood: 0.0,
          moodDistribution: {},
          trends: [],
          patterns: [],
          insights: [],
          correlations: [],
          recommendations: [],
          predictions: [],
          totalEntries: 0,
          averageMoodScore: 0.0,
          currentStreak: 0,
          positivityRate: 0.0,
          emotionCategoryCounts: {},
          triggerCategoryCounts: {},
        );
      }

      // Calculate analytics
      final totalEntries = entries.length;
      double totalMoodScore = 0.0;
      final emotionCategoryCounts = <String, int>{};
      final triggerCategoryCounts = <String, int>{};
      int positiveEntries = 0;
      final moodDistribution = <int, double>{};

      for (final entry in entries) {
        totalMoodScore += entry.moodScore;

        if (entry.isPositive) {
          positiveEntries++;
        }

        // Build mood distribution
        final moodScoreInt = entry.moodScore.round();
        moodDistribution[moodScoreInt] =
            (moodDistribution[moodScoreInt] ?? 0) + 1;

        // Count emotions by name instead of category (since category doesn't exist)
        for (final emotion in entry.emotions) {
          emotionCategoryCounts[emotion.name] =
              (emotionCategoryCounts[emotion.name] ?? 0) + 1;
        }

        // Count triggers by name instead of category (since category doesn't exist)
        for (final trigger in entry.triggers) {
          triggerCategoryCounts[trigger.name] =
              (triggerCategoryCounts[trigger.name] ?? 0) + 1;
        }
      }

      // Get streak data
      final currentStreak = await getCurrentStreak();
      final positivityRate = positiveEntries / totalEntries;
      final averageMoodScore = totalMoodScore / totalEntries;

      return MoodAnalytics(
        period: DateRange(start: startDate, end: endDate),
        averageMood: averageMoodScore,
        moodDistribution: moodDistribution,
        trends: [], // Placeholder for future trend analysis
        patterns: [], // Placeholder for future pattern analysis
        insights: [], // Placeholder for future insights
        correlations: [], // Placeholder for future correlations
        recommendations: [], // Placeholder for future recommendations
        predictions: [], // Placeholder for future predictions
        totalEntries: totalEntries,
        averageMoodScore: averageMoodScore,
        currentStreak: currentStreak,
        positivityRate: positivityRate,
        emotionCategoryCounts: emotionCategoryCounts,
        triggerCategoryCounts: triggerCategoryCounts,
      );
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get mood analytics', error, stackTrace);
      rethrow;
    }
  }

  /// Calculate weekly mood averages
  Map<String, double> _calculateWeeklyAverages(
    List<MoodEntry> entries,
    DateTime startDate,
    DateTime endDate,
  ) {
    final weeklyScores = <String, List<double>>{};

    for (final entry in entries) {
      final weekKey = _getWeekKey(entry.timestamp);
      weeklyScores.putIfAbsent(weekKey, () => []).add(entry.moodScore);
    }

    return weeklyScores.map((key, scores) => MapEntry(
          key,
          scores.reduce((a, b) => a + b) / scores.length,
        ));
  }

  /// Calculate monthly mood averages
  Map<String, double> _calculateMonthlyAverages(
    List<MoodEntry> entries,
    DateTime startDate,
    DateTime endDate,
  ) {
    final monthlyScores = <String, List<double>>{};

    for (final entry in entries) {
      final monthKey =
          '${entry.timestamp.year}-${entry.timestamp.month.toString().padLeft(2, '0')}';
      monthlyScores.putIfAbsent(monthKey, () => []).add(entry.moodScore);
    }

    return monthlyScores.map((key, scores) => MapEntry(
          key,
          scores.reduce((a, b) => a + b) / scores.length,
        ));
  }

  /// Helper to format date as string key
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Helper to get week key for grouping
  String _getWeekKey(DateTime date) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    return _formatDateKey(weekStart);
  }

  /// Get mood entries that indicate distress (for crisis support)
  Stream<List<MoodEntry>> getDistressEntriesStream() {
    try {
      // Get recent entries and filter for distress in the app
      return getMoodEntriesStream(limit: 50).map((entries) {
        return entries.where((entry) => entry.indicatesDistress).toList();
      });
    } catch (error, stackTrace) {
      AppLogger.error(
          'Failed to get distress entries stream', error, stackTrace);
      return Stream.error(error);
    }
  }

  /// Get suggested spiritual practices based on recent mood patterns
  Future<List<String>> getSuggestedPractices({int? lookbackDays}) async {
    try {
      lookbackDays ??= 7;
      final startDate = DateTime.now().subtract(Duration(days: lookbackDays));

      final entries = await getMoodEntries(startDate: startDate);

      if (entries.isEmpty) {
        return ['Daily Prayer', 'Gratitude Journaling', 'Scripture Reading'];
      }

      // Collect all suggested practices
      final practicesSet = <String>{};
      for (final entry in entries) {
        practicesSet.addAll(entry.suggestedPractices);
      }

      return practicesSet.toList()..take(6);
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get suggested practices', error, stackTrace);
      return ['Daily Prayer', 'Gratitude Journaling', 'Scripture Reading'];
    }
  }
  
  /// Calculate mood score from emotions and intensity for analytics
  int _calculateMoodScore(List<EmotionType> emotions, MoodIntensity intensity) {
    if (emotions.isEmpty) return 5;
    
    // Base score from intensity (1-10)
    final intensityScore = switch (intensity) {
      MoodIntensity.veryLow => 1,
      MoodIntensity.low => 3,
      MoodIntensity.moderate => 5,
      MoodIntensity.high => 7,
      MoodIntensity.veryHigh => 9,
    };
    
    // Adjust based on emotion positivity/negativity
    double emotionAdjustment = 0.0;
    for (final emotion in emotions) {
      // Positive emotions
      if (['joy', 'peace', 'hope', 'gratitude', 'love', 'contentment'].contains(emotion.name.toLowerCase())) {
        emotionAdjustment += 0.5;
      }
      // Negative emotions
      else if (['anxiety', 'sadness', 'fear', 'anger', 'frustration', 'overwhelmed'].contains(emotion.name.toLowerCase())) {
        emotionAdjustment -= 0.5;
      }
    }
    
    // Clamp between 1-10
    final finalScore = (intensityScore + emotionAdjustment).round();
    return finalScore.clamp(1, 10);
  }
}

/// Provider for MoodTrackingService
final moodTrackingServiceProvider = Provider<MoodTrackingService>((ref) {
  return MoodTrackingService();
});
