import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

/// Centralized application configuration management
class AppConfig {
  AppConfig._();

  static bool _initialized = false;

  // App Information
  static String get appName => dotenv.env['APP_NAME'] ?? 'HealPray';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';

  // Firebase Configuration
  static String get firebaseProjectId => 
      dotenv.env['FIREBASE_PROJECT_ID'] ?? 'healpray-dev';
  static String get firebaseWebApiKey => 
      dotenv.env['FIREBASE_WEB_API_KEY'] ?? '';

  // AI Service Configuration
  static String get openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get geminiApiKey => dotenv.env['GOOGLE_GEMINI_API_KEY'] ?? '';
  static String get anthropicApiKey => dotenv.env['ANTHROPIC_API_KEY'] ?? '';

  // Feature Flags
  static bool get enableAnalytics => 
      dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';
  static bool get enableLogging => 
      dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';
  static bool get debugMode => 
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  static bool get mockAiResponses => 
      dotenv.env['MOCK_AI_RESPONSES']?.toLowerCase() == 'true';
  static bool get skipOnboarding => 
      dotenv.env['SKIP_ONBOARDING']?.toLowerCase() == 'true';

  // Crisis Support Configuration
  static bool get enableCrisisDetection => 
      dotenv.env['ENABLE_CRISIS_DETECTION']?.toLowerCase() == 'true';
  static String get crisisTextLineApi => 
      dotenv.env['CRISIS_TEXT_LINE_API'] ?? '';

  // Validation
  static bool get hasValidOpenAiKey => openAiApiKey.isNotEmpty && openAiApiKey.startsWith('sk-');
  static bool get hasValidGeminiKey => geminiApiKey.isNotEmpty;
  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';

  /// Initialize app configuration
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await dotenv.load(fileName: '.env');
      _initialized = true;
      
      AppLogger.info('App configuration loaded successfully');
      AppLogger.info('Environment: $environment');
      AppLogger.info('Firebase Project: $firebaseProjectId');
      AppLogger.info('OpenAI Key Available: ${hasValidOpenAiKey}');
      AppLogger.info('Gemini Key Available: ${hasValidGeminiKey}');

      // Validate required keys in production
      if (isProduction) {
        _validateProductionConfig();
      }

    } catch (e) {
      AppLogger.error('Failed to load app configuration', e);
      
      // Set sensible defaults for development
      if (isDevelopment) {
        AppLogger.warning('Using default development configuration');
      } else {
        rethrow;
      }
    }
  }

  static void _validateProductionConfig() {
    final missingKeys = <String>[];

    if (!hasValidOpenAiKey) missingKeys.add('OPENAI_API_KEY');
    if (!hasValidGeminiKey) missingKeys.add('GOOGLE_GEMINI_API_KEY');
    if (firebaseProjectId.isEmpty) missingKeys.add('FIREBASE_PROJECT_ID');

    if (missingKeys.isNotEmpty) {
      throw Exception(
        'Missing required configuration keys for production: ${missingKeys.join(', ')}'
      );
    }
  }

  /// Get API endpoint based on environment
  static String getApiEndpoint(String path) {
    switch (environment) {
      case 'production':
        return 'https://api.healpray.app$path';
      case 'staging':
        return 'https://api-staging.healpray.app$path';
      default:
        return 'http://localhost:5001/$firebaseProjectId/us-central1$path';
    }
  }

  /// Print configuration summary (safe for logs)
  static void printConfigSummary() {
    AppLogger.info('=== HealPray Configuration ===');
    AppLogger.info('App: $appName v$appVersion');
    AppLogger.info('Environment: $environment');
    AppLogger.info('Firebase: $firebaseProjectId');
    AppLogger.info('Debug Mode: $debugMode');
    AppLogger.info('Analytics: $enableAnalytics');
    AppLogger.info('Crisis Detection: $enableCrisisDetection');
    AppLogger.info('AI Keys: OpenAI=${hasValidOpenAiKey}, Gemini=${hasValidGeminiKey}');
    AppLogger.info('===============================');
  }
}
