import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/logger.dart';
import '../../features/mood/models/simple_mood_entry.dart';

/// Comprehensive analytics service for insights and growth optimization
class AdvancedAnalyticsService {
  static final AdvancedAnalyticsService _instance = AdvancedAnalyticsService._internal();
  factory AdvancedAnalyticsService() => _instance;
  AdvancedAnalyticsService._internal();

  static AdvancedAnalyticsService get instance => _instance;

  bool _initialized = false;
  String? _userId;
  String? _sessionId;
  DateTime? _sessionStartTime;
  final Map<String, dynamic> _deviceInfo = {};
  final List<Map<String, dynamic>> _eventQueue = [];
  Timer? _flushTimer;

  // Analytics keys
  static const String _analyticsPrefix = 'healpray_analytics';
  static const String _userIdKey = '${_analyticsPrefix}_user_id';
  static const String _sessionCountKey = '${_analyticsPrefix}_session_count';
  static const String _firstLaunchKey = '${_analyticsPrefix}_first_launch';
  static const String _lastActiveKey = '${_analyticsPrefix}_last_active';

  /// Initialize analytics system
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      await _initializeDeviceInfo();
      await _initializeUser();
      await _startSession();
      _scheduleEventFlush();

      _initialized = true;
      AppLogger.info('Advanced analytics service initialized');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize advanced analytics', e, stackTrace);
      return false;
    }
  }

  /// Initialize device information
  Future<void> _initializeDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      _deviceInfo['app_version'] = packageInfo.version;
      _deviceInfo['build_number'] = packageInfo.buildNumber;
      _deviceInfo['package_name'] = packageInfo.packageName;
      _deviceInfo['platform'] = defaultTargetPlatform.name;

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceInfo['device_model'] = iosInfo.model;
        _deviceInfo['os_version'] = iosInfo.systemVersion;
        _deviceInfo['device_name'] = iosInfo.name;
        _deviceInfo['is_simulator'] = !iosInfo.isPhysicalDevice;
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceInfo['device_model'] = androidInfo.model;
        _deviceInfo['os_version'] = androidInfo.version.release;
        _deviceInfo['manufacturer'] = androidInfo.manufacturer;
        _deviceInfo['is_emulator'] = !androidInfo.isPhysicalDevice;
      }

      AppLogger.debug('Device info initialized');
    } catch (e) {
      AppLogger.error('Failed to get device info', e);
    }
  }

  /// Initialize user tracking
  Future<void> _initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get or create user ID
    _userId = prefs.getString(_userIdKey);
    if (_userId == null) {
      _userId = _generateUserId();
      await prefs.setString(_userIdKey, _userId!);
      
      // Track first launch
      await prefs.setString(_firstLaunchKey, DateTime.now().toIso8601String());
      trackEvent('app_installed', {
        'install_date': DateTime.now().toIso8601String(),
      });
    }

    // Update last active
    await prefs.setString(_lastActiveKey, DateTime.now().toIso8601String());
  }

  /// Start new session
  Future<void> _startSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    _sessionId = _generateSessionId();
    _sessionStartTime = DateTime.now();
    
    // Increment session count
    final sessionCount = prefs.getInt(_sessionCountKey) ?? 0;
    await prefs.setInt(_sessionCountKey, sessionCount + 1);

    trackEvent('session_start', {
      'session_id': _sessionId,
      'session_count': sessionCount + 1,
      'timestamp': _sessionStartTime!.toIso8601String(),
    });
  }

  /// Schedule periodic event flushing
  void _scheduleEventFlush() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _flushEvents();
    });
  }

  /// Track general event
  void trackEvent(String eventName, [Map<String, dynamic>? properties]) {
    if (!_initialized) return;

    final event = {
      'event_name': eventName,
      'properties': {
        ...?properties,
        'user_id': _userId,
        'session_id': _sessionId,
        'timestamp': DateTime.now().toIso8601String(),
        ..._deviceInfo,
      },
    };

    _eventQueue.add(event);
    AppLogger.debug('Analytics event tracked: $eventName');

    // Flush immediately for critical events
    if (_isCriticalEvent(eventName)) {
      _flushEvents();
    }
  }

  /// Track user engagement metrics
  void trackEngagement({
    required String feature,
    required Duration sessionDuration,
    Map<String, dynamic>? metadata,
  }) {
    trackEvent('feature_engagement', {
      'feature': feature,
      'session_duration_seconds': sessionDuration.inSeconds,
      'session_duration_minutes': sessionDuration.inMinutes,
      ...?metadata,
    });
  }

  /// Track mood entry with analytics
  void trackMoodEntry({
    required SimpleMoodEntry moodEntry,
    required String entryMethod,
  }) {
    trackEvent('mood_entry_created', {
      'mood_score': moodEntry.score,
      'emotions_count': moodEntry.emotions.length,
      'has_notes': moodEntry.notes?.isNotEmpty ?? false,
      'has_location': moodEntry.location != null,
      'metadata_count': moodEntry.metadata.length,
      'entry_method': entryMethod,
      'hour_of_day': moodEntry.timestamp.hour,
      'day_of_week': moodEntry.timestamp.weekday,
    });

    // Track mood trends
    _trackMoodTrends(moodEntry);
  }

  /// Track prayer generation analytics
  void trackPrayerGeneration({
    required String prayerCategory,
    required String aiModel,
    required Duration generationTime,
    required int characterCount,
    String? moodContext,
  }) {
    trackEvent('prayer_generated', {
      'category': prayerCategory,
      'ai_model': aiModel,
      'generation_time_ms': generationTime.inMilliseconds,
      'character_count': characterCount,
      'word_count': _estimateWordCount(characterCount),
      'mood_context': moodContext,
      'hour_of_day': DateTime.now().hour,
    });
  }

  /// Track meditation session analytics
  void trackMeditationSession({
    required String meditationType,
    required Duration sessionDuration,
    required Duration plannedDuration,
    required bool completedFully,
  }) {
    trackEvent('meditation_session', {
      'meditation_type': meditationType,
      'session_duration_seconds': sessionDuration.inSeconds,
      'planned_duration_seconds': plannedDuration.inSeconds,
      'completion_rate': sessionDuration.inSeconds / plannedDuration.inSeconds,
      'completed_fully': completedFully,
      'abandoned': !completedFully,
      'hour_of_day': DateTime.now().hour,
    });
  }

  /// Track crisis detection events
  void trackCrisisDetection({
    required String crisisLevel,
    required double riskScore,
    required List<String> triggerFactors,
    required String interventionOffered,
  }) {
    trackEvent('crisis_detected', {
      'crisis_level': crisisLevel,
      'risk_score': riskScore,
      'trigger_factors': triggerFactors,
      'intervention_offered': interventionOffered,
      'immediate_response': true,
    });
  }

  /// Track user retention metrics
  void trackRetention() {
    trackEvent('daily_active_user', {
      'date': DateTime.now().toIso8601String().split('T')[0],
    });
  }

  /// Track feature adoption
  void trackFeatureAdoption({
    required String feature,
    required bool firstTime,
    String? onboardingStep,
  }) {
    if (firstTime) {
      trackEvent('feature_first_use', {
        'feature': feature,
        'onboarding_step': onboardingStep,
      });
    }

    trackEvent('feature_used', {
      'feature': feature,
      'first_time': firstTime,
    });
  }

  /// Track user journey funnel
  void trackFunnelStep({
    required String funnelName,
    required String stepName,
    required int stepNumber,
    Map<String, dynamic>? stepData,
  }) {
    trackEvent('funnel_step', {
      'funnel_name': funnelName,
      'step_name': stepName,
      'step_number': stepNumber,
      'step_data': stepData,
    });
  }

  /// Track error events
  void trackError({
    required String errorType,
    required String errorMessage,
    String? feature,
    String? stackTrace,
  }) {
    trackEvent('error_occurred', {
      'error_type': errorType,
      'error_message': errorMessage,
      'feature': feature,
      'has_stack_trace': stackTrace != null,
    });
  }

  /// Track performance metrics
  void trackPerformance({
    required String operation,
    required Duration duration,
    bool? success,
    Map<String, dynamic>? metadata,
  }) {
    trackEvent('performance_metric', {
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      'success': success,
      ...?metadata,
    });
  }

  /// Track A/B test variant
  void trackABTest({
    required String testName,
    required String variant,
    String? feature,
  }) {
    trackEvent('ab_test_exposure', {
      'test_name': testName,
      'variant': variant,
      'feature': feature,
    });
  }

  /// Get user analytics summary
  Future<Map<String, dynamic>> getUserAnalyticsSummary() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'user_id': _userId,
      'current_session_id': _sessionId,
      'session_count': prefs.getInt(_sessionCountKey) ?? 0,
      'first_launch': prefs.getString(_firstLaunchKey),
      'last_active': prefs.getString(_lastActiveKey),
      'session_start_time': _sessionStartTime?.toIso8601String(),
      'events_queued': _eventQueue.length,
      'device_info': _deviceInfo,
    };
  }

  /// Track mood trends for insights
  void _trackMoodTrends(SimpleMoodEntry moodEntry) {
    // Track mood score distribution
    final moodRange = _getMoodRange(moodEntry.score);
    trackEvent('mood_range_entry', {
      'mood_range': moodRange,
      'exact_score': moodEntry.score,
    });

    // Track emotion patterns
    for (final emotion in moodEntry.emotions) {
      trackEvent('emotion_selected', {
        'emotion': emotion,
        'mood_score': moodEntry.score,
      });
    }

    // Track trigger patterns (triggers are now just strings)
    // Note: triggers would need to be handled differently if they were objects
  }

  /// Get mood score range for analytics
  String _getMoodRange(int score) {
    if (score <= 2) return 'very_low';
    if (score <= 4) return 'low';
    if (score <= 6) return 'moderate';
    if (score <= 8) return 'good';
    return 'excellent';
  }

  /// Estimate word count from character count
  int _estimateWordCount(int characterCount) {
    return (characterCount / 5).round(); // Average word length approximation
  }

  /// Check if event is critical and needs immediate flushing
  bool _isCriticalEvent(String eventName) {
    const criticalEvents = [
      'crisis_detected',
      'error_occurred',
      'session_start',
      'app_installed',
    ];
    return criticalEvents.contains(eventName);
  }

  /// Flush events to analytics backend
  void _flushEvents() {
    if (_eventQueue.isEmpty) return;

    // In a real app, this would send events to your analytics backend
    // For now, we'll just log them locally
    AppLogger.info('Flushing ${_eventQueue.length} analytics events');
    
    // Simulate sending to backend
    _sendEventsToBackend(List.from(_eventQueue));
    _eventQueue.clear();
  }

  /// Send events to analytics backend (placeholder)
  Future<void> _sendEventsToBackend(List<Map<String, dynamic>> events) async {
    try {
      // Placeholder for actual analytics service integration
      // This could be Firebase Analytics, Mixpanel, Amplitude, etc.
      
      // For development, log a summary
      final eventSummary = <String, int>{};
      for (final event in events) {
        final eventName = event['event_name'] as String;
        eventSummary[eventName] = (eventSummary[eventName] ?? 0) + 1;
      }
      
      AppLogger.debug('Analytics events sent: $eventSummary');
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 100));
      
    } catch (e) {
      AppLogger.error('Failed to send analytics events', e);
      // In case of failure, we could store events locally for retry
    }
  }

  /// Generate unique user ID
  String _generateUserId() {
    final random = math.Random.secure();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = random.nextInt(999999).toString().padLeft(6, '0');
    return 'user_${timestamp}_$randomSuffix';
  }

  /// Generate unique session ID
  String _generateSessionId() {
    final random = math.Random.secure();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = random.nextInt(9999).toString().padLeft(4, '0');
    return 'session_${timestamp}_$randomSuffix';
  }

  /// End current session
  void endSession() {
    if (_sessionStartTime != null) {
      final sessionDuration = DateTime.now().difference(_sessionStartTime!);
      trackEvent('session_end', {
        'session_id': _sessionId,
        'session_duration_seconds': sessionDuration.inSeconds,
        'session_duration_minutes': sessionDuration.inMinutes,
      });
      
      _flushEvents(); // Ensure session end is recorded
    }
  }

  /// Dispose analytics service
  void dispose() {
    endSession();
    _flushTimer?.cancel();
    _flushEvents(); // Final flush
    _initialized = false;
    AppLogger.info('Advanced analytics service disposed');
  }
}

/// Analytics dashboard data aggregation
class AnalyticsDashboard {
  static final Map<String, List<Map<String, dynamic>>> _storedEvents = {};

  /// Add analytics event for dashboard (development/testing)
  static void addEvent(String eventName, Map<String, dynamic> properties) {
    _storedEvents.putIfAbsent(eventName, () => []);
    _storedEvents[eventName]!.add({
      ...properties,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Get dashboard insights
  static Map<String, dynamic> getDashboardInsights() {
    final insights = <String, dynamic>{};
    
    // User engagement insights
    insights['total_events'] = _storedEvents.values.fold<int>(
      0, (sum, events) => sum + events.length);
    
    insights['unique_event_types'] = _storedEvents.keys.length;
    
    // Most common events
    final eventCounts = <String, int>{};
    _storedEvents.forEach((eventName, events) {
      eventCounts[eventName] = events.length;
    });
    
    final sortedEvents = eventCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    insights['top_events'] = sortedEvents.take(10)
      .map((e) => {'event': e.key, 'count': e.value})
      .toList();
    
    // Recent activity (last hour)
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    var recentEventCount = 0;
    
    _storedEvents.forEach((eventName, events) {
      recentEventCount += events.where((event) {
        final timestamp = DateTime.parse(event['timestamp']);
        return timestamp.isAfter(oneHourAgo);
      }).length;
    });
    
    insights['recent_activity_count'] = recentEventCount;
    insights['generated_at'] = DateTime.now().toIso8601String();
    
    return insights;
  }

  /// Clear stored events (for testing)
  static void clearEvents() {
    _storedEvents.clear();
  }
}
