import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';
import '../../shared/services/analytics_service.dart';

/// Global error handling service for the HealPray application
class ErrorHandlingService {
  static ErrorHandlingService? _instance;
  static ErrorHandlingService get instance =>
      _instance ??= ErrorHandlingService._();

  ErrorHandlingService._();

  final AnalyticsService _analytics = AnalyticsService.instance;

  /// Initialize global error handling
  void initialize() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };

    // Handle async errors that escape Flutter's error handling
    PlatformDispatcher.instance.onError = (error, stack) {
      _handlePlatformError(error, stack);
      return true;
    };

    // Handle zone errors for async operations
    runZonedGuarded(() {
      // Application initialization happens here
    }, (error, stack) {
      _handleZoneError(error, stack);
    });

    AppLogger.info('Error handling service initialized');
  }

  /// Handle specific app errors with context
  Future<void> handleAppError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) async {
    try {
      final errorDetails = _createErrorDetails(
        error,
        stackTrace,
        context: context,
        additionalData: additionalData,
        severity: severity,
      );

      // Log the error
      _logError(errorDetails);

      // Track error in analytics if not in debug mode
      if (!kDebugMode) {
        await _trackError(errorDetails);
      }

      // Handle based on severity
      await _handleBySeverity(errorDetails);
    } catch (e) {
      // Fallback logging if error handling fails
      AppLogger.error('Error handling failed', e);
      print('CRITICAL: Error handling failed - $e');
    }
  }

  /// Handle network-related errors
  Future<void> handleNetworkError(
    dynamic error, {
    String? endpoint,
    Map<String, dynamic>? requestData,
  }) async {
    final context = 'Network Error${endpoint != null ? ' - $endpoint' : ''}';
    final additionalData = {
      'endpoint': endpoint,
      'request_data': requestData,
      'network_type': await _getNetworkType(),
    };

    await handleAppError(
      error,
      StackTrace.current,
      context: context,
      additionalData: additionalData,
      severity: ErrorSeverity.low,
    );
  }

  /// Handle authentication errors
  Future<void> handleAuthError(
    dynamic error, {
    String? authMethod,
    String? userId,
  }) async {
    final context =
        'Authentication Error${authMethod != null ? ' - $authMethod' : ''}';
    final additionalData = {
      'auth_method': authMethod,
      'user_id': userId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await handleAppError(
      error,
      StackTrace.current,
      context: context,
      additionalData: additionalData,
      severity: ErrorSeverity.high,
    );
  }

  /// Handle database/storage errors
  Future<void> handleStorageError(
    dynamic error, {
    String? operation,
    String? collection,
  }) async {
    final context = 'Storage Error${operation != null ? ' - $operation' : ''}';
    final additionalData = {
      'operation': operation,
      'collection': collection,
      'storage_type': 'hive_local',
    };

    await handleAppError(
      error,
      StackTrace.current,
      context: context,
      additionalData: additionalData,
      severity: ErrorSeverity.medium,
    );
  }

  /// Handle AI service errors
  Future<void> handleAIError(
    dynamic error, {
    String? aiService,
    String? requestType,
  }) async {
    final context =
        'AI Service Error${aiService != null ? ' - $aiService' : ''}';
    final additionalData = {
      'ai_service': aiService,
      'request_type': requestType,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await handleAppError(
      error,
      StackTrace.current,
      context: context,
      additionalData: additionalData,
      severity: ErrorSeverity.medium,
    );
  }

  // Private methods

  void _handleFlutterError(FlutterErrorDetails details) {
    AppLogger.error(
        'Flutter Error: ${details.exceptionAsString()}', details.exception);

    if (!kDebugMode) {
      _analytics.trackEvent('flutter_error', {
        'error': details.exceptionAsString(),
        'library': details.library,
        'context': details.context.toString(),
      });
    }
  }

  bool _handlePlatformError(Object error, StackTrace stack) {
    AppLogger.error('Platform Error: $error', error, stack);

    if (!kDebugMode) {
      _analytics.trackEvent('platform_error', {
        'error': error.toString(),
        'stack_trace': stack.toString().substring(0, 500), // Limit size
      });
    }

    return true;
  }

  void _handleZoneError(Object error, StackTrace stack) {
    AppLogger.error('Zone Error: $error', error, stack);

    if (!kDebugMode) {
      _analytics.trackEvent('zone_error', {
        'error': error.toString(),
        'stack_trace': stack.toString().substring(0, 500), // Limit size
      });
    }
  }

  AppErrorDetails _createErrorDetails(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) {
    return AppErrorDetails(
      error: error,
      stackTrace: stackTrace ?? StackTrace.current,
      context: context,
      additionalData: additionalData ?? {},
      severity: severity,
      timestamp: DateTime.now(),
      platform: Platform.operatingSystem,
      appVersion: '1.0.0', // Should be from package info
    );
  }

  void _logError(AppErrorDetails details) {
    final message = '${details.context ?? 'App Error'}: ${details.error}';

    switch (details.severity) {
      case ErrorSeverity.low:
        AppLogger.info(message);
        break;
      case ErrorSeverity.medium:
        AppLogger.warning(message);
        break;
      case ErrorSeverity.high:
        AppLogger.error(message, details.error, details.stackTrace);
        break;
      case ErrorSeverity.critical:
        AppLogger.error(
            'CRITICAL: $message', details.error, details.stackTrace);
        break;
    }
  }

  Future<void> _trackError(AppErrorDetails details) async {
    try {
      await _analytics.trackEvent('app_error', {
        'error_type': details.error.runtimeType.toString(),
        'error_message': details.error.toString(),
        'context': details.context,
        'severity': details.severity.toString(),
        'platform': details.platform,
        'timestamp': details.timestamp.toIso8601String(),
        ...details.additionalData,
      });
    } catch (e) {
      AppLogger.warning('Failed to track error in analytics: $e');
    }
  }

  Future<void> _handleBySeverity(AppErrorDetails details) async {
    switch (details.severity) {
      case ErrorSeverity.critical:
        // For critical errors, you might want to show a dialog
        // or restart certain services
        break;
      case ErrorSeverity.high:
        // High priority errors might need user notification
        break;
      case ErrorSeverity.medium:
      case ErrorSeverity.low:
        // Log and continue
        break;
    }
  }

  Future<String> _getNetworkType() async {
    // Simplified network type detection
    try {
      return Platform.isIOS ? 'iOS Network' : 'Android Network';
    } catch (e) {
      return 'Unknown';
    }
  }
}

/// Error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// Detailed error information for tracking and debugging
class AppErrorDetails {
  final dynamic error;
  final StackTrace stackTrace;
  final String? context;
  final Map<String, dynamic> additionalData;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final String platform;
  final String appVersion;

  AppErrorDetails({
    required this.error,
    required this.stackTrace,
    this.context,
    required this.additionalData,
    required this.severity,
    required this.timestamp,
    required this.platform,
    required this.appVersion,
  });
}

/// Extension for easy error handling in widgets and services
extension ErrorHandlingExtension on Object {
  /// Handle this error with optional context
  Future<void> handleAsAppError({
    String? context,
    Map<String, dynamic>? additionalData,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) async {
    await ErrorHandlingService.instance.handleAppError(
      this,
      StackTrace.current,
      context: context,
      additionalData: additionalData,
      severity: severity,
    );
  }
}
