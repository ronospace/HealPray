import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/config/app_config.dart';
import 'core/utils/logger.dart';
import 'shared/services/firebase_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeApp();

  runApp(
    const ProviderScope(
      child: HealPrayApp(),
    ),
  );
}

/// Initialize the application
Future<void> _initializeApp() async {
  try {
    AppLogger.info('🚀 Initializing HealPray app...');

    // Initialize app configuration
    await AppConfig.initialize();
    AppLogger.info('✅ App configuration loaded');

    // Set system UI overlay style
    _configureSystemUI();

    // Initialize Firebase
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      AppLogger.info('✅ Firebase initialized');
      
      // Initialize Firebase services
      await FirebaseService.initialize();
      AppLogger.info('✅ Firebase services initialized');
    } catch (firebaseError) {
      AppLogger.warning('Firebase initialization failed, running in offline mode: $firebaseError');
      // Continue without Firebase - the app should work in offline mode
    }

    AppLogger.info('🎉 App initialization complete');

  } catch (error, stackTrace) {
    AppLogger.error('💥 App initialization failed', error, stackTrace);
    
    // Show critical error to user
    runApp(
      MaterialApp(
        title: 'HealPray - Error',
        home: _ErrorScreen(
          error: error.toString(),
          onRetry: () {
            main(); // Restart app
          },
        ),
      ),
    );
    return;
  }
}

/// Configure system UI overlay style
void _configureSystemUI() {
  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

/// Error screen shown when app initialization fails
class _ErrorScreen extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorScreen({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 40,
                ),
              ),

              const SizedBox(height: 24),

              // Error title
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Error message
              Text(
                'HealPray encountered an error while starting up. '
                'Please try again or contact support if the problem persists.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              if (AppConfig.isDevelopment) ...[
                const SizedBox(height: 24),

                // Developer error details
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Error Details:\n$error',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Retry button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Version info
              if (AppConfig.isDevelopment)
                Text(
                  'HealPray v${AppConfig.appVersion} (${AppConfig.environment})',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
