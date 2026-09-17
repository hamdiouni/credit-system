import 'package:flutter/foundation.dart' show kIsWeb;
import '../domain/models/customer.dart';
import '../domain/models/transaction.dart';
import '../utils/date_formatter.dart';

// Platform-specific imports using conditional import
import 'csv_export_web.dart' if (dart.library.io) 'csv_export_io.dart' as platform;

/// CSV Export Service
/// Exports customer and transaction data to CSV format
class CsvExportService {
  /// Export all customers with their debt information
  static Future<void> exportCustomers({
    required List<Map<String, dynamic>> customersWithDebt,
    required String language,
  }) async {
    final csv = _generateCustomersCsv(customersWithDebt, language);
    final filename = 'customers_${DateTime.now().millisecondsSinceEpoch}.csv';
    
    await platform.downloadCsv(csv, filename);
  }

  /// Export customer transactions
  static Future<void> exportCustomerTransactions({
    required Customer customer,
    required List<Transaction> transactions,
    required String language,
  }) async {
    final csv = _generateTransactionsCsv(customer, transactions, language);
    final filename = 'transactions_${customer.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.csv';
    
    await platform.downloadCsv(csv, filename);
  }

  /// Generate CSV for customers list
  static String _generateCustomersCsv(
    List<Map<String, dynamic>> customersWithDebt,
    String language,
  ) {
    final buffer = StringBuffer();
    
    // Headers
    final headers = _getCustomerHeaders(language);
    buffer.writeln(_escapeCsvRow(headers));
    
    // Data rows
    for (final data in customersWithDebt) {
      final customer = data['customer'] as Customer;
      final debt = data['remainingDebt'] as double;
      final balanceCredit = data['balanceCredit'] as double? ?? 0.0;
      
      final row = [
        customer.name,
        customer.phone ?? '',
        AppDateFormatter.formatDate(customer.createdAt, language),
        debt.toStringAsFixed(3),
        balanceCredit.toStringAsFixed(3),
        (debt - balanceCredit).toStringAsFixed(3), // Net debt
      ];
      
      buffer.writeln(_escapeCsvRow(row));
    }
    
    return buffer.toString();
  }

  /// Generate CSV for transactions
  static String _generateTransactionsCsv(
    Customer customer,
    List<Transaction> transactions,
    String language,
  ) {
    final buffer = StringBuffer();
    
    // Headers
    final headers = _getTransactionHeaders(language);
    buffer.writeln(_escapeCsvRow(headers));
    
    // Data rows
    for (final txn in transactions) {
      final row = [
        AppDateFormatter.formatDateTime(txn.createdAt, language),
        _getTransactionType(txn.type, language),
        txn.amount.toStringAsFixed(3),
        txn.selectedItems.join('; '),
        txn.note ?? '',
      ];
      
      buffer.writeln(_escapeCsvRow(row));
    }
    
    return buffer.toString();
  }

  /// Get customer CSV headers based on language
  static List<String> _getCustomerHeaders(String language) {
    switch (language) {
      case 'ar':
        return ['الاسم', 'الهاتف', 'تاريخ الإنشاء', 'الدين', 'رصيد الرصيد', 'صافي الدين'];
      case 'fr':
        return ['Nom', 'Téléphone', 'Date de création', 'Dette', 'Crédit de solde', 'Dette nette'];
      default:
        return ['Name', 'Phone', 'Created Date', 'Debt', 'Balance Credit', 'Net Debt'];
    }
  }

  /// Get transaction CSV headers based on language
  static List<String> _getTransactionHeaders(String language) {
    switch (language) {
      case 'ar':
        return ['التاريخ', 'النوع', 'المبلغ', 'العناصر', 'ملاحظة'];
      case 'fr':
        return ['Date', 'Type', 'Montant', 'Articles', 'Note'];
      default:
        return ['Date', 'Type', 'Amount', 'Items', 'Note'];
    }
  }

  /// Get transaction type label
  static String _getTransactionType(TransactionType type, String language) {
    switch (type) {
      case TransactionType.CREDIT:
        return language == 'ar' ? 'رصيد' : language == 'fr' ? 'Crédit' : 'Credit';
      case TransactionType.PAYMENT:
        return language == 'ar' ? 'دفعة' : language == 'fr' ? 'Paiement' : 'Payment';
      case TransactionType.BALANCE_CREDIT:
        return language == 'ar' ? 'رصيد الرصيد' : language == 'fr' ? 'Crédit de solde' : 'Balance Credit';
    }
  }

  /// Escape CSV row (handle commas, quotes, newlines)
  static String _escapeCsvRow(List<String> fields) {
    return fields.map((field) {
      // Escape quotes by doubling them
      final escaped = field.replaceAll('"', '""');
      // Wrap in quotes if contains comma, quote, or newline
      if (escaped.contains(',') || escaped.contains('"') || escaped.contains('\n')) {
        return '"$escaped"';
      }
      return escaped;
    }).join(',');
  }
}
