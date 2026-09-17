import 'package:credit_app/domain/models/transaction.dart';

class DebtCalculator {
  /// Calculates remaining debt for a customer
  /// Returns positive for debt, 0 for paid, negative for balance credit
  /// Balance credits reduce the debt
  static double calculateRemainingDebt(List<Transaction> transactions) {
    double totalCredit = 0;
    double totalPayment = 0;

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.CREDIT) {
        totalCredit += transaction.amount;
      } else if (transaction.type == TransactionType.PAYMENT) {
        totalPayment += transaction.amount;
      } else if (transaction.type == TransactionType.BALANCE_CREDIT) {
        // BALANCE_CREDIT transactions work like payments
        // Positive BALANCE_CREDIT = customer has credit balance (overpayment)
        // Negative BALANCE_CREDIT = consuming the balance (reducing it)
        // Both should be treated as payments in the calculation
        totalPayment += transaction.amount;
      }
    }

    // Debt = Credits - Payments (including balance credit transactions)
    final remaining = totalCredit - totalPayment;
    
    // Return actual remaining (can be negative for balance credit)
    return remaining;
  }

  /// Calculates balance credit (overpayments)
  /// Returns positive value if customer has credit balance
  static double calculateBalanceCredit(List<Transaction> transactions) {
    final remaining = calculateRemainingDebt(transactions);
    // If remaining is negative, that's the balance credit
    return remaining < 0 ? -remaining : 0;
  }

  /// Calculates actual debt (positive only)
  /// Returns 0 if customer has balance credit
  static double calculateActualDebt(List<Transaction> transactions) {
    final remaining = calculateRemainingDebt(transactions);
    // If remaining is positive, that's the debt
    return remaining > 0 ? remaining : 0;
  }

  /// Calculates total credit given
  static double calculateTotalCredit(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.CREDIT)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculates total payments received
  static double calculateTotalPayments(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.PAYMENT)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Returns true if customer is fully paid (no debt, may have balance)
  static bool isPaid(List<Transaction> transactions) {
    return calculateActualDebt(transactions) == 0;
  }
}
