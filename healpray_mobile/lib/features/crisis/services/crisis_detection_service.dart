import 'dart:async';
import 'dart:math';

import '../../../core/utils/logger.dart';
import '../../../shared/services/analytics_service.dart';
import '../../mood/models/simple_mood_entry.dart';
import '../../mood/services/mood_service.dart';
import '../models/crisis_alert.dart';
import '../models/crisis_level.dart';

/// Advanced AI-powered crisis detection and intervention service
class CrisisDetectionService {
  static CrisisDetectionService? _instance;
  static CrisisDetectionService get instance =>
      _instance ??= CrisisDetectionService._();

  CrisisDetectionService._();

  final MoodService _moodService = MoodService.instance;
  final AnalyticsService _analytics = AnalyticsService.instance;

  // Detection thresholds and weights
  static const double _lowMoodThreshold = 3.0;
  static const double _criticalMoodThreshold = 2.0;
  static const double _moodTrendWeight = 0.4;
  static const double _emotionWeight = 0.3;
  static const double _contextWeight = 0.2;
  static const double _frequencyWeight = 0.1;

  // Crisis keywords and phrases for text analysis
  static const List<String> _crisisKeywords = [
    // Suicidal ideation
    'kill myself', 'end it all', 'not worth living', 'want to die',
    'suicide', 'kill me', 'end my life', 'better off dead',

    // Self-harm
    'hurt myself', 'cut myself', 'self harm', 'self-harm',
    'harm myself', 'punish myself',

    // Despair and hopelessness
    'no hope', 'hopeless', 'can\'t go on', 'give up',
    'nothing matters', 'no point', 'pointless', 'worthless',

    // Crisis situations
    'emergency', 'crisis', 'breaking down', 'can\'t cope',
    'overwhelmed', 'drowning', 'falling apart',

    // Mental health emergency
    'panic attack', 'breakdown', 'losing it', 'going crazy',
    'can\'t breathe', 'help me', 'save me',
  ];

  static const List<String> _highRiskEmotions = [
    'suicidal',
    'hopeless',
    'desperate',
    'trapped',
    'worthless',
    'empty',
    'numb',
    'overwhelmed',
    'panicked',
    'terrified',
    'abandoned',
    'betrayed',
    'rejected',
    'ashamed',
    'guilty',
  ];

  /// Monitor user for crisis indicators
  Future<CrisisAlert?> assessCrisisRisk() async {
    try {
      AppLogger.info('Starting crisis risk assessment');

      // Gather data for assessment
      final recentMoods = await _moodService.getRecentEntries(limit: 14);
      if (recentMoods.isEmpty) {
        return null;
      }

      // Calculate various risk factors
      final moodRisk = _calculateMoodBasedRisk(recentMoods);
      final emotionRisk = _calculateEmotionBasedRisk(recentMoods);
      final contextRisk = _calculateContextBasedRisk(recentMoods);
      final frequencyRisk = _calculateFrequencyBasedRisk(recentMoods);
      final textRisk = _calculateTextBasedRisk(recentMoods);

      // Weighted overall risk calculation
      final overallRisk = ((moodRisk * _moodTrendWeight) +
              (emotionRisk * _emotionWeight) +
              (contextRisk * _contextWeight) +
              (frequencyRisk * _frequencyWeight) +
              (textRisk * 0.3) // Text analysis gets additional weight
          );

      AppLogger.debug(
          'Crisis risk factors: mood=$moodRisk, emotion=$emotionRisk, context=$contextRisk, frequency=$frequencyRisk, text=$textRisk, overall=$overallRisk');

      // Determine crisis level based on overall risk
      final crisisLevel = _determineCrisisLevel(overallRisk);

      if (crisisLevel != CrisisLevel.none) {
        final alert = CrisisAlert(
          id: _generateAlertId(),
          timestamp: DateTime.now(),
          crisisLevel: crisisLevel,
          riskScore: overallRisk,
          triggerFactors: _identifyTriggerFactors(
            moodRisk,
            emotionRisk,
            contextRisk,
            frequencyRisk,
            textRisk,
          ),
          recommendedActions: _getRecommendedActions(crisisLevel),
          emergencyContacts: _getEmergencyContacts(),
          supportResources: _getSupportResources(crisisLevel),
        );

        // Track crisis detection
        await _analytics.trackEvent('crisis_detected', {
          'crisis_level': crisisLevel.toString(),
          'risk_score': overallRisk,
          'trigger_factors': alert.triggerFactors,
        });

        AppLogger.warning(
            'Crisis detected: ${crisisLevel.toString()} (risk: $overallRisk)');
        return alert;
      }

      return null;
    } catch (e) {
      AppLogger.error('Failed to assess crisis risk', e);
      return null;
    }
  }

  /// Calculate mood-based crisis risk
  double _calculateMoodBasedRisk(List<SimpleMoodEntry> moods) {
    if (moods.isEmpty) return 0.0;

    double risk = 0.0;

    // Recent mood scores
    final recentMoods = moods.take(7).toList();
    final averageRecentMood =
        recentMoods.fold<double>(0, (sum, entry) => sum + entry.score) /
            recentMoods.length;

    // Low mood risk
    if (averageRecentMood <= _criticalMoodThreshold) {
      risk += 0.8;
    } else if (averageRecentMood <= _lowMoodThreshold) {
      risk += 0.4;
    }

    // Downward trend analysis
    if (moods.length >= 3) {
      final trend = _calculateMoodTrend(moods.take(7).toList());
      if (trend < -0.5) {
        risk += 0.6; // Strong downward trend
      } else if (trend < -0.2) {
        risk += 0.3; // Moderate downward trend
      }
    }

    // Extreme mood swings
    final moodVariance = _calculateMoodVariance(recentMoods);
    if (moodVariance > 6.0) {
      risk += 0.4; // High volatility is also a risk factor
    }

    return math.min(risk, 1.0);
  }

  /// Calculate emotion-based crisis risk
  double _calculateEmotionBasedRisk(List<SimpleMoodEntry> moods) {
    if (moods.isEmpty) return 0.0;

    double risk = 0.0;
    final recentMoods = moods.take(7).toList();

    for (final mood in recentMoods) {
      for (final emotion in mood.emotions) {
        if (_highRiskEmotions.contains(emotion.toLowerCase())) {
          risk += 0.2;
        }
      }
    }

    return math.min(risk, 1.0);
  }

  /// Calculate context-based crisis risk
  double _calculateContextBasedRisk(List<SimpleMoodEntry> moods) {
    if (moods.isEmpty) return 0.0;

    double risk = 0.0;
    final recentMoods = moods.take(7).toList();

    for (final mood in recentMoods) {
      // Check for crisis-related context in notes and metadata
      final contextText = (mood.notes ?? '').toLowerCase();
      if (contextText.contains('loss') ||
          contextText.contains('death') ||
          contextText.contains('abuse') ||
          contextText.contains('trauma') ||
          contextText.contains('divorce') ||
          contextText.contains('job') ||
          contextText.contains('financial')) {
        risk += 0.3;
      }

      // Check location patterns (isolation indicators)
      if (mood.location?.toLowerCase().contains('alone') == true ||
          mood.location?.toLowerCase().contains('isolated') == true) {
        risk += 0.2;
      }
    }

    return math.min(risk, 1.0);
  }

  /// Calculate frequency-based crisis risk
  double _calculateFrequencyBasedRisk(List<SimpleMoodEntry> moods) {
    if (moods.isEmpty) return 0.0;

    final now = DateTime.now();
    final last24Hours =
        moods.where((m) => now.difference(m.timestamp).inHours <= 24).toList();

    final last7Days =
        moods.where((m) => now.difference(m.timestamp).inDays <= 7).toList();

    double risk = 0.0;

    // Multiple low mood entries in short period
    final lowMoodCount24h =
        last24Hours.where((m) => m.score <= _lowMoodThreshold).length;
    final lowMoodCount7d =
        last7Days.where((m) => m.score <= _lowMoodThreshold).length;

    if (lowMoodCount24h >= 3) {
      risk += 0.7; // Multiple crisis entries in one day
    } else if (lowMoodCount7d >= 10) {
      risk += 0.5; // Sustained low mood over a week
    }

    // Absence of positive entries (indicator of persistent low mood)
    final positiveCount7d = last7Days.where((m) => m.score >= 7).length;
    if (last7Days.length >= 5 && positiveCount7d == 0) {
      risk += 0.4; // No positive moods in a week
    }

    return math.min(risk, 1.0);
  }

  /// Calculate text-based crisis risk using keyword analysis
  double _calculateTextBasedRisk(List<SimpleMoodEntry> moods) {
    if (moods.isEmpty) return 0.0;

    double risk = 0.0;
    final recentMoods = moods.take(7).toList();

    for (final mood in recentMoods) {
      final allText = [
        mood.notes ?? '',
        ...mood.emotions,
      ].join(' ').toLowerCase();

      for (final keyword in _crisisKeywords) {
        if (allText.contains(keyword)) {
          // Weight based on severity of keyword
          if (_isHighSeverityKeyword(keyword)) {
            risk += 0.8;
          } else if (_isModerateSeverityKeyword(keyword)) {
            risk += 0.4;
          } else {
            risk += 0.2;
          }
        }
      }
    }

    return math.min(risk, 1.0);
  }

  /// Determine crisis level based on overall risk score
  CrisisLevel _determineCrisisLevel(double riskScore) {
    if (riskScore >= 0.8) {
      return CrisisLevel.severe;
    } else if (riskScore >= 0.6) {
      return CrisisLevel.high;
    } else if (riskScore >= 0.4) {
      return CrisisLevel.moderate;
    } else if (riskScore >= 0.2) {
      return CrisisLevel.low;
    } else {
      return CrisisLevel.none;
    }
  }

  /// Helper methods
  double _calculateMoodTrend(List<SimpleMoodEntry> moods) {
    if (moods.length < 2) return 0.0;

    final first = moods.last.score.toDouble();
    final last = moods.first.score.toDouble();

    return (last - first) / moods.length;
  }

  double _calculateMoodVariance(List<SimpleMoodEntry> moods) {
    if (moods.length < 2) return 0.0;

    final mean =
        moods.fold<double>(0, (sum, entry) => sum + entry.score) / moods.length;
    final variance = moods.fold<double>(
            0, (sum, entry) => sum + math.pow(entry.score - mean, 2)) /
        moods.length;

    return variance;
  }

  bool _isHighSeverityKeyword(String keyword) {
    const highSeverity = [
      'kill myself',
      'suicide',
      'end my life',
      'want to die',
      'hurt myself',
      'cut myself',
      'self harm',
    ];
    return highSeverity.contains(keyword);
  }

  bool _isModerateSeverityKeyword(String keyword) {
    const moderateSeverity = [
      'hopeless',
      'no hope',
      'give up',
      'breaking down',
      'can\'t cope',
      'overwhelmed',
      'panic attack',
    ];
    return moderateSeverity.contains(keyword);
  }

  List<String> _identifyTriggerFactors(
    double moodRisk,
    double emotionRisk,
    double contextRisk,
    double frequencyRisk,
    double textRisk,
  ) {
    final factors = <String>[];

    if (moodRisk > 0.5) factors.add('Persistent low mood');
    if (emotionRisk > 0.4) factors.add('High-risk emotions detected');
    if (contextRisk > 0.4) factors.add('Stressful life circumstances');
    if (frequencyRisk > 0.4) factors.add('Frequent crisis indicators');
    if (textRisk > 0.6) factors.add('Crisis language detected');

    return factors;
  }

  List<String> _getRecommendedActions(CrisisLevel level) {
    switch (level) {
      case CrisisLevel.severe:
        return [
          'Contact emergency services immediately (911)',
          'Reach out to a trusted person right now',
          'Go to the nearest emergency room',
          'Call the National Suicide Prevention Lifeline',
          'Do not be alone - stay with someone',
        ];
      case CrisisLevel.high:
        return [
          'Contact your therapist or counselor',
          'Call a crisis helpline',
          'Reach out to family or friends',
          'Consider visiting urgent care',
          'Remove any means of self-harm',
          'Use grounding techniques',
        ];
      case CrisisLevel.moderate:
        return [
          'Schedule an appointment with a mental health professional',
          'Talk to someone you trust',
          'Practice self-care activities',
          'Use coping strategies you\'ve learned',
          'Consider contacting a helpline',
          'Engage in spiritual practices',
        ];
      case CrisisLevel.low:
        return [
          'Continue monitoring your mood',
          'Practice mindfulness and meditation',
          'Engage in prayer or spiritual reflection',
          'Maintain healthy routines',
          'Connect with supportive people',
          'Consider professional support',
        ];
      case CrisisLevel.none:
        return [];
    }
  }

  List<String> _getEmergencyContacts() {
    return [
      'Emergency Services: 911',
      'National Suicide Prevention Lifeline: 988',
      'Crisis Text Line: Text HOME to 741741',
      'SAMHSA National Helpline: 1-800-662-4357',
      'National Alliance on Mental Illness: 1-800-950-6264',
    ];
  }

  List<String> _getSupportResources(CrisisLevel level) {
    final resources = [
      'National Suicide Prevention Lifeline',
      'Crisis Text Line',
      'SAMHSA Treatment Locator',
      'Psychology Today Therapist Finder',
      'Local emergency services',
    ];

    if (level == CrisisLevel.severe || level == CrisisLevel.high) {
      resources.insertAll(0, [
        'Nearest Emergency Room',
        'Mobile Crisis Team',
        'Psychiatric Emergency Services',
      ]);
    }

    return resources;
  }

  String _generateAlertId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1000);
    return 'crisis_alert_$timestamp_$random';
  }
}
