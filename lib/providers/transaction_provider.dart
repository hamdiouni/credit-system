import 'package:flutter/foundation.dart';
import '../data/repositories/transaction_repository.dart';
import '../domain/models/transaction.dart';
import 'customer_provider.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionRepository _repository;
  final CustomerProvider _customerProvider;

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  TransactionProvider(this._repository, this._customerProvider);

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _repository.getAllTransactions();
      _error = null;
    } catch (e) {
      _error = 'Failed to load transactions: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Add transaction and refresh customer data
  /// If adding CREDIT and customer has balance credit, automatically consume it
  Future<void> addTransaction(Transaction transaction) async {
    _error = null;
    notifyListeners();

    // Step 1: Check if we need to auto-consume balance credit
    if (transaction.type == TransactionType.CREDIT) {
      try {
        // Get customer's current transactions
        final existingTransactions = await _repository.getTransactionsByCustomerId(transaction.customerId);
        
        // Calculate current balance credit
        final balanceCredit = existingTransactions
            .where((t) => t.type == TransactionType.BALANCE_CREDIT)
            .fold(0.0, (sum, t) => sum + t.amount);
        
        if (balanceCredit > 0) {
          // Customer has balance credit - consume it automatically
          final newDebt = transaction.amount;
          
          if (balanceCredit >= newDebt) {
            // Balance credit covers ALL the new debt
            // Don't add credit transaction, just reduce balance credit
            final consumeTransaction = Transaction(
              id: 0,
              customerId: transaction.customerId,
              amount: -newDebt, // Negative to reduce balance credit
              type: TransactionType.BALANCE_CREDIT,
              note: 'Auto-consumed: ${transaction.note ?? 'Purchase'}',
              selectedItems: transaction.selectedItems,
              createdAt: transaction.createdAt,
            );
            await _repository.addTransaction(consumeTransaction);
            
            print('✅ [TransactionProvider] Balance covers all debt: consumed $newDebt TND from $balanceCredit TND balance');
          } else {
            // Balance credit PARTIALLY covers the debt
            // Add only the REMAINING debt as credit
            final remainingDebt = newDebt - balanceCredit;
            
            // Add credit for remaining amount only
            final reducedCreditTransaction = Transaction(
              id: 0,
              customerId: transaction.customerId,
              amount: remainingDebt, // Only the remaining debt
              type: TransactionType.CREDIT,
              note: transaction.note,
              selectedItems: transaction.selectedItems,
              createdAt: transaction.createdAt,
            );
            await _repository.addTransaction(reducedCreditTransaction);
            
            // Consume all balance credit
            final consumeTransaction = Transaction(
              id: 0,
              customerId: transaction.customerId,
              amount: -balanceCredit, // Consume all balance
              type: TransactionType.BALANCE_CREDIT,
              note: 'Auto-consumed from balance credit',
              selectedItems: [],
              createdAt: transaction.createdAt,
            );
            await _repository.addTransaction(consumeTransaction);
            
            print('✅ [TransactionProvider] Partial coverage: $balanceCredit TND balance consumed, $remainingDebt TND debt added');
          }
        } else {
          // No balance credit - just add the transaction normally
          await _repository.addTransaction(transaction);
        }
      } catch (e, st) {
        _error = 'Failed to add transaction: $e';
        print('❌ [TransactionProvider] Add failed: $e\n$st');
        notifyListeners();
        rethrow; // true failure - bubble up to UI
      }
    } else {
      // Not a credit transaction - add normally
      try {
        await _repository.addTransaction(transaction);
      } catch (e, st) {
        _error = 'Failed to add transaction: $e';
        print('❌ [TransactionProvider] Add failed: $e\n$st');
        notifyListeners();
        rethrow; // true failure - bubble up to UI
      }
    }

    // Step 2: Refresh customers (best-effort)
    try {
      await _customerProvider.loadAllCustomers();
    } catch (e, st) {
      _error = 'Transaction added but failed to refresh customers: $e';
      print('⚠️ [TransactionProvider] Refresh customers failed: $e\n$st');
      notifyListeners();
      // don't rethrow - add succeeded, but refresh failed
      return;
    }

    // Step 3: Reload transactions (best-effort)
    try {
      await loadTransactions();
    } catch (e, st) {
      _error = 'Transaction added but failed to load transactions: $e';
      print('⚠️ [TransactionProvider] Load transactions failed: $e\n$st');
      notifyListeners();
    }

    notifyListeners();
  }

  Future<List<Transaction>> getCustomerTransactions(dynamic customerId) async {
    return _repository.getCustomerTransactions(customerId);
  }

  /// Update transaction and refresh customer data
  Future<void> updateTransaction(Transaction transaction) async {
    _error = null;
    notifyListeners();

    try {
      await _repository.updateTransaction(transaction);
    } catch (e, st) {
      _error = 'Failed to update transaction: $e';
      print('❌ [TransactionProvider] Update failed: $e\n$st');
      notifyListeners();
      rethrow;
    }

    // Refresh customers
    try {
      await _customerProvider.loadAllCustomers();
    } catch (e, st) {
      _error = 'Transaction updated but failed to refresh customers: $e';
      print('⚠️ [TransactionProvider] Refresh customers failed: $e\n$st');
      notifyListeners();
      return;
    }

    // Reload transactions
    try {
      await loadTransactions();
    } catch (e, st) {
      _error = 'Transaction updated but failed to load transactions: $e';
      print('⚠️ [TransactionProvider] Load transactions failed: $e\n$st');
      notifyListeners();
    }

    notifyListeners();
  }

  /// Delete transaction and refresh customer data
  Future<void> deleteTransaction(dynamic transactionId) async {
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteTransaction(transactionId);
    } catch (e, st) {
      _error = 'Failed to delete transaction: $e';
      print('❌ [TransactionProvider] Delete failed: $e\n$st');
      notifyListeners();
      rethrow;
    }

    // Refresh customers
    try {
      await _customerProvider.loadAllCustomers();
    } catch (e, st) {
      _error = 'Transaction deleted but failed to refresh customers: $e';
      print('⚠️ [TransactionProvider] Refresh customers failed: $e\n$st');
      notifyListeners();
      return;
    }

    // Reload transactions
    try {
      await loadTransactions();
    } catch (e, st) {
      _error = 'Transaction deleted but failed to load transactions: $e';
      print('⚠️ [TransactionProvider] Load transactions failed: $e\n$st');
      notifyListeners();
    }

    notifyListeners();
  }
}
