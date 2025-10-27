import 'dart:async';
import 'dart:math';

import '../../../core/utils/logger.dart';
import '../../../shared/services/analytics_service.dart';
import '../models/prayer_circle.dart';
import '../models/prayer_request.dart';
import '../models/prayer_response.dart';
import '../models/community_member.dart';

/// Service for managing prayer circles and community spiritual support
class PrayerCircleService {
  static PrayerCircleService? _instance;
  static PrayerCircleService get instance =>
      _instance ??= PrayerCircleService._();

  PrayerCircleService._();

  final AnalyticsService _analytics = AnalyticsService.instance;
  final Random _random = Random();

  // In-memory storage for demo purposes
  final List<PrayerCircle> _prayerCircles = [];
  final List<PrayerRequest> _prayerRequests = [];
  final List<PrayerResponse> _prayerResponses = [];
  final List<CommunityMember> _communityMembers = [];

  /// Initialize with sample data
  Future<void> initialize() async {
    try {
      AppLogger.info('Initializing prayer circle service');

      // Load sample data
      await _loadSampleData();

      AppLogger.info(
          'Prayer circle service initialized with ${_prayerCircles.length} circles');
    } catch (e) {
      AppLogger.error('Failed to initialize prayer circle service', e);
    }
  }

  /// Get prayer circles for the current user
  Future<List<PrayerCircle>> getUserPrayerCircles() async {
    try {
      // In a real app, filter by user membership
      return _prayerCircles;
    } catch (e) {
      AppLogger.error('Failed to get user prayer circles', e);
      return [];
    }
  }

  /// Join a prayer circle
  Future<bool> joinPrayerCircle(String circleId, String userId) async {
    try {
      AppLogger.info('User $userId joining prayer circle $circleId');

      final circleIndex = _prayerCircles.indexWhere((c) => c.id == circleId);
      if (circleIndex == -1) {
        return false;
      }

      final circle = _prayerCircles[circleIndex];
      if (circle.memberIds.contains(userId)) {
        return true; // Already a member
      }

      // Add user to circle
      final updatedCircle = circle.copyWith(
        memberIds: [...circle.memberIds, userId],
        memberCount: circle.memberCount + 1,
      );

      _prayerCircles[circleIndex] = updatedCircle;

      // Track join event
      await _analytics.trackEvent('prayer_circle_joined', {
        'circle_id': circleId,
        'circle_name': circle.name,
        'member_count': updatedCircle.memberCount,
      });

      return true;
    } catch (e) {
      AppLogger.error('Failed to join prayer circle', e);
      return false;
    }
  }

  /// Create a new prayer circle
  Future<PrayerCircle?> createPrayerCircle({
    required String name,
    required String description,
    required String creatorId,
    bool isPrivate = false,
    List<String> tags = const [],
  }) async {
    try {
      AppLogger.info('Creating new prayer circle: $name');

      final circle = PrayerCircle(
        id: _generateCircleId(),
        name: name,
        description: description,
        creatorId: creatorId,
        memberIds: [creatorId],
        memberCount: 1,
        isPrivate: isPrivate,
        tags: tags,
        createdAt: DateTime.now(),
        lastActivity: DateTime.now(),
      );

      _prayerCircles.add(circle);

      // Track creation
      await _analytics.trackEvent('prayer_circle_created', {
        'circle_id': circle.id,
        'circle_name': name,
        'is_private': isPrivate,
        'tags': tags,
      });

      return circle;
    } catch (e) {
      AppLogger.error('Failed to create prayer circle', e);
      return null;
    }
  }

  /// Submit a prayer request
  Future<PrayerRequest?> submitPrayerRequest({
    required String circleId,
    required String requesterId,
    required String title,
    required String description,
    PrayerUrgency urgency = PrayerUrgency.normal,
    List<String> tags = const [],
    bool isAnonymous = false,
  }) async {
    try {
      AppLogger.info('Submitting prayer request to circle $circleId');

      final request = PrayerRequest(
        id: _generateRequestId(),
        circleId: circleId,
        requesterId: requesterId,
        title: title,
        description: description,
        urgency: urgency,
        tags: tags,
        isAnonymous: isAnonymous,
        createdAt: DateTime.now(),
        prayerCount: 0,
        responseCount: 0,
      );

      _prayerRequests.add(request);

      // Update circle activity
      _updateCircleActivity(circleId);

      // Track request submission
      await _analytics.trackEvent('prayer_request_submitted', {
        'request_id': request.id,
        'circle_id': circleId,
        'urgency': urgency.toString(),
        'is_anonymous': isAnonymous,
        'tags': tags,
      });

      return request;
    } catch (e) {
      AppLogger.error('Failed to submit prayer request', e);
      return null;
    }
  }

  /// Get prayer requests for a circle
  Future<List<PrayerRequest>> getPrayerRequests(String circleId) async {
    try {
      return _prayerRequests.where((r) => r.circleId == circleId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      AppLogger.error('Failed to get prayer requests', e);
      return [];
    }
  }

  /// Pray for a request
  Future<bool> prayForRequest(String requestId, String userId) async {
    try {
      final requestIndex = _prayerRequests.indexWhere((r) => r.id == requestId);
      if (requestIndex == -1) {
        return false;
      }

      // Update prayer count
      final request = _prayerRequests[requestIndex];
      final updatedRequest = request.copyWith(
        prayerCount: request.prayerCount + 1,
      );

      _prayerRequests[requestIndex] = updatedRequest;

      // Track prayer
      await _analytics.trackEvent('prayer_offered', {
        'request_id': requestId,
        'circle_id': request.circleId,
        'total_prayers': updatedRequest.prayerCount,
      });

      AppLogger.info('Prayer offered for request $requestId');
      return true;
    } catch (e) {
      AppLogger.error('Failed to pray for request', e);
      return false;
    }
  }

  /// Respond to a prayer request with encouragement
  Future<PrayerResponse?> respondToPrayerRequest({
    required String requestId,
    required String responderId,
    required String message,
    bool includeVerse = false,
    String? verseReference,
    String? verseText,
  }) async {
    try {
      AppLogger.info('Responding to prayer request $requestId');

      final response = PrayerResponse(
        id: _generateResponseId(),
        requestId: requestId,
        responderId: responderId,
        message: message,
        verseReference: verseReference,
        verseText: verseText,
        createdAt: DateTime.now(),
        likesCount: 0,
      );

      _prayerResponses.add(response);

      // Update request response count
      final requestIndex = _prayerRequests.indexWhere((r) => r.id == requestId);
      if (requestIndex != -1) {
        final request = _prayerRequests[requestIndex];
        _prayerRequests[requestIndex] = request.copyWith(
          responseCount: request.responseCount + 1,
        );
      }

      // Track response
      await _analytics.trackEvent('prayer_response_submitted', {
        'response_id': response.id,
        'request_id': requestId,
        'includes_verse': includeVerse,
        'message_length': message.length,
      });

      return response;
    } catch (e) {
      AppLogger.error('Failed to respond to prayer request', e);
      return null;
    }
  }

  /// Get responses for a prayer request
  Future<List<PrayerResponse>> getPrayerResponses(String requestId) async {
    try {
      return _prayerResponses.where((r) => r.requestId == requestId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      AppLogger.error('Failed to get prayer responses', e);
      return [];
    }
  }

  /// Discover public prayer circles
  Future<List<PrayerCircle>> discoverPrayerCircles({
    String? searchQuery,
    List<String> tags = const [],
  }) async {
    try {
      var circles = _prayerCircles.where((c) => !c.isPrivate).toList();

      // Filter by search query
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        circles = circles
            .where((c) =>
                c.name.toLowerCase().contains(query) ||
                c.description.toLowerCase().contains(query))
            .toList();
      }

      // Filter by tags
      if (tags.isNotEmpty) {
        circles = circles
            .where((c) => c.tags.any((tag) => tags.contains(tag)))
            .toList();
      }

      // Sort by activity and member count
      circles.sort((a, b) {
        final aScore = a.memberCount * 2 + _getDaysSinceActivity(a);
        final bScore = b.memberCount * 2 + _getDaysSinceActivity(b);
        return bScore.compareTo(aScore);
      });

      return circles;
    } catch (e) {
      AppLogger.error('Failed to discover prayer circles', e);
      return [];
    }
  }

  /// Get community statistics
  Future<Map<String, dynamic>> getCommunityStats() async {
    try {
      final totalPrayers = _prayerRequests.fold<int>(
          0, (sum, request) => sum + request.prayerCount);

      final activeMembersCount =
          _communityMembers.where((m) => _isRecentlyActive(m)).length;

      return {
        'total_circles': _prayerCircles.length,
        'total_members': _communityMembers.length,
        'active_members': activeMembersCount,
        'total_prayer_requests': _prayerRequests.length,
        'total_prayers_offered': totalPrayers,
        'total_responses': _prayerResponses.length,
        'most_active_circle': _getMostActiveCircle()?.name ?? 'N/A',
      };
    } catch (e) {
      AppLogger.error('Failed to get community stats', e);
      return {};
    }
  }

  /// Private helper methods

  void _updateCircleActivity(String circleId) {
    final circleIndex = _prayerCircles.indexWhere((c) => c.id == circleId);
    if (circleIndex != -1) {
      _prayerCircles[circleIndex] = _prayerCircles[circleIndex].copyWith(
        lastActivity: DateTime.now(),
      );
    }
  }

  int _getDaysSinceActivity(PrayerCircle circle) {
    return DateTime.now().difference(circle.lastActivity).inDays;
  }

  bool _isRecentlyActive(CommunityMember member) {
    return DateTime.now().difference(member.lastSeen).inDays <= 7;
  }

  PrayerCircle? _getMostActiveCircle() {
    if (_prayerCircles.isEmpty) return null;

    return _prayerCircles
        .reduce((a, b) => a.memberCount > b.memberCount ? a : b);
  }

  String _generateCircleId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _random.nextInt(1000);
    return 'circle_${timestamp}_$random';
  }

  String _generateRequestId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _random.nextInt(1000);
    return 'request_${timestamp}_$random';
  }

  String _generateResponseId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _random.nextInt(1000);
    return 'response_${timestamp}_$random';
  }

  /// Load sample data for demo
  Future<void> _loadSampleData() async {
    // Sample prayer circles
    _prayerCircles.addAll([
      PrayerCircle(
        id: 'healing_circle',
        name: 'Healing & Recovery',
        description:
            'A supportive community for those seeking physical, emotional, and spiritual healing.',
        creatorId: 'user_1',
        memberIds: ['user_1', 'user_2', 'user_3', 'user_4'],
        memberCount: 4,
        tags: ['healing', 'recovery', 'support'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
        isPrivate: false,
      ),
      PrayerCircle(
        id: 'family_circle',
        name: 'Families in Faith',
        description:
            'Prayers for families, children, marriages, and relationships.',
        creatorId: 'user_2',
        memberIds: ['user_2', 'user_5', 'user_6'],
        memberCount: 3,
        tags: ['family', 'marriage', 'children'],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        lastActivity: DateTime.now().subtract(const Duration(hours: 6)),
        isPrivate: false,
      ),
      PrayerCircle(
        id: 'work_circle',
        name: 'Workplace Blessings',
        description:
            'Finding purpose and peace in our work and career challenges.',
        creatorId: 'user_3',
        memberIds: ['user_3', 'user_7', 'user_8', 'user_9'],
        memberCount: 4,
        tags: ['work', 'career', 'purpose'],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        lastActivity: DateTime.now().subtract(const Duration(hours: 12)),
        isPrivate: false,
      ),
    ]);

    // Sample prayer requests
    _prayerRequests.addAll([
      PrayerRequest(
        id: 'request_1',
        circleId: 'healing_circle',
        requesterId: 'user_2',
        title: 'Recovery from Surgery',
        description:
            'Please pray for my mother\'s recovery from heart surgery. She\'s doing well but needs strength for the healing process.',
        urgency: PrayerUrgency.high,
        tags: ['healing', 'surgery', 'family'],
        isAnonymous: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        prayerCount: 8,
        responseCount: 3,
      ),
      PrayerRequest(
        id: 'request_2',
        circleId: 'family_circle',
        requesterId: 'user_5',
        title: 'Marriage Healing',
        description:
            'My husband and I are going through a difficult time. Please pray for understanding, forgiveness, and renewed love.',
        urgency: PrayerUrgency.normal,
        tags: ['marriage', 'forgiveness', 'love'],
        isAnonymous: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        prayerCount: 12,
        responseCount: 5,
      ),
      PrayerRequest(
        id: 'request_3',
        circleId: 'work_circle',
        requesterId: 'user_7',
        title: 'Job Search Guidance',
        description:
            'I\'ve been unemployed for three months. Praying for the right opportunity and God\'s guidance in this season.',
        urgency: PrayerUrgency.normal,
        tags: ['work', 'guidance', 'provision'],
        isAnonymous: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
        prayerCount: 6,
        responseCount: 2,
      ),
    ]);

    // Sample community members
    _communityMembers.addAll([
      CommunityMember(
        id: 'user_1',
        displayName: 'Sarah M.',
        avatarUrl: null,
        joinedAt: DateTime.now().subtract(const Duration(days: 60)),
        lastSeen: DateTime.now().subtract(const Duration(minutes: 30)),
        prayersOffered: 45,
        requestsSubmitted: 8,
        circlesJoined: 3,
        isVerified: true,
      ),
      CommunityMember(
        id: 'user_2',
        displayName: 'David L.',
        avatarUrl: null,
        joinedAt: DateTime.now().subtract(const Duration(days: 45)),
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
        prayersOffered: 32,
        requestsSubmitted: 5,
        circlesJoined: 2,
        isVerified: false,
      ),
    ]);

    // Sample responses
    _prayerResponses.addAll([
      PrayerResponse(
        id: 'response_1',
        requestId: 'request_1',
        responderId: 'user_1',
        message:
            'Praying for your mother\'s complete healing and strength. God is with you both during this time.',
        verseReference: 'Jeremiah 30:17',
        verseText:
            'For I will restore health to you, and your wounds I will heal, declares the Lord.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likesCount: 5,
      ),
    ]);
  }
}
