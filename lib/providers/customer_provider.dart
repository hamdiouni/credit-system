import 'package:flutter/foundation.dart';
import '../data/repositories/customer_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../data/repositories/exceptions.dart';
import '../domain/models/customer.dart';
import '../domain/models/transaction.dart';
import '../domain/services/debt_calculator_service.dart';
import '../services/app_logger.dart';
import '../services/performance_tracker.dart';

class CustomerWithDebt {
  final Customer customer;
  final double remainingDebt;
  final List<Transaction> transactions;

  CustomerWithDebt({
    required this.customer,
    required this.remainingDebt,
    required this.transactions,
  });
}

class CustomerProvider with ChangeNotifier {
  final CustomerRepository _customerRepository;
  final TransactionRepository _transactionRepository;

  List<CustomerWithDebt> _customersWithDebt = [];
  bool _isLoading = false;
  String? _error;

  CustomerProvider(this._customerRepository, this._transactionRepository);

  List<CustomerWithDebt> get customersWithDebt => _customersWithDebt;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Load all customers and their transactions
  Future<void> loadAllCustomers() async {
    PerformanceTracker.startTrace('loadAllCustomers');
    AppLogger.info('Loading all customers', context: 'CustomerProvider');
    
    _isLoading = true;
    notifyListeners();
    try {
      final customers = await _customerRepository.getAllCustomers();
      _customersWithDebt = [];
      for (final customer in customers) {
        final transactions = await _transactionRepository.getTransactionsByCustomerId(customer.id);
        final debt = DebtCalculator.calculateActualDebt(transactions);
        _customersWithDebt.add(CustomerWithDebt(
          customer: customer,
          remainingDebt: debt,
          transactions: transactions,
        ));
      }
      _isLoading = false;
      AppLogger.info('Loaded ${_customersWithDebt.length} customers', context: 'CustomerProvider');
      PerformanceTracker.endTrace('loadAllCustomers');
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load customers: $e';
      AppLogger.error('Failed to load customers', context: 'CustomerProvider', error: e);
      PerformanceTracker.endTrace('loadAllCustomers');
      notifyListeners();
    }
  }

  /// Add a new customer
  /// Returns the created customer's id (dynamic: int or String) on success
  Future<dynamic> addCustomer(Customer customer) async {
    try {
      final dynamic newId = await _customerRepository.createCustomer(customer.name, customer.phone);
      debugPrint('Customer created successfully with ID: $newId');
      await loadAllCustomers();
      return newId;
    } on PhoneInUseException {
      // Let UI handle localization and display
      rethrow;
    } catch (e, st) {
      _error = 'Failed to add customer: $e';
      print('❌ [Provider] $e\n$st');
      notifyListeners();
      return null;
    }
  }

  /// Update customer details
  Future<void> updateCustomer(Customer customer) async {
    try {
      await _customerRepository.updateCustomer(customer);
      await loadAllCustomers();
    } catch (e, st) {
      _error = 'Failed to update customer: $e';
      print('❌ [Provider] $e\n$st');
      notifyListeners();
    }
  }

  /// Delete customer (only if no transactions)
  Future<void> deleteCustomer(dynamic id) async {
    try {
      await _customerRepository.deleteCustomer(id);
      await loadAllCustomers();
    } catch (e, st) {
      _error = 'Failed to delete customer: $e';
      print('❌ [Provider] $e\n$st');
      notifyListeners();
    }
  }

  /// Get single customer with debt
  CustomerWithDebt? getCustomerWithDebt(dynamic customerId) {
    try {
      return _customersWithDebt
          .firstWhere((c) => c.customer.id.toString() == customerId.toString());
    } catch (_) {
      return null;
    }
  }

  /// Search customers by name (case-insensitive)
  List<CustomerWithDebt> searchCustomers(String query) {
    if (query.isEmpty) return _customersWithDebt;

    final lowerQuery = query.toLowerCase();
    return _customersWithDebt
        .where((c) => c.customer.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
