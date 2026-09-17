import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// App Logger - Simple logging service for debugging
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  static const int _maxLogFileSize = 2 * 1024 * 1024; // 2MB
  static bool _enableFileLogging = true;
  static bool _enableConsoleLogging = true;

  /// Log info message
  static void info(String message, {String? context}) {
    _log('INFO', message, context: context);
  }

  /// Log warning message
  static void warning(String message, {String? context}) {
    _log('WARNING', message, context: context);
  }

  /// Log error message
  static void error(String message, {String? context, dynamic error}) {
    _log('ERROR', message, context: context, error: error);
  }

  /// Log debug message
  static void debug(String message, {String? context}) {
    _log('DEBUG', message, context: context);
  }

  /// Internal log method
  static void _log(
    String level,
    String message, {
    String? context,
    dynamic error,
  }) {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final contextStr = context != null ? '[$context] ' : '';
    final errorStr = error != null ? '\nError: $error' : '';
    final logMessage = '$timestamp [$level] $contextStr$message$errorStr';

    // Console logging
    if (_enableConsoleLogging) {
      final icon = _getIcon(level);
      print('$icon $logMessage');
    }

    // File logging (only on non-web platforms)
    if (_enableFileLogging && !kIsWeb) {
      _writeToFile(logMessage);
    }
  }

  /// Get icon for log level
  static String _getIcon(String level) {
    switch (level) {
      case 'INFO':
        return 'ℹ️';
      case 'WARNING':
        return '⚠️';
      case 'ERROR':
        return '❌';
      case 'DEBUG':
        return '🔍';
      default:
        return '📝';
    }
  }

  /// Write log to file (not available on web)
  static Future<void> _writeToFile(String message) async {
    if (kIsWeb) return; // Skip on web
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/app_log.txt');

      // Check file size and rotate if needed
      if (await logFile.exists()) {
        final fileSize = await logFile.length();
        if (fileSize > _maxLogFileSize) {
          await _rotateLogFile(logFile);
        }
      }

      // Append to file
      await logFile.writeAsString(
        '$message\n',
        mode: FileMode.append,
      );
    } catch (e) {
      // Silently fail - don't spam console
    }
  }

  /// Rotate log file
  static Future<void> _rotateLogFile(File logFile) async {
    if (kIsWeb) return;
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final archiveFile = File('${directory.path}/app_log_$timestamp.txt');
      
      await logFile.copy(archiveFile.path);
      await logFile.delete();
    } catch (e) {
      // Silently fail
    }
  }

  /// Enable/disable file logging
  static void setFileLogging(bool enabled) {
    _enableFileLogging = enabled;
  }

  /// Enable/disable console logging
  static void setConsoleLogging(bool enabled) {
    _enableConsoleLogging = enabled;
  }

  /// Get log file path (not available on web)
  static Future<String?> getLogFilePath() async {
    if (kIsWeb) return null;
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/app_log.txt');
      if (await logFile.exists()) {
        return logFile.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete log file (not available on web)
  static Future<void> deleteLogFile() async {
    if (kIsWeb) return;
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/app_log.txt');
      if (await logFile.exists()) {
        await logFile.delete();
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Read log file content (not available on web)
  static Future<String?> readLogFile() async {
    if (kIsWeb) return null;
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/app_log.txt');
      if (await logFile.exists()) {
        return await logFile.readAsString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
