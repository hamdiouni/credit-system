import 'package:flutter/material.dart';

/// Reusable confirmation dialog widget
/// Provides consistent confirmation UI across the app
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final IconData? icon;
  final bool isDangerous;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.confirmColor,
    this.icon,
    this.isDangerous = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveConfirmColor = confirmColor ?? 
        (isDangerous ? Colors.red : Theme.of(context).primaryColor);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: isDangerous ? Colors.red : Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDangerous ? Colors.red.shade700 : null,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: effectiveConfirmColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            confirmText,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  /// Show a delete confirmation dialog
  static Future<bool> showDeleteConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: Icons.delete_forever,
        isDangerous: true,
      ),
    );
    return result ?? false;
  }

  /// Show a generic confirmation dialog
  static Future<bool> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    IconData? icon,
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        confirmColor: confirmColor,
      ),
    );
    return result ?? false;
  }

  /// Show a warning dialog
  static Future<bool> showWarning({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Continue',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: Icons.warning_amber,
        confirmColor: Colors.orange,
      ),
    );
    return result ?? false;
  }
}
