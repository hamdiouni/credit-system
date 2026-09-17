import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// Error Logger - Logs errors to file for debugging
class ErrorLogger {
  static final ErrorLogger _instance = ErrorLogger._internal();
  factory ErrorLogger() => _instance;
  ErrorLogger._internal();

  final List<ErrorLog> _errorCache = [];
  static const int _maxCacheSize = 100;
  static const int _maxLogFileSize = 5 * 1024 * 1024; // 5MB

  /// Log an error
  static Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) async {
    final instance = ErrorLogger();
    
    final errorLog = ErrorLog(
      timestamp: DateTime.now(),
      error: error.toString(),
      stackTrace: stackTrace?.toString(),
      context: context,
      additionalData: additionalData,
    );

    // Add to cache
    instance._errorCache.add(errorLog);
    if (instance._errorCache.length > _maxCacheSize) {
      instance._errorCache.removeAt(0);
    }

    // Log to console
    print('❌ [ErrorLogger] ${errorLog.context ?? 'Error'}: ${errorLog.error}');
    if (stackTrace != null) {
      print('Stack trace: ${stackTrace.toString().split('\n').take(5).join('\n')}');
    }

    // Write to file (skip on web platform)
    if (!kIsWeb) {
      try {
        await instance._writeToFile(errorLog);
      } catch (e) {
        print('⚠️ [ErrorLogger] Failed to write error to file: $e');
      }
    }
  }

  /// Write error to log file
  Future<void> _writeToFile(ErrorLog errorLog) async {
    if (kIsWeb) return; // Skip file operations on web
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/error_log.txt');

      // Check file size and rotate if needed
      if (await logFile.exists()) {
        final fileSize = await logFile.length();
        if (fileSize > _maxLogFileSize) {
          await _rotateLogFile(logFile);
        }
      }

      // Format log entry
      final logEntry = _formatLogEntry(errorLog);

      // Append to file
      await logFile.writeAsString(
        logEntry,
        mode: FileMode.append,
      );
    } catch (e) {
      print('⚠️ [ErrorLogger] Error writing to file: $e');
    }
  }

  /// Rotate log file when it gets too large
  Future<void> _rotateLogFile(File logFile) async {
    if (kIsWeb) return; // Skip file operations on web
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final archiveFile = File('${directory.path}/error_log_$timestamp.txt');
      
      await logFile.copy(archiveFile.path);
      await logFile.delete();
      
      print('📦 [ErrorLogger] Log file rotated to: ${archiveFile.path}');
    } catch (e) {
      print('⚠️ [ErrorLogger] Error rotating log file: $e');
    }
  }

  /// Format log entry
  String _formatLogEntry(ErrorLog errorLog) {
    final buffer = StringBuffer();
    buffer.writeln('=' * 80);
    buffer.writeln('Timestamp: ${errorLog.timestamp.toIso8601String()}');
    if (errorLog.context != null) {
      buffer.writeln('Context: ${errorLog.context}');
    }
    buffer.writeln('Error: ${errorLog.error}');
    if (errorLog.stackTrace != null) {
      buffer.writeln('Stack Trace:');
      buffer.writeln(errorLog.stackTrace);
    }
    if (errorLog.additionalData != null && errorLog.additionalData!.isNotEmpty) {
      buffer.writeln('Additional Data:');
      errorLog.additionalData!.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }
    buffer.writeln('=' * 80);
    buffer.writeln();
    return buffer.toString();
  }

  /// Get recent errors from cache
  static List<ErrorLog> getRecentErrors({int limit = 50}) {
    final instance = ErrorLogger();
    final errors = instance._errorCache.toList();
    return errors.reversed.take(limit).toList();
  }

  /// Get error count
  static int getErrorCount() {
    return ErrorLogger()._errorCache.length;
  }

  /// Clear error cache
  static void clearCache() {
    ErrorLogger()._errorCache.clear();
    print('🗑️ [ErrorLogger] Error cache cleared');
  }

  /// Get log file path
  static Future<String?> getLogFilePath() async {
    if (kIsWeb) return null; // No file system on web
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/error_log.txt');
      if (await logFile.exists()) {
        return logFile.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete log file
  static Future<void> deleteLogFile() async {
    if (kIsWeb) return; // No file system on web
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/error_log.txt');
      if (await logFile.exists()) {
        await logFile.delete();
        print('🗑️ [ErrorLogger] Log file deleted');
      }
    } catch (e) {
      print('⚠️ [ErrorLogger] Error deleting log file: $e');
    }
  }
}

/// Error log entry
class ErrorLog {
  final DateTime timestamp;
  final String error;
  final String? stackTrace;
  final String? context;
  final Map<String, dynamic>? additionalData;

  ErrorLog({
    required this.timestamp,
    required this.error,
    this.stackTrace,
    this.context,
    this.additionalData,
  });

  @override
  String toString() {
    return 'ErrorLog(timestamp: $timestamp, context: $context, error: $error)';
  }
}
