import 'package:credit_app/domain/models/transaction.dart';
import 'package:credit_app/data/dao/transaction_dao.dart';

class TransactionRepository {
  final TransactionDAO _transactionDAO;

  TransactionRepository(this._transactionDAO);

  Future<void> addTransaction(Transaction transaction) async {
    await _transactionDAO.addTransaction(transaction);
  }

  Future<dynamic> addCredit(dynamic customerId, double amount, String? note,
      {List<String> selectedItems = const []}) async {
    final transaction = Transaction(
      id: 0,
      customerId: customerId,
      type: TransactionType.CREDIT,
      amount: amount,
      note: note,
      selectedItems: selectedItems,
      createdAt: DateTime.now(),
    );
    return await _transactionDAO.addTransaction(transaction);
  }

  Future<dynamic> addPayment(dynamic customerId, double amount) async {
    final transaction = Transaction(
      id: 0,
      customerId: customerId,
      type: TransactionType.PAYMENT,
      amount: amount,
      note: null,
      createdAt: DateTime.now(),
    );
    return await _transactionDAO.addTransaction(transaction);
  }

  Future<dynamic> createBalanceCredit(dynamic customerId, double amount) async {
    final transaction = Transaction(
      id: 0,
      customerId: customerId,
      type: TransactionType.BALANCE_CREDIT,
      amount: amount,
      note: null,
      createdAt: DateTime.now(),
    );
    return await _transactionDAO.addTransaction(transaction);
  }

  Future<List<Transaction>> getCustomerTransactions(dynamic customerId) async {
    return await _transactionDAO.getTransactionsByCustomerId(customerId);
  }

  Future<List<Transaction>> getTransactionsByCustomerId(dynamic customerId) async {
    return await _transactionDAO.getTransactionsByCustomerId(customerId);
  }

  Future<List<Transaction>> getAllTransactions() async {
    return await _transactionDAO.getAllTransactions();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionDAO.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(dynamic transactionId) async {
    await _transactionDAO.deleteTransaction(transactionId);
  }
}

