import 'dart:async';
import 'dart:math';

import '../../../core/utils/logger.dart';
import '../../../shared/services/analytics_service.dart';
import '../../mood/services/mood_service.dart';
import '../models/guided_meditation.dart';
import '../models/meditation_session.dart';
import '../models/meditation_type.dart' as guided_type;

/// Advanced guided meditation service with AI-powered personalization
class GuidedMeditationService {
  static GuidedMeditationService? _instance;
  static GuidedMeditationService get instance =>
      _instance ??= GuidedMeditationService._();

  GuidedMeditationService._();

  final MoodService _moodService = MoodService.instance;
  final AnalyticsService _analytics = AnalyticsService.instance;
  final Random _random = Random();

  Timer? _sessionTimer;
  StreamController<MeditationSession>? _sessionController;
  MeditationSession? _currentSession;

  /// Get personalized meditation recommendations based on current state
  Future<List<GuidedMeditation>> getPersonalizedRecommendations() async {
    try {
      AppLogger.info('Getting personalized meditation recommendations');

      // Get recent mood data for personalization
      final recentMoods = await _moodService.getRecentEntries(limit: 7);
      final averageMood = recentMoods.isEmpty
          ? 5.0
          : recentMoods.fold<double>(0, (sum, entry) => sum + entry.score) /
              recentMoods.length;

      // Analyze current emotional state
      final emotionalNeeds = _analyzeEmotionalNeeds(recentMoods);
      final timeOfDay = _getTimeOfDay();

      // Get base meditations
      final allMeditations = _getAllMeditations();

      // Score and rank meditations based on personal needs
      final scoredMeditations = allMeditations.map((meditation) {
        final score = _scoreMeditation(
          meditation,
          averageMood,
          emotionalNeeds,
          timeOfDay,
        );
        return MapEntry(meditation, score);
      }).toList();

      // Sort by score and return top recommendations
      scoredMeditations.sort((a, b) => b.value.compareTo(a.value));

      final recommendations =
          scoredMeditations.take(8).map((entry) => entry.key).toList();

      await _analytics.trackEvent('meditation_recommendations_generated', {
        'average_mood': averageMood,
        'emotional_needs': emotionalNeeds,
        'time_of_day': timeOfDay,
        'recommendations_count': recommendations.length,
      });

      return recommendations;
    } catch (e) {
      AppLogger.error('Failed to get personalized recommendations', e);
      return _getDefaultMeditations();
    }
  }

  /// Start a guided meditation session
  Future<Stream<MeditationSession>> startMeditationSession(
    GuidedMeditation meditation,
  ) async {
    try {
      AppLogger.info('Starting meditation session: ${meditation.title}');

      // End any existing session
      await endCurrentSession();

      // Create new session
      _currentSession = MeditationSession(
        id: _generateSessionId(),
        userId: 'current_user', // Will be replaced by actual user ID when Firebase is enabled
        type: MeditationType.guided,
        duration: MeditationDuration.custom,
        startedAt: DateTime.now(),
        targetDurationMinutes: meditation.duration.inMinutes,
        title: meditation.title,
        isActive: true,
      );

      _sessionController =
          StreamController<MeditationSession>.broadcast();

      // Start the session timer
      _startSessionTimer(meditation);

      // Track session start
      await _analytics.trackEvent('meditation_session_started', {
        'meditation_id': meditation.id,
        'meditation_type': meditation.type.toString(),
        'duration': meditation.duration.inMinutes,
        'difficulty': meditation.difficulty,
      });

      return _sessionController!.stream;
    } catch (e) {
      AppLogger.error('Failed to start meditation session', e);
      rethrow;
    }
  }

  /// End the current meditation session
  Future<MeditationSession?> endCurrentSession() async{
    if (_currentSession == null) return null;

    try {
      AppLogger.info('Ending meditation session: ${_currentSession!.id}');

      // Stop timer
      _sessionTimer?.cancel();
      _sessionTimer = null;

      // Update session
      final endedSession = _currentSession!.copyWith(
        endTime: DateTime.now(),
        isActive: false,
        completionPercentage: _calculateCompletionPercentage(),
      );

      // Close stream
      await _sessionController?.close();
      _sessionController = null;

      // Track session end
      final actualDuration = endedSession.elapsedTime ?? Duration.zero;
      await _analytics.trackEvent('meditation_session_ended', {
        'session_id': endedSession.id,
        'duration_completed': actualDuration.inMinutes,
        'completion_percentage': endedSession.completionPercentage,
        'was_completed': endedSession.isCompleted,
      });

      _currentSession = null;
      return endedSession;
    } catch (e) {
      AppLogger.error('Failed to end meditation session', e);
      _currentSession = null;
      return null;
    }
  }

  /// Get meditation by type and preferences
  Future<List<GuidedMeditation>> getMeditationsByType(
      guided_type.MeditationType type) async {
    final allMeditations = _getAllMeditations();
    return allMeditations.where((m) => m.type == type).toList();
  }

  /// Get meditation progress and statistics
  Future<Map<String, dynamic>> getMeditationStats() async {
    try {
      // In a real app, this would come from stored session data
      // For now, return mock statistics
      return {
        'total_sessions': 15,
        'total_minutes': 180,
        'current_streak': 5,
        'longest_streak': 12,
        'favorite_type': guided_type.MeditationType.mindfulness.toString(),
        'average_session_length': 12,
        'sessions_this_week': 7,
        'sessions_this_month': 28,
      };
    } catch (e) {
      AppLogger.error('Failed to get meditation stats', e);
      return {};
    }
  }

  /// Private methods

  void _startSessionTimer(GuidedMeditation meditation) {
    const tickInterval = Duration(seconds: 1);
    var elapsed = Duration.zero;

    _sessionTimer = Timer.periodic(tickInterval, (timer) {
      elapsed += tickInterval;

      if (_currentSession != null && _sessionController != null) {
        // Update session phase based on elapsed time
        final newPhase = _calculateCurrentPhase(elapsed, meditation.duration);

        _currentSession = _currentSession!.copyWith(
          currentPhase: newPhase,
          elapsedTime: elapsed,
        );

        _sessionController!.add(_currentSession!);

        // Check if session is complete
        if (elapsed >= meditation.duration) {
          _completeSession();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _completeSession() {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        currentPhase: MeditationPhase.completion,
        state: MeditationState.completed,
      );

      _sessionController?.add(_currentSession!);
    }
  }

  MeditationPhase _calculateCurrentPhase(Duration elapsed, Duration total) {
    final progress = elapsed.inSeconds / total.inSeconds;

    if (progress < 0.1) {
      return MeditationPhase.preparation;
    } else if (progress < 0.2) {
      return MeditationPhase.settling;
    } else if (progress < 0.8) {
      return MeditationPhase.main;
    } else if (progress < 0.95) {
      return MeditationPhase.integration;
    } else {
      return MeditationPhase.completion;
    }
  }

  double _calculateCompletionPercentage() {
    if (_currentSession == null) return 0.0;

    final elapsed = _currentSession!.elapsedTime ?? Duration.zero;
    final target = _currentSession!.targetDuration;

    return (elapsed.inSeconds / target.inSeconds).clamp(0.0, 1.0);
  }

  List<String> _analyzeEmotionalNeeds(List moods) {
    final needs = <String>[];

    if (moods.isEmpty) {
      return ['balance', 'awareness'];
    }

    // Analyze patterns in recent moods
    final averageMood =
        moods.fold<double>(0, (sum, entry) => sum + entry.score) / moods.length;

    if (averageMood <= 4) {
      needs.addAll(['healing', 'comfort', 'strength']);
    } else if (averageMood >= 8) {
      needs.addAll(['gratitude', 'joy', 'celebration']);
    } else {
      needs.addAll(['balance', 'awareness', 'peace']);
    }

    // Check for specific emotions in recent entries
    for (final mood in moods) {
      for (final emotion in mood.emotions) {
        switch (emotion.toLowerCase()) {
          case 'anxious':
          case 'worried':
            needs.add('calming');
            break;
          case 'angry':
          case 'frustrated':
            needs.add('patience');
            break;
          case 'sad':
          case 'depressed':
            needs.add('healing');
            break;
          case 'stressed':
            needs.add('stress_relief');
            break;
        }
      }
    }

    return needs.toSet().toList(); // Remove duplicates
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'morning';
    } else if (hour >= 12 && hour < 17) {
      return 'afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'evening';
    } else {
      return 'night';
    }
  }

  double _scoreMeditation(
    GuidedMeditation meditation,
    double averageMood,
    List<String> emotionalNeeds,
    String timeOfDay,
  ) {
    double score = 0.0;

    // Base score from meditation quality/popularity
    score += 5.0;

    // Time of day matching
    if (_isSuitableForTime(meditation, timeOfDay)) {
      score += 3.0;
    }

    // Emotional needs matching
    for (final need in emotionalNeeds) {
      if (_meditationAddressesNeed(meditation, need)) {
        score += 2.0;
      }
    }

    // Mood-based scoring
    if (averageMood <= 4 && _isHealingMeditation(meditation)) {
      score += 4.0;
    } else if (averageMood >= 7 && _isUplifitingMeditation(meditation)) {
      score += 3.0;
    }

    // Duration preference (moderate durations score higher)
    final durationMinutes = meditation.duration.inMinutes;
    if (durationMinutes >= 10 && durationMinutes <= 20) {
      score += 2.0;
    } else if (durationMinutes >= 5 && durationMinutes <= 30) {
      score += 1.0;
    }

    // Add some randomness for variety
    score += _random.nextDouble() * 2.0;

    return score;
  }

  bool _isSuitableForTime(GuidedMeditation meditation, String timeOfDay) {
    final tags = meditation.tags.map((t) => t.toLowerCase()).toList();

    switch (timeOfDay) {
      case 'morning':
        return tags.any((tag) =>
            ['morning', 'energy', 'awakening', 'intention'].contains(tag));
      case 'afternoon':
        return tags.any((tag) =>
            ['focus', 'productivity', 'clarity', 'balance'].contains(tag));
      case 'evening':
        return tags.any((tag) =>
            ['relaxation', 'reflection', 'gratitude', 'peace'].contains(tag));
      case 'night':
        return tags.any(
            (tag) => ['sleep', 'rest', 'calming', 'healing'].contains(tag));
      default:
        return true;
    }
  }

  bool _meditationAddressesNeed(GuidedMeditation meditation, String need) {
    final tags = meditation.tags.map((t) => t.toLowerCase()).toList();

    switch (need) {
      case 'healing':
        return tags.any((tag) =>
            ['healing', 'recovery', 'restoration', 'comfort'].contains(tag));
      case 'calming':
        return tags.any((tag) =>
            ['calming', 'peace', 'tranquil', 'soothing'].contains(tag));
      case 'strength':
        return tags.any((tag) =>
            ['strength', 'courage', 'empowerment', 'resilience'].contains(tag));
      case 'stress_relief':
        return tags.any(
            (tag) => ['stress', 'tension', 'relief', 'release'].contains(tag));
      default:
        return tags.contains(need);
    }
  }

  bool _isHealingMeditation(GuidedMeditation meditation) {
    return meditation.type == guided_type.MeditationType.healing ||
        meditation.tags.any((tag) =>
            ['healing', 'comfort', 'recovery'].contains(tag.toLowerCase()));
  }

  bool _isUplifitingMeditation(GuidedMeditation meditation) {
    return meditation.type == guided_type.MeditationType.gratitude ||
        meditation.tags.any((tag) => [
              'joy',
              'gratitude',
              'celebration',
              'positive'
            ].contains(tag.toLowerCase()));
  }

  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _random.nextInt(1000);
    return 'meditation_session_${timestamp}_$random';
  }

  /// Get all available meditations (in a real app, this would come from a database)
  List<GuidedMeditation> _getAllMeditations() {
    return [
      // Morning meditations
      GuidedMeditation(
        id: 'morning_intention',
        title: 'Morning Intention Setting',
        description:
            'Start your day with purpose and clarity through guided intention setting.',
        type: guided_type.MeditationType.mindfulness,
        duration: const Duration(minutes: 15),
        difficulty: 'Beginner',
        instructor: 'Sarah Chen',
        audioUrl: 'assets/audio/morning_intention.mp3',
        tags: ['morning', 'intention', 'clarity', 'purpose'],
        scriptSteps: [
          'Find a comfortable seated position',
          'Take three deep breaths to center yourself',
          'Reflect on your intentions for the day',
          'Visualize yourself moving through the day with purpose',
          'Set a positive intention for how you want to be',
        ],
      ),

      // Healing meditations
      GuidedMeditation(
        id: 'inner_healing',
        title: 'Inner Healing Light',
        description:
            'A gentle healing meditation using visualization and breathing techniques.',
        type: guided_type.MeditationType.healing,
        duration: const Duration(minutes: 20),
        difficulty: 'Intermediate',
        instructor: 'Dr. Michael Rivera',
        audioUrl: 'assets/audio/inner_healing.mp3',
        tags: ['healing', 'visualization', 'comfort', 'restoration'],
        scriptSteps: [
          'Lie down comfortably and close your eyes',
          'Focus on your breath becoming deeper and slower',
          'Visualize warm, healing light entering your body',
          'Allow this light to flow to areas that need healing',
          'Rest in this healing energy for several minutes',
        ],
      ),

      // Stress relief
      GuidedMeditation(
        id: 'stress_release',
        title: 'Progressive Stress Release',
        description:
            'Release tension and stress through progressive relaxation and mindful breathing.',
        type: guided_type.MeditationType.relaxation,
        duration: const Duration(minutes: 18),
        difficulty: 'Beginner',
        instructor: 'Lisa Thompson',
        audioUrl: 'assets/audio/stress_release.mp3',
        tags: ['stress', 'tension', 'relief', 'relaxation', 'breathing'],
        scriptSteps: [
          'Sit or lie down in a comfortable position',
          'Begin with slow, deep breathing',
          'Progressively tense and release each muscle group',
          'Notice the contrast between tension and relaxation',
          'End with whole-body relaxation and calm breathing',
        ],
      ),

      // Gratitude meditation
      GuidedMeditation(
        id: 'gratitude_heart',
        title: 'Grateful Heart Practice',
        description:
            'Cultivate gratitude and joy through heart-centered meditation.',
        type: guided_type.MeditationType.gratitude,
        duration: const Duration(minutes: 12),
        difficulty: 'Beginner',
        instructor: 'Rachel Green',
        audioUrl: 'assets/audio/gratitude_heart.mp3',
        tags: ['gratitude', 'joy', 'heart', 'appreciation', 'positive'],
        scriptSteps: [
          'Place your hand on your heart',
          'Take several deep, appreciative breaths',
          'Bring to mind three things you\'re grateful for',
          'Feel the warmth of gratitude in your heart',
          'Expand this feeling throughout your whole being',
        ],
      ),

      // Sleep meditation
      GuidedMeditation(
        id: 'peaceful_sleep',
        title: 'Journey to Peaceful Sleep',
        description:
            'Gentle meditation to help you unwind and prepare for restful sleep.',
        type: guided_type.MeditationType.sleep,
        duration: const Duration(minutes: 25),
        difficulty: 'Beginner',
        instructor: 'David Park',
        audioUrl: 'assets/audio/peaceful_sleep.mp3',
        tags: ['sleep', 'rest', 'calming', 'night', 'peaceful'],
        scriptSteps: [
          'Get comfortable in your bed',
          'Progressive relaxation from head to toe',
          'Gentle breathing awareness',
          'Peaceful visualization of a safe place',
          'Drift into natural, restful sleep',
        ],
      ),

      // Mindfulness meditation
      GuidedMeditation(
        id: 'present_moment',
        title: 'Present Moment Awareness',
        description:
            'Develop mindfulness and presence through breath and body awareness.',
        type: guided_type.MeditationType.mindfulness,
        duration: const Duration(minutes: 16),
        difficulty: 'Intermediate',
        instructor: 'Anna Martinez',
        audioUrl: 'assets/audio/present_moment.mp3',
        tags: ['mindfulness', 'presence', 'awareness', 'breath', 'body'],
        scriptSteps: [
          'Sit with spine naturally upright',
          'Bring attention to your natural breathing',
          'Notice sensations in your body',
          'When mind wanders, gently return to breath',
          'Rest in present moment awareness',
        ],
      ),
    ];
  }

  List<GuidedMeditation> _getDefaultMeditations() {
    return _getAllMeditations().take(4).toList();
  }
}
