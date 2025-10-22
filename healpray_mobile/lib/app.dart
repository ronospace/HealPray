import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'core/utils/logger.dart';
import 'shared/services/analytics_service.dart';
import 'shared/services/notification_service.dart';
import 'features/settings/screens/notification_settings_screen.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/onboarding/screens/onboarding_welcome_screen.dart';
import 'features/onboarding/screens/spiritual_preferences_screen.dart';
import 'features/main/screens/app_shell.dart';
import 'features/mood/screens/mood_tracking_screen.dart';
import 'features/mood/screens/mood_analytics_screen.dart';
import 'features/mood/screens/mood_calendar_screen.dart';
import 'features/mood/screens/enhanced_mood_entry_screen.dart';
import 'features/analytics/analytics_dashboard_screen.dart';
import 'features/feedback/feedback_form_screen.dart';
import 'features/prayer/screens/prayer_screen.dart';
import 'features/chat/screens/chat_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/crisis/screens/crisis_support_screen.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/community/screens/community_screen_placeholder.dart';
import 'features/error/screens/error_screen.dart';
import 'features/inspiration/screens/inspiration_screen.dart';

/// Main HealPray application widget
class HealPrayApp extends ConsumerStatefulWidget {
  const HealPrayApp({super.key});

  @override
  ConsumerState<HealPrayApp> createState() => _HealPrayAppState();
}

class _HealPrayAppState extends ConsumerState<HealPrayApp>
    with WidgetsBindingObserver {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupRouter();
    _initializeServices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _setupRouter() {
    _router = GoRouter(
      initialLocation: _getInitialRoute(),
      debugLogDiagnostics: AppConfig.debugMode,
      routes: [
        // Splash Screen
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // Onboarding Flow
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingWelcomeScreen(),
          routes: [
            GoRoute(
              path: '/spiritual-preferences',
              name: 'spiritual-preferences',
              builder: (context, state) => const SpiritualPreferencesScreen(),
            ),
            GoRoute(
              path: '/notification-preferences',
              name: 'onboarding-notification-preferences',
              builder: (context, state) => const NotificationSettingsScreen(),
            ),
          ],
        ),

        // Authentication
        GoRoute(
          path: '/auth',
          name: 'auth',
          builder: (context, state) => const WelcomeScreen(),
          routes: [
            GoRoute(
              path: '/login',
              name: 'login',
              builder: (context, state) => const LoginScreen(),
            ),
            GoRoute(
              path: '/register',
              name: 'register',
              builder: (context, state) => const RegisterScreen(),
            ),
          ],
        ),

        // Main App Shell
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const AppShell(),
          routes: [
            // Mood Tracking
            GoRoute(
              path: '/mood',
              name: 'mood',
              builder: (context, state) => const MoodTrackingScreen(),
              routes: [
                GoRoute(
                  path: '/calendar',
                  name: 'mood-calendar',
                  builder: (context, state) => const MoodCalendarScreen(),
                ),
                GoRoute(
                  path: '/entry',
                  name: 'mood-entry',
                  builder: (context, state) => const EnhancedMoodEntryScreen(),
                ),
              ],
            ),

            // Prayer Generation
            GoRoute(
              path: '/prayer',
              name: 'prayer',
              builder: (context, state) => const PrayerScreen(),
            ),

            // AI Conversation
            GoRoute(
              path: '/chat',
              name: 'chat',
              builder: (context, state) => const ChatScreen(),
            ),

            // Analytics
            GoRoute(
              path: '/analytics',
              name: 'analytics',
              builder: (context, state) => const MoodAnalyticsScreen(),
            ),
            
            // Analytics Dashboard
            GoRoute(
              path: '/analytics-dashboard',
              name: 'analytics-dashboard',
              builder: (context, state) => const AnalyticsDashboardScreen(),
            ),
            
            // Feedback Form
            GoRoute(
              path: '/feedback',
              name: 'feedback',
              builder: (context, state) => const FeedbackFormScreen(),
            ),

            // Community (placeholder)
            GoRoute(
              path: '/community',
              name: 'community',
              builder: (context, state) => const CommunityScreenPlaceholder(),
            ),

            // Crisis Support
            GoRoute(
              path: '/crisis-support',
              name: 'crisis-support',
              builder: (context, state) => const CrisisSupportScreen(),
            ),
            
            // Inspiration
            GoRoute(
              path: 'inspiration',
              name: 'inspiration',
              builder: (context, state) => const InspirationScreen(),
            ),

            // Settings
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: '/notifications',
                  name: 'notification-settings',
                  builder: (context, state) =>
                      const NotificationSettingsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => ErrorScreen(
        error: state.error,
      ),
    );
  }

  String _getInitialRoute() {
    // Skip onboarding in development if configured
    if (AppConfig.skipOnboarding && AppConfig.isDevelopment) {
      return '/';
    }

    // Firebase disabled in development mode - always go to auth
    AppLogger.info('Skipping authentication check - Firebase disabled, redirecting to auth');
    return '/auth';
    
    // TODO: When Firebase is enabled, implement proper authentication check:
    // try {
    //   final user = FirebaseAuth.instance.currentUser;
    //   if (user == null) {
    //     return '/auth';
    //   }
    //   // Check if user has completed onboarding
    //   return '/onboarding';
    // } catch (e) {
    //   return '/auth';
    // }
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize analytics if enabled
      if (AppConfig.enableAnalytics) {
        await AnalyticsService.initialize();
        AppLogger.info('Analytics service initialized');
      }

      // Initialize notification service
      final notificationInitialized =
          await NotificationService.instance.initialize();
      if (notificationInitialized) {
        AppLogger.info('Notification service initialized');
      } else {
        AppLogger.warning('Notification service initialization failed');
      }

      // Initialize Firebase services (disabled in development)
      AppLogger.info(
          'Firebase services initialization skipped in development mode');
      // TODO: Enable when Firebase is properly configured
      // await FirebaseService.initialize();
      // AppLogger.info('Firebase services initialized');

      // Log app startup
      AppLogger.info('HealPray app initialized successfully');

      if (AppConfig.debugMode) {
        AppConfig.printConfigSummary();
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to initialize services', error, stackTrace);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        AppLogger.debug('App resumed');
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        AppLogger.debug('App paused');
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
        AppLogger.debug('App detached');
        break;
      default:
        break;
    }
  }

  void _handleAppResumed() {
    // Refresh user data if needed
    // Check for pending notifications
    // Resume analytics tracking
    if (AppConfig.enableAnalytics) {
      AnalyticsService.trackAppResumed();
    }
  }

  void _handleAppPaused() {
    // Save any pending data
    // Pause non-essential services
    if (AppConfig.enableAnalytics) {
      AnalyticsService.trackAppPaused();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // App Metadata
      title: AppConfig.appName,
      debugShowCheckedModeBanner: AppConfig.debugMode,

      // Routing
      routerConfig: _router,

      // Theming
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Respect system setting

      // Localization
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('es', ''), // Spanish
        Locale('pt', ''), // Portuguese
        Locale('fr', ''), // French
        Locale('hi', ''), // Hindi
        Locale('sw', ''), // Swahili
      ],

      // Builder for additional wrappers
      builder: (context, child) {
        return MediaQuery(
          // Ensure text scaling doesn't break UI
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
                  minScaleFactor: 0.8,
                  maxScaleFactor: 1.2,
                ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
