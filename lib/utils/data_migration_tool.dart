import '../data/database/mongo_database.dart';
import '../data/database/database_helper.dart';
import '../data/database/database_interface.dart';

/// Data Migration Tool - Migrate data from MongoDB to SQLite
/// 
/// Usage:
/// ```dart
/// final migrator = DataMigrationTool();
/// final result = await migrator.migrateFromMongoToSqlite();
/// print('Migrated ${result.customersCount} customers and ${result.transactionsCount} transactions');
/// ```
class DataMigrationTool {
  final MongoDatabase _mongoDb = MongoDatabase();
  late final DatabaseInterface _sqliteDb;

  /// Migration result with statistics
  MigrationResult? _lastResult;

  /// Get the last migration result
  MigrationResult? get lastResult => _lastResult;

  /// Migrate all data from MongoDB to SQLite
  /// 
  /// Returns a [MigrationResult] with statistics and any errors
  Future<MigrationResult> migrateFromMongoToSqlite({
    bool clearSqliteFirst = false,
    Function(String)? onProgress,
  }) async {
    final result = MigrationResult();
    final startTime = DateTime.now();

    try {
      onProgress?.call('🚀 Starting migration from MongoDB to SQLite...');

      // Initialize databases
      onProgress?.call('📦 Initializing databases...');
      await _mongoDb.initialize();
      
      // Get SQLite database from DatabaseHelper
      _sqliteDb = DatabaseHelper().database;
      if (!await _sqliteDb.isReady()) {
        await _sqliteDb.initialize();
      }

      // Check if MongoDB is available
      final mongoReady = await _mongoDb.isReady();
      if (!mongoReady) {
        throw Exception('MongoDB is not available. Make sure the server is running.');
      }

      onProgress?.call('✅ Databases initialized');

      // Clear SQLite if requested
      if (clearSqliteFirst) {
        onProgress?.call('🗑️ Clearing existing SQLite data...');
        await _clearSqliteData();
        onProgress?.call('✅ SQLite data cleared');
      }

      // Migrate customers
      onProgress?.call('👥 Migrating customers...');
      final customersResult = await _migrateCustomers(onProgress);
      result.customersCount = customersResult.success;
      result.customerErrors.addAll(customersResult.errors);
      onProgress?.call('✅ Migrated ${result.customersCount} customers');

      // Migrate transactions
      onProgress?.call('💰 Migrating transactions...');
      final transactionsResult = await _migrateTransactions(onProgress);
      result.transactionsCount = transactionsResult.success;
      result.transactionErrors.addAll(transactionsResult.errors);
      onProgress?.call('✅ Migrated ${result.transactionsCount} transactions');

      // Calculate duration
      result.duration = DateTime.now().difference(startTime);
      result.success = true;

      onProgress?.call('🎉 Migration complete!');
      onProgress?.call('📊 Summary:');
      onProgress?.call('   - Customers: ${result.customersCount}');
      onProgress?.call('   - Transactions: ${result.transactionsCount}');
      onProgress?.call('   - Duration: ${result.duration.inSeconds}s');
      
      if (result.hasErrors) {
        onProgress?.call('⚠️ Errors: ${result.totalErrors}');
      }

    } catch (e, stackTrace) {
      result.success = false;
      result.generalError = 'Migration failed: $e';
      onProgress?.call('❌ Migration failed: $e');
      print('Stack trace: $stackTrace');
    } finally {
      // Close MongoDB (SQLite is managed by DatabaseHelper)
      await _mongoDb.close();
    }

    _lastResult = result;
    return result;
  }

  /// Clear all data from SQLite
  Future<void> _clearSqliteData() async {
    try {
      final customers = await _sqliteDb.getAllCustomers();
      for (final customer in customers) {
        await _sqliteDb.deleteCustomer(customer.id);
      }
    } catch (e) {
      print('⚠️ Error clearing SQLite data: $e');
    }
  }

  /// Migrate customers from MongoDB to SQLite
  Future<_MigrationStepResult> _migrateCustomers(Function(String)? onProgress) async {
    final result = _MigrationStepResult();

    try {
      // Get all customers from MongoDB
      final customers = await _mongoDb.getAllCustomers();
      onProgress?.call('   Found ${customers.length} customers in MongoDB');

      // Migrate each customer
      for (var i = 0; i < customers.length; i++) {
        final customer = customers[i];
        try {
          // Check if customer already exists in SQLite
          final existing = await _sqliteDb.getCustomerById(customer.id);
          
          if (existing != null) {
            // Update existing customer
            await _sqliteDb.updateCustomer(customer);
            onProgress?.call('   Updated customer: ${customer.name}');
          } else {
            // Add new customer
            await _sqliteDb.addCustomer(customer);
            onProgress?.call('   Added customer: ${customer.name}');
          }
          
          result.success++;
        } catch (e) {
          result.errors.add('Customer ${customer.name}: $e');
          onProgress?.call('   ❌ Error migrating ${customer.name}: $e');
        }
      }
    } catch (e) {
      result.errors.add('Failed to fetch customers from MongoDB: $e');
    }

    return result;
  }

  /// Migrate transactions from MongoDB to SQLite
  Future<_MigrationStepResult> _migrateTransactions(Function(String)? onProgress) async {
    final result = _MigrationStepResult();

    try {
      // Get all transactions from MongoDB
      final transactions = await _mongoDb.getAllTransactions();
      onProgress?.call('   Found ${transactions.length} transactions in MongoDB');

      // Migrate each transaction
      for (var i = 0; i < transactions.length; i++) {
        final transaction = transactions[i];
        try {
          // Add transaction to SQLite
          await _sqliteDb.addTransaction(transaction);
          
          if ((i + 1) % 10 == 0) {
            onProgress?.call('   Migrated ${i + 1}/${transactions.length} transactions');
          }
          
          result.success++;
        } catch (e) {
          result.errors.add('Transaction ${transaction.id}: $e');
          onProgress?.call('   ❌ Error migrating transaction: $e');
        }
      }
    } catch (e) {
      result.errors.add('Failed to fetch transactions from MongoDB: $e');
    }

    return result;
  }

  /// Validate migration by comparing counts
  Future<ValidationResult> validateMigration() async {
    final result = ValidationResult();

    try {
      await _mongoDb.initialize();
      
      // Get SQLite database from DatabaseHelper
      _sqliteDb = DatabaseHelper().database;
      if (!await _sqliteDb.isReady()) {
        await _sqliteDb.initialize();
      }

      // Compare customer counts
      final mongoCustomers = await _mongoDb.getAllCustomers();
      final sqliteCustomers = await _sqliteDb.getAllCustomers();
      
      result.mongoCustomersCount = mongoCustomers.length;
      result.sqliteCustomersCount = sqliteCustomers.length;
      result.customersMatch = result.mongoCustomersCount == result.sqliteCustomersCount;

      // Compare transaction counts
      final mongoTransactions = await _mongoDb.getAllTransactions();
      final sqliteTransactions = await _sqliteDb.getAllTransactions();
      
      result.mongoTransactionsCount = mongoTransactions.length;
      result.sqliteTransactionsCount = sqliteTransactions.length;
      result.transactionsMatch = result.mongoTransactionsCount == result.sqliteTransactionsCount;

      result.success = result.customersMatch && result.transactionsMatch;

    } catch (e) {
      result.success = false;
      result.error = 'Validation failed: $e';
    } finally {
      // Close MongoDB (SQLite is managed by DatabaseHelper)
      await _mongoDb.close();
    }

    return result;
  }
}

/// Result of a migration operation
class MigrationResult {
  bool success = false;
  int customersCount = 0;
  int transactionsCount = 0;
  Duration duration = Duration.zero;
  List<String> customerErrors = [];
  List<String> transactionErrors = [];
  String? generalError;

  bool get hasErrors => customerErrors.isNotEmpty || transactionErrors.isNotEmpty || generalError != null;
  int get totalErrors => customerErrors.length + transactionErrors.length + (generalError != null ? 1 : 0);

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Migration Result:');
    buffer.writeln('  Success: $success');
    buffer.writeln('  Customers: $customersCount');
    buffer.writeln('  Transactions: $transactionsCount');
    buffer.writeln('  Duration: ${duration.inSeconds}s');
    
    if (hasErrors) {
      buffer.writeln('  Errors: $totalErrors');
      if (generalError != null) {
        buffer.writeln('    General: $generalError');
      }
      if (customerErrors.isNotEmpty) {
        buffer.writeln('    Customer errors: ${customerErrors.length}');
      }
      if (transactionErrors.isNotEmpty) {
        buffer.writeln('    Transaction errors: ${transactionErrors.length}');
      }
    }
    
    return buffer.toString();
  }
}

/// Result of validating a migration
class ValidationResult {
  bool success = false;
  int mongoCustomersCount = 0;
  int sqliteCustomersCount = 0;
  bool customersMatch = false;
  int mongoTransactionsCount = 0;
  int sqliteTransactionsCount = 0;
  bool transactionsMatch = false;
  String? error;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Validation Result:');
    buffer.writeln('  Success: $success');
    buffer.writeln('  Customers:');
    buffer.writeln('    MongoDB: $mongoCustomersCount');
    buffer.writeln('    SQLite: $sqliteCustomersCount');
    buffer.writeln('    Match: $customersMatch');
    buffer.writeln('  Transactions:');
    buffer.writeln('    MongoDB: $mongoTransactionsCount');
    buffer.writeln('    SQLite: $sqliteTransactionsCount');
    buffer.writeln('    Match: $transactionsMatch');
    
    if (error != null) {
      buffer.writeln('  Error: $error');
    }
    
    return buffer.toString();
  }
}

/// Internal result for migration steps
class _MigrationStepResult {
  int success = 0;
  List<String> errors = [];
}
