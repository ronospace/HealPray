import 'dart:async';
import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/meditation_session.dart';
import '../repositories/meditation_repository.dart';
import '../../mood/services/mood_service.dart';
import '../../../core/config/app_config.dart';
import '../../../core/utils/logger.dart';
import '../../../core/services/advanced_analytics_service.dart';
import '../../../shared/services/analytics_service.dart';

/// Service for managing meditation sessions and AI-generated content
class MeditationService {
  static MeditationService? _instance;
  static MeditationService get instance => _instance ??= MeditationService._();

  MeditationService._();

  final MeditationRepository _repository = MeditationRepository.instance;
  final MoodService _moodService = MoodService.instance;
  final AnalyticsService _analytics = AnalyticsService.instance;

  GenerativeModel? _aiModel;
  Timer? _sessionTimer;
  StreamController<MeditationSession>? _currentSessionController;

  MeditationSession? _currentSession;

  /// Initialize the meditation service
  Future<void> initialize() async {
    try {
      await _repository.initialize();

      // Initialize AI model for script generation
      if (AppConfig.geminiApiKey.isNotEmpty) {
        _aiModel = GenerativeModel(
          model: 'gemini-pro',
          apiKey: AppConfig.geminiApiKey,
        );
        AppLogger.info('MeditationService initialized with Gemini AI');
      } else {
        AppLogger.warning(
            'No Gemini API key found - AI script generation disabled');
      }
    } catch (e) {
      AppLogger.error('Failed to initialize MeditationService', e);
      rethrow;
    }
  }

  /// Stream of current session updates
  Stream<MeditationSession>? get currentSessionStream =>
      _currentSessionController?.stream;

  // ============= SESSION MANAGEMENT =============

  /// Start a new meditation session
  Future<MeditationSession> startMeditationSession({
    required MeditationType type,
    required MeditationDuration duration,
    int? customDurationMinutes,
    String? title,
    String? customScript,
  }) async {
    try {
      // End any existing session
      if (_currentSession != null && _currentSession!.isInProgress) {
        await endCurrentSession();
      }

      // Get current mood for context
      final currentMood = await _getCurrentMoodContext();

      // Determine target duration
      int targetMinutes;
      switch (duration) {
        case MeditationDuration.short:
          targetMinutes = 5;
          break;
        case MeditationDuration.medium:
          targetMinutes = 10;
          break;
        case MeditationDuration.long:
          targetMinutes = 20;
          break;
        case MeditationDuration.custom:
          targetMinutes = customDurationMinutes ?? 10;
          break;
      }

      // Generate meditation script if not provided
      String? scriptContent = customScript;
      if (scriptContent == null && type != MeditationType.silent) {
        scriptContent =
            await generateMeditationScript(type, targetMinutes, currentMood);
      }

      // Create session
      final session = MeditationSession(
        id: _generateSessionId(),
        userId: 'current_user', // Will be replaced by actual user ID when Firebase is enabled
        type: type,
        duration: duration,
        targetDurationMinutes: targetMinutes,
        startedAt: DateTime.now(),
        title: title ?? _getDefaultTitle(type),
        description: _getDefaultDescription(type),
        scriptContent: scriptContent,
        moodBefore: currentMood,
        state: MeditationState.preparing,
        tags: _getDefaultTags(type),
      );

      // Save session
      await _repository.saveMeditationSession(session);

      _currentSession = session;
      _initializeSessionStream();

      // Track analytics
      await _analytics.trackEvent('meditation_started', {
        'type': type.name,
        'duration': duration.name,
        'target_minutes': targetMinutes,
        'has_custom_script': customScript != null,
      });

      AppLogger.info(
          'Started meditation session: ${session.id} (${session.typeDisplayName})');
      return session;
    } catch (e) {
      AppLogger.error('Failed to start meditation session', e);
      rethrow;
    }
  }

  /// Begin the active meditation (after preparation)
  Future<void> beginMeditation() async {
    if (_currentSession == null) {
      throw Exception('No active session to begin');
    }

    final updatedSession = _currentSession!.copyWith(
      state: MeditationState.active,
    );

    await _updateCurrentSession(updatedSession);
    _startSessionTimer();

    await _analytics.trackEvent('meditation_began', {
      'session_id': _currentSession!.id,
      'type': _currentSession!.type.name,
    });
  }

  /// Pause the current meditation
  Future<void> pauseMeditation() async {
    if (_currentSession?.state != MeditationState.active) {
      throw Exception('No active session to pause');
    }

    final updatedSession = _currentSession!.copyWith(
      state: MeditationState.paused,
    );

    await _updateCurrentSession(updatedSession);
    _stopSessionTimer();

    await _analytics.trackEvent('meditation_paused', {
      'session_id': _currentSession!.id,
      'duration_so_far': _currentSession!.actualDurationSeconds,
    });
  }

  /// Resume the paused meditation
  Future<void> resumeMeditation() async {
    if (_currentSession?.state != MeditationState.paused) {
      throw Exception('No paused session to resume');
    }

    final updatedSession = _currentSession!.copyWith(
      state: MeditationState.active,
    );

    await _updateCurrentSession(updatedSession);
    _startSessionTimer();

    await _analytics.trackEvent('meditation_resumed', {
      'session_id': _currentSession!.id,
    });
  }

  /// Complete the current meditation session
  Future<MeditationSession> completeMeditationSession({
    int? rating,
    String? reflection,
  }) async {
    if (_currentSession == null) {
      throw Exception('No session to complete');
    }

    _stopSessionTimer();

    // Get post-meditation mood
    final postMood = await _getCurrentMoodContext();

    final completedSession = _currentSession!.copyWith(
      state: MeditationState.completed,
      completedAt: DateTime.now(),
      rating: rating ?? 0,
      reflection: reflection,
      moodAfter: postMood,
    );

    await _repository.saveMeditationSession(completedSession);

    // Track completion analytics
    await _analytics.trackEvent('meditation_completed', {
      'session_id': completedSession.id,
      'type': completedSession.type.name,
      'target_minutes': completedSession.targetDurationMinutes,
      'actual_seconds': completedSession.actualDurationSeconds,
      'completion_rate': completedSession.completionPercentage,
      'rating': rating ?? 0,
      'has_reflection': reflection != null,
    });
    
    // Track advanced analytics
    AdvancedAnalyticsService.instance.trackMeditationSession(
      meditationType: completedSession.type.name,
      sessionDuration: Duration(seconds: completedSession.actualDurationSeconds),
      plannedDuration: Duration(minutes: completedSession.targetDurationMinutes),
      completedFully: completedSession.completionPercentage >= 90, // Consider 90%+ as fully completed
    );

    _currentSession = null;
    _currentSessionController?.close();
    _currentSessionController = null;

    AppLogger.info('Completed meditation session: ${completedSession.id}');
    return completedSession;
  }

  /// End the current session (cancel or complete)
  Future<void> endCurrentSession({bool cancelled = false}) async {
    if (_currentSession == null) return;

    _stopSessionTimer();

    final endedSession = _currentSession!.copyWith(
      state: cancelled ? MeditationState.cancelled : MeditationState.completed,
      completedAt: DateTime.now(),
    );

    await _repository.saveMeditationSession(endedSession);

    await _analytics.trackEvent('meditation_ended', {
      'session_id': endedSession.id,
      'was_cancelled': cancelled,
      'actual_seconds': endedSession.actualDurationSeconds,
    });

    _currentSession = null;
    _currentSessionController?.close();
    _currentSessionController = null;
  }

  // ============= MEDITATION SCRIPTS =============

  /// Generate AI-powered meditation script
  Future<String> generateMeditationScript(
    MeditationType type,
    int durationMinutes,
    Map<String, dynamic>? moodContext,
  ) async {
    if (_aiModel == null) {
      return _getFallbackScript(type, durationMinutes);
    }

    try {
      final prompt = _buildMeditationPrompt(type, durationMinutes, moodContext);

      final content = [Content.text(prompt)];
      final response = await _aiModel!.generateContent(content);

      final script = response.text?.trim();
      if (script?.isNotEmpty == true) {
        return script!;
      } else {
        return _getFallbackScript(type, durationMinutes);
      }
    } catch (e) {
      AppLogger.error('Failed to generate meditation script', e);
      return _getFallbackScript(type, durationMinutes);
    }
  }

  /// Get built-in meditation scripts
  List<Map<String, dynamic>> getBuiltInScripts() {
    return [
      {
        'id': 'breathing_basic',
        'title': 'Basic Breathing Exercise',
        'type': MeditationType.breathing,
        'duration': 5,
        'description': 'Simple breathing exercise for beginners',
        'script': _getBuiltInBreathingScript(),
      },
      {
        'id': 'prayer_gratitude',
        'title': 'Gratitude Prayer',
        'type': MeditationType.gratitude,
        'duration': 10,
        'description': 'Express thankfulness in prayer',
        'script': _getBuiltInGratitudeScript(),
      },
      {
        'id': 'peace_healing',
        'title': 'Peace and Healing',
        'type': MeditationType.healing,
        'duration': 15,
        'description': 'Find peace and spiritual healing',
        'script': _getBuiltInHealingScript(),
      },
      {
        'id': 'scripture_reflection',
        'title': 'Scripture Reflection',
        'type': MeditationType.scripture,
        'duration': 10,
        'description': 'Meditate on God\'s word',
        'script': _getBuiltInScriptureScript(),
      },
    ];
  }

  // ============= SESSION HISTORY =============

  /// Get all user meditation sessions
  Future<List<MeditationSession>> getAllSessions() async {
    return await _repository.getAllSessions();
  }

  /// Get recent meditation sessions
  Future<List<MeditationSession>> getRecentSessions({int limit = 10}) async {
    return await _repository.getRecentSessions(limit: limit);
  }

  /// Get sessions by date range
  Future<List<MeditationSession>> getSessionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return await _repository.getSessionsByDateRange(start, end);
  }

  /// Get meditation statistics
  Future<Map<String, dynamic>> getMeditationStats() async {
    final sessions = await getAllSessions();
    final completedSessions = sessions.where((s) => s.isCompleted).toList();

    if (completedSessions.isEmpty) {
      return {
        'totalSessions': 0,
        'totalMinutes': 0,
        'averageRating': 0.0,
        'streak': 0,
        'favoriteType': null,
        'completionRate': 0.0,
      };
    }

    final totalMinutes = completedSessions.fold<int>(
      0,
      (sum, session) => sum + (session.actualDurationSeconds ~/ 60),
    );

    final averageRating = completedSessions
            .where((s) => s.rating > 0)
            .map((s) => s.rating)
            .fold<double>(0, (sum, rating) => sum + rating) /
        completedSessions.where((s) => s.rating > 0).length;

    final typeFrequency = <MeditationType, int>{};
    for (final session in completedSessions) {
      typeFrequency[session.type] = (typeFrequency[session.type] ?? 0) + 1;
    }

    final favoriteType =
        typeFrequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return {
      'totalSessions': completedSessions.length,
      'totalMinutes': totalMinutes,
      'averageRating': averageRating.isNaN ? 0.0 : averageRating,
      'streak': _calculateMeditationStreak(sessions),
      'favoriteType': favoriteType.name,
      'completionRate': completedSessions.length / sessions.length,
    };
  }

  // ============= PRIVATE METHODS =============

  void _initializeSessionStream() {
    _currentSessionController = StreamController<MeditationSession>();
  }

  Future<void> _updateCurrentSession(MeditationSession session) async {
    _currentSession = session;
    await _repository.saveMeditationSession(session);
    _currentSessionController?.add(session);
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_currentSession?.state == MeditationState.active) {
        final updatedSession = _currentSession!.copyWith(
          actualDurationSeconds: _currentSession!.actualDurationSeconds + 1,
        );
        await _updateCurrentSession(updatedSession);

        // Check if target duration reached
        if (updatedSession.actualDurationSeconds >=
            updatedSession.targetDurationMinutes * 60) {
          timer.cancel();
          // Auto-complete session
          await completeMeditationSession();
        }
      }
    });
  }

  void _stopSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  Future<Map<String, dynamic>?> _getCurrentMoodContext() async {
    try {
      final recentEntries = await _moodService.getRecentEntries(limit: 1);
      if (recentEntries.isNotEmpty) {
        final entry = recentEntries.first;
        return {
          'moodScore': entry.score,
          'emotions': entry.emotions,
          'triggers': [], // SimpleMoodEntry doesn't have triggers
          'timestamp': entry.timestamp.toIso8601String(),
        };
      }
    } catch (e) {
      AppLogger.warning('Could not get mood context for meditation');
    }
    return null;
  }

  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1000);
    return 'med_${timestamp}_$random';
  }

  String _getDefaultTitle(MeditationType type) {
    switch (type) {
      case MeditationType.guided:
        return 'Guided Meditation Session';
      case MeditationType.breathing:
        return 'Breathing Exercise';
      case MeditationType.prayer:
        return 'Prayer Meditation';
      case MeditationType.scripture:
        return 'Scripture Meditation';
      case MeditationType.gratitude:
        return 'Gratitude Practice';
      case MeditationType.healing:
        return 'Healing Meditation';
      case MeditationType.peace:
        return 'Peace & Calm';
      case MeditationType.silent:
        return 'Silent Meditation';
    }
  }

  String _getDefaultDescription(MeditationType type) {
    switch (type) {
      case MeditationType.guided:
        return 'A gentle guided meditation to center your mind and spirit';
      case MeditationType.breathing:
        return 'Focus on your breath to find peace and clarity';
      case MeditationType.prayer:
        return 'Connect with God through meditative prayer';
      case MeditationType.scripture:
        return 'Reflect deeply on God\'s word';
      case MeditationType.gratitude:
        return 'Cultivate thankfulness and appreciation';
      case MeditationType.healing:
        return 'Find spiritual and emotional healing';
      case MeditationType.peace:
        return 'Discover inner peace and tranquility';
      case MeditationType.silent:
        return 'Sit in peaceful silence with your thoughts';
    }
  }

  List<String> _getDefaultTags(MeditationType type) {
    switch (type) {
      case MeditationType.guided:
        return ['guided', 'beginner-friendly', 'mindfulness'];
      case MeditationType.breathing:
        return ['breathing', 'relaxation', 'stress-relief'];
      case MeditationType.prayer:
        return ['prayer', 'spiritual', 'connection'];
      case MeditationType.scripture:
        return ['scripture', 'bible', 'reflection'];
      case MeditationType.gratitude:
        return ['gratitude', 'thankfulness', 'positive'];
      case MeditationType.healing:
        return ['healing', 'recovery', 'peace'];
      case MeditationType.peace:
        return ['peace', 'calm', 'serenity'];
      case MeditationType.silent:
        return ['silent', 'contemplation', 'quiet'];
    }
  }

  String _buildMeditationPrompt(
    MeditationType type,
    int durationMinutes,
    Map<String, dynamic>? moodContext,
  ) {
    final moodInfo = moodContext != null
        ? 'The user\'s current mood: score ${moodContext['moodScore']}/10, emotions: ${moodContext['emotions']?.join(', ') ?? 'none'}, triggers: ${moodContext['triggers']?.join(', ') ?? 'none'}.'
        : '';

    switch (type) {
      case MeditationType.guided:
        return '''Create a $durationMinutes-minute guided meditation script with spiritual themes. 
        Include gentle instructions for breathing, body awareness, and spiritual connection.
        $moodInfo
        Format with clear timing guidance and peaceful, encouraging language.
        Focus on finding God's presence and inner peace.''';

      case MeditationType.breathing:
        return '''Create a $durationMinutes-minute breathing meditation script.
        Include specific breathing techniques, counts, and gentle guidance.
        $moodInfo
        Focus on spiritual aspects of breath as God's gift of life.
        Include timing cues and peaceful transitions.''';

      case MeditationType.prayer:
        return '''Create a $durationMinutes-minute prayer meditation script.
        Include guided prayer prompts, reflection questions, and spiritual contemplation.
        $moodInfo
        Focus on deepening connection with God through meditative prayer.
        Include moments of silence and listening.''';

      case MeditationType.scripture:
        return '''Create a $durationMinutes-minute scripture meditation script.
        Include a meaningful Bible verse, reflection questions, and contemplative guidance.
        $moodInfo
        Choose an appropriate verse and provide deep reflection prompts.
        Include practical application and spiritual insights.''';

      case MeditationType.gratitude:
        return '''Create a $durationMinutes-minute gratitude meditation script.
        Include prompts for thankfulness, appreciation exercises, and spiritual gratitude.
        $moodInfo
        Focus on recognizing God's blessings and developing a grateful heart.
        Include specific gratitude practices and reflection.''';

      case MeditationType.healing:
        return '''Create a $durationMinutes-minute healing meditation script.
        Include gentle healing imagery, spiritual comfort, and restoration themes.
        $moodInfo
        Focus on God's healing presence and inner wholeness.
        Include soothing language and hope-filled affirmations.''';

      case MeditationType.peace:
        return '''Create a $durationMinutes-minute peace meditation script.
        Include calming imagery, peace-focused breathing, and spiritual serenity.
        $moodInfo
        Focus on finding God's peace that surpasses understanding.
        Include gentle guidance and tranquil visualization.''';

      default:
        return '''Create a $durationMinutes-minute general meditation script with spiritual themes.
        Include gentle guidance, breathing awareness, and connection with the divine.
        $moodInfo
        Focus on inner peace, spiritual presence, and mindful awareness.''';
    }
  }

  String _getFallbackScript(MeditationType type, int durationMinutes) {
    switch (type) {
      case MeditationType.breathing:
        return _getBuiltInBreathingScript();
      case MeditationType.gratitude:
        return _getBuiltInGratitudeScript();
      case MeditationType.healing:
        return _getBuiltInHealingScript();
      case MeditationType.scripture:
        return _getBuiltInScriptureScript();
      default:
        return '''Welcome to this $durationMinutes-minute meditation.
        
        Find a comfortable position and gently close your eyes.
        
        Take a deep breath in... and slowly release it.
        
        Allow yourself to settle into this moment of peace.
        
        Feel God's presence surrounding you with love and comfort.
        
        Continue to breathe naturally, knowing you are held in divine love.
        
        Rest in this sacred silence, opening your heart to peace.''';
    }
  }

  String _getBuiltInBreathingScript() {
    return '''Welcome to this breathing meditation.
    
    Settle into a comfortable position and gently close your eyes.
    
    [0:30] Begin by taking a natural breath in... and out.
    
    [1:00] Now breathe in for 4 counts: 1... 2... 3... 4...
    Hold for 2 counts: 1... 2...
    Breathe out for 6 counts: 1... 2... 3... 4... 5... 6...
    
    [2:00] Continue this rhythm. In for 4... hold for 2... out for 6...
    
    [3:00] With each breath, feel God's gift of life filling your lungs.
    
    [4:00] As you exhale, release any tension or worry to God.
    
    [5:00] Take a few more natural breaths and gently open your eyes.''';
  }

  String _getBuiltInGratitudeScript() {
    return '''Welcome to this gratitude meditation.
    
    Close your eyes and take a comfortable breath.
    
    [1:00] Bring to mind one thing you're grateful for today.
    
    [2:30] Feel the warmth of gratitude in your heart.
    
    [4:00] Think of a person you appreciate. Send them your thankfulness.
    
    [6:00] Consider a simple blessing - perhaps your health, home, or food.
    
    [8:00] Thank God for His constant love and provision in your life.
    
    [10:00] Rest in this grateful heart, knowing you are blessed.''';
  }

  String _getBuiltInHealingScript() {
    return '''Welcome to this healing meditation.
    
    Find a peaceful position and breathe gently.
    
    [2:00] Imagine warm, golden light surrounding your entire being.
    
    [5:00] This is God's healing presence, touching every part of you.
    
    [8:00] Allow this divine light to heal what needs healing.
    
    [11:00] Feel peace replacing any pain or discomfort.
    
    [14:00] Rest in God's complete love and restoration.
    
    [15:00] Carry this healing peace with you throughout your day.''';
  }

  String _getBuiltInScriptureScript() {
    return '''Welcome to this scripture meditation.
    
    Today we reflect on Psalm 23:1-2: "The Lord is my shepherd, I lack nothing. He makes me lie down in green pastures, he leads me beside quiet waters."
    
    [2:00] Imagine yourself in those green pastures, safe and provided for.
    
    [4:00] Feel the Good Shepherd's presence beside you.
    
    [6:00] What does it mean that you "lack nothing" in God's care?
    
    [8:00] Rest beside those quiet waters, feeling God's peace.
    
    [10:00] Carry this truth with you: you are loved, guided, and provided for.''';
  }

  int _calculateMeditationStreak(List<MeditationSession> sessions) {
    if (sessions.isEmpty) return 0;

    final completedSessions = sessions.where((s) => s.isCompleted).toList();

    if (completedSessions.isEmpty) return 0;

    completedSessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));

    int streak = 0;
    DateTime? lastDate;

    for (final session in completedSessions) {
      final sessionDate = DateTime(
        session.startedAt.year,
        session.startedAt.month,
        session.startedAt.day,
      );

      if (lastDate == null) {
        // Check if today or yesterday
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final yesterday = todayDate.subtract(const Duration(days: 1));

        if (sessionDate == todayDate || sessionDate == yesterday) {
          streak = 1;
          lastDate = sessionDate;
        } else {
          break;
        }
      } else {
        final expectedDate = lastDate.subtract(const Duration(days: 1));
        if (sessionDate == expectedDate) {
          streak++;
          lastDate = sessionDate;
        } else {
          break;
        }
      }
    }

    return streak;
  }
}
