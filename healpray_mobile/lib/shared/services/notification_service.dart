import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../../core/utils/logger.dart';
import 'analytics_service.dart';

/// Notification channels
enum NotificationChannel {
  meditation('meditation', 'Meditation Reminders',
      'Reminders for meditation sessions'),
  moodCheckin(
      'mood_checkin', 'Mood Check-ins', 'Daily mood tracking reminders'),
  verseOfDay('verse_of_day', 'Verse of the Day', 'Daily scripture verses'),
  prayerTime('prayer_time', 'Prayer Times', 'Prayer reminder notifications'),
  insights('spiritual_insights', 'Spiritual Insights',
      'Personalized spiritual guidance'),
  crisis('crisis_support', 'Crisis Support', 'Important mental health alerts');

  const NotificationChannel(this.id, this.name, this.description);
  final String id;
  final String name;
  final String description;
}

/// Notification preferences
class NotificationPreferences {
  final bool meditationReminders;
  final TimeOfDay? meditationTime;
  final List<int> meditationDays; // 1-7 for Monday-Sunday

  final bool moodCheckins;
  final TimeOfDay? moodCheckinTime;
  final List<int> moodCheckinDays;

  final bool verseOfDay;
  final TimeOfDay? verseOfDayTime;

  final bool prayerReminders;
  final List<TimeOfDay> prayerTimes;
  final List<int> prayerDays;

  final bool spiritualInsights;
  final bool crisisAlerts;

  const NotificationPreferences({
    this.meditationReminders = true,
    this.meditationTime = const TimeOfDay(hour: 8, minute: 0),
    this.meditationDays = const [1, 2, 3, 4, 5, 6, 7], // Daily by default

    this.moodCheckins = true,
    this.moodCheckinTime = const TimeOfDay(hour: 20, minute: 0),
    this.moodCheckinDays = const [1, 2, 3, 4, 5, 6, 7],
    this.verseOfDay = true,
    this.verseOfDayTime = const TimeOfDay(hour: 7, minute: 0),
    this.prayerReminders = false,
    this.prayerTimes = const [],
    this.prayerDays = const [1, 2, 3, 4, 5, 6, 7],
    this.spiritualInsights = true,
    this.crisisAlerts = true,
  });

  NotificationPreferences copyWith({
    bool? meditationReminders,
    TimeOfDay? meditationTime,
    List<int>? meditationDays,
    bool? moodCheckins,
    TimeOfDay? moodCheckinTime,
    List<int>? moodCheckinDays,
    bool? verseOfDay,
    TimeOfDay? verseOfDayTime,
    bool? prayerReminders,
    List<TimeOfDay>? prayerTimes,
    List<int>? prayerDays,
    bool? spiritualInsights,
    bool? crisisAlerts,
  }) {
    return NotificationPreferences(
      meditationReminders: meditationReminders ?? this.meditationReminders,
      meditationTime: meditationTime ?? this.meditationTime,
      meditationDays: meditationDays ?? this.meditationDays,
      moodCheckins: moodCheckins ?? this.moodCheckins,
      moodCheckinTime: moodCheckinTime ?? this.moodCheckinTime,
      moodCheckinDays: moodCheckinDays ?? this.moodCheckinDays,
      verseOfDay: verseOfDay ?? this.verseOfDay,
      verseOfDayTime: verseOfDayTime ?? this.verseOfDayTime,
      prayerReminders: prayerReminders ?? this.prayerReminders,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      prayerDays: prayerDays ?? this.prayerDays,
      spiritualInsights: spiritualInsights ?? this.spiritualInsights,
      crisisAlerts: crisisAlerts ?? this.crisisAlerts,
    );
  }
}

/// Advanced notification service
class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance =>
      _instance ??= NotificationService._();

  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final AnalyticsService _analytics = AnalyticsService.instance;

  NotificationPreferences _preferences = const NotificationPreferences();
  bool _isInitialized = false;

  /// Get current notification preferences
  NotificationPreferences get preferences => _preferences;

  /// Initialize the notification service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Configure Android settings
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configure iOS settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize plugin
      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == true) {
        // Request permissions
        if (Platform.isIOS) {
          await _notifications
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              );
        } else if (Platform.isAndroid) {
          await _notifications
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission();
        }

        // Create notification channels
        await _createNotificationChannels();

        // Load saved preferences
        await _loadPreferences();

        // Schedule notifications based on preferences
        await _scheduleAllNotifications();

        _isInitialized = true;
        AppLogger.info('NotificationService initialized successfully');

        return true;
      }

      return false;
    } catch (e) {
      AppLogger.error('Failed to initialize NotificationService', e);
      return false;
    }
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation == null) return;

    for (final channel in NotificationChannel.values) {
      await androidImplementation.createNotificationChannel(
        AndroidNotificationChannel(
          channel.id,
          channel.name,
          description: channel.description,
          importance: channel == NotificationChannel.crisis
              ? Importance.max
              : Importance.defaultImportance,
        ),
      );
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    AppLogger.info('Notification tapped: $payload');

    // Track analytics
    _analytics.logEvent('notification_tapped', {
      'notification_id': response.id,
      'payload': payload,
    });

    // Handle navigation based on payload
    if (payload != null) {
      _handleNotificationPayload(payload);
    }
  }

  /// Handle notification payload for navigation
  void _handleNotificationPayload(String payload) {
    // Parse payload and navigate
    final parts = payload.split(':');
    if (parts.length < 2) return;

    final type = parts[0];
    final data = parts[1];

    // Navigation will be handled by the main app
    // This could be expanded to use a navigation service
    AppLogger.debug('Handling notification payload: $type -> $data');
  }

  /// Update notification preferences
  Future<void> updatePreferences(NotificationPreferences newPreferences) async {
    _preferences = newPreferences;

    // Save preferences (implement storage later)
    await _savePreferences();

    // Reschedule notifications
    await cancelAllNotifications();
    await _scheduleAllNotifications();

    AppLogger.info('Notification preferences updated');
  }

  /// Schedule meditation reminders
  Future<void> _scheduleMeditationReminders() async {
    if (!_preferences.meditationReminders ||
        _preferences.meditationTime == null) {
      return;
    }

    final time = _preferences.meditationTime!;

    for (final day in _preferences.meditationDays) {
      final scheduledDate = _getNextScheduledDate(day, time);

      await _notifications.zonedSchedule(
        _generateNotificationId('meditation', day),
        'Time for Meditation 🧘',
        'Take a moment to center yourself and find peace.',
        scheduledDate,
        _getNotificationDetails(NotificationChannel.meditation),
        payload: 'meditation:reminder',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// Schedule mood check-in reminders
  Future<void> _scheduleMoodCheckinReminders() async {
    if (!_preferences.moodCheckins || _preferences.moodCheckinTime == null) {
      return;
    }

    final time = _preferences.moodCheckinTime!;

    for (final day in _preferences.moodCheckinDays) {
      final scheduledDate = _getNextScheduledDate(day, time);

      await _notifications.zonedSchedule(
        _generateNotificationId('mood', day),
        'How are you feeling? 💭',
        'Take a moment to check in with your emotional well-being.',
        scheduledDate,
        _getNotificationDetails(NotificationChannel.moodCheckin),
        payload: 'mood:checkin',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// Schedule daily verse notifications
  Future<void> _scheduleVerseOfDayNotifications() async {
    if (!_preferences.verseOfDay || _preferences.verseOfDayTime == null) {
      return;
    }

    final time = _preferences.verseOfDayTime!;
    final scheduledDate = _getNextScheduledDate(DateTime.now().weekday, time);

    await _notifications.zonedSchedule(
      _generateNotificationId('verse', 0),
      'Daily Verse 📖',
      'Your spiritual inspiration for today is ready.',
      scheduledDate,
      _getNotificationDetails(NotificationChannel.verseOfDay),
      payload: 'scripture:daily',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule prayer time reminders
  Future<void> _schedulePrayerReminders() async {
    if (!_preferences.prayerReminders || _preferences.prayerTimes.isEmpty) {
      return;
    }

    for (int i = 0; i < _preferences.prayerTimes.length; i++) {
      final time = _preferences.prayerTimes[i];

      for (final day in _preferences.prayerDays) {
        final scheduledDate = _getNextScheduledDate(day, time);

        await _notifications.zonedSchedule(
          _generateNotificationId('prayer', day * 100 + i),
          'Prayer Time 🙏',
          'Take a moment to connect with the Divine.',
          scheduledDate,
          _getNotificationDetails(NotificationChannel.prayerTime),
          payload: 'prayer:reminder',
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  /// Show immediate notification (for insights, crisis support, etc.)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    required NotificationChannel channel,
    String? payload,
    int? id,
  }) async {
    if (!_isInitialized) return;

    await _notifications.show(
      id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      _getNotificationDetails(channel),
      payload: payload,
    );
  }

  /// Show crisis support notification
  Future<void> showCrisisNotification({
    required String message,
    String? actionPayload,
  }) async {
    if (!_preferences.crisisAlerts) return;

    await showImmediateNotification(
      title: 'We\'re Here for You 💝',
      body: message,
      channel: NotificationChannel.crisis,
      payload: actionPayload ?? 'crisis:support',
    );
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    AppLogger.info('All notifications cancelled');
  }

  /// Schedule all enabled notifications
  Future<void> _scheduleAllNotifications() async {
    await _scheduleMeditationReminders();
    await _scheduleMoodCheckinReminders();
    await _scheduleVerseOfDayNotifications();
    await _schedulePrayerReminders();

    AppLogger.info('All notifications scheduled');
  }

  /// Generate notification details for platform
  NotificationDetails _getNotificationDetails(NotificationChannel channel) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel == NotificationChannel.crisis
            ? Importance.max
            : Importance.defaultImportance,
        priority: channel == NotificationChannel.crisis
            ? Priority.max
            : Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: channel == NotificationChannel.crisis ? 'default' : null,
      ),
    );
  }

  /// Get next scheduled date for given day and time
  tz.TZDateTime _getNextScheduledDate(int weekday, TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Find next occurrence of the weekday
    final daysUntilTarget = (weekday - now.weekday) % 7;
    final targetDate = scheduledDate.add(Duration(days: daysUntilTarget));

    // If the time has already passed today, schedule for next week
    if (daysUntilTarget == 0 && targetDate.isBefore(now)) {
      return targetDate.add(const Duration(days: 7));
    }

    return targetDate;
  }

  /// Generate unique notification ID
  int _generateNotificationId(String type, int day) {
    return (type.hashCode + day).abs() % 100000;
  }

  /// Load saved preferences (placeholder - implement with SharedPreferences or Hive)
  Future<void> _loadPreferences() async {
    // TODO: Load from storage
    AppLogger.debug('Loading notification preferences from storage');
  }

  /// Save preferences (placeholder - implement with SharedPreferences or Hive)
  Future<void> _savePreferences() async {
    // TODO: Save to storage
    AppLogger.debug('Saving notification preferences to storage');
  }
}
