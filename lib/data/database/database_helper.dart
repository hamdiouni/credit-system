import 'package:flutter/foundation.dart' show kIsWeb;
import 'database_interface.dart';
import 'sqlite_database.dart';
import 'mongo_database.dart';
import 'in_memory_database.dart';

enum DatabaseType { sqlite, mongo, inMemory }

/// Database Helper - Manages database initialization and switching
/// Default: SQLite (offline-first)
/// Optional: MongoDB (cloud sync)
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  
  // Default to SQLite for offline-first architecture
  static DatabaseType _dbType = DatabaseType.sqlite;
  
  DatabaseInterface? _db;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  /// Get the current database instance
  DatabaseInterface get database {
    if (_db == null) {
      throw StateError('Database not initialized. Call initDatabase() first.');
    }
    return _db!;
  }

  /// Initialize the database
  Future<void> initDatabase() async {
    print('🔧 [DatabaseHelper] Initializing database...');
    print('📦 [DatabaseHelper] Type: ${_dbType.toString().split('.').last}');
    
    try {
      // Create database instance based on type
      switch (_dbType) {
        case DatabaseType.sqlite:
          if (kIsWeb) {
            // Web doesn't support SQLite, fall back to in-memory
            print('⚠️ [DatabaseHelper] Web platform detected, using in-memory database');
            _db = InMemoryDatabase();
          } else {
            _db = SqliteDatabase();
          }
          break;
          
        case DatabaseType.mongo:
          _db = MongoDatabase();
          break;
          
        case DatabaseType.inMemory:
          _db = InMemoryDatabase();
          break;
      }
      
      // Initialize the database
      await _db!.initialize();
      
      print('✅ [DatabaseHelper] Database initialized successfully');
      print('📊 [DatabaseHelper] Database type: ${_db!.databaseType}');
    } catch (e, stackTrace) {
      print('❌ [DatabaseHelper] Failed to initialize database: $e');
      print('Stack: $stackTrace');
      rethrow;
    }
  }

  /// Switch database type (for testing or migration)
  static void setDatabaseType(DatabaseType type) {
    print('🔄 [DatabaseHelper] Switching database type to: ${type.toString().split('.').last}');
    _dbType = type;
  }

  /// Get current database type
  static DatabaseType get currentDatabaseType => _dbType;

  /// Check if database is ready
  Future<bool> isReady() async {
    if (_db == null) return false;
    return await _db!.isReady();
  }

  /// Close the database
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
      print('🔒 [DatabaseHelper] Database closed');
    }
  }
}
