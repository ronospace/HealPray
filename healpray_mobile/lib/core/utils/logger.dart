import 'dart:developer' as developer;
import 'package:logger/logger.dart';

/// Advanced logging utility for HealPray
class AppLogger {
  static late Logger _logger;
  static bool _initialized = false;

  /// Initialize the logger with appropriate configuration
  static void initialize({bool enableInProduction = false}) {
    if (_initialized) return;

    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      output: enableInProduction ? ConsoleOutput() : DevelopmentConsoleOutput(),
      level: enableInProduction ? Level.warning : Level.debug,
    );

    _initialized = true;
  }

  /// Log debug information (development only)
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.d(message, error: error, stackTrace: stackTrace);
    developer.log(
      message,
      name: 'HealPray.Debug',
      error: error,
      stackTrace: stackTrace,
      level: 500,
    );
  }

  /// Log general information
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.i(message, error: error, stackTrace: stackTrace);
    developer.log(
      message,
      name: 'HealPray.Info',
      error: error,
      stackTrace: stackTrace,
      level: 800,
    );
  }

  /// Log warnings
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.w(message, error: error, stackTrace: stackTrace);
    developer.log(
      message,
      name: 'HealPray.Warning',
      error: error,
      stackTrace: stackTrace,
      level: 900,
    );
  }

  /// Log errors
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.e(message, error: error, stackTrace: stackTrace);
    developer.log(
      message,
      name: 'HealPray.Error',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }

  /// Log fatal errors
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.f(message, error: error, stackTrace: stackTrace);
    developer.log(
      message,
      name: 'HealPray.Fatal',
      error: error,
      stackTrace: stackTrace,
      level: 1200,
    );
  }

  /// Log prayer generation events
  static void prayerGenerated({
    required String prayerId,
    required String category,
    required int moodLevel,
    required String aiModel,
    required int generationTimeMs,
  }) {
    _ensureInitialized();
    final message = 'Prayer generated: $prayerId ($category, mood: $moodLevel, '
        'model: $aiModel, time: ${generationTimeMs}ms)';
    
    info(message);
    developer.log(
      message,
      name: 'HealPray.Prayer',
      level: 800,
    );
  }

  /// Log mood entries
  static void moodLogged({
    required int moodLevel,
    required String userId,
    String? description,
  }) {
    _ensureInitialized();
    final message = 'Mood logged: $moodLevel/10 for user ${userId.substring(0, 8)}...';
    
    info(message);
    developer.log(
      message,
      name: 'HealPray.Mood',
      level: 800,
    );
  }

  /// Log crisis detection events
  static void crisisDetected({
    required String userId,
    required double averageMood,
    required String riskLevel,
  }) {
    _ensureInitialized();
    final message = 'CRISIS DETECTED: User ${userId.substring(0, 8)}... '
        '(avg mood: $averageMood, risk: $riskLevel)';
    
    warning(message);
    developer.log(
      message,
      name: 'HealPray.Crisis',
      level: 1000,
    );
  }

  /// Log user authentication events
  static void userAuthenticated({
    required String userId,
    required String method,
  }) {
    _ensureInitialized();
    final message = 'User authenticated: ${userId.substring(0, 8)}... via $method';
    
    info(message);
    developer.log(
      message,
      name: 'HealPray.Auth',
      level: 800,
    );
  }

  /// Log API calls
  static void apiCall({
    required String endpoint,
    required String method,
    required int statusCode,
    required int responseTimeMs,
  }) {
    _ensureInitialized();
    final message = '$method $endpoint -> $statusCode (${responseTimeMs}ms)';
    
    if (statusCode >= 400) {
      warning(message);
    } else {
      debug(message);
    }

    developer.log(
      message,
      name: 'HealPray.API',
      level: statusCode >= 400 ? 900 : 500,
    );
  }

  /// Log performance metrics
  static void performance({
    required String operation,
    required int durationMs,
    Map<String, dynamic>? metadata,
  }) {
    _ensureInitialized();
    final message = 'Performance: $operation took ${durationMs}ms';
    
    if (durationMs > 5000) {
      warning('$message (SLOW)');
    } else {
      debug(message);
    }

    developer.log(
      message,
      name: 'HealPray.Performance',
      level: durationMs > 5000 ? 900 : 500,
    );
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      initialize();
    }
  }
}

/// Custom console output for development that includes colors and emojis
class DevelopmentConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      print(line);
    }
  }
}
