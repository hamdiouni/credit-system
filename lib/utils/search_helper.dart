/// Search and filter helper utilities
class SearchHelper {
  /// Search customers by name or phone
  static bool matchesCustomerSearch(String customerName, String customerPhone, String query) {
    if (query.isEmpty) return true;
    
    final lowerQuery = query.toLowerCase();
    final lowerName = customerName.toLowerCase();
    final lowerPhone = customerPhone.toLowerCase();
    
    return lowerName.contains(lowerQuery) || lowerPhone.contains(lowerQuery);
  }

  /// Search transactions by note or amount
  static bool matchesTransactionSearch(String? note, double amount, String query) {
    if (query.isEmpty) return true;
    
    final lowerQuery = query.toLowerCase();
    
    // Search in note
    if (note != null && note.toLowerCase().contains(lowerQuery)) {
      return true;
    }
    
    // Search in amount
    if (amount.toString().contains(lowerQuery)) {
      return true;
    }
    
    return false;
  }

  /// Filter by date range
  static bool isInDateRange(DateTime date, DateTime? startDate, DateTime? endDate) {
    if (startDate != null && date.isBefore(startDate)) {
      return false;
    }
    if (endDate != null && date.isAfter(endDate)) {
      return false;
    }
    return true;
  }

  /// Filter by amount range
  static bool isInAmountRange(double amount, double? minAmount, double? maxAmount) {
    if (minAmount != null && amount < minAmount) {
      return false;
    }
    if (maxAmount != null && amount > maxAmount) {
      return false;
    }
    return true;
  }

  /// Normalize Arabic text for better search
  static String normalizeArabic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }

  /// Enhanced search with Arabic normalization
  static bool matchesSearchWithNormalization(String text, String query) {
    if (query.isEmpty) return true;
    
    final normalizedText = normalizeArabic(text.toLowerCase());
    final normalizedQuery = normalizeArabic(query.toLowerCase());
    
    return normalizedText.contains(normalizedQuery);
  }
}
