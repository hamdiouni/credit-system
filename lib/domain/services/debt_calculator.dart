import 'package:credit_app/domain/models/transaction.dart';

class DebtCalculator {
  double calculateDebt(List<Transaction> transactions) {
    double credit = transactions
        .where((t) => t.type == TransactionType.CREDIT)
        .fold(0.0, (sum, t) => sum + t.amount);
    double payment = transactions
        .where((t) => t.type == TransactionType.PAYMENT)
        .fold(0.0, (sum, t) => sum + t.amount);
    return (credit - payment).clamp(0.0, double.infinity);
  }

  void validatePayment(double amount, double currentDebt) {
    if (amount > currentDebt) {
      throw Exception('Payment cannot exceed remaining debt of $currentDebt');
    }
  }

  double getBalance(List<Transaction> transactions) {
    double balanceCredit = transactions
        .where((t) => t.type == TransactionType.BALANCE_CREDIT)
        .fold(0.0, (sum, t) => sum + t.amount);
    return balanceCredit;
  }

  bool isValidAmount(double amount) => amount > 0;
}
