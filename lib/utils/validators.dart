/// Input validation utilities
/// Provides consistent validation across the app
class Validators {
  /// Validates customer name
  /// Returns error message or null if valid
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-Z\u0600-\u06FF\s\-']+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Name contains invalid characters';
    }
    return null;
  }

  /// Validates phone number
  /// Returns error message or null if valid
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }
    
    // Remove spaces and common separators
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Check if it contains only digits and optional + at start
    final phoneRegex = RegExp(r'^\+?\d{8,15}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Invalid phone number format';
    }
    
    return null;
  }

  /// Validates amount (must be positive number)
  /// Returns error message or null if valid
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    
    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return 'Please enter a valid number';
    }
    
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    
    if (amount > 999999999) {
      return 'Amount is too large';
    }
    
    // Check for reasonable decimal places (max 3)
    final parts = value.split('.');
    if (parts.length > 1 && parts[1].length > 3) {
      return 'Maximum 3 decimal places allowed';
    }
    
    return null;
  }

  /// Validates note/comment (optional but has max length)
  /// Returns error message or null if valid
  static String? validateNote(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Note is optional
    }
    
    if (value.trim().length > 500) {
      return 'Note must be less than 500 characters';
    }
    
    return null;
  }

  /// Formats phone number for display
  static String formatPhoneForDisplay(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // If starts with country code
    if (cleaned.startsWith('+')) {
      return cleaned;
    }
    
    // Format as groups of digits
    if (cleaned.length >= 8) {
      return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6)}';
    }
    
    return cleaned;
  }

  /// Cleans phone number for storage
  static String cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }
}
