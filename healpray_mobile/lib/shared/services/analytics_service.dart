import 'package:firebase_analytics/firebase_analytics.dart';

import '../../core/config/app_config.dart';
import '../../core/utils/logger.dart';

/// Analytics service for tracking user events
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService _instance = AnalyticsService._();
  static AnalyticsService get instance => _instance;

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static bool _initialized = false;

  /// Initialize analytics service
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (AppConfig.enableAnalytics) {
        await _analytics.setAnalyticsCollectionEnabled(true);

        // Set app info
        await _analytics.setUserProperty(
          name: 'app_version',
          value: AppConfig.appVersion,
        );

        await _analytics.setUserProperty(
          name: 'environment',
          value: AppConfig.environment,
        );

        _initialized = true;
        AppLogger.info('Analytics service initialized');
      }
    } catch (error) {
      AppLogger.error('Failed to initialize analytics service', error);
    }
  }

  /// Track app launch
  static Future<void> trackAppLaunch() async {
    if (!_initialized) return;

    try {
      await _analytics.logAppOpen();
      AppLogger.debug('App launch tracked');
    } catch (error) {
      AppLogger.error('Failed to track app launch', error);
    }
  }

  /// Track app resumed
  static Future<void> trackAppResumed() async {
    if (!_initialized) return;

    try {
      await _analytics.logEvent(
        name: 'app_resumed',
        parameters: {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (error) {
      AppLogger.error('Failed to track app resumed', error);
    }
  }

  /// Track app paused
  static Future<void> trackAppPaused() async {
    if (!_initialized) return;

    try {
      await _analytics.logEvent(
        name: 'app_paused',
        parameters: {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (error) {
      AppLogger.error('Failed to track app paused', error);
    }
  }

  /// Track user sign in
  static Future<void> trackSignIn(String method) async {
    if (!_initialized) return;

    try {
      await _analytics.logLogin(loginMethod: method);
      AppLogger.debug('Sign in tracked: $method');
    } catch (error) {
      AppLogger.error('Failed to track sign in', error);
    }
  }

  /// Track user sign up
  static Future<void> trackSignUp(String method) async {
    if (!_initialized) return;

    try {
      await _analytics.logSignUp(signUpMethod: method);
      AppLogger.debug('Sign up tracked: $method');
    } catch (error) {
      AppLogger.error('Failed to track sign up', error);
    }
  }

  /// Track prayer generation
  static Future<void> trackPrayerGenerated({
    required String prayerType,
    required int moodLevel,
    required String aiModel,
    required int generationTimeMs,
  }) async {
    if (!_initialized) return;

    try {
      await _analytics.logEvent(
        name: 'prayer_generated',
        parameters: {
          'prayer_type': prayerType,
          'mood_level': moodLevel,
          'ai_model': aiModel,
          'generation_time_ms': generationTimeMs,
        },
      );
    } catch (error) {
      AppLogger.error('Failed to track prayer generation', error);
    }
  }

  /// Track mood entry
  static Future<void> trackMoodEntry({
    required int moodScore,
    required String emotion,
    List<String>? triggers,
    List<String>? activities,
  }) async {
    if (!_initialized) return;

    try {
      await _analytics.logEvent(
        name: 'mood_entry',
        parameters: {
          'mood_score': moodScore,
          'emotion': emotion,
          'trigger_count': triggers?.length ?? 0,
          'activity_count': activities?.length ?? 0,
        },
      );
    } catch (error) {
      AppLogger.error('Failed to track mood entry', error);
    }
  }

  /// Track AI conversation start
  static Future<void> trackConversationStart(String conversationType) async {
    if (!_initialized) return;

    try {
      await _analytics.logEvent(
        name: 'conversation_start',
        parameters: {
          'conversation_type': conversationType,
        },
      );
    } catch (error) {
      AppLogger.error('Failed to track conversation start', error);
    }
  }

  /// Track screen view
  static Future<void> trackScreenView(String screenName) async {
    if (!_initialized) return;

    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (error) {
      AppLogger.error('Failed to track screen view', error);
    }
  }

  /// Track crisis detection
  static Future<void> trackCrisisDetected({
    required double averageMood,
    required String riskLevel,
  }) async {
    if (!_initialized) return;

    try {
      await _analytics.logEvent(
        name: 'crisis_detected',
        parameters: {
          'average_mood': averageMood,
          'risk_level': riskLevel,
        },
      );
    } catch (error) {
      AppLogger.error('Failed to track crisis detection', error);
    }
  }

  /// Track feature usage
  static Future<void> trackFeatureUsage(String featureName) async {
    if (!_initialized) return;

    try {
      await _analytics.logEvent(
        name: 'feature_used',
        parameters: {
          'feature_name': featureName,
        },
      );
    } catch (error) {
      AppLogger.error('Failed to track feature usage', error);
    }
  }

  /// Track error
  static Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? screen,
  }) async {
    if (!_initialized) return;

    try {
      await _analytics.logEvent(
        name: 'app_error',
        parameters: {
          'error_type': errorType,
          'error_message': errorMessage,
          if (screen != null) 'screen': screen,
        },
      );
    } catch (error) {
      AppLogger.error('Failed to track error', error);
    }
  }

  /// Set user properties
  static Future<void> setUserProperties({
    String? denomination,
    String? language,
    String? spiritualTone,
    int? totalPrayers,
    int? totalMoodEntries,
    int? currentStreak,
  }) async {
    if (!_initialized) return;

    try {
      if (denomination != null) {
        await _analytics.setUserProperty(
            name: 'denomination', value: denomination);
      }

      if (language != null) {
        await _analytics.setUserProperty(name: 'language', value: language);
      }

      if (spiritualTone != null) {
        await _analytics.setUserProperty(
            name: 'spiritual_tone', value: spiritualTone);
      }

      if (totalPrayers != null) {
        await _analytics.setUserProperty(
            name: 'total_prayers', value: totalPrayers.toString());
      }

      if (totalMoodEntries != null) {
        await _analytics.setUserProperty(
            name: 'total_mood_entries', value: totalMoodEntries.toString());
      }

      if (currentStreak != null) {
        await _analytics.setUserProperty(
            name: 'current_streak', value: currentStreak.toString());
      }
    } catch (error) {
      AppLogger.error('Failed to set user properties', error);
    }
  }

  /// Get analytics instance
  static FirebaseAnalytics get firebase => _analytics;

  // Instance methods for compatibility
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    if (!_initialized) return;

    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters?.cast<String, Object>(),
      );
    } catch (error) {
      AppLogger.error('Failed to log event: $name', error);
    }
  }

  Future<void> logScreenView(String screenName,
      [Map<String, dynamic>? parameters]) async {
    await trackScreenView(screenName);
  }

  // Alias for backward compatibility
  Future<void> trackEvent(String name,
      [Map<String, dynamic>? parameters]) async {
    await logEvent(name, parameters);
  }
}
