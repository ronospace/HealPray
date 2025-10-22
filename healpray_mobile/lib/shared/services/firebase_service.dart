import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../core/utils/logger.dart';
import '../../core/config/app_config.dart';

/// Centralized Firebase service management
class FirebaseService {
  FirebaseService._();

  static FirebaseAuth get auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      throw Exception(
          'Firebase not initialized. Please ensure Firebase.initializeApp() is called first.');
    }
  }

  static FirebaseFirestore get firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      throw Exception(
          'Firebase not initialized. Please ensure Firebase.initializeApp() is called first.');
    }
  }

  static FirebaseMessaging get messaging {
    try {
      return FirebaseMessaging.instance;
    } catch (e) {
      throw Exception(
          'Firebase not initialized. Please ensure Firebase.initializeApp() is called first.');
    }
  }

  static FirebaseAnalytics get analytics {
    try {
      return FirebaseAnalytics.instance;
    } catch (e) {
      throw Exception(
          'Firebase not initialized. Please ensure Firebase.initializeApp() is called first.');
    }
  }

  static FirebaseCrashlytics get crashlytics {
    try {
      return FirebaseCrashlytics.instance;
    } catch (e) {
      throw Exception(
          'Firebase not initialized. Please ensure Firebase.initializeApp() is called first.');
    }
  }

  static bool _initialized = false;

  /// Initialize Firebase services
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      AppLogger.info('Initializing Firebase services...');

      // Configure Firestore settings
      if (!AppConfig.isProduction) {
        // Use emulator in development
        try {
          await firestore.enableNetwork();
          firestore.settings = const Settings(
            persistenceEnabled: true,
            cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
          );
        } catch (e) {
          AppLogger.warning('Failed to configure Firestore settings: $e');
        }
      }

      // Configure authentication state changes
      auth.authStateChanges().listen(_onAuthStateChanged);

      // Configure FCM
      await _configureFCM();

      // Configure analytics
      if (AppConfig.enableAnalytics) {
        await analytics.setAnalyticsCollectionEnabled(true);
        AppLogger.info('Firebase Analytics enabled');
      }

      // Configure crashlytics
      await crashlytics
          .setCrashlyticsCollectionEnabled(!AppConfig.isDevelopment);

      _initialized = true;
      AppLogger.info('Firebase services initialized successfully');
    } catch (error, stackTrace) {
      AppLogger.error(
          'Failed to initialize Firebase services', error, stackTrace);
      rethrow;
    }
  }

  /// Configure Firebase Cloud Messaging
  static Future<void> _configureFCM() async {
    try {
      // Request permission for notifications
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      AppLogger.info('FCM permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        final token = await messaging.getToken();
        AppLogger.info('FCM Token: ${token?.substring(0, 20)}...');

        // Listen for token refresh
        messaging.onTokenRefresh.listen((token) {
          AppLogger.info('FCM Token refreshed');
          _updateUserFCMToken(token);
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background message clicks
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      }
    } catch (error) {
      AppLogger.error('Failed to configure FCM', error);
    }
  }

  /// Handle authentication state changes
  static void _onAuthStateChanged(User? user) {
    if (user != null) {
      AppLogger.userAuthenticated(
        userId: user.uid,
        method: _getSignInMethod(user),
      );

      // Update user analytics properties
      if (AppConfig.enableAnalytics) {
        analytics.setUserId(id: user.uid);
        analytics.setUserProperty(
            name: 'sign_in_method', value: _getSignInMethod(user));
      }

      // Update FCM token in user profile
      _updateUserFCMToken();
    } else {
      AppLogger.info('User signed out');

      if (AppConfig.enableAnalytics) {
        analytics.setUserId(id: null);
      }
    }
  }

  /// Handle foreground FCM messages
  static void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info('Received FCM message: ${message.messageId}');

    // Handle different message types
    final messageType = message.data['type'] ?? 'general';

    switch (messageType) {
      case 'morning_prayer':
        _handlePrayerReminder(message);
        break;
      case 'crisis_support':
        _handleCrisisSupport(message);
        break;
      case 'community_update':
        _handleCommunityUpdate(message);
        break;
      default:
        AppLogger.info('Unhandled message type: $messageType');
    }
  }

  /// Handle FCM message opened from background/terminated state
  static void _handleMessageOpenedApp(RemoteMessage message) {
    AppLogger.info('App opened from FCM message: ${message.messageId}');

    // Navigate to appropriate screen based on message type
    final messageType = message.data['type'] ?? 'general';
    // Navigation logic would go here
  }

  /// Handle prayer reminder notifications
  static void _handlePrayerReminder(RemoteMessage message) {
    // Show local notification or update UI
    AppLogger.info('Prayer reminder received');
  }

  /// Handle crisis support notifications
  static void _handleCrisisSupport(RemoteMessage message) {
    AppLogger.warning('Crisis support notification received');
    // Show immediate support resources
  }

  /// Handle community update notifications
  static void _handleCommunityUpdate(RemoteMessage message) {
    AppLogger.info('Community update received');
    // Update community feed or show notification
  }

  /// Update user's FCM token in Firestore
  static Future<void> _updateUserFCMToken([String? token]) async {
    try {
      final user = auth.currentUser;
      if (user == null) return;

      token ??= await messaging.getToken();
      if (token == null) return;

      await firestore.doc('users/${user.uid}').set({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      AppLogger.debug('FCM token updated for user');
    } catch (error) {
      AppLogger.error('Failed to update FCM token', error);
    }
  }

  /// Get sign-in method from user
  static String _getSignInMethod(User user) {
    if (user.providerData.isEmpty) return 'anonymous';

    final provider = user.providerData.first.providerId;
    switch (provider) {
      case 'google.com':
        return 'google';
      case 'apple.com':
        return 'apple';
      case 'password':
        return 'email';
      default:
        return provider;
    }
  }

  /// Check if user is authenticated
  static bool get isAuthenticated => auth.currentUser != null;

  /// Get current user
  static User? get currentUser => auth.currentUser;

  /// Get current user ID
  static String? get currentUserId => auth.currentUser?.uid;

  /// Sign out user
  static Future<void> signOut() async {
    try {
      await auth.signOut();
      AppLogger.info('User signed out successfully');
    } catch (error) {
      AppLogger.error('Failed to sign out', error);
      rethrow;
    }
  }

  /// Create user document in Firestore
  static Future<void> createUserDocument(User user) async {
    try {
      final userDoc = firestore.doc('users/${user.uid}');

      // Check if document already exists
      final docSnapshot = await userDoc.get();
      if (docSnapshot.exists) {
        AppLogger.info('User document already exists');
        return;
      }

      // Create new user document
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSignIn': FieldValue.serverTimestamp(),
        'signInMethod': _getSignInMethod(user),
        'preferences': {
          'notifications': {
            'morning': true,
            'midday': true,
            'evening': true,
            'community': true,
            'crisisSupport': true,
          },
          'privacy': {
            'shareAnalytics': true,
            'shareCommunity': false,
          },
          'spiritual': {
            'denomination': '',
            'language': 'en',
            'tone': 'warm',
            'length': 'medium',
          },
        },
        'analytics': {
          'totalPrayers': 0,
          'totalMoodEntries': 0,
          'averageMood': 5.0,
          'longestStreak': 0,
          'currentStreak': 0,
        },
      });

      AppLogger.info('User document created successfully');
    } catch (error) {
      AppLogger.error('Failed to create user document', error);
      rethrow;
    }
  }

  /// Update user's last activity
  static Future<void> updateLastActivity() async {
    try {
      final user = auth.currentUser;
      if (user == null) return;

      await firestore.doc('users/${user.uid}').update({
        'lastActivity': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      AppLogger.error('Failed to update last activity', error);
    }
  }

  /// Get user document
  static DocumentReference<Map<String, dynamic>> getUserDocument(
      String userId) {
    return firestore.doc('users/$userId');
  }

  /// Get user's mood entries collection
  static CollectionReference<Map<String, dynamic>> getMoodEntriesCollection(
      String userId) {
    return firestore.collection('users/$userId/moodEntries');
  }

  /// Get user's prayers collection
  static CollectionReference<Map<String, dynamic>> getPrayersCollection(
      String userId) {
    return firestore.collection('users/$userId/prayers');
  }

  /// Get user's conversations collection
  static CollectionReference<Map<String, dynamic>> getConversationsCollection(
      String userId) {
    return firestore.collection('users/$userId/conversations');
  }

  /// Handle Firebase errors with user-friendly messages
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email address.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'weak-password':
          return 'Please choose a stronger password.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return 'Authentication failed. Please try again.';
      }
    } else if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You don\'t have permission to perform this action.';
        case 'not-found':
          return 'The requested data was not found.';
        case 'already-exists':
          return 'This data already exists.';
        case 'unavailable':
          return 'Service is currently unavailable. Please try again.';
        default:
          return 'An error occurred. Please try again.';
      }
    }

    return 'An unexpected error occurred. Please try again.';
  }
}
