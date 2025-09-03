import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/config/app_config.dart';
import 'core/services/notification_service.dart';
import 'core/services/analytics_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'shared/services/firebase_service.dart';
import 'shared/services/local_storage_service.dart';
import 'app.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services and configuration
  await _initializeApp();

  // Run the app with proper error handling
  runApp(
    ProviderScope(
      child: const HealPrayApp(),
    ),
  );
}

Future<void> _initializeApp() async {
  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");
    AppLogger.info('Environment configuration loaded');

    // Initialize app configuration
    await AppConfig.initialize();
    AppLogger.info('App configuration initialized');

    // Initialize local storage (Hive)
    await Hive.initFlutter();
    await LocalStorageService.initialize();
    AppLogger.info('Local storage initialized');

    // Initialize Firebase
    await Firebase.initializeApp();
    AppLogger.info('Firebase initialized');

    // Initialize timezone data for scheduling
    tz.initializeTimeZones();
    AppLogger.info('Timezone data initialized');

    // Initialize notification service
    await NotificationService.initialize();
    AppLogger.info('Notification service initialized');

    // Set up Firebase Crashlytics
    await _setupCrashlytics();

    // Set up Firebase Analytics
    await _setupAnalytics();

    // Set system UI overlay style
    _setupSystemUI();

    // Lock orientation to portrait
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    AppLogger.info('HealPray app initialization completed successfully');

  } catch (error, stackTrace) {
    AppLogger.error('Failed to initialize app', error, stackTrace);
    
    // Report to crashlytics if available
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        fatal: true,
      );
    } catch (_) {
      // Ignore crashlytics errors during initialization
    }
    
    rethrow;
  }
}

Future<void> _setupCrashlytics() async {
  try {
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    
    AppLogger.info('Crashlytics configured successfully');
  } catch (error) {
    AppLogger.error('Failed to setup Crashlytics: $error');
  }
}

Future<void> _setupAnalytics() async {
  try {
    if (AppConfig.enableAnalytics) {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      await AnalyticsService.initialize();
      AppLogger.info('Analytics configured successfully');
    } else {
      AppLogger.info('Analytics disabled in configuration');
    }
  } catch (error) {
    AppLogger.error('Failed to setup Analytics: $error');
  }
}

void _setupSystemUI() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.backgroundLight,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}
