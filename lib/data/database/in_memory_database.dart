import 'database_interface.dart';
import '../../domain/models/customer.dart';
import '../../domain/models/transaction.dart';

/// In-Memory Database Implementation
/// Used for web platform (where SQLite is not available)
/// Data is stored in memory and lost when app closes
class InMemoryDatabase implements DatabaseInterface {
  final Map<String, Customer> _customers = {};
  final Map<String, Transaction> _transactions = {};
  final Map<String, String> _metadata = {};
  bool _initialized = false;

  @override
  String get databaseType => 'InMemory';

  @override
  Future<void> initialize() async {
    print('📦 [InMemory] Initializing in-memory database...');
    _initialized = true;
    print('✅ [InMemory] Database initialized');
  }

  @override
  Future<bool> isReady() async => _initialized;

  @override
  Future<void> close() async {
    _customers.clear();
    _transactions.clear();
    _metadata.clear();
    _initialized = false;
    print('🔒 [InMemory] Database closed');
  }

  // ===== CUSTOMERS =====

  @override
  Future<String> addCustomer(Customer customer) async {
    // Generate new ID if customer has no ID or has placeholder ID (0)
    final String id;
    if (customer.id == null || customer.id == 0 || customer.id == '0') {
      id = _generateId();
    } else {
      id = customer.id.toString(); // Convert to String if it's an int
    }
    
    _customers[id] = customer.copyWith(id: id);
    print('✅ [InMemory] Customer added: $id');
    return id;
  }

  @override
  Future<List<Customer>> getAllCustomers() async {
    return _customers.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<Customer?> getCustomerById(dynamic id) async {
    return _customers[id.toString()];
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    if (customer.id != null) {
      _customers[customer.id!] = customer;
      print('✅ [InMemory] Customer updated: ${customer.id}');
    }
  }

  @override
  Future<void> deleteCustomer(dynamic id) async {
    _customers.remove(id.toString());
    // Also delete related transactions
    _transactions.removeWhere((key, txn) => txn.customerId.toString() == id.toString());
    print('✅ [InMemory] Customer deleted: $id');
  }

  // ===== TRANSACTIONS =====

  @override
  Future<String> addTransaction(Transaction transaction) async {
    // Generate new ID if transaction has no ID or has placeholder ID (0)
    final String id;
    if (transaction.id == null || transaction.id == 0 || transaction.id == '0') {
      id = _generateId();
    } else {
      id = transaction.id.toString(); // Convert to String if it's an int
    }
    
    _transactions[id] = transaction.copyWith(id: id);
    print('✅ [InMemory] Transaction added: $id');
    return id;
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    return _transactions.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Transaction>> getTransactionsByCustomerId(dynamic customerId) async {
    return _transactions.values
        .where((txn) => txn.customerId.toString() == customerId.toString())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    if (transaction.id != null) {
      _transactions[transaction.id!] = transaction;
      print('✅ [InMemory] Transaction updated: ${transaction.id}');
    }
  }

  @override
  Future<void> deleteTransaction(dynamic id) async {
    _transactions.remove(id.toString());
    print('✅ [InMemory] Transaction deleted: $id');
  }

  @override
  Future<void> deleteAllTransactionsByCustomerId(dynamic customerId) async {
    _transactions.removeWhere((key, txn) => txn.customerId.toString() == customerId.toString());
  }

  // ===== SYNC (Not implemented for in-memory) =====

  @override
  Future<DateTime?> getLastSyncTime() async => null;

  @override
  Future<void> setLastSyncTime(DateTime time) async {}

  @override
  Future<List<Map<String, dynamic>>> getPendingSyncOperations() async => [];

  @override
  Future<void> addSyncOperation(String operation, String entityType, dynamic entityId, Map<String, dynamic> data) async {}

  @override
  Future<void> removeSyncOperation(int operationId) async {}

  // ===== USER MANAGEMENT (Basic support for web) =====
  
  final Map<String, Map<String, dynamic>> _users = {};
  
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return _users.values.toList();
  }
  
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    return _users[username];
  }
  
  Future<String> addUser(Map<String, dynamic> user) async {
    final username = user['username'] as String;
    _users[username] = user;
    print('✅ [InMemory] User added: $username');
    return username;
  }
  
  Future<void> updateUser(Map<String, dynamic> user) async {
    final username = user['username'] as String;
    _users[username] = user;
    print('✅ [InMemory] User updated: $username');
  }
  
  Future<void> deleteUser(String username) async {
    _users.remove(username);
    print('✅ [InMemory] User deleted: $username');
  }

  // ===== HELPER METHODS =====

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

// Extension to add copyWith methods if not already present
extension CustomerCopyWith on Customer {
  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

extension TransactionCopyWith on Transaction {
  Transaction copyWith({
    String? id,
    String? customerId,
    TransactionType? type,
    double? amount,
    String? note,
    List<String>? selectedItems,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      selectedItems: selectedItems ?? this.selectedItems,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
