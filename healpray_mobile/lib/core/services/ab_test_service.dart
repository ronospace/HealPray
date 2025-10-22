import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import 'advanced_analytics_service.dart';

/// A/B testing service for growth optimization
class ABTestService {
  static final ABTestService _instance = ABTestService._internal();
  factory ABTestService() => _instance;
  ABTestService._internal();

  static ABTestService get instance => _instance;

  static const String _abTestPrefix = 'healpray_ab_test';
  final Map<String, ABTestVariant> _activeTests = {};
  final Map<String, String> _userVariants = {};

  /// Initialize A/B testing service
  Future<void> initialize() async {
    await _loadUserVariants();
    _setupActiveTests();
    AppLogger.info('A/B test service initialized with ${_activeTests.length} tests');
  }

  /// Setup active A/B tests
  void _setupActiveTests() {
    // Test 1: Onboarding Flow
    _activeTests['onboarding_flow'] = ABTestVariant(
      testName: 'onboarding_flow',
      variants: ['original', 'simplified', 'detailed'],
      weights: [0.4, 0.3, 0.3],
      description: 'Testing different onboarding experiences',
    );

    // Test 2: Prayer Generation UI
    _activeTests['prayer_generation_ui'] = ABTestVariant(
      testName: 'prayer_generation_ui',
      variants: ['card_style', 'minimal', 'guided'],
      weights: [0.33, 0.33, 0.34],
      description: 'Testing different prayer generation interfaces',
    );

    // Test 3: Mood Tracking Frequency
    _activeTests['mood_tracking_frequency'] = ABTestVariant(
      testName: 'mood_tracking_frequency',
      variants: ['daily_only', 'multiple_daily', 'flexible'],
      weights: [0.5, 0.25, 0.25],
      description: 'Testing different mood tracking reminder frequencies',
    );

    // Test 4: Crisis Detection Sensitivity
    _activeTests['crisis_detection_sensitivity'] = ABTestVariant(
      testName: 'crisis_detection_sensitivity',
      variants: ['conservative', 'moderate', 'sensitive'],
      weights: [0.3, 0.4, 0.3],
      description: 'Testing different crisis detection thresholds',
    );

    // Test 5: Community Feature Prominence
    _activeTests['community_prominence'] = ABTestVariant(
      testName: 'community_prominence',
      variants: ['hidden', 'tab_bar', 'dashboard_card'],
      weights: [0.25, 0.5, 0.25],
      description: 'Testing community feature visibility',
    );

    // Test 6: Meditation Session Length Options
    _activeTests['meditation_session_lengths'] = ABTestVariant(
      testName: 'meditation_session_lengths',
      variants: ['short_only', 'varied_options', 'custom_length'],
      weights: [0.33, 0.34, 0.33],
      description: 'Testing different meditation duration options',
    );

    // Test 7: Notification Timing
    _activeTests['notification_timing'] = ABTestVariant(
      testName: 'notification_timing',
      variants: ['morning_focused', 'evening_focused', 'distributed'],
      weights: [0.33, 0.33, 0.34],
      description: 'Testing optimal notification timing',
    );

    // Test 8: AI Prayer Personalization
    _activeTests['ai_personalization'] = ABTestVariant(
      testName: 'ai_personalization',
      variants: ['basic', 'mood_based', 'comprehensive'],
      weights: [0.3, 0.4, 0.3],
      description: 'Testing levels of AI prayer personalization',
    );
  }

  /// Get variant for a specific test
  Future<String> getVariant(String testName) async {
    if (!_activeTests.containsKey(testName)) {
      AppLogger.warning('Unknown A/B test: $testName');
      return 'original'; // Default fallback
    }

    // Check if user already has a variant assigned
    if (_userVariants.containsKey(testName)) {
      final variant = _userVariants[testName]!;
      _trackTestExposure(testName, variant);
      return variant;
    }

    // Assign new variant
    final test = _activeTests[testName]!;
    final variant = _assignVariant(test);
    _userVariants[testName] = variant;
    
    // Save to persistent storage
    await _saveUserVariant(testName, variant);
    
    // Track exposure
    _trackTestExposure(testName, variant);
    
    AppLogger.debug('Assigned variant "$variant" for test "$testName"');
    return variant;
  }

  /// Check if user is in a specific variant
  Future<bool> isInVariant(String testName, String variant) async {
    final userVariant = await getVariant(testName);
    return userVariant == variant;
  }

  /// Track A/B test conversion event
  void trackConversion({
    required String testName,
    required String conversionEvent,
    Map<String, dynamic>? metadata,
  }) {
    final variant = _userVariants[testName];
    if (variant == null) {
      AppLogger.warning('Tracking conversion for unassigned test: $testName');
      return;
    }

    AdvancedAnalyticsService.instance.trackEvent('ab_test_conversion', {
      'test_name': testName,
      'variant': variant,
      'conversion_event': conversionEvent,
      ...?metadata,
    });

    AppLogger.debug('A/B test conversion tracked: $testName/$variant -> $conversionEvent');
  }

  /// Get all user's test variants
  Future<Map<String, String>> getAllUserVariants() async {
    final variants = <String, String>{};
    
    for (final testName in _activeTests.keys) {
      variants[testName] = await getVariant(testName);
    }
    
    return variants;
  }

  /// Get test configuration for UI adaptation
  Future<ABTestConfig> getTestConfig(String testName) async {
    final variant = await getVariant(testName);
    
    switch (testName) {
      case 'onboarding_flow':
        return _getOnboardingConfig(variant);
      case 'prayer_generation_ui':
        return _getPrayerUIConfig(variant);
      case 'mood_tracking_frequency':
        return _getMoodTrackingConfig(variant);
      case 'crisis_detection_sensitivity':
        return _getCrisisDetectionConfig(variant);
      case 'community_prominence':
        return _getCommunityConfig(variant);
      case 'meditation_session_lengths':
        return _getMeditationConfig(variant);
      case 'notification_timing':
        return _getNotificationConfig(variant);
      case 'ai_personalization':
        return _getAIPersonalizationConfig(variant);
      default:
        return ABTestConfig(
          testName: testName,
          variant: variant,
          config: {},
        );
    }
  }

  /// Force assign variant (for testing)
  Future<void> forceVariant(String testName, String variant) async {
    if (!_activeTests.containsKey(testName)) {
      throw ArgumentError('Unknown test: $testName');
    }

    final test = _activeTests[testName]!;
    if (!test.variants.contains(variant)) {
      throw ArgumentError('Unknown variant "$variant" for test "$testName"');
    }

    _userVariants[testName] = variant;
    await _saveUserVariant(testName, variant);
    AppLogger.info('Forced variant "$variant" for test "$testName"');
  }

  /// Reset all test assignments (for debugging)
  Future<void> resetAllTests() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_abTestPrefix));
    
    for (final key in keys) {
      await prefs.remove(key);
    }
    
    _userVariants.clear();
    AppLogger.info('Reset all A/B test assignments');
  }

  /// Get test performance summary
  Map<String, dynamic> getTestSummary() {
    return {
      'active_tests': _activeTests.length,
      'user_assignments': _userVariants.length,
      'test_names': _activeTests.keys.toList(),
      'user_variants': Map.from(_userVariants),
    };
  }

  // Private methods

  /// Assign variant based on weights
  String _assignVariant(ABTestVariant test) {
    final random = math.Random().nextDouble();
    double cumulativeWeight = 0.0;

    for (int i = 0; i < test.variants.length; i++) {
      cumulativeWeight += test.weights[i];
      if (random <= cumulativeWeight) {
        return test.variants[i];
      }
    }

    // Fallback to last variant
    return test.variants.last;
  }

  /// Load user variants from storage
  Future<void> _loadUserVariants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_abTestPrefix));
      
      for (final key in keys) {
        final testName = key.replaceFirst('${_abTestPrefix}_', '');
        final variant = prefs.getString(key);
        if (variant != null) {
          _userVariants[testName] = variant;
        }
      }
      
      AppLogger.debug('Loaded ${_userVariants.length} A/B test assignments');
    } catch (e) {
      AppLogger.error('Failed to load A/B test assignments', e);
    }
  }

  /// Save user variant to storage
  Future<void> _saveUserVariant(String testName, String variant) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_abTestPrefix}_$testName', variant);
    } catch (e) {
      AppLogger.error('Failed to save A/B test variant', e);
    }
  }

  /// Track test exposure for analytics
  void _trackTestExposure(String testName, String variant) {
    AdvancedAnalyticsService.instance.trackABTest(
      testName: testName,
      variant: variant,
    );
  }

  // Configuration generators for specific tests

  ABTestConfig _getOnboardingConfig(String variant) {
    switch (variant) {
      case 'simplified':
        return ABTestConfig(
          testName: 'onboarding_flow',
          variant: variant,
          config: {
            'skip_intro_video': true,
            'reduce_steps': true,
            'auto_permissions': true,
          },
        );
      case 'detailed':
        return ABTestConfig(
          testName: 'onboarding_flow',
          variant: variant,
          config: {
            'show_intro_video': true,
            'detailed_explanations': true,
            'feature_highlights': true,
          },
        );
      default: // original
        return ABTestConfig(
          testName: 'onboarding_flow',
          variant: variant,
          config: {
            'standard_flow': true,
          },
        );
    }
  }

  ABTestConfig _getPrayerUIConfig(String variant) {
    switch (variant) {
      case 'minimal':
        return ABTestConfig(
          testName: 'prayer_generation_ui',
          variant: variant,
          config: {
            'show_categories': false,
            'simple_input': true,
            'minimal_options': true,
          },
        );
      case 'guided':
        return ABTestConfig(
          testName: 'prayer_generation_ui',
          variant: variant,
          config: {
            'show_prompts': true,
            'guided_questions': true,
            'context_suggestions': true,
          },
        );
      default: // card_style
        return ABTestConfig(
          testName: 'prayer_generation_ui',
          variant: variant,
          config: {
            'card_layout': true,
            'visual_categories': true,
          },
        );
    }
  }

  ABTestConfig _getMoodTrackingConfig(String variant) {
    switch (variant) {
      case 'multiple_daily':
        return ABTestConfig(
          testName: 'mood_tracking_frequency',
          variant: variant,
          config: {
            'reminders_per_day': 3,
            'allow_multiple_entries': true,
          },
        );
      case 'flexible':
        return ABTestConfig(
          testName: 'mood_tracking_frequency',
          variant: variant,
          config: {
            'user_defined_frequency': true,
            'adaptive_reminders': true,
          },
        );
      default: // daily_only
        return ABTestConfig(
          testName: 'mood_tracking_frequency',
          variant: variant,
          config: {
            'reminders_per_day': 1,
            'single_daily_entry': true,
          },
        );
    }
  }

  ABTestConfig _getCrisisDetectionConfig(String variant) {
    switch (variant) {
      case 'conservative':
        return ABTestConfig(
          testName: 'crisis_detection_sensitivity',
          variant: variant,
          config: {
            'crisis_threshold': 0.8,
            'require_multiple_indicators': true,
          },
        );
      case 'sensitive':
        return ABTestConfig(
          testName: 'crisis_detection_sensitivity',
          variant: variant,
          config: {
            'crisis_threshold': 0.4,
            'proactive_outreach': true,
          },
        );
      default: // moderate
        return ABTestConfig(
          testName: 'crisis_detection_sensitivity',
          variant: variant,
          config: {
            'crisis_threshold': 0.6,
            'balanced_approach': true,
          },
        );
    }
  }

  ABTestConfig _getCommunityConfig(String variant) {
    switch (variant) {
      case 'hidden':
        return ABTestConfig(
          testName: 'community_prominence',
          variant: variant,
          config: {
            'show_community_tab': false,
            'hide_community_features': true,
          },
        );
      case 'dashboard_card':
        return ABTestConfig(
          testName: 'community_prominence',
          variant: variant,
          config: {
            'community_dashboard_card': true,
            'show_community_tab': false,
          },
        );
      default: // tab_bar
        return ABTestConfig(
          testName: 'community_prominence',
          variant: variant,
          config: {
            'show_community_tab': true,
            'community_dashboard_card': false,
          },
        );
    }
  }

  ABTestConfig _getMeditationConfig(String variant) {
    switch (variant) {
      case 'short_only':
        return ABTestConfig(
          testName: 'meditation_session_lengths',
          variant: variant,
          config: {
            'available_lengths': [5, 10, 15],
            'focus_short_sessions': true,
          },
        );
      case 'custom_length':
        return ABTestConfig(
          testName: 'meditation_session_lengths',
          variant: variant,
          config: {
            'allow_custom_length': true,
            'length_slider': true,
          },
        );
      default: // varied_options
        return ABTestConfig(
          testName: 'meditation_session_lengths',
          variant: variant,
          config: {
            'available_lengths': [5, 10, 15, 20, 30, 45],
            'preset_options': true,
          },
        );
    }
  }

  ABTestConfig _getNotificationConfig(String variant) {
    switch (variant) {
      case 'morning_focused':
        return ABTestConfig(
          testName: 'notification_timing',
          variant: variant,
          config: {
            'preferred_hours': [7, 8, 9, 10],
            'morning_emphasis': true,
          },
        );
      case 'evening_focused':
        return ABTestConfig(
          testName: 'notification_timing',
          variant: variant,
          config: {
            'preferred_hours': [18, 19, 20, 21],
            'evening_emphasis': true,
          },
        );
      default: // distributed
        return ABTestConfig(
          testName: 'notification_timing',
          variant: variant,
          config: {
            'preferred_hours': [9, 14, 19],
            'distributed_timing': true,
          },
        );
    }
  }

  ABTestConfig _getAIPersonalizationConfig(String variant) {
    switch (variant) {
      case 'basic':
        return ABTestConfig(
          testName: 'ai_personalization',
          variant: variant,
          config: {
            'use_mood_context': false,
            'simple_templates': true,
          },
        );
      case 'comprehensive':
        return ABTestConfig(
          testName: 'ai_personalization',
          variant: variant,
          config: {
            'use_mood_context': true,
            'use_activity_context': true,
            'use_trigger_context': true,
            'personalized_style': true,
          },
        );
      default: // mood_based
        return ABTestConfig(
          testName: 'ai_personalization',
          variant: variant,
          config: {
            'use_mood_context': true,
            'mood_based_prayers': true,
          },
        );
    }
  }
}

/// A/B test variant definition
class ABTestVariant {
  final String testName;
  final List<String> variants;
  final List<double> weights;
  final String description;

  ABTestVariant({
    required this.testName,
    required this.variants,
    required this.weights,
    required this.description,
  }) : assert(variants.length == weights.length,
             'Variants and weights must have the same length');
}

/// A/B test configuration for UI adaptation
class ABTestConfig {
  final String testName;
  final String variant;
  final Map<String, dynamic> config;

  ABTestConfig({
    required this.testName,
    required this.variant,
    required this.config,
  });

  /// Get configuration value with type safety
  T getValue<T>(String key, T defaultValue) {
    final value = config[key];
    if (value is T) {
      return value;
    }
    return defaultValue;
  }

  /// Check if configuration contains key
  bool hasKey(String key) => config.containsKey(key);

  @override
  String toString() {
    return 'ABTestConfig(test: $testName, variant: $variant, config: $config)';
  }
}
