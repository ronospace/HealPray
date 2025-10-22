import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/scripture.dart';
import '../repositories/scripture_repository.dart';
import '../../mood/services/mood_service.dart';
import '../../../core/config/app_config.dart';
import '../../../core/utils/logger.dart';
import '../../../shared/services/analytics_service.dart';

/// Service for managing scripture and daily verses
class ScriptureService {
  static ScriptureService? _instance;
  static ScriptureService get instance => _instance ??= ScriptureService._();

  ScriptureService._();

  final ScriptureRepository _repository = ScriptureRepository.instance;
  final MoodService _moodService = MoodService.instance;
  final AnalyticsService _analytics = AnalyticsService.instance;

  GenerativeModel? _aiModel;
  final Random _random = Random();

  /// Initialize the scripture service
  Future<void> initialize() async {
    try {
      await _repository.initialize();

      // Initialize AI model for personalized reflections
      if (AppConfig.geminiApiKey.isNotEmpty) {
        _aiModel = GenerativeModel(
          model: 'gemini-pro',
          apiKey: AppConfig.geminiApiKey,
        );
        AppLogger.info('ScriptureService initialized with Gemini AI');
      } else {
        AppLogger.warning('No Gemini API key found - AI features disabled');
      }

      // Load initial scripture database if empty
      await _ensureScriptureDatabase();
    } catch (e) {
      AppLogger.error('Failed to initialize ScriptureService', e);
      rethrow;
    }
  }

  // ============= DAILY VERSES =============

  /// Get today's daily verse
  Future<Scripture?> getTodaysVerse() async {
    try {
      // Check if we have a daily verse for today
      final today = DateTime.now();
      final dateKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final existingVerse = await _repository.getDailyVerse(dateKey);
      if (existingVerse != null) {
        return existingVerse;
      }

      // Generate new daily verse based on user's current mood/needs
      final personalizedVerse = await _generatePersonalizedDailyVerse();
      if (personalizedVerse != null) {
        await _repository.saveDailyVerse(dateKey, personalizedVerse.id);
        return personalizedVerse;
      }

      // Fallback to random verse
      final allVerses = await _repository.getAllScriptures();
      if (allVerses.isNotEmpty) {
        final randomVerse = allVerses[_random.nextInt(allVerses.length)];
        await _repository.saveDailyVerse(dateKey, randomVerse.id);
        return randomVerse;
      }

      return null;
    } catch (e) {
      AppLogger.error('Failed to get today\'s verse', e);
      return null;
    }
  }

  /// Get daily verse for a specific date
  Future<Scripture?> getDailyVerseForDate(DateTime date) async {
    try {
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      return await _repository.getDailyVerse(dateKey);
    } catch (e) {
      AppLogger.error('Failed to get daily verse for date', e);
      return null;
    }
  }

  /// Generate personalized daily verse based on user's recent mood
  Future<Scripture?> _generatePersonalizedDailyVerse() async {
    try {
      // Get recent mood context
      final recentMoodEntries = await _moodService.getRecentEntries(limit: 3);

      if (recentMoodEntries.isEmpty) {
        return null;
      }

      // Determine themes based on mood patterns
      final themes = <ScriptureTheme>[];
      for (final entry in recentMoodEntries) {
        if (entry.score <= 4) {
          themes.addAll([
            ScriptureTheme.comfort,
            ScriptureTheme.hope,
            ScriptureTheme.strength,
          ]);
        } else if (entry.score >= 8) {
          themes.addAll([
            ScriptureTheme.gratitude,
            ScriptureTheme.joy,
          ]);
        } else {
          themes.addAll([
            ScriptureTheme.peace,
            ScriptureTheme.guidance,
            ScriptureTheme.faith,
          ]);
        }

        // Add emotion-specific themes
        for (final emotion in entry.emotions) {
          switch (emotion.toLowerCase()) {
            case 'anxious':
            case 'worried':
              themes.add(ScriptureTheme.anxiety);
              break;
            case 'sad':
            case 'depressed':
              themes.addAll([ScriptureTheme.comfort, ScriptureTheme.hope]);
              break;
            case 'angry':
            case 'frustrated':
              themes.addAll([ScriptureTheme.anger, ScriptureTheme.forgiveness]);
              break;
            case 'fearful':
            case 'scared':
              themes.add(ScriptureTheme.fear);
              break;
            case 'grateful':
            case 'thankful':
              themes.add(ScriptureTheme.gratitude);
              break;
            case 'loved':
            case 'loving':
              themes.add(ScriptureTheme.love);
              break;
          }
        }
      }

      if (themes.isNotEmpty) {
        final suitableVerses =
            await _repository.getScripturesByThemes(themes.toSet().toList());
        if (suitableVerses.isNotEmpty) {
          return suitableVerses[_random.nextInt(suitableVerses.length)];
        }
      }

      return null;
    } catch (e) {
      AppLogger.error('Failed to generate personalized daily verse', e);
      return null;
    }
  }

  // ============= SCRIPTURE SEARCH =============

  /// Search scriptures by query
  Future<List<Scripture>> searchScriptures(String query) async {
    try {
      final allScriptures = await _repository.getAllScriptures();

      if (query.trim().isEmpty) {
        return allScriptures.take(20).toList();
      }

      final results = allScriptures
          .where((scripture) => scripture.matchesQuery(query))
          .toList();

      // Sort by relevance (rough scoring)
      results.sort((a, b) {
        final aScore = _calculateRelevanceScore(a, query);
        final bScore = _calculateRelevanceScore(b, query);
        return bScore.compareTo(aScore);
      });

      await _analytics.trackEvent('scripture_search', {
        'query': query,
        'results_count': results.length,
      });

      return results.take(50).toList();
    } catch (e) {
      AppLogger.error('Failed to search scriptures', e);
      return [];
    }
  }

  /// Get scriptures by theme
  Future<List<Scripture>> getScripturesByTheme(ScriptureTheme theme) async {
    return await _repository.getScripturesByTheme(theme);
  }

  /// Get scriptures by multiple themes
  Future<List<Scripture>> getScripturesByThemes(
      List<ScriptureTheme> themes) async {
    return await _repository.getScripturesByThemes(themes);
  }

  /// Get scriptures by category
  Future<List<Scripture>> getScripturesByCategory(
      ScriptureCategory category) async {
    return await _repository.getScripturesByCategory(category);
  }

  /// Get random verse
  Future<Scripture?> getRandomVerse({List<ScriptureTheme>? themes}) async {
    try {
      List<Scripture> verses;

      if (themes?.isNotEmpty == true) {
        verses = await getScripturesByThemes(themes!);
      } else {
        verses = await _repository.getAllScriptures();
      }

      if (verses.isNotEmpty) {
        return verses[_random.nextInt(verses.length)];
      }

      return null;
    } catch (e) {
      AppLogger.error('Failed to get random verse', e);
      return null;
    }
  }

  // ============= READING TRACKING =============

  /// Record a scripture reading
  Future<ScriptureReadingEntry> recordReading({
    required String scriptureId,
    int? moodBefore,
    int? moodAfter,
    String? personalReflection,
    String? prayer,
    List<String>? insights,
    List<String>? applications,
    int? rating,
  }) async {
    try {
      final entry = ScriptureReadingEntry(
        id: _generateReadingId(),
        scriptureId: scriptureId,
        userId: 'current_user', // TODO: Get from auth service
        timestamp: DateTime.now(),
        moodBefore: moodBefore ?? 0,
        moodAfter: moodAfter ?? 0,
        personalReflection: personalReflection,
        prayer: prayer,
        insights: insights ?? [],
        applications: applications ?? [],
        rating: rating ?? 0,
      );

      await _repository.saveReadingEntry(entry);

      // Update scripture read count
      final scripture = await _repository.getScripture(scriptureId);
      if (scripture != null) {
        final updatedScripture = scripture.copyWith(
          readCount: scripture.readCount + 1,
          lastRead: DateTime.now(),
        );
        await _repository.saveScripture(updatedScripture);
      }

      // Track analytics
      await _analytics.trackEvent('scripture_read', {
        'scripture_id': scriptureId,
        'has_reflection': personalReflection?.isNotEmpty == true,
        'has_prayer': prayer?.isNotEmpty == true,
        'mood_before': moodBefore,
        'mood_after': moodAfter,
        'rating': rating,
      });

      AppLogger.info('Recorded scripture reading: $scriptureId');
      return entry;
    } catch (e) {
      AppLogger.error('Failed to record scripture reading', e);
      rethrow;
    }
  }

  /// Get reading history
  Future<List<ScriptureReadingEntry>> getReadingHistory(
      {int limit = 50}) async {
    return await _repository.getReadingEntries();
  }

  /// Get reading stats
  Future<Map<String, dynamic>> getReadingStats() async {
    try {
      final entries = await _repository.getAllReadingEntries();

      if (entries.isEmpty) {
        return {
          'totalReadings': 0,
          'uniqueScriptures': 0,
          'averageRating': 0.0,
          'streakDays': 0,
          'moodImprovements': 0,
          'totalReflections': 0,
          'totalPrayers': 0,
        };
      }

      final uniqueScriptures = entries.map((e) => e.scriptureId).toSet().length;

      final ratedEntries = entries.where((e) => e.rating > 0).toList();
      final averageRating = ratedEntries.isNotEmpty
          ? ratedEntries.fold<double>(0, (sum, e) => sum + e.rating) /
              ratedEntries.length
          : 0.0;

      final streak = _calculateReadingStreak(entries);
      final moodImprovements = entries.where((e) => e.moodImproved).length;
      final totalReflections = entries.where((e) => e.hasReflection).length;
      final totalPrayers = entries.where((e) => e.hasPrayer).length;

      return {
        'totalReadings': entries.length,
        'uniqueScriptures': uniqueScriptures,
        'averageRating': averageRating,
        'streakDays': streak,
        'moodImprovements': moodImprovements,
        'totalReflections': totalReflections,
        'totalPrayers': totalPrayers,
      };
    } catch (e) {
      AppLogger.error('Failed to get reading stats', e);
      return {};
    }
  }

  // ============= FAVORITES =============

  /// Toggle scripture favorite
  Future<void> toggleFavorite(String scriptureId) async {
    try {
      final scripture = await _repository.getScripture(scriptureId);
      if (scripture != null) {
        final updatedScripture = scripture.copyWith(
          isFavorite: !scripture.isFavorite,
        );
        await _repository.saveScripture(updatedScripture);

        await _analytics.trackEvent('scripture_favorite_toggled', {
          'scripture_id': scriptureId,
          'is_favorite': updatedScripture.isFavorite,
        });
      }
    } catch (e) {
      AppLogger.error('Failed to toggle favorite', e);
      rethrow;
    }
  }

  /// Get favorite scriptures
  Future<List<Scripture>> getFavoriteScriptures() async {
    return await _repository.getFavoriteScriptures();
  }

  // ============= AI INSIGHTS =============

  /// Generate AI-powered reflection for a scripture
  Future<String?> generateReflection(Scripture scripture,
      {String? personalContext}) async {
    if (_aiModel == null) {
      return null;
    }

    try {
      final prompt = _buildReflectionPrompt(scripture, personalContext);

      final content = [Content.text(prompt)];
      final response = await _aiModel!.generateContent(content);

      final reflection = response.text?.trim();
      if (reflection?.isNotEmpty == true) {
        await _analytics.trackEvent('ai_reflection_generated', {
          'scripture_id': scripture.id,
          'has_context': personalContext?.isNotEmpty == true,
        });

        return reflection;
      }

      return null;
    } catch (e) {
      AppLogger.error('Failed to generate AI reflection', e);
      return null;
    }
  }

  /// Generate prayer based on scripture
  Future<String?> generatePrayer(Scripture scripture,
      {String? personalRequest}) async {
    if (_aiModel == null) {
      return null;
    }

    try {
      final prompt = _buildPrayerPrompt(scripture, personalRequest);

      final content = [Content.text(prompt)];
      final response = await _aiModel!.generateContent(content);

      final prayer = response.text?.trim();
      if (prayer?.isNotEmpty == true) {
        await _analytics.trackEvent('ai_prayer_generated', {
          'scripture_id': scripture.id,
          'has_request': personalRequest?.isNotEmpty == true,
        });

        return prayer;
      }

      return null;
    } catch (e) {
      AppLogger.error('Failed to generate AI prayer', e);
      return null;
    }
  }

  // ============= PRIVATE METHODS =============

  Future<void> _ensureScriptureDatabase() async {
    final count = await _repository.getScriptureCount();
    if (count == 0) {
      await _loadInitialScriptures();
    }
  }

  Future<void> _loadInitialScriptures() async {
    // Load a curated set of essential scriptures
    final initialScriptures = _getEssentialScriptures();

    for (final scripture in initialScriptures) {
      await _repository.saveScripture(scripture);
    }

    AppLogger.info('Loaded ${initialScriptures.length} initial scriptures');
  }

  List<Scripture> _getEssentialScriptures() {
    return [
      // Hope and Peace
      Scripture(
        id: 'john_14_27',
        book: 'John',
        chapter: 14,
        verse: '27',
        text:
            'Peace I leave with you; my peace I give you. I do not give to you as the world gives. Do not let your hearts be troubled and do not be afraid.',
        version: 'NIV',
        category: ScriptureCategory.gospels,
        themes: [
          ScriptureTheme.peace,
          ScriptureTheme.comfort,
          ScriptureTheme.fear
        ],
        keywords: ['peace', 'afraid', 'troubled', 'heart'],
      ),

      Scripture(
        id: 'jeremiah_29_11',
        book: 'Jeremiah',
        chapter: 29,
        verse: '11',
        text:
            'For I know the plans I have for you," declares the Lord, "plans to prosper you and not to harm you, to give you hope and a future.',
        version: 'NIV',
        category: ScriptureCategory.oldTestament,
        themes: [
          ScriptureTheme.hope,
          ScriptureTheme.trust,
          ScriptureTheme.guidance
        ],
        keywords: ['plans', 'hope', 'future', 'prosper'],
      ),

      // Strength and Comfort
      Scripture(
        id: 'philippians_4_13',
        book: 'Philippians',
        chapter: 4,
        verse: '13',
        text: 'I can do all this through him who gives me strength.',
        version: 'NIV',
        category: ScriptureCategory.epistles,
        themes: [ScriptureTheme.strength, ScriptureTheme.faith],
        keywords: ['strength', 'all things'],
      ),

      Scripture(
        id: 'psalm_23_4',
        book: 'Psalm',
        chapter: 23,
        verse: '4',
        text:
            'Even though I walk through the darkest valley, I will fear no evil, for you are with me; your rod and your staff, they comfort me.',
        version: 'NIV',
        category: ScriptureCategory.psalms,
        themes: [
          ScriptureTheme.comfort,
          ScriptureTheme.protection,
          ScriptureTheme.fear
        ],
        keywords: ['valley', 'fear', 'comfort', 'with me'],
      ),

      // Love and Grace
      Scripture(
        id: 'john_3_16',
        book: 'John',
        chapter: 3,
        verse: '16',
        text:
            'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
        version: 'NIV',
        category: ScriptureCategory.gospels,
        themes: [
          ScriptureTheme.love,
          ScriptureTheme.faith,
          ScriptureTheme.hope
        ],
        keywords: ['love', 'world', 'believes', 'eternal life'],
      ),

      // Anxiety and Worry
      Scripture(
        id: 'matthew_6_26',
        book: 'Matthew',
        chapter: 6,
        verse: '26',
        text:
            'Look at the birds of the air; they do not sow or reap or store away in barns, and yet your heavenly Father feeds them. Are you not much more valuable than they?',
        version: 'NIV',
        category: ScriptureCategory.gospels,
        themes: [
          ScriptureTheme.anxiety,
          ScriptureTheme.trust,
          ScriptureTheme.protection
        ],
        keywords: ['worry', 'birds', 'Father', 'valuable'],
      ),

      Scripture(
        id: 'philippians_4_6_7',
        book: 'Philippians',
        chapter: 4,
        verse: '6-7',
        text:
            'Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God. And the peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus.',
        version: 'NIV',
        category: ScriptureCategory.epistles,
        themes: [
          ScriptureTheme.anxiety,
          ScriptureTheme.prayer,
          ScriptureTheme.peace
        ],
        keywords: ['anxious', 'prayer', 'peace', 'thanksgiving'],
      ),

      // Forgiveness
      Scripture(
        id: '1_john_1_9',
        book: '1 John',
        chapter: 1,
        verse: '9',
        text:
            'If we confess our sins, he is faithful and just and will forgive us our sins and purify us from all unrighteousness.',
        version: 'NIV',
        category: ScriptureCategory.epistles,
        themes: [ScriptureTheme.forgiveness, ScriptureTheme.faith],
        keywords: ['confess', 'forgive', 'faithful', 'purify'],
      ),

      // Guidance
      Scripture(
        id: 'proverbs_3_5_6',
        book: 'Proverbs',
        chapter: 3,
        verse: '5-6',
        text:
            'Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.',
        version: 'NIV',
        category: ScriptureCategory.proverbs,
        themes: [
          ScriptureTheme.guidance,
          ScriptureTheme.trust,
          ScriptureTheme.wisdom
        ],
        keywords: ['trust', 'heart', 'understanding', 'paths'],
      ),

      // Gratitude
      Scripture(
        id: '1_thessalonians_5_18',
        book: '1 Thessalonians',
        chapter: 5,
        verse: '18',
        text:
            'Give thanks in all circumstances; for this is God\'s will for you in Christ Jesus.',
        version: 'NIV',
        category: ScriptureCategory.epistles,
        themes: [ScriptureTheme.gratitude, ScriptureTheme.joy],
        keywords: ['thanks', 'circumstances', 'will'],
      ),
    ];
  }

  int _calculateRelevanceScore(Scripture scripture, String query) {
    final lowerQuery = query.toLowerCase();
    int score = 0;

    // Reference match (highest priority)
    if (scripture.reference.toLowerCase().contains(lowerQuery)) {
      score += 100;
    }

    // Text matches
    final words = lowerQuery.split(' ');
    for (final word in words) {
      if (scripture.text.toLowerCase().contains(word)) {
        score += 10;
      }
    }

    // Keyword matches
    for (final keyword in scripture.keywords) {
      if (keyword.toLowerCase().contains(lowerQuery)) {
        score += 20;
      }
    }

    // Theme matches
    for (final theme in scripture.themes) {
      if (theme.displayName.toLowerCase().contains(lowerQuery)) {
        score += 15;
      }
    }

    return score;
  }

  String _generateReadingId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _random.nextInt(1000);
    return 'reading_$timestamp_$random';
  }

  int _calculateReadingStreak(List<ScriptureReadingEntry> entries) {
    if (entries.isEmpty) return 0;

    // Group entries by date
    final entriesByDate = <DateTime, List<ScriptureReadingEntry>>{};
    for (final entry in entries) {
      final date = DateTime(
          entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      entriesByDate[date] = (entriesByDate[date] ?? [])..add(entry);
    }

    final uniqueDates = entriesByDate.keys.toList();
    uniqueDates.sort((a, b) => b.compareTo(a)); // Most recent first

    if (uniqueDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));

    // Check if we have a reading today or yesterday to start the streak
    if (uniqueDates.first != todayDate && uniqueDates.first != yesterday) {
      return 0;
    }

    int streak = 1;
    DateTime expectedDate = uniqueDates.first.subtract(const Duration(days: 1));

    for (int i = 1; i < uniqueDates.length; i++) {
      if (uniqueDates[i] == expectedDate) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  String _buildReflectionPrompt(Scripture scripture, String? personalContext) {
    final contextPart = personalContext?.isNotEmpty == true
        ? 'Personal context: $personalContext'
        : '';

    return '''Generate a thoughtful, personal reflection on this Bible verse for spiritual meditation:

Scripture: ${scripture.fullReference}
"${scripture.text}"

Themes: ${scripture.themes.map((t) => t.displayName).join(', ')}
$contextPart

Please provide:
1. A brief explanation of the verse's meaning and context
2. Personal application for daily life
3. Questions for reflection
4. A practical way to live out this truth

Keep it encouraging, practical, and spiritually grounding. Write in a warm, pastoral tone.''';
  }

  String _buildPrayerPrompt(Scripture scripture, String? personalRequest) {
    final requestPart = personalRequest?.isNotEmpty == true
        ? 'Personal prayer request: $personalRequest'
        : '';

    return '''Create a heartfelt prayer based on this Bible verse:

Scripture: ${scripture.fullReference}
"${scripture.text}"

Themes: ${scripture.themes.map((t) => t.displayName).join(', ')}
$requestPart

Write a prayer that:
1. Acknowledges God's character as revealed in this verse
2. Thanks Him for the truths contained in this passage
3. Asks for help in applying these truths to life
4. Includes any personal requests if provided

Write in first person, with reverence and intimacy. Keep it meaningful but not overly long.''';
  }
}
