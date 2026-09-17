import 'package:credit_app/domain/models/transaction.dart';
import '../database/database_interface.dart';

class TransactionDAO {
  final DatabaseInterface _db;

  TransactionDAO(this._db);

  Future<dynamic> addTransaction(Transaction transaction) async {
    return await _db.addTransaction(transaction);
  }

  Future<List<Transaction>> getTransactionsByCustomerId(dynamic customerId) async {
    return await _db.getTransactionsByCustomerId(customerId);
  }

  Future<List<Transaction>> getAllTransactions() async {
    return await _db.getAllTransactions();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    return await _db.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(dynamic transactionId) async {
    return await _db.deleteTransaction(transactionId);
  }
}
