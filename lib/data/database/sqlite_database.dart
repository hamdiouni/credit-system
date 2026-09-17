import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../domain/models/customer.dart';
import '../../domain/models/transaction.dart' as app_transaction;
import 'database_interface.dart';

// Conditional import for Platform (not available on web)
import 'sqlite_database_io.dart' if (dart.library.html) 'sqlite_database_web.dart';

/// SQLite Database Implementation - Primary local database
/// Features:
/// - Offline-first (works without internet)
/// - Fast local storage
/// - Automatic migrations
/// - Sync queue for cloud sync (optional)
class SqliteDatabase implements DatabaseInterface {
  static final SqliteDatabase _instance = SqliteDatabase._internal();
  static Database? _database;
  static const int _currentVersion = 3;
  static bool _ffiInitialized = false;

  factory SqliteDatabase() {
    return _instance;
  }

  SqliteDatabase._internal();

  @override
  String get databaseType => 'SQLite';

  /// Initialize FFI for desktop platforms
  static void initializeFfi() {
    if (_ffiInitialized) return;
    
    // Skip on web platform
    if (kIsWeb) {
      print('⚠️ [SQLite] Web platform detected, skipping FFI initialization');
      _ffiInitialized = true;
      return;
    }
    
    // Initialize FFI for desktop platforms (Windows, macOS, Linux)
    initializeFfiImpl();
    
    _ffiInitialized = true;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // Initialize FFI before opening database
    initializeFfi();
    
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'credit_app.db');

    print('📦 [SQLite] Initializing database at: $path');

    return await openDatabase(
      path,
      version: _currentVersion,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
      onOpen: (db) {
        print('✅ [SQLite] Database opened successfully');
      },
    );
  }  Future<void> _createTables(Database db, int version) async {
    print('🔧 [SQLite] Creating tables (version $version)...');

    // Customers table
    await db.execute('''
      CREATE TABLE customers(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus TEXT DEFAULT 'synced'
      )
    ''');

    // Transactions table
    await db.execute('''
      CREATE TABLE transactions(
        id TEXT PRIMARY KEY,
        customerId TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        selectedItems TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus TEXT DEFAULT 'synced',
        FOREIGN KEY(customerId) REFERENCES customers(id) ON DELETE CASCADE
      )
    ''');

    // Sync queue table (for offline-first sync)
    await db.execute('''
      CREATE TABLE sync_queue(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        entityType TEXT NOT NULL,
        entityId TEXT NOT NULL,
        data TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        retryCount INTEGER DEFAULT 0
      )
    ''');

    // Metadata table
    await db.execute('''
      CREATE TABLE metadata(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Users table (Phase 9: Security)
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        pinHash TEXT NOT NULL,
        role TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        lastLoginAt TEXT,
        isActive INTEGER DEFAULT 1
      )
    ''');

    // Audit logs table (Phase 9: Security)
    await db.execute('''
      CREATE TABLE audit_logs(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        username TEXT NOT NULL,
        action TEXT NOT NULL,
        entityType TEXT,
        entityId TEXT,
        details TEXT,
        timestamp TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_customers_name ON customers(name)');
    await db.execute('CREATE INDEX idx_transactions_customerId ON transactions(customerId)');
    await db.execute('CREATE INDEX idx_transactions_createdAt ON transactions(createdAt)');
    await db.execute('CREATE INDEX idx_users_username ON users(username)');
    await db.execute('CREATE INDEX idx_audit_logs_userId ON audit_logs(userId)');
    await db.execute('CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp)');

    print('✅ [SQLite] Tables created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 [SQLite] Upgrading database from v$oldVersion to v$newVersion');

    if (oldVersion < 2) {
      // Add sync-related columns if upgrading from v1
      try {
        await db.execute('ALTER TABLE customers ADD COLUMN syncStatus TEXT DEFAULT "synced"');
        await db.execute('ALTER TABLE customers ADD COLUMN updatedAt TEXT');
        await db.execute('ALTER TABLE transactions ADD COLUMN syncStatus TEXT DEFAULT "synced"');
        await db.execute('ALTER TABLE transactions ADD COLUMN updatedAt TEXT');
        
        // Update existing records with current timestamp
        final now = DateTime.now().toIso8601String();
        await db.execute('UPDATE customers SET updatedAt = ? WHERE updatedAt IS NULL', [now]);
        await db.execute('UPDATE transactions SET updatedAt = ? WHERE updatedAt IS NULL', [now]);
        
        print('✅ [SQLite] Migration to v2 complete');
      } catch (e) {
        print('⚠️ [SQLite] Migration warning: $e');
      }
    }

    if (oldVersion < 3) {
      // Add users and audit_logs tables (Phase 9: Security)
      try {
        await db.execute('''
          CREATE TABLE users(
            id TEXT PRIMARY KEY,
            username TEXT NOT NULL UNIQUE,
            pinHash TEXT NOT NULL,
            role TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            lastLoginAt TEXT,
            isActive INTEGER DEFAULT 1
          )
        ''');

        await db.execute('''
          CREATE TABLE audit_logs(
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            username TEXT NOT NULL,
            action TEXT NOT NULL,
            entityType TEXT,
            entityId TEXT,
            details TEXT,
            timestamp TEXT NOT NULL
          )
        ''');

        // Create indexes
        await db.execute('CREATE INDEX idx_users_username ON users(username)');
        await db.execute('CREATE INDEX idx_audit_logs_userId ON audit_logs(userId)');
        await db.execute('CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp)');
        
        print('✅ [SQLite] Migration to v3 complete (Security tables added)');
      } catch (e) {
        print('⚠️ [SQLite] Migration warning: $e');
      }
    }
  }

  @override
  Future<void> initialize() async {
    await database; // Trigger initialization
  }

  @override
  Future<bool> isReady() async {
    try {
      final db = await database;
      return db.isOpen;
    } catch (e) {
      return false;
    }
  }

  // ===== CUSTOMERS =====

  @override
  Future<String> addCustomer(Customer customer) async {
    try {
      final db = await database;
      final id = customer.id ?? _generateId();
      final now = DateTime.now().toIso8601String();

      print('📝 [SQLite] Adding customer: ${customer.name} (ID: $id)');

      await db.insert(
        'customers',
        {
          'id': id,
          'name': customer.name,
          'phone': customer.phone,
          'createdAt': customer.createdAt.toIso8601String(),
          'updatedAt': now,
          'syncStatus': 'pending',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('✅ [SQLite] Customer added successfully');
      return id;
    } catch (e, stackTrace) {
      print('❌ [SQLite] Error adding customer: $e');
      print('Stack: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<Customer>> getAllCustomers() async {
    try {
      final db = await database;
      print('📤 [SQLite] Fetching all customers...');

      final List<Map<String, dynamic>> maps = await db.query(
        'customers',
        orderBy: 'name ASC',
      );

      print('✅ [SQLite] Retrieved ${maps.length} customers');

      return List.generate(maps.length, (i) {
        return Customer(
          id: maps[i]['id'] as String,
          name: maps[i]['name'] as String,
          phone: maps[i]['phone'] as String?,
          createdAt: DateTime.parse(maps[i]['createdAt'] as String),
        );
      });
    } catch (e, stackTrace) {
      print('❌ [SQLite] Error fetching customers: $e');
      print('Stack: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<Customer?> getCustomerById(dynamic id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'customers',
        where: 'id = ?',
        whereArgs: [id.toString()],
      );

      if (maps.isEmpty) return null;

      return Customer(
        id: maps[0]['id'] as String,
        name: maps[0]['name'] as String,
        phone: maps[0]['phone'] as String?,
        createdAt: DateTime.parse(maps[0]['createdAt'] as String),
      );
    } catch (e) {
      print('❌ [SQLite] Error fetching customer: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();

      print('📝 [SQLite] Updating customer: ${customer.name}');

      await db.update(
        'customers',
        {
          'name': customer.name,
          'phone': customer.phone,
          'updatedAt': now,
          'syncStatus': 'pending',
        },
        where: 'id = ?',
        whereArgs: [customer.id.toString()],
      );

      print('✅ [SQLite] Customer updated successfully');
    } catch (e) {
      print('❌ [SQLite] Error updating customer: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCustomer(dynamic id) async {
    try {
      final db = await database;
      print('🗑️ [SQLite] Deleting customer: $id');

      await db.delete(
        'customers',
        where: 'id = ?',
        whereArgs: [id.toString()],
      );

      print('✅ [SQLite] Customer deleted successfully');
    } catch (e) {
      print('❌ [SQLite] Error deleting customer: $e');
      rethrow;
    }
  }

  // ===== TRANSACTIONS =====

  @override
  Future<String> addTransaction(app_transaction.Transaction transaction) async {
    try {
      final db = await database;
      // Generate new ID if transaction has no ID or has placeholder ID (0)
      final String id;
      if (transaction.id == null || transaction.id == 0 || transaction.id.toString().isEmpty) {
        id = _generateId();
      } else {
        id = transaction.id.toString();
      }
      
      final now = DateTime.now().toIso8601String();

      print('📝 [SQLite] Adding transaction: ${transaction.type} - ${transaction.amount} (ID: $id)');

      final rowId = await db.insert(
        'transactions',
        {
          'id': id,
          'customerId': transaction.customerId.toString(),
          'type': transaction.type.toString().split('.').last,
          'amount': transaction.amount,
          'note': transaction.note,
          'selectedItems': jsonEncode(transaction.selectedItems),
          'createdAt': transaction.createdAt.toIso8601String(),
          'updatedAt': now,
          'syncStatus': 'pending',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('✅ [SQLite] Transaction added successfully with ID: $id');
      return id; // Return the String ID
    } catch (e, stackTrace) {
      print('❌ [SQLite] Error adding transaction: $e');
      print('Stack: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<app_transaction.Transaction>> getAllTransactions() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        orderBy: 'createdAt DESC',
      );

      return _mapToTransactions(maps);
    } catch (e) {
      print('❌ [SQLite] Error fetching transactions: $e');
      rethrow;
    }
  }

  @override
  Future<List<app_transaction.Transaction>> getTransactionsByCustomerId(dynamic customerId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'customerId = ?',
        whereArgs: [customerId.toString()],
        orderBy: 'createdAt DESC',
      );

      return _mapToTransactions(maps);
    } catch (e) {
      print('❌ [SQLite] Error fetching transactions: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateTransaction(app_transaction.Transaction transaction) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();

      print('📝 [SQLite] Updating transaction: ${transaction.id}');

      await db.update(
        'transactions',
        {
          'type': transaction.type.toString().split('.').last,
          'amount': transaction.amount,
          'note': transaction.note,
          'selectedItems': jsonEncode(transaction.selectedItems),
          'updatedAt': now,
          'syncStatus': 'pending',
        },
        where: 'id = ?',
        whereArgs: [transaction.id.toString()],
      );

      print('✅ [SQLite] Transaction updated successfully');
    } catch (e) {
      print('❌ [SQLite] Error updating transaction: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTransaction(dynamic id) async {
    try {
      final db = await database;
      print('🗑️ [SQLite] Deleting transaction: $id');

      await db.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [id.toString()],
      );

      print('✅ [SQLite] Transaction deleted successfully');
    } catch (e) {
      print('❌ [SQLite] Error deleting transaction: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAllTransactionsByCustomerId(dynamic customerId) async {
    try {
      final db = await database;
      await db.delete(
        'transactions',
        where: 'customerId = ?',
        whereArgs: [customerId.toString()],
      );
    } catch (e) {
      print('❌ [SQLite] Error deleting transactions: $e');
      rethrow;
    }
  }

  // ===== SYNC OPERATIONS =====

  @override
  Future<DateTime?> getLastSyncTime() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'metadata',
        where: 'key = ?',
        whereArgs: ['last_sync_time'],
      );

      if (maps.isEmpty) return null;
      return DateTime.parse(maps[0]['value'] as String);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setLastSyncTime(DateTime time) async {
    try {
      final db = await database;
      await db.insert(
        'metadata',
        {
          'key': 'last_sync_time',
          'value': time.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('❌ [SQLite] Error setting sync time: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingSyncOperations() async {
    try {
      final db = await database;
      return await db.query(
        'sync_queue',
        orderBy: 'createdAt ASC',
      );
    } catch (e) {
      print('❌ [SQLite] Error fetching sync operations: $e');
      return [];
    }
  }

  @override
  Future<void> addSyncOperation(String operation, String entityType, dynamic entityId, Map<String, dynamic> data) async {
    try {
      final db = await database;
      await db.insert('sync_queue', {
        'operation': operation,
        'entityType': entityType,
        'entityId': entityId.toString(),
        'data': jsonEncode(data),
        'createdAt': DateTime.now().toIso8601String(),
        'retryCount': 0,
      });
    } catch (e) {
      print('❌ [SQLite] Error adding sync operation: $e');
    }
  }

  @override
  Future<void> removeSyncOperation(int operationId) async {
    try {
      final db = await database;
      await db.delete(
        'sync_queue',
        where: 'id = ?',
        whereArgs: [operationId],
      );
    } catch (e) {
      print('❌ [SQLite] Error removing sync operation: $e');
    }
  }

  @override
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    print('🔒 [SQLite] Database closed');
  }

  // ===== HELPER METHODS =====

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  List<app_transaction.Transaction> _mapToTransactions(List<Map<String, dynamic>> maps) {
    return List.generate(maps.length, (i) {
      final typeString = maps[i]['type'] as String;
      final type = app_transaction.TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == typeString,
        orElse: () => app_transaction.TransactionType.CREDIT,
      );

      List<String> selectedItems = [];
      try {
        final itemsJson = maps[i]['selectedItems'] as String?;
        if (itemsJson != null && itemsJson.isNotEmpty) {
          selectedItems = List<String>.from(jsonDecode(itemsJson));
        }
      } catch (e) {
        print('⚠️ [SQLite] Error parsing selectedItems: $e');
      }

      return app_transaction.Transaction(
        id: maps[i]['id'] as String,
        customerId: maps[i]['customerId'] as String,
        type: type,
        amount: (maps[i]['amount'] as num).toDouble(),
        note: maps[i]['note'] as String?,
        selectedItems: selectedItems,
        createdAt: DateTime.parse(maps[i]['createdAt'] as String),
      );
    });
  }
}

