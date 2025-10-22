import 'package:google_generative_ai/google_generative_ai.dart';

import '../../mood/services/mood_service.dart';
import '../../scripture/services/scripture_service.dart';
import '../../meditation/services/meditation_service.dart';
import '../../../core/config/app_config.dart';
import '../../../core/utils/logger.dart';
import '../../../shared/services/analytics_service.dart';

/// Types of spiritual insights
enum InsightType {
  moodBased,
  growthRecommendation,
  scriptureRecommendation,
  prayerSuggestion,
  meditationRecommendation,
  lifestyleRecommendation,
  encouragement,
  challenge,
}

/// Spiritual insight data
class SpiritualInsight {
  final String id;
  final String title;
  final String content;
  final InsightType type;
  final List<String> tags;
  final String? scriptureReference;
  final String? actionSuggestion;
  final DateTime createdAt;
  final int priority; // 1-10, higher = more important
  final Map<String, dynamic> metadata;

  const SpiritualInsight({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.tags,
    this.scriptureReference,
    this.actionSuggestion,
    required this.createdAt,
    required this.priority,
    this.metadata = const {},
  });

  String get typeDisplayName {
    switch (type) {
      case InsightType.moodBased:
        return 'Mood Insight';
      case InsightType.growthRecommendation:
        return 'Growth Opportunity';
      case InsightType.scriptureRecommendation:
        return 'Scripture Focus';
      case InsightType.prayerSuggestion:
        return 'Prayer Guide';
      case InsightType.meditationRecommendation:
        return 'Meditation Suggestion';
      case InsightType.lifestyleRecommendation:
        return 'Life Application';
      case InsightType.encouragement:
        return 'Encouragement';
      case InsightType.challenge:
        return 'Spiritual Challenge';
    }
  }

  String get typeIcon {
    switch (type) {
      case InsightType.moodBased:
        return '💭';
      case InsightType.growthRecommendation:
        return '🌱';
      case InsightType.scriptureRecommendation:
        return '📖';
      case InsightType.prayerSuggestion:
        return '🙏';
      case InsightType.meditationRecommendation:
        return '🧘';
      case InsightType.lifestyleRecommendation:
        return '⭐';
      case InsightType.encouragement:
        return '💝';
      case InsightType.challenge:
        return '🎯';
    }
  }
}

/// Service for generating personalized spiritual insights
class SpiritualInsightsService {
  static SpiritualInsightsService? _instance;
  static SpiritualInsightsService get instance =>
      _instance ??= SpiritualInsightsService._();

  SpiritualInsightsService._();

  final MoodService _moodService = MoodService.instance;
  final ScriptureService _scriptureService = ScriptureService.instance;
  final MeditationService _meditationService = MeditationService.instance;
  final AnalyticsService _analytics = AnalyticsService.instance;

  GenerativeModel? _aiModel;
  final List<SpiritualInsight> _cachedInsights = [];
  DateTime? _lastGeneratedTime;

  /// Initialize the service
  Future<void> initialize() async {
    try {
      if (AppConfig.geminiApiKey.isNotEmpty) {
        _aiModel = GenerativeModel(
          model: 'gemini-pro',
          apiKey: AppConfig.geminiApiKey,
        );
        AppLogger.info('SpiritualInsightsService initialized with AI');
      } else {
        AppLogger.warning('No AI key found - using fallback insights');
      }
    } catch (e) {
      AppLogger.error('Failed to initialize SpiritualInsightsService', e);
      rethrow;
    }
  }

  /// Get personalized insights for the user
  Future<List<SpiritualInsight>> getPersonalizedInsights({
    int limit = 5,
    bool forceRefresh = false,
  }) async {
    try {
      // Check if we need to refresh insights
      final now = DateTime.now();
      final needsRefresh = forceRefresh ||
          _lastGeneratedTime == null ||
          now.difference(_lastGeneratedTime!).inHours >= 12;

      if (!needsRefresh && _cachedInsights.isNotEmpty) {
        return _cachedInsights.take(limit).toList();
      }

      // Generate new insights
      final insights = await _generateInsights();
      _cachedInsights.clear();
      _cachedInsights.addAll(insights);
      _lastGeneratedTime = now;

      // Track analytics
      await _analytics.logEvent('spiritual_insights_generated', {
        'count': insights.length,
        'types': insights.map((i) => i.type.name).toSet().toList(),
      });

      return _cachedInsights.take(limit).toList();
    } catch (e) {
      AppLogger.error('Failed to get personalized insights', e);
      return _getFallbackInsights();
    }
  }

  /// Generate insights based on user patterns
  Future<List<SpiritualInsight>> _generateInsights() async {
    final insights = <SpiritualInsight>[];

    try {
      // Get user data for analysis - use fallback methods
      final moodStats = await _getMockMoodStats();
      final meditationStats = await _getMockMeditationStats();

      // Generate growth recommendations
      final growthInsights =
          await _generateGrowthRecommendations(moodStats, meditationStats);
      insights.addAll(growthInsights);

      // Generate encouragement or challenge
      final motivationalInsight = await _generateMotivationalInsight(moodStats);
      if (motivationalInsight != null) {
        insights.add(motivationalInsight);
      }
    } catch (e) {
      AppLogger.error('Error generating insights', e);
    }

    // Sort by priority and return
    insights.sort((a, b) => b.priority.compareTo(a.priority));
    return insights;
  }

  /// Generate growth recommendations
  Future<List<SpiritualInsight>> _generateGrowthRecommendations(
    Map<String, dynamic> moodStats,
    Map<String, dynamic> meditationStats,
  ) async {
    final insights = <SpiritualInsight>[];

    final meditationStreak = meditationStats['streak'] ?? 0;
    final totalMeditations = meditationStats['totalSessions'] ?? 0;

    if (totalMeditations == 0) {
      insights.add(SpiritualInsight(
        id: 'growth_meditation_start_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Begin Your Meditation Journey',
        content:
            'Meditation can be a powerful tool for spiritual growth and emotional well-being. Starting with just 5 minutes of guided meditation can help you connect with God and find inner peace.',
        type: InsightType.growthRecommendation,
        tags: ['meditation', 'spiritual growth', 'getting started'],
        actionSuggestion: 'Try a 5-minute breathing meditation today',
        createdAt: DateTime.now(),
        priority: 7,
      ));
    } else if (meditationStreak == 0 && totalMeditations > 0) {
      insights.add(SpiritualInsight(
        id: 'growth_meditation_return_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Return to Your Practice',
        content:
            'You have meditated before but have not in a while. Consider returning to this spiritual practice. Even a short session can help reset your spiritual focus and bring peace to your day.',
        type: InsightType.growthRecommendation,
        tags: ['meditation', 'consistency', 'spiritual practice'],
        actionSuggestion: 'Schedule 10 minutes for meditation this week',
        createdAt: DateTime.now(),
        priority: 5,
      ));
    }

    return insights;
  }

  /// Generate motivational insight
  Future<SpiritualInsight?> _generateMotivationalInsight(
      Map<String, dynamic> moodStats) async {
    final currentStreak = moodStats['currentStreak'] ?? 0;
    final averageMood = moodStats['averageMoodScore'] ?? 5;

    if (currentStreak > 7) {
      return SpiritualInsight(
        id: 'encouragement_streak_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Celebrating Consistency',
        content:
            'You have been consistently tracking your spiritual and emotional journey for $currentStreak days! This commitment to self-reflection and growth is admirable. Keep nurturing this healthy spiritual habit.',
        type: InsightType.encouragement,
        tags: ['consistency', 'growth', 'celebration'],
        actionSuggestion: 'Set a goal for your next streak milestone',
        createdAt: DateTime.now(),
        priority: 4,
      );
    } else if (averageMood < 4) {
      return SpiritualInsight(
        id: 'challenge_hope_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Finding Hope in Difficulty',
        content:
            'Challenging seasons are part of the human experience, but they are also opportunities for spiritual growth. Consider how God might be using this time to develop your character and deepen your faith.',
        type: InsightType.challenge,
        tags: ['hope', 'growth', 'perseverance'],
        scriptureReference: 'Romans 5:3-4',
        actionSuggestion:
            'Journal about one way you have grown through difficulty',
        createdAt: DateTime.now(),
        priority: 7,
      );
    }

    return null;
  }

  /// Get mock mood statistics
  Future<Map<String, dynamic>> _getMockMoodStats() async {
    return {
      'currentStreak': 5,
      'averageMoodScore': 6.5,
      'totalEntries': 20,
    };
  }

  /// Get mock meditation statistics
  Future<Map<String, dynamic>> _getMockMeditationStats() async {
    return {
      'streak': 0,
      'totalSessions': 3,
      'averageRating': 4.5,
    };
  }

  /// Get fallback insights when AI is not available
  List<SpiritualInsight> _getFallbackInsights() {
    return [
      SpiritualInsight(
        id: 'fallback_daily_1',
        title: 'Daily Spiritual Practice',
        content:
            'Consider establishing a daily time for prayer and reflection. Even 5 minutes can help center your heart and mind on God\'s presence throughout the day.',
        type: InsightType.lifestyleRecommendation,
        tags: ['prayer', 'daily practice', 'spiritual discipline'],
        actionSuggestion: 'Set aside 5 minutes for prayer today',
        createdAt: DateTime.now(),
        priority: 5,
      ),
      SpiritualInsight(
        id: 'fallback_gratitude_1',
        title: 'Cultivate Gratitude',
        content:
            'Gratitude transforms our perspective and draws us closer to God. Take time to acknowledge the blessings in your life, both big and small.',
        type: InsightType.encouragement,
        tags: ['gratitude', 'thanksgiving', 'perspective'],
        scriptureReference: '1 Thessalonians 5:18',
        actionSuggestion: 'List 3 things you\'re grateful for right now',
        createdAt: DateTime.now(),
        priority: 4,
      ),
    ];
  }
}
