import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import 'advanced_analytics_service.dart';

/// User feedback service for continuous improvement
class UserFeedbackService {
  static final UserFeedbackService _instance = UserFeedbackService._internal();
  factory UserFeedbackService() => _instance;
  UserFeedbackService._internal();

  static UserFeedbackService get instance => _instance;

  static const String _feedbackPrefix = 'healpray_feedback';
  static const String _feedbackHistoryKey = '${_feedbackPrefix}_history';
  static const String _npsScoreKey = '${_feedbackPrefix}_nps_score';
  static const String _lastFeedbackPromptKey = '${_feedbackPrefix}_last_prompt';

  final List<FeedbackEntry> _feedbackHistory = [];
  bool _initialized = false;

  /// Initialize feedback service
  Future<void> initialize() async {
    if (_initialized) return;

    await _loadFeedbackHistory();
    _initialized = true;
    AppLogger.info('User feedback service initialized');
  }

  /// Check if we should prompt for feedback
  Future<bool> shouldPromptForFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPrompt = prefs.getString(_lastFeedbackPromptKey);
    
    if (lastPrompt == null) {
      // Never prompted before
      return true;
    }

    final lastPromptDate = DateTime.parse(lastPrompt);
    final daysSinceLastPrompt = DateTime.now().difference(lastPromptDate).inDays;
    
    // Prompt every 7 days
    return daysSinceLastPrompt >= 7;
  }

  /// Record that we prompted for feedback
  Future<void> recordFeedbackPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastFeedbackPromptKey, DateTime.now().toIso8601String());
  }

  /// Submit general app feedback
  Future<bool> submitFeedback({
    required String feedbackText,
    required FeedbackCategory category,
    int? rating,
    String? feature,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final feedback = FeedbackEntry(
        id: _generateFeedbackId(),
        feedbackText: feedbackText,
        category: category,
        rating: rating,
        feature: feature,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      );

      _feedbackHistory.add(feedback);
      await _saveFeedbackHistory();

      // Track analytics
      AdvancedAnalyticsService.instance.trackEvent('feedback_submitted', {
        'category': category.name,
        'rating': rating,
        'feature': feature,
        'has_text': feedbackText.isNotEmpty,
        'text_length': feedbackText.length,
        ...?metadata,
      });

      AppLogger.info('Feedback submitted: ${category.name}');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to submit feedback', e, stackTrace);
      return false;
    }
  }

  /// Submit Net Promoter Score
  Future<bool> submitNPS({
    required int score,
    String? reason,
  }) async {
    if (score < 0 || score > 10) {
      throw ArgumentError('NPS score must be between 0 and 10');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_npsScoreKey, score);

      final npsCategory = _getNPSCategory(score);
      
      if (reason != null && reason.isNotEmpty) {
        await submitFeedback(
          feedbackText: reason,
          category: FeedbackCategory.nps,
          rating: score,
          metadata: {
            'nps_category': npsCategory,
          },
        );
      }

      // Track analytics
      AdvancedAnalyticsService.instance.trackEvent('nps_submitted', {
        'score': score,
        'category': npsCategory,
        'has_reason': reason != null && reason.isNotEmpty,
      });

      AppLogger.info('NPS submitted: $score ($npsCategory)');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to submit NPS', e, stackTrace);
      return false;
    }
  }

  /// Submit feature request
  Future<bool> submitFeatureRequest({
    required String title,
    required String description,
    FeaturePriority priority = FeaturePriority.medium,
    List<String>? tags,
  }) async {
    try {
      await submitFeedback(
        feedbackText: description,
        category: FeedbackCategory.featureRequest,
        feature: title,
        metadata: {
          'priority': priority.name,
          'tags': tags ?? [],
          'title': title,
        },
      );

      AdvancedAnalyticsService.instance.trackEvent('feature_request_submitted', {
        'title': title,
        'priority': priority.name,
        'has_tags': tags?.isNotEmpty ?? false,
        'description_length': description.length,
      });

      AppLogger.info('Feature request submitted: $title');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to submit feature request', e, stackTrace);
      return false;
    }
  }

  /// Submit bug report
  Future<bool> submitBugReport({
    required String title,
    required String description,
    BugSeverity severity = BugSeverity.medium,
    String? stepsToReproduce,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      await submitFeedback(
        feedbackText: description,
        category: FeedbackCategory.bugReport,
        feature: title,
        metadata: {
          'severity': severity.name,
          'steps_to_reproduce': stepsToReproduce,
          'device_info': deviceInfo,
          'title': title,
        },
      );

      AdvancedAnalyticsService.instance.trackEvent('bug_report_submitted', {
        'title': title,
        'severity': severity.name,
        'has_steps': stepsToReproduce?.isNotEmpty ?? false,
        'has_device_info': deviceInfo?.isNotEmpty ?? false,
        'description_length': description.length,
      });

      AppLogger.info('Bug report submitted: $title');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to submit bug report', e, stackTrace);
      return false;
    }
  }

  /// Submit usability feedback
  Future<bool> submitUsabilityFeedback({
    required String feature,
    required int usabilityRating,
    String? improvementSuggestion,
    Map<String, dynamic>? usabilityMetrics,
  }) async {
    if (usabilityRating < 1 || usabilityRating > 5) {
      throw ArgumentError('Usability rating must be between 1 and 5');
    }

    try {
      await submitFeedback(
        feedbackText: improvementSuggestion ?? '',
        category: FeedbackCategory.usability,
        rating: usabilityRating,
        feature: feature,
        metadata: {
          'usability_metrics': usabilityMetrics,
          'has_suggestion': improvementSuggestion?.isNotEmpty ?? false,
        },
      );

      AdvancedAnalyticsService.instance.trackEvent('usability_feedback_submitted', {
        'feature': feature,
        'rating': usabilityRating,
        'has_suggestion': improvementSuggestion?.isNotEmpty ?? false,
        ...?usabilityMetrics,
      });

      AppLogger.info('Usability feedback submitted for: $feature');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to submit usability feedback', e, stackTrace);
      return false;
    }
  }

  /// Get feedback statistics
  Future<FeedbackStats> getFeedbackStats() async {
    final prefs = await SharedPreferences.getInstance();
    final npsScore = prefs.getInt(_npsScoreKey);

    final stats = FeedbackStats();
    stats.totalFeedback = _feedbackHistory.length;
    stats.npsScore = npsScore;

    // Category breakdown
    for (final feedback in _feedbackHistory) {
      stats.categoryBreakdown[feedback.category.name] = 
          (stats.categoryBreakdown[feedback.category.name] ?? 0) + 1;
    }

    // Average rating
    final ratingsData = _feedbackHistory.where((f) => f.rating != null);
    if (ratingsData.isNotEmpty) {
      stats.averageRating = ratingsData
          .map((f) => f.rating!)
          .reduce((a, b) => a + b) / ratingsData.length;
    }

    // Recent feedback (last 30 days)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    stats.recentFeedbackCount = _feedbackHistory
        .where((f) => f.timestamp.isAfter(thirtyDaysAgo))
        .length;

    return stats;
  }

  /// Get feedback by category
  List<FeedbackEntry> getFeedbackByCategory(FeedbackCategory category) {
    return _feedbackHistory.where((f) => f.category == category).toList();
  }

  /// Get recent feedback
  List<FeedbackEntry> getRecentFeedback({int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _feedbackHistory
        .where((f) => f.timestamp.isAfter(cutoffDate))
        .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Export feedback data
  String exportFeedbackData() {
    final exportData = {
      'export_timestamp': DateTime.now().toIso8601String(),
      'feedback_entries': _feedbackHistory.map((f) => f.toJson()).toList(),
    };
    return jsonEncode(exportData);
  }

  /// Clear old feedback (keep last 100 entries)
  Future<void> cleanupOldFeedback() async {
    if (_feedbackHistory.length > 100) {
      _feedbackHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _feedbackHistory.removeRange(100, _feedbackHistory.length);
      await _saveFeedbackHistory();
      AppLogger.info('Cleaned up old feedback entries');
    }
  }

  // Private methods

  /// Generate unique feedback ID
  String _generateFeedbackId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'feedback_$timestamp';
  }

  /// Get NPS category
  String _getNPSCategory(int score) {
    if (score >= 9) return 'promoter';
    if (score >= 7) return 'passive';
    return 'detractor';
  }

  /// Load feedback history from storage
  Future<void> _loadFeedbackHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_feedbackHistoryKey);
      
      if (historyJson != null) {
        final List<dynamic> historyData = jsonDecode(historyJson);
        _feedbackHistory.clear();
        _feedbackHistory.addAll(
          historyData.map((data) => FeedbackEntry.fromJson(data)),
        );
      }
      
      AppLogger.debug('Loaded ${_feedbackHistory.length} feedback entries');
    } catch (e) {
      AppLogger.error('Failed to load feedback history', e);
    }
  }

  /// Save feedback history to storage
  Future<void> _saveFeedbackHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(
        _feedbackHistory.map((f) => f.toJson()).toList(),
      );
      await prefs.setString(_feedbackHistoryKey, historyJson);
    } catch (e) {
      AppLogger.error('Failed to save feedback history', e);
    }
  }
}

/// Feedback entry model
class FeedbackEntry {
  final String id;
  final String feedbackText;
  final FeedbackCategory category;
  final int? rating;
  final String? feature;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  FeedbackEntry({
    required this.id,
    required this.feedbackText,
    required this.category,
    this.rating,
    this.feature,
    required this.timestamp,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'feedback_text': feedbackText,
      'category': category.name,
      'rating': rating,
      'feature': feature,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory FeedbackEntry.fromJson(Map<String, dynamic> json) {
    return FeedbackEntry(
      id: json['id'],
      feedbackText: json['feedback_text'],
      category: FeedbackCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => FeedbackCategory.general,
      ),
      rating: json['rating'],
      feature: json['feature'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

/// Feedback categories
enum FeedbackCategory {
  general,
  featureRequest,
  bugReport,
  usability,
  performance,
  nps,
  content,
  privacy,
  accessibility,
}

/// Feature request priority levels
enum FeaturePriority {
  low,
  medium,
  high,
  critical,
}

/// Bug report severity levels
enum BugSeverity {
  low,
  medium,
  high,
  critical,
}

/// Feedback statistics
class FeedbackStats {
  int totalFeedback = 0;
  int? npsScore;
  double? averageRating;
  int recentFeedbackCount = 0;
  Map<String, int> categoryBreakdown = {};

  Map<String, dynamic> toJson() {
    return {
      'total_feedback': totalFeedback,
      'nps_score': npsScore,
      'average_rating': averageRating,
      'recent_feedback_count': recentFeedbackCount,
      'category_breakdown': categoryBreakdown,
    };
  }
}
