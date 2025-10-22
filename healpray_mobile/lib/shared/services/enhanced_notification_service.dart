import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/logger.dart';
import '../../features/mood/models/simple_mood_entry.dart';

/// Enhanced notification service with push notifications and intelligent scheduling
class EnhancedNotificationService {
  static final EnhancedNotificationService _instance = EnhancedNotificationService._internal();
  factory EnhancedNotificationService() => _instance;
  EnhancedNotificationService._internal();

  static EnhancedNotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  
  bool _initialized = false;
  String? _fcmToken;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;

  // Notification categories
  static const String _channelIdGeneral = 'healpray_general';
  static const String _channelIdPrayer = 'healpray_prayer';
  static const String _channelIdMood = 'healpray_mood';
  static const String _channelIdMeditation = 'healpray_meditation';
  static const String _channelIdCrisis = 'healpray_crisis';
  static const String _channelIdCommunity = 'healpray_community';

  /// Initialize the enhanced notification system
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Initialize Firebase messaging
      await _initializeFirebaseMessaging();
      
      // Setup background handlers
      await _setupBackgroundHandlers();
      
      _initialized = true;
      AppLogger.info('Enhanced notification service initialized successfully');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize enhanced notification service', e, stackTrace);
      return false;
    }
  }

  /// Initialize local notification configurations
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    const List<AndroidNotificationChannel> channels = [
      AndroidNotificationChannel(
        _channelIdGeneral,
        'General Notifications',
        description: 'General HealPray notifications and updates',
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        _channelIdPrayer,
        'Prayer Reminders',
        description: 'Prayer reminders and spiritual guidance',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        _channelIdMood,
        'Mood Check-ins',
        description: 'Mood tracking reminders and insights',
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        _channelIdMeditation,
        'Meditation Reminders',
        description: 'Meditation session reminders and mindfulness prompts',
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        _channelIdCrisis,
        'Crisis Support',
        description: 'Critical crisis detection alerts and support resources',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
      ),
      AndroidNotificationChannel(
        _channelIdCommunity,
        'Community Updates',
        description: 'Prayer circle updates and community notifications',
        importance: Importance.defaultImportance,
      ),
    ];

    for (final channel in channels) {
      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initializeFirebaseMessaging() async {
    try {
      // Request permission
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLogger.info('FCM permission granted');
        
        // Get FCM token
        _fcmToken = await _fcm.getToken();
        AppLogger.info('FCM Token obtained');
        
        // Listen for token refresh
        _fcm.onTokenRefresh.listen(_onFcmTokenRefresh);
        
      } else {
        AppLogger.warning('FCM permission not granted');
      }
    } catch (e) {
      AppLogger.error('Failed to initialize Firebase messaging', e);
    }
  }

  /// Setup background message handlers
  Future<void> _setupBackgroundHandlers() async {
    // Handle foreground messages
    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle notification tap when app is terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info('Foreground message received: ${message.messageId}');
    
    if (message.notification != null) {
      _showLocalNotification(
        title: message.notification!.title ?? 'HealPray',
        body: message.notification!.body ?? '',
        payload: jsonEncode(message.data),
        channelId: _getChannelIdFromData(message.data),
      );
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    AppLogger.info('Notification tapped: ${message.messageId}');
    _handleNotificationAction(message.data);
  }

  /// Handle FCM token refresh
  void _onFcmTokenRefresh(String token) {
    _fcmToken = token;
    AppLogger.info('FCM token refreshed');
    // TODO: Send token to backend
  }

  /// Handle notification tap response
  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _handleNotificationAction(data);
      } catch (e) {
        AppLogger.error('Failed to parse notification payload', e);
      }
    }
  }

  /// Handle notification actions
  void _handleNotificationAction(Map<String, dynamic> data) {
    final String? action = data['action'];
    
    switch (action) {
      case 'open_prayer':
        // Navigate to prayer screen
        break;
      case 'mood_reminder':
        // Navigate to mood entry screen
        break;
      case 'meditation_reminder':
        // Navigate to meditation screen
        break;
      case 'crisis_alert':
        // Navigate to crisis support screen
        break;
      case 'community_update':
        // Navigate to community screen
        break;
      default:
        // Navigate to home screen
        break;
    }
  }

  /// Get appropriate channel ID from message data
  String _getChannelIdFromData(Map<String, dynamic> data) {
    final String? type = data['type'];
    
    switch (type) {
      case 'prayer':
        return _channelIdPrayer;
      case 'mood':
        return _channelIdMood;
      case 'meditation':
        return _channelIdMeditation;
      case 'crisis':
        return _channelIdCrisis;
      case 'community':
        return _channelIdCommunity;
      default:
        return _channelIdGeneral;
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = _channelIdGeneral,
    int? id,
  }) async {
    final int notificationId = id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelIdGeneral,
      'General Notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Schedule intelligent prayer reminders
  Future<void> scheduleIntelligentPrayerReminders({
    required List<SimpleMoodEntry> recentMoods,
    required List<TimeOfDay> preferredTimes,
  }) async {
    await _cancelPrayerReminders();
    
    for (int i = 0; i < preferredTimes.length; i++) {
      final TimeOfDay time = preferredTimes[i];
      final String message = _generatePrayerReminderMessage(recentMoods);
      
      await _scheduleWeeklyNotification(
        id: 1000 + i,
        title: '🙏 Time for Prayer',
        body: message,
        time: time,
        payload: jsonEncode({'action': 'open_prayer'}),
        channelId: _channelIdPrayer,
      );
    }
    
    AppLogger.info('Scheduled ${preferredTimes.length} intelligent prayer reminders');
  }

  /// Schedule mood check-in reminders
  Future<void> scheduleMoodReminders({
    required List<TimeOfDay> reminderTimes,
    required int streakDays,
  }) async {
    await _cancelMoodReminders();
    
    for (int i = 0; i < reminderTimes.length; i++) {
      final TimeOfDay time = reminderTimes[i];
      String message = 'How are you feeling today?';
      
      if (streakDays > 0) {
        message = 'Keep your $streakDays-day streak going! How are you feeling?';
      }
      
      await _scheduleWeeklyNotification(
        id: 2000 + i,
        title: '😊 Mood Check-in',
        body: message,
        time: time,
        payload: jsonEncode({'action': 'mood_reminder'}),
        channelId: _channelIdMood,
      );
    }
    
    AppLogger.info('Scheduled ${reminderTimes.length} mood reminders');
  }

  /// Schedule meditation reminders
  Future<void> scheduleMeditationReminders({
    required List<TimeOfDay> meditationTimes,
    required String preferredType,
  }) async {
    await _cancelMeditationReminders();
    
    final List<String> messages = [
      'Take a moment to find inner peace 🧘‍♀️',
      'Your daily meditation awaits you ✨',
      'Time to reconnect with your inner self 🌸',
      'A few minutes of mindfulness can transform your day 🌿',
    ];
    
    for (int i = 0; i < meditationTimes.length; i++) {
      final TimeOfDay time = meditationTimes[i];
      final String message = messages[i % messages.length];
      
      await _scheduleWeeklyNotification(
        id: 3000 + i,
        title: '🧘‍♀️ Meditation Time',
        body: message,
        time: time,
        payload: jsonEncode({
          'action': 'meditation_reminder',
          'type': preferredType,
        }),
        channelId: _channelIdMeditation,
      );
    }
    
    AppLogger.info('Scheduled ${meditationTimes.length} meditation reminders');
  }

  /// Send immediate crisis support notification
  Future<void> sendCrisisNotification({
    required String message,
    required String supportAction,
  }) async {
    await _showLocalNotification(
      title: '🚨 Crisis Support Available',
      body: message,
      payload: jsonEncode({
        'action': 'crisis_alert',
        'support_action': supportAction,
      }),
      channelId: _channelIdCrisis,
      id: 9999, // High priority ID
    );
    
    AppLogger.info('Crisis notification sent');
  }

  /// Schedule weekly notification
  Future<void> _scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
    String channelId = _channelIdGeneral,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    // If time has passed today, schedule for tomorrow
    final finalDate = scheduledDate.isBefore(now) 
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelIdGeneral,
      'General Notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      finalDate,
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Generate personalized prayer reminder message
  String _generatePrayerReminderMessage(List<SimpleMoodEntry> recentMoods) {
    if (recentMoods.isEmpty) {
      return 'Take a moment to connect with the divine 🙏';
    }
    
    final averageMood = recentMoods.fold<double>(
      0, (sum, entry) => sum + entry.score
    ) / recentMoods.length;
    
    if (averageMood >= 8) {
      return 'Share your gratitude in prayer today 🌟';
    } else if (averageMood >= 6) {
      return 'Find peace and guidance through prayer 🕊️';
    } else if (averageMood >= 4) {
      return 'Let prayer lift your spirits today 💫';
    } else {
      return 'Seek comfort and strength through prayer 🤲';
    }
  }

  /// Cancel specific notification categories
  Future<void> _cancelPrayerReminders() async {
    for (int i = 1000; i < 1100; i++) {
      await _notifications.cancel(i);
    }
  }

  Future<void> _cancelMoodReminders() async {
    for (int i = 2000; i < 2100; i++) {
      await _notifications.cancel(i);
    }
  }

  Future<void> _cancelMeditationReminders() async {
    for (int i = 3000; i < 3100; i++) {
      await _notifications.cancel(i);
    }
  }

  /// Get current FCM token
  String? get fcmToken => _fcmToken;

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (!_initialized) return false;
    
    final settings = await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    
    return settings ?? false;
  }

  /// Dispose resources
  void dispose() {
    _foregroundMessageSubscription?.cancel();
    _initialized = false;
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('Background message received: ${message.messageId}');
  
  // Handle background message logic here
  // This runs when the app is completely closed
}
