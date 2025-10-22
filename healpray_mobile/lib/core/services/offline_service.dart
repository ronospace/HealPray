import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/logger.dart';
import '../../features/mood/models/simple_mood_entry.dart';
import '../../shared/models/prayer.dart';
import '../../features/meditation/models/meditation_session.dart';

/// Offline-first service that enables HealPray to work seamlessly without internet
class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  static OfflineService get instance => _instance;

  // Hive boxes for offline storage
  static const String _moodEntriesBox = 'offline_mood_entries';
  static const String _prayersBox = 'offline_prayers';
  static const String _meditationSessionsBox = 'offline_meditation_sessions';
  static const String _cachedPrayersBox = 'cached_prayers';
  static const String _syncQueueBox = 'sync_queue';
  static const String _offlinePrayerTemplatesBox = 'offline_prayer_templates';

  late Box<Map<dynamic, dynamic>> _moodEntriesBoxInstance;
  late Box<Map<dynamic, dynamic>> _prayersBoxInstance;
  late Box<Map<dynamic, dynamic>> _meditationSessionsBoxInstance;
  late Box<String> _cachedPrayersBoxInstance;
  late Box<Map<dynamic, dynamic>> _syncQueueBoxInstance;
  late Box<String> _offlinePrayerTemplatesBoxInstance;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = false;
  bool _initialized = false;

  // Offline prayer templates for when AI generation isn't available
  final List<Map<String, String>> _prayerTemplates = [
    {
      'category': 'gratitude',
      'template': 'Thank you, Divine Source, for the countless blessings in my life. Today I am especially grateful for {specific_blessing}. Help me to remember that even in challenging times, there is always something to appreciate. May my heart overflow with gratitude and may I share this blessing with others. Amen.',
    },
    {
      'category': 'strength',
      'template': 'Divine Source of strength, I come to you feeling overwhelmed and in need of your power. Please grant me the courage to face {current_challenge} with dignity and grace. Help me remember that I am stronger than I know and that you are always with me. Fill me with your peace and guide my steps forward. Amen.',
    },
    {
      'category': 'peace',
      'template': 'God of peace, quiet the storms within my heart and mind. In this moment of {current_emotion}, I seek your calming presence. Help me to breathe deeply, release my worries, and trust in your loving care. May your peace, which surpasses all understanding, guard my heart and mind. Amen.',
    },
    {
      'category': 'guidance',
      'template': 'Wise and loving God, I stand at a crossroads regarding {decision_area} and seek your divine guidance. Open my heart to hear your voice and my mind to understand your will. Grant me wisdom to make choices that align with your love and purpose for my life. Lead me on the path that brings healing and growth. Amen.',
    },
    {
      'category': 'healing',
      'template': 'Great Healer, I bring before you my need for healing - whether physical, emotional, or spiritual regarding {healing_area}. Touch me with your restorative power and grant me patience in the healing process. Help me to trust in your timing and to find hope even in difficult moments. Surround me with your love and the support of caring people. Amen.',
    },
    {
      'category': 'forgiveness',
      'template': 'Merciful God, I struggle with {forgiveness_issue} and need your help to forgive and be forgiven. Soften my heart and help me release the burden of resentment. Teach me to extend the same grace that you have shown me. Fill the empty spaces left by hurt with your love and healing. Amen.',
    },
    {
      'category': 'anxiety',
      'template': 'Loving God, anxiety about {worry_area} threatens to overwhelm me. Remind me that you hold my future in your hands and that I need not fear. Help me to cast all my anxieties on you, knowing that you care for me deeply. Replace my fear with faith and my worry with worship. Grant me your perfect peace. Amen.',
    },
    {
      'category': 'hope',
      'template': 'God of hope, when despair clouds my vision regarding {hopeless_situation}, be my light. Help me to remember that every ending can be a new beginning and that your love never fails. Renew my hope and strength like the eagle\'s. Show me the possibilities I cannot yet see and fill me with anticipation for better days ahead. Amen.',
    },
  ];

  /// Initialize the offline service
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      // Initialize Hive boxes for offline storage
      await _initializeHiveBoxes();

      // Initialize offline prayer templates
      await _initializeOfflinePrayerTemplates();

      // Setup connectivity monitoring
      await _setupConnectivityMonitoring();

      // Process any pending sync operations
      _processSyncQueue();

      _initialized = true;
      AppLogger.info('Offline service initialized successfully');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize offline service', e, stackTrace);
      return false;
    }
  }

  /// Initialize Hive boxes for offline storage
  Future<void> _initializeHiveBoxes() async {
    _moodEntriesBoxInstance = await Hive.openBox<Map<dynamic, dynamic>>(_moodEntriesBox);
    _prayersBoxInstance = await Hive.openBox<Map<dynamic, dynamic>>(_prayersBox);
    _meditationSessionsBoxInstance = await Hive.openBox<Map<dynamic, dynamic>>(_meditationSessionsBox);
    _cachedPrayersBoxInstance = await Hive.openBox<String>(_cachedPrayersBox);
    _syncQueueBoxInstance = await Hive.openBox<Map<dynamic, dynamic>>(_syncQueueBox);
    _offlinePrayerTemplatesBoxInstance = await Hive.openBox<String>(_offlinePrayerTemplatesBox);
  }

  /// Initialize offline prayer templates
  Future<void> _initializeOfflinePrayerTemplates() async {
    // Only populate templates if box is empty (first run)
    if (_offlinePrayerTemplatesBoxInstance.isEmpty) {
      for (int i = 0; i < _prayerTemplates.length; i++) {
        final template = _prayerTemplates[i];
        await _offlinePrayerTemplatesBoxInstance.put(
          '${template['category']}_$i',
          jsonEncode(template),
        );
      }
      AppLogger.info('Offline prayer templates initialized');
    }
  }

  /// Setup connectivity monitoring
  Future<void> _setupConnectivityMonitoring() async {
    // Check initial connectivity
    final connectivityResult = await _connectivity.checkConnectivity();
    _isOnline = !connectivityResult.contains(ConnectivityResult.none);

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final wasOnline = _isOnline;
        _isOnline = !results.contains(ConnectivityResult.none);

        if (!wasOnline && _isOnline) {
          AppLogger.info('Internet connection restored - processing sync queue');
          _processSyncQueue();
        } else if (wasOnline && !_isOnline) {
          AppLogger.info('Internet connection lost - switching to offline mode');
        }
      },
    );
  }

  /// Save mood entry with offline support
  Future<bool> saveMoodEntry(SimpleMoodEntry moodEntry) async {
    try {
      // Always save locally first
      final moodData = moodEntry.toJson();
      await _moodEntriesBoxInstance.put(moodEntry.id, moodData);

      // If online, attempt to sync immediately
      if (_isOnline) {
        await _addToSyncQueue('mood_entry', 'create', moodData);
      } else {
        // Queue for later sync
        await _addToSyncQueue('mood_entry', 'create', moodData);
      }

      AppLogger.info('Mood entry saved offline: ${moodEntry.id}');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save mood entry offline', e, stackTrace);
      return false;
    }
  }

  /// Get mood entries from offline storage
  Future<List<SimpleMoodEntry>> getOfflineMoodEntries() async {
    try {
      final List<SimpleMoodEntry> entries = [];
      
      for (final entry in _moodEntriesBoxInstance.values) {
        try {
          final moodEntry = SimpleMoodEntry.fromJson(Map<String, dynamic>.from(entry));
          entries.add(moodEntry);
        } catch (e) {
          AppLogger.warning('Failed to parse mood entry from offline storage: $e');
        }
      }

      // Sort by timestamp, newest first
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      AppLogger.info('Retrieved ${entries.length} mood entries from offline storage');
      return entries;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get offline mood entries', e, stackTrace);
      return [];
    }
  }

  /// Generate offline prayer using templates
  Future<String> generateOfflinePrayer({
    required String category,
    required String mood,
    Map<String, String> personalContext = const {},
  }) async {
    try {
      // Find matching template
      String? templateJson;
      
      for (final key in _offlinePrayerTemplatesBoxInstance.keys) {
        if (key.toString().startsWith(category.toLowerCase())) {
          templateJson = _offlinePrayerTemplatesBoxInstance.get(key);
          break;
        }
      }

      // Fallback to gratitude if no specific category found
      templateJson ??= _offlinePrayerTemplatesBoxInstance.get('gratitude_0');
      
      if (templateJson == null) {
        return _getGenericOfflinePrayer(mood);
      }

      final template = Map<String, String>.from(jsonDecode(templateJson));
      String prayer = template['template'] ?? _getGenericOfflinePrayer(mood);

      // Replace placeholders with personal context
      prayer = _personalizePrayer(prayer, personalContext, mood);

      // Cache the generated prayer
      final prayerId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
      await _cachedPrayersBoxInstance.put(prayerId, prayer);

      AppLogger.info('Generated offline prayer for category: $category');
      return prayer;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to generate offline prayer', e, stackTrace);
      return _getGenericOfflinePrayer(mood);
    }
  }

  /// Personalize prayer template with context
  String _personalizePrayer(String template, Map<String, String> context, String mood) {
    String personalizedPrayer = template;

    // Replace common placeholders
    personalizedPrayer = personalizedPrayer.replaceAll('{current_emotion}', mood.toLowerCase());
    personalizedPrayer = personalizedPrayer.replaceAll('{specific_blessing}', 
        context['blessing'] ?? 'the gift of this day');
    personalizedPrayer = personalizedPrayer.replaceAll('{current_challenge}', 
        context['challenge'] ?? 'the challenges before me');
    personalizedPrayer = personalizedPrayer.replaceAll('{decision_area}', 
        context['decision'] ?? 'the decisions I must make');
    personalizedPrayer = personalizedPrayer.replaceAll('{healing_area}', 
        context['healing'] ?? 'all areas of my life that need restoration');
    personalizedPrayer = personalizedPrayer.replaceAll('{forgiveness_issue}', 
        context['forgiveness'] ?? 'matters of forgiveness in my heart');
    personalizedPrayer = personalizedPrayer.replaceAll('{worry_area}', 
        context['worry'] ?? 'the uncertainties of tomorrow');
    personalizedPrayer = personalizedPrayer.replaceAll('{hopeless_situation}', 
        context['hopeless'] ?? 'the difficulties I face');

    return personalizedPrayer;
  }

  /// Get generic offline prayer for any mood
  String _getGenericOfflinePrayer(String mood) {
    switch (mood.toLowerCase()) {
      case 'anxious':
      case 'worried':
      case 'stressed':
        return 'Divine Source of peace, in this moment of anxiety, I seek your calming presence. Help me to breathe deeply and trust in your care. Grant me the serenity to accept what I cannot change and the courage to change what I can. Fill my heart with your peace. Amen.';
      
      case 'sad':
      case 'depressed':
      case 'lonely':
        return 'Loving God, in this time of sadness, wrap me in your comforting embrace. Remind me that this feeling will pass and that you are always with me. Help me to find hope in small things and strength in your love. Bring healing to my heart. Amen.';
      
      case 'angry':
      case 'frustrated':
      case 'annoyed':
        return 'God of patience, help me to channel my anger into positive action. Grant me wisdom to understand the source of my frustration and the strength to respond with grace. Cool the fire in my heart and fill me with your peace instead. Amen.';
      
      case 'grateful':
      case 'thankful':
      case 'blessed':
        return 'Thank you, gracious God, for the abundance of blessings in my life. Today my heart overflows with gratitude. Help me to share this joy with others and to remember your goodness in all circumstances. May my gratitude be a prayer of praise. Amen.';
      
      default:
        return 'Loving God, meet me where I am in this moment. You know my heart and all that I feel. Grant me your peace, your wisdom, and your strength. Help me to trust in your love and to find hope for tomorrow. Be with me now and always. Amen.';
    }
  }

  /// Save prayer offline
  Future<bool> savePrayerOffline(Prayer prayer) async {
    try {
      final prayerData = prayer.toJson();
      await _prayersBoxInstance.put(prayer.id, prayerData);
      
      // Queue for sync when online
      if (!_isOnline) {
        await _addToSyncQueue('prayer', 'create', prayerData);
      }

      AppLogger.info('Prayer saved offline: ${prayer.id}');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save prayer offline', e, stackTrace);
      return false;
    }
  }

  /// Get offline prayers
  Future<List<Prayer>> getOfflinePrayers() async {
    try {
      final List<Prayer> prayers = [];
      
      for (final entry in _prayersBoxInstance.values) {
        try {
          final prayer = Prayer.fromJson(Map<String, dynamic>.from(entry));
          prayers.add(prayer);
        } catch (e) {
          AppLogger.warning('Failed to parse prayer from offline storage: $e');
        }
      }

      // Sort by date, newest first
      prayers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return prayers;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get offline prayers', e, stackTrace);
      return [];
    }
  }

  /// Save meditation session offline
  Future<bool> saveMeditationSessionOffline(MeditationSession session) async {
    try {
      final sessionData = session.toJson();
      await _meditationSessionsBoxInstance.put(session.id, sessionData);
      
      // Queue for sync when online
      if (!_isOnline) {
        await _addToSyncQueue('meditation_session', 'create', sessionData);
      }

      AppLogger.info('Meditation session saved offline: ${session.id}');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save meditation session offline', e, stackTrace);
      return false;
    }
  }

  /// Get offline meditation sessions
  Future<List<MeditationSession>> getOfflineMeditationSessions() async {
    try {
      final List<MeditationSession> sessions = [];
      
      for (final entry in _meditationSessionsBoxInstance.values) {
        try {
          final session = MeditationSession.fromJson(Map<String, dynamic>.from(entry));
          sessions.add(session);
        } catch (e) {
          AppLogger.warning('Failed to parse meditation session from offline storage: $e');
        }
      }

      // Sort by date, newest first
      sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      
      return sessions;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get offline meditation sessions', e, stackTrace);
      return [];
    }
  }

  /// Add item to sync queue
  Future<void> _addToSyncQueue(String type, String action, Map<String, dynamic> data) async {
    final syncItem = {
      'type': type,
      'action': action,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'retryCount': 0,
    };

    final syncId = 'sync_${DateTime.now().millisecondsSinceEpoch}_${type}_$action';
    await _syncQueueBoxInstance.put(syncId, syncItem);
    
    AppLogger.debug('Added to sync queue: $syncId');
  }

  /// Process sync queue when online
  void _processSyncQueue() async {
    if (!_isOnline || _syncQueueBoxInstance.isEmpty) return;

    AppLogger.info('Processing sync queue with ${_syncQueueBoxInstance.length} items');

    final itemsToRemove = <String>[];
    
    for (final entry in _syncQueueBoxInstance.toMap().entries) {
      final key = entry.key;
      final syncItem = Map<String, dynamic>.from(entry.value);

      try {
        final bool success = await _syncItemToServer(syncItem);
        
        if (success) {
          itemsToRemove.add(key);
          AppLogger.debug('Successfully synced item: $key');
        } else {
          // Increment retry count
          syncItem['retryCount'] = (syncItem['retryCount'] ?? 0) + 1;
          
          // Remove items that have failed too many times
          if (syncItem['retryCount'] > 5) {
            itemsToRemove.add(key);
            AppLogger.warning('Removing failed sync item after max retries: $key');
          } else {
            await _syncQueueBoxInstance.put(key, syncItem);
          }
        }
      } catch (e) {
        AppLogger.error('Failed to sync item $key', e);
        
        // Increment retry count
        syncItem['retryCount'] = (syncItem['retryCount'] ?? 0) + 1;
        await _syncQueueBoxInstance.put(key, syncItem);
      }
    }

    // Remove successfully synced items
    for (final key in itemsToRemove) {
      await _syncQueueBoxInstance.delete(key);
    }

    if (itemsToRemove.isNotEmpty) {
      AppLogger.info('Sync completed: ${itemsToRemove.length} items synced successfully');
    }
  }

  /// Sync individual item to server (placeholder for actual API calls)
  Future<bool> _syncItemToServer(Map<String, dynamic> syncItem) async {
    // This is a placeholder for actual server sync logic
    // In a real implementation, you would make API calls here
    
    final String type = syncItem['type'];
    final String action = syncItem['action'];
    final Map<String, dynamic> data = Map<String, dynamic>.from(syncItem['data']);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    AppLogger.debug('Syncing to server: $type $action');
    
    switch (type) {
      case 'mood_entry':
        return await _syncMoodEntryToServer(action, data);
      case 'prayer':
        return await _syncPrayerToServer(action, data);
      case 'meditation_session':
        return await _syncMeditationSessionToServer(action, data);
      default:
        AppLogger.warning('Unknown sync type: $type');
        return false;
    }
  }

  /// Sync mood entry to server
  Future<bool> _syncMoodEntryToServer(String action, Map<String, dynamic> data) async {
    // Placeholder for actual API call
    // In a real app, this would call your backend API
    AppLogger.debug('Would sync mood entry to server: $action');
    return true; // Assume success for offline demo
  }

  /// Sync prayer to server
  Future<bool> _syncPrayerToServer(String action, Map<String, dynamic> data) async {
    // Placeholder for actual API call
    AppLogger.debug('Would sync prayer to server: $action');
    return true; // Assume success for offline demo
  }

  /// Sync meditation session to server
  Future<bool> _syncMeditationSessionToServer(String action, Map<String, dynamic> data) async {
    // Placeholder for actual API call
    AppLogger.debug('Would sync meditation session to server: $action');
    return true; // Assume success for offline demo
  }

  /// Check if device is online
  bool get isOnline => _isOnline;

  /// Get sync queue status
  Future<Map<String, dynamic>> getSyncQueueStatus() async {
    return {
      'pendingItems': _syncQueueBoxInstance.length,
      'isOnline': _isOnline,
      'lastSyncAttempt': DateTime.now().toIso8601String(),
    };
  }

  /// Clear all offline data (use carefully)
  Future<void> clearOfflineData() async {
    await _moodEntriesBoxInstance.clear();
    await _prayersBoxInstance.clear();
    await _meditationSessionsBoxInstance.clear();
    await _cachedPrayersBoxInstance.clear();
    AppLogger.info('All offline data cleared');
  }

  /// Force sync attempt
  Future<void> forceSyncAttempt() async {
    if (_isOnline) {
      _processSyncQueue();
    } else {
      AppLogger.warning('Cannot force sync - device is offline');
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _initialized = false;
    AppLogger.info('Offline service disposed');
  }
}
