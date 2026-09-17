import '../../domain/models/customer.dart';
import '../../domain/models/transaction.dart';

/// Database Interface - Abstract interface for all database implementations
/// Supports: SQLite (primary), MongoDB (optional cloud sync), In-Memory (testing)
abstract class DatabaseInterface {
  // ===== INITIALIZATION =====
  
  /// Initialize the database
  Future<void> initialize();
  
  /// Close the database connection
  Future<void> close();
  
  // ===== CUSTOMERS =====
  
  /// Add a new customer
  /// Returns the customer ID (String for MongoDB, int for SQLite)
  Future<dynamic> addCustomer(Customer customer);
  
  /// Get all customers
  Future<List<Customer>> getAllCustomers();
  
  /// Get customer by ID
  Future<Customer?> getCustomerById(dynamic id);
  
  /// Update existing customer
  Future<void> updateCustomer(Customer customer);
  
  /// Delete customer (and all their transactions)
  Future<void> deleteCustomer(dynamic id);
  
  // ===== TRANSACTIONS =====
  
  /// Add a new transaction
  /// Returns the transaction ID
  Future<dynamic> addTransaction(Transaction transaction);
  
  /// Get all transactions
  Future<List<Transaction>> getAllTransactions();
  
  /// Get transactions for a specific customer
  Future<List<Transaction>> getTransactionsByCustomerId(dynamic customerId);
  
  /// Update existing transaction
  Future<void> updateTransaction(Transaction transaction);
  
  /// Delete transaction
  Future<void> deleteTransaction(dynamic id);
  
  /// Delete all transactions for a customer
  Future<void> deleteAllTransactionsByCustomerId(dynamic customerId);
  
  // ===== SYNC (Optional - for cloud sync) =====
  
  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime();
  
  /// Set last sync timestamp
  Future<void> setLastSyncTime(DateTime time);
  
  /// Get pending sync operations (for offline-first)
  Future<List<Map<String, dynamic>>> getPendingSyncOperations();
  
  /// Add sync operation to queue
  Future<void> addSyncOperation(String operation, String entityType, dynamic entityId, Map<String, dynamic> data);
  
  /// Remove sync operation from queue
  Future<void> removeSyncOperation(int operationId);
  
  // ===== METADATA =====
  
  /// Get database type name
  String get databaseType;
  
  /// Check if database is ready
  Future<bool> isReady();
}
