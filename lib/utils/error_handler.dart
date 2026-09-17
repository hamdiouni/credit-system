import 'package:flutter/material.dart';
import '../services/error_logger.dart';
import '../services/app_logger.dart';

/// Error Handler - Centralized error handling utilities
class ErrorHandler {
  /// Handle error with context
  static void handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    bool showSnackbar = false,
    BuildContext? buildContext,
  }) {
    // Log error
    ErrorLogger.logError(
      error,
      stackTrace,
      context: context,
    );

    AppLogger.error(
      error.toString(),
      context: context,
      error: error,
    );

    // Show user-friendly message
    if (showSnackbar && buildContext != null) {
      _showErrorSnackbar(buildContext, error, context);
    }
  }

  /// Show error snackbar
  static void _showErrorSnackbar(
    BuildContext context,
    dynamic error,
    String? errorContext,
  ) {
    final message = _getUserFriendlyMessage(error, errorContext);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Get user-friendly error message
  static String _getUserFriendlyMessage(dynamic error, String? context) {
    final errorStr = error.toString().toLowerCase();

    // Network errors
    if (errorStr.contains('socket') || errorStr.contains('network')) {
      return 'Network connection error. Please check your internet.';
    }

    // Database errors
    if (errorStr.contains('database') || errorStr.contains('sql')) {
      return 'Database error. Please try again.';
    }

    // File errors
    if (errorStr.contains('file') || errorStr.contains('permission')) {
      return 'File access error. Please check permissions.';
    }

    // Validation errors
    if (errorStr.contains('validation') || errorStr.contains('invalid')) {
      return 'Invalid data. Please check your input.';
    }

    // Generic error with context
    if (context != null) {
      return '$context failed. Please try again.';
    }

    // Generic error
    return 'An error occurred. Please try again.';
  }

  /// Wrap async operation with error handling
  static Future<T?> wrapAsync<T>(
    Future<T> Function() operation, {
    String? context,
    bool showSnackbar = false,
    BuildContext? buildContext,
    T? defaultValue,
  }) async {
    try {
      return await operation();
    } catch (e, stack) {
      handleError(
        e,
        stackTrace: stack,
        context: context,
        showSnackbar: showSnackbar,
        buildContext: buildContext,
      );
      return defaultValue;
    }
  }

  /// Wrap sync operation with error handling
  static T? wrapSync<T>(
    T Function() operation, {
    String? context,
    bool showSnackbar = false,
    BuildContext? buildContext,
    T? defaultValue,
  }) {
    try {
      return operation();
    } catch (e, stack) {
      handleError(
        e,
        stackTrace: stack,
        context: context,
        showSnackbar: showSnackbar,
        buildContext: buildContext,
      );
      return defaultValue;
    }
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? details,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (details != null) ...[
              const SizedBox(height: 16),
              const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  details,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Validate and handle operation
  static Future<bool> validateAndHandle(
    BuildContext context, {
    required Future<void> Function() operation,
    required String successMessage,
    String? errorContext,
  }) async {
    try {
      await operation();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(successMessage)),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
      
      return true;
    } catch (e, stack) {
      handleError(
        e,
        stackTrace: stack,
        context: errorContext,
        showSnackbar: true,
        buildContext: context,
      );
      return false;
    }
  }
}
