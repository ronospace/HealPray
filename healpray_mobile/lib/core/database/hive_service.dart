import 'package:hive_flutter/hive_flutter.dart';
import '../utils/logger.dart';

/// Hive database service for local data persistence
class HiveService {
  static HiveService? _instance;
  static HiveService get instance => _instance ??= HiveService._();

  HiveService._();

  // Box names
  static const String _prayersBox = 'prayers';
  static const String _moodEntriesBox = 'mood_entries';
  static const String _chatMessagesBox = 'chat_messages';
  static const String _conversationsBox = 'conversations';
  static const String _chatSessionsBox = 'chat_sessions';
  static const String _scripturesBox = 'scriptures';
  static const String _scriptureReadingsBox = 'scripture_readings';
  static const String _userPreferencesBox = 'user_preferences';
  static const String _appSettingsBox = 'app_settings';
  static const String _userAnalyticsBox = 'user_analytics';

  bool _isInitialized = false;

  /// Initialize Hive database
  Future<void> initialize() async {
    if (_isInitialized) {
      AppLogger.debug('Hive service already initialized');
      return;
    }

    try {
      // Open all boxes
      await _openBoxes();
      
      _isInitialized = true;
      AppLogger.info('✅ Hive service initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize Hive service', e, stackTrace);
      rethrow;
    }
  }

  /// Open all Hive boxes
  Future<void> _openBoxes() async {
    try {
      // Open boxes in parallel for faster startup
      await Future.wait([
        Hive.openBox(_prayersBox),
        Hive.openBox(_moodEntriesBox),
        Hive.openBox(_chatMessagesBox),
        Hive.openBox(_conversationsBox),
        Hive.openBox(_chatSessionsBox),
        Hive.openBox(_scripturesBox),
        Hive.openBox(_scriptureReadingsBox),
        Hive.openBox(_userPreferencesBox),
        Hive.openBox(_appSettingsBox),
        Hive.openBox(_userAnalyticsBox),
      ]);
      
      AppLogger.debug('All Hive boxes opened successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to open Hive boxes', e, stackTrace);
      rethrow;
    }
  }

  /// Ensure Hive is initialized
  static Future<void> ensureInitialized() async {
    await instance.initialize();
  }

  /// Get a specific box
  Box<T> getBox<T>(String boxName) {
    if (!_isInitialized) {
      throw StateError('Hive service not initialized. Call initialize() first.');
    }
    return Hive.box<T>(boxName);
  }

  /// Get prayers box
  Box getPrayersBox() => getBox(_prayersBox);

  /// Get mood entries box
  Box getMoodEntriesBox() => getBox(_moodEntriesBox);

  /// Get chat messages box
  Box getChatMessagesBox() => getBox(_chatMessagesBox);

  /// Get conversations box
  Box getConversationsBox() => getBox(_conversationsBox);

  /// Get chat sessions box
  Box getChatSessionsBox() => getBox(_chatSessionsBox);

  /// Get scriptures box
  Box getScripturesBox() => getBox(_scripturesBox);

  /// Get scripture readings box
  Box getScriptureReadingsBox() => getBox(_scriptureReadingsBox);

  /// Get user preferences box
  Box getUserPreferencesBox() => getBox(_userPreferencesBox);

  /// Get app settings box
  Box getAppSettingsBox() => getBox(_appSettingsBox);

  /// Get user analytics box
  Box getUserAnalyticsBox() => getBox(_userAnalyticsBox);

  /// Clear all data (for debugging/reset)
  Future<void> clearAllData() async {
    if (!_isInitialized) {
      AppLogger.warning('Cannot clear data - Hive not initialized');
      return;
    }

    try {
      await Future.wait([
        Hive.box(_prayersBox).clear(),
        Hive.box(_moodEntriesBox).clear(),
        Hive.box(_chatMessagesBox).clear(),
        Hive.box(_conversationsBox).clear(),
        Hive.box(_chatSessionsBox).clear(),
        Hive.box(_scripturesBox).clear(),
        Hive.box(_scriptureReadingsBox).clear(),
        Hive.box(_userPreferencesBox).clear(),
        Hive.box(_appSettingsBox).clear(),
        Hive.box(_userAnalyticsBox).clear(),
      ]);
      
      AppLogger.info('All Hive data cleared');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear Hive data', e, stackTrace);
      rethrow;
    }
  }

  /// Close all boxes
  Future<void> close() async {
    if (!_isInitialized) {
      AppLogger.debug('Hive service not initialized, nothing to close');
      return;
    }

    try {
      await Hive.close();
      _isInitialized = false;
      AppLogger.info('Hive service closed');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to close Hive service', e, stackTrace);
      rethrow;
    }
  }

  /// Get database size information
  Future<Map<String, int>> getDatabaseInfo() async {
    if (!_isInitialized) {
      return {
        'prayers': 0,
        'moodEntries': 0,
        'chatMessages': 0,
        'conversations': 0,
        'chatSessions': 0,
        'scriptures': 0,
        'scriptureReadings': 0,
        'userPreferences': 0,
        'appSettings': 0,
        'userAnalytics': 0,
      };
    }

    try {
      return {
        'prayers': Hive.box(_prayersBox).length,
        'moodEntries': Hive.box(_moodEntriesBox).length,
        'chatMessages': Hive.box(_chatMessagesBox).length,
        'conversations': Hive.box(_conversationsBox).length,
        'chatSessions': Hive.box(_chatSessionsBox).length,
        'scriptures': Hive.box(_scripturesBox).length,
        'scriptureReadings': Hive.box(_scriptureReadingsBox).length,
        'userPreferences': Hive.box(_userPreferencesBox).length,
        'appSettings': Hive.box(_appSettingsBox).length,
        'userAnalytics': Hive.box(_userAnalyticsBox).length,
      };
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get database info', e, stackTrace);
      return {};
    }
  }

  /// Compact all boxes to reduce storage size
  Future<void> compactAll() async {
    if (!_isInitialized) {
      AppLogger.warning('Cannot compact - Hive not initialized');
      return;
    }

    try {
      await Future.wait([
        Hive.box(_prayersBox).compact(),
        Hive.box(_moodEntriesBox).compact(),
        Hive.box(_chatMessagesBox).compact(),
        Hive.box(_conversationsBox).compact(),
        Hive.box(_chatSessionsBox).compact(),
        Hive.box(_scripturesBox).compact(),
        Hive.box(_scriptureReadingsBox).compact(),
        Hive.box(_userPreferencesBox).compact(),
        Hive.box(_appSettingsBox).compact(),
        Hive.box(_userAnalyticsBox).compact(),
      ]);
      
      AppLogger.info('All Hive boxes compacted');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to compact Hive boxes', e, stackTrace);
    }
  }
}
