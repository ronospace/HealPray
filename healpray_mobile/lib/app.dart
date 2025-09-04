import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'core/utils/logger.dart';
import 'shared/services/firebase_service.dart';
import 'shared/services/analytics_service.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/onboarding/screens/onboarding_welcome_screen.dart';
import 'features/onboarding/screens/spiritual_preferences_screen.dart';
import 'features/main/screens/app_shell.dart';
import 'features/mood/screens/mood_tracking_screen.dart';
import 'features/mood/screens/mood_analytics_screen.dart';
import 'features/prayer/screens/prayer_screen.dart';
import 'features/chat/screens/chat_screen.dart';
import 'features/settings/screens/settings_screen.dart';

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

            // Community (placeholder)
            GoRoute(
              path: '/community',
              name: 'community',
              builder: (context, state) => const CommunityScreenPlaceholder(),
            ),

            // Settings
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
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

    // Check if user is authenticated (safely)
    bool isAuthenticated = false;
    try {
      isAuthenticated = FirebaseService.isAuthenticated;
    } catch (e) {
      AppLogger.warning('Cannot check authentication status - Firebase not initialized: $e');
      // Default to auth screen if Firebase is not available
      return '/auth';
    }
    
    if (!isAuthenticated) {
      return '/auth';
    }

    // Check if user has completed onboarding
    // This would typically check SharedPreferences or user profile
    // For now, assume onboarding is needed for new users
    return '/onboarding';
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize analytics if enabled
      if (AppConfig.enableAnalytics) {
        await AnalyticsService.initialize();
        AppLogger.info('Analytics service initialized');
      }

      // Initialize Firebase services
      await FirebaseService.initialize();
      AppLogger.info('Firebase services initialized');

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

/// Splash screen widget
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.morningGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 60,
                  color: AppTheme.healingTeal,
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'HealPray',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Your Daily Healing & Prayer Companion',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder screens for missing features
class CommunityScreenPlaceholder extends StatelessWidget {
  const CommunityScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    appBar: null,
    body: Center(child: Text('Community Feature - Coming Soon')),
  );
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, this.error});
  
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Something went wrong')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            if (AppConfig.debugMode && error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
