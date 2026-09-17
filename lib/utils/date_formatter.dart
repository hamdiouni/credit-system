import 'package:intl/intl.dart';

/// Centralized date formatting utility
/// Ensures consistent, locale-aware date formatting across the app
class AppDateFormatter {
  /// Format date only (e.g., "2024-01-15" or "١٥/٠١/٢٠٢٤")
  static String formatDate(DateTime date, String locale) {
    return DateFormat.yMd(locale).format(date);
  }
  
  /// Format date with time (e.g., "2024-01-15 14:30" or "١٥/٠١/٢٠٢٤ ١٤:٣٠")
  static String formatDateTime(DateTime date, String locale) {
    return DateFormat.yMd(locale).add_Hm().format(date);
  }
  
  /// Format time only (e.g., "14:30" or "١٤:٣٠")
  static String formatTime(DateTime date, String locale) {
    return DateFormat.Hm(locale).format(date);
  }
  
  /// Format date for display in lists (short format)
  static String formatShortDate(DateTime date, String locale) {
    return DateFormat.MMMd(locale).format(date);
  }
  
  /// Format date for PDF export
  static String formatForPdf(DateTime date, String locale) {
    return DateFormat.yMd(locale).add_Hm().format(date.toLocal());
  }
  
  /// Format relative time (e.g., "2 hours ago", "just now")
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }
}
