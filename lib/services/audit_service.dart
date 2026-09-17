import '../domain/models/audit_log.dart';
import '../data/database/database_helper.dart';
import '../data/database/sqlite_database.dart';

/// Service for logging and retrieving audit logs
class AuditService {
  static final AuditService _instance = AuditService._internal();
  factory AuditService() => _instance;
  AuditService._internal();

  /// Log an action
  Future<void> log({
    required String userId,
    required String username,
    required AuditAction action,
    String? entityType,
    String? entityId,
    String? details,
  }) async {
    try {
      final log = AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        username: username,
        action: action,
        entityType: entityType,
        entityId: entityId,
        details: details,
        timestamp: DateTime.now(),
      );

      print('📝 [AuditService] ${log.action.icon} ${log.action.displayName} by ${log.username}');

      // Save to database
      await _saveLog(log);
    } catch (e) {
      print('❌ [AuditService] Error logging action: $e');
      // Don't throw - audit logging should not break the app
    }
  }

  /// Save audit log to database
  Future<void> _saveLog(AuditLog log) async {
    try {
      final dbInterface = DatabaseHelper().database;
      
      // Audit logs are only supported in SQLite
      if (dbInterface is SqliteDatabase) {
        final db = await dbInterface.database;
        
        await db.insert(
          'audit_logs',
          log.toMap(),
        );
        
        print('💾 [AuditService] Log saved: ${log.id}');
      } else {
        print('⚠️ [AuditService] Audit logs not supported for ${dbInterface.databaseType}');
      }
    } catch (e) {
      print('❌ [AuditService] Error saving log: $e');
    }
  }

  /// Get recent audit logs
  Future<List<AuditLog>> getRecentLogs({int limit = 100}) async {
    try {
      final dbInterface = DatabaseHelper().database;
      
      // Audit logs are only supported in SQLite
      if (dbInterface is! SqliteDatabase) {
        print('⚠️ [AuditService] Audit logs not supported for ${dbInterface.databaseType}');
        return [];
      }
      
      final db = await dbInterface.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        'audit_logs',
        orderBy: 'timestamp DESC',
        limit: limit,
      );
      
      return List.generate(maps.length, (i) => AuditLog.fromMap(maps[i]));
    } catch (e) {
      print('❌ [AuditService] Error fetching logs: $e');
      return [];
    }
  }

  /// Get logs for a specific user
  Future<List<AuditLog>> getLogsForUser(String userId, {int limit = 100}) async {
    try {
      final dbInterface = DatabaseHelper().database;
      
      // Audit logs are only supported in SQLite
      if (dbInterface is! SqliteDatabase) {
        print('⚠️ [AuditService] Audit logs not supported for ${dbInterface.databaseType}');
        return [];
      }
      
      final db = await dbInterface.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        'audit_logs',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'timestamp DESC',
        limit: limit,
      );
      
      return List.generate(maps.length, (i) => AuditLog.fromMap(maps[i]));
    } catch (e) {
      print('❌ [AuditService] Error fetching user logs: $e');
      return [];
    }
  }

  /// Get logs for a specific entity
  Future<List<AuditLog>> getLogsForEntity(
    String entityType,
    String entityId, {
    int limit = 100,
  }) async {
    try {
      final dbInterface = DatabaseHelper().database;
      
      // Audit logs are only supported in SQLite
      if (dbInterface is! SqliteDatabase) {
        print('⚠️ [AuditService] Audit logs not supported for ${dbInterface.databaseType}');
        return [];
      }
      
      final db = await dbInterface.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        'audit_logs',
        where: 'entityType = ? AND entityId = ?',
        whereArgs: [entityType, entityId],
        orderBy: 'timestamp DESC',
        limit: limit,
      );
      
      return List.generate(maps.length, (i) => AuditLog.fromMap(maps[i]));
    } catch (e) {
      print('❌ [AuditService] Error fetching entity logs: $e');
      return [];
    }
  }

  /// Clear old logs (keep last N days)
  Future<void> clearOldLogs({int keepDays = 90}) async {
    try {
      final dbInterface = DatabaseHelper().database;
      
      // Audit logs are only supported in SQLite
      if (dbInterface is! SqliteDatabase) {
        print('⚠️ [AuditService] Audit logs not supported for ${dbInterface.databaseType}');
        return;
      }
      
      final db = await dbInterface.database;
      final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
      
      print('🗑️ [AuditService] Clearing logs older than $cutoffDate');
      
      await db.delete(
        'audit_logs',
        where: 'timestamp < ?',
        whereArgs: [cutoffDate.toIso8601String()],
      );
      
      print('✅ [AuditService] Old logs cleared');
    } catch (e) {
      print('❌ [AuditService] Error clearing old logs: $e');
    }
  }
}
