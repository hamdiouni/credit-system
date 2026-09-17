import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatTND(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'fr_TN',
      symbol: 'TND ',
      decimalDigits: 3,
    );
    return formatter.format(amount);
  }

  static String formatTNDSimple(double amount) {
    return '${amount.toStringAsFixed(3)} TND';
  }
}
