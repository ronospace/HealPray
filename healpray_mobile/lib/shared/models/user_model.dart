import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'user_model.g.dart';

/// User data model
class UserModel extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime? lastSignIn;
  final DateTime? lastActivity;
  final String signInMethod;
  final UserPreferences preferences;
  final UserAnalytics analytics;
  final String? fcmToken;

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    required this.createdAt,
    this.lastSignIn,
    this.lastActivity,
    required this.signInMethod,
    required this.preferences,
    required this.analytics,
    this.fcmToken,
  });

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoURL,
        createdAt,
        lastSignIn,
        lastActivity,
        signInMethod,
        preferences,
        analytics,
        fcmToken,
      ];

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return UserModel(
      uid: data['uid'] as String,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoURL: data['photoURL'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastSignIn: data['lastSignIn'] != null
          ? (data['lastSignIn'] as Timestamp).toDate()
          : null,
      lastActivity: data['lastActivity'] != null
          ? (data['lastActivity'] as Timestamp).toDate()
          : null,
      signInMethod: data['signInMethod'] as String,
      preferences:
          UserPreferences.fromMap(data['preferences'] as Map<String, dynamic>),
      analytics:
          UserAnalytics.fromMap(data['analytics'] as Map<String, dynamic>),
      fcmToken: data['fcmToken'] as String?,
    );
  }

  /// Convert UserModel to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSignIn': lastSignIn != null ? Timestamp.fromDate(lastSignIn!) : null,
      'lastActivity':
          lastActivity != null ? Timestamp.fromDate(lastActivity!) : null,
      'signInMethod': signInMethod,
      'preferences': preferences.toMap(),
      'analytics': analytics.toMap(),
      'fcmToken': fcmToken,
    };
  }

  /// Create a copy with updated values
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastSignIn,
    DateTime? lastActivity,
    String? signInMethod,
    UserPreferences? preferences,
    UserAnalytics? analytics,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastSignIn: lastSignIn ?? this.lastSignIn,
      lastActivity: lastActivity ?? this.lastActivity,
      signInMethod: signInMethod ?? this.signInMethod,
      preferences: preferences ?? this.preferences,
      analytics: analytics ?? this.analytics,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}

/// User preferences model
@HiveType(typeId: 4)
class UserPreferences extends Equatable {
  @HiveField(0)
  final NotificationPreferences notifications;

  @HiveField(1)
  final PrivacyPreferences privacy;

  @HiveField(2)
  final SpiritualPreferences spiritual;

  const UserPreferences({
    required this.notifications,
    required this.privacy,
    required this.spiritual,
  });

  @override
  List<Object> get props => [notifications, privacy, spiritual];

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      notifications: NotificationPreferences.fromMap(
          map['notifications'] as Map<String, dynamic>),
      privacy:
          PrivacyPreferences.fromMap(map['privacy'] as Map<String, dynamic>),
      spiritual: SpiritualPreferences.fromMap(
          map['spiritual'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notifications': notifications.toMap(),
      'privacy': privacy.toMap(),
      'spiritual': spiritual.toMap(),
    };
  }

  UserPreferences copyWith({
    NotificationPreferences? notifications,
    PrivacyPreferences? privacy,
    SpiritualPreferences? spiritual,
  }) {
    return UserPreferences(
      notifications: notifications ?? this.notifications,
      privacy: privacy ?? this.privacy,
      spiritual: spiritual ?? this.spiritual,
    );
  }
}

/// Notification preferences
@HiveType(typeId: 5)
class NotificationPreferences extends Equatable {
  @HiveField(0)
  final bool morning;

  @HiveField(1)
  final bool midday;

  @HiveField(2)
  final bool evening;

  @HiveField(3)
  final bool community;

  @HiveField(4)
  final bool crisisSupport;

  const NotificationPreferences({
    required this.morning,
    required this.midday,
    required this.evening,
    required this.community,
    required this.crisisSupport,
  });

  @override
  List<Object> get props =>
      [morning, midday, evening, community, crisisSupport];

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      morning: map['morning'] as bool? ?? true,
      midday: map['midday'] as bool? ?? true,
      evening: map['evening'] as bool? ?? true,
      community: map['community'] as bool? ?? true,
      crisisSupport: map['crisisSupport'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'morning': morning,
      'midday': midday,
      'evening': evening,
      'community': community,
      'crisisSupport': crisisSupport,
    };
  }

  NotificationPreferences copyWith({
    bool? morning,
    bool? midday,
    bool? evening,
    bool? community,
    bool? crisisSupport,
  }) {
    return NotificationPreferences(
      morning: morning ?? this.morning,
      midday: midday ?? this.midday,
      evening: evening ?? this.evening,
      community: community ?? this.community,
      crisisSupport: crisisSupport ?? this.crisisSupport,
    );
  }
}

/// Privacy preferences
@HiveType(typeId: 6)
class PrivacyPreferences extends Equatable {
  @HiveField(0)
  final bool shareAnalytics;

  @HiveField(1)
  final bool shareCommunity;

  const PrivacyPreferences({
    required this.shareAnalytics,
    required this.shareCommunity,
  });

  @override
  List<Object> get props => [shareAnalytics, shareCommunity];

  factory PrivacyPreferences.fromMap(Map<String, dynamic> map) {
    return PrivacyPreferences(
      shareAnalytics: map['shareAnalytics'] as bool? ?? true,
      shareCommunity: map['shareCommunity'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shareAnalytics': shareAnalytics,
      'shareCommunity': shareCommunity,
    };
  }

  PrivacyPreferences copyWith({
    bool? shareAnalytics,
    bool? shareCommunity,
  }) {
    return PrivacyPreferences(
      shareAnalytics: shareAnalytics ?? this.shareAnalytics,
      shareCommunity: shareCommunity ?? this.shareCommunity,
    );
  }
}

/// Spiritual preferences
@HiveType(typeId: 7)
class SpiritualPreferences extends Equatable {
  @HiveField(0)
  final String denomination;

  @HiveField(1)
  final String language;

  @HiveField(2)
  final String tone;

  @HiveField(3)
  final String length;

  const SpiritualPreferences({
    required this.denomination,
    required this.language,
    required this.tone,
    required this.length,
  });

  @override
  List<Object> get props => [denomination, language, tone, length];

  factory SpiritualPreferences.fromMap(Map<String, dynamic> map) {
    return SpiritualPreferences(
      denomination: map['denomination'] as String? ?? '',
      language: map['language'] as String? ?? 'en',
      tone: map['tone'] as String? ?? 'warm',
      length: map['length'] as String? ?? 'medium',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'denomination': denomination,
      'language': language,
      'tone': tone,
      'length': length,
    };
  }

  SpiritualPreferences copyWith({
    String? denomination,
    String? language,
    String? tone,
    String? length,
  }) {
    return SpiritualPreferences(
      denomination: denomination ?? this.denomination,
      language: language ?? this.language,
      tone: tone ?? this.tone,
      length: length ?? this.length,
    );
  }
}

/// User analytics model
@HiveType(typeId: 8)
class UserAnalytics extends Equatable {
  @HiveField(0)
  final int totalPrayers;

  @HiveField(1)
  final int totalMoodEntries;

  @HiveField(2)
  final double averageMood;

  @HiveField(3)
  final int longestStreak;

  @HiveField(4)
  final int currentStreak;

  const UserAnalytics({
    required this.totalPrayers,
    required this.totalMoodEntries,
    required this.averageMood,
    required this.longestStreak,
    required this.currentStreak,
  });

  @override
  List<Object> get props => [
        totalPrayers,
        totalMoodEntries,
        averageMood,
        longestStreak,
        currentStreak,
      ];

  factory UserAnalytics.fromMap(Map<String, dynamic> map) {
    return UserAnalytics(
      totalPrayers: map['totalPrayers'] as int? ?? 0,
      totalMoodEntries: map['totalMoodEntries'] as int? ?? 0,
      averageMood: (map['averageMood'] as num?)?.toDouble() ?? 5.0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      currentStreak: map['currentStreak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalPrayers': totalPrayers,
      'totalMoodEntries': totalMoodEntries,
      'averageMood': averageMood,
      'longestStreak': longestStreak,
      'currentStreak': currentStreak,
    };
  }

  UserAnalytics copyWith({
    int? totalPrayers,
    int? totalMoodEntries,
    double? averageMood,
    int? longestStreak,
    int? currentStreak,
  }) {
    return UserAnalytics(
      totalPrayers: totalPrayers ?? this.totalPrayers,
      totalMoodEntries: totalMoodEntries ?? this.totalMoodEntries,
      averageMood: averageMood ?? this.averageMood,
      longestStreak: longestStreak ?? this.longestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }
}
