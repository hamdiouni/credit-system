// Database Configuration - SQLite as primary database

import 'package:credit_app/data/database/database_helper.dart' as db_helper;

class DatabaseConfig {
  // SQLite is now the default (offline-first)
  static const db_helper.DatabaseType activeDatabase = db_helper.DatabaseType.sqlite;
  
  // MongoDB API endpoint (optional, for cloud sync)
  static const String mongoApiUrl = 'http://localhost:3000/api';

  /// Initialize the selected database
  static Future<void> initialize() async {
    print('🚀 [DatabaseConfig] Initializing database...');
    print('📦 [DatabaseConfig] Active database: ${activeDatabase.toString().split('.').last.toUpperCase()}');
    
    // Set the database type
    db_helper.DatabaseHelper.setDatabaseType(activeDatabase);
    
    // Initialize database
    await db_helper.DatabaseHelper().initDatabase();
    
    print('✅ [DatabaseConfig] Database initialized successfully');
    
    if (activeDatabase == db_helper.DatabaseType.sqlite) {
      print('🎉 [DatabaseConfig] Using SQLite - No server needed!');
      print('📱 [DatabaseConfig] Works 100% offline');
    } else if (activeDatabase == db_helper.DatabaseType.mongo) {
      print('☁️ [DatabaseConfig] Using MongoDB');
      print('🌐 [DatabaseConfig] API URL: $mongoApiUrl');
    }
  }

  /// Check which database is active
  static String get statusInfo {
    final dbType = db_helper.DatabaseHelper.currentDatabaseType.toString().split('.').last;
    return 'Active Database: $dbType\n${activeDatabase == db_helper.DatabaseType.mongo ? "Mongo API: $mongoApiUrl" : "Offline-first: No server needed"}';
  }
  
  /// Check if using offline-first database
  static bool get isOfflineFirst => activeDatabase == db_helper.DatabaseType.sqlite;
  
  /// Check if using cloud database
  static bool get isCloudEnabled => activeDatabase == db_helper.DatabaseType.mongo;
}
