import 'dart:convert';
import 'dart:io';
import '../data/database/database_helper.dart';
import '../data/database/sqlite_database.dart';
import '../domain/models/transaction.dart';
import '../domain/models/user.dart';
import 'backup_service.dart';

/// Service for restoring data from backups
class RestoreService {
  static final RestoreService _instance = RestoreService._internal();
  factory RestoreService() => _instance;
  RestoreService._internal();

  /// Load backup from file
  Future<BackupData> loadBackupFromFile(File file) async {
    print('📂 [RestoreService] Loading backup from file...');

    try {
      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final backup = BackupData.fromJson(json);

      print('✅ [RestoreService] Backup loaded: ${backup.customers.length} customers, ${backup.transactions.length} transactions');
      return backup;
    } catch (e) {
      print('❌ [RestoreService] Error loading backup: $e');
      rethrow;
    }
  }

  /// Validate backup data
  Future<ValidationResult> validateBackup(BackupData backup) async {
    print('🔍 [RestoreService] Validating backup...');

    final errors = <String>[];
    final warnings = <String>[];

    try {
      // Check version
      if (backup.version != 1) {
        errors.add('Unsupported backup version: ${backup.version}');
      }

      // Check data integrity
      if (backup.customers.isEmpty && backup.transactions.isNotEmpty) {
        warnings.add('Backup has transactions but no customers');
      }

      // Check for duplicate IDs
      final customerIds = backup.customers.map((c) => c.id).toSet();
      if (customerIds.length != backup.customers.length) {
        errors.add('Duplicate customer IDs found');
      }

      final transactionIds = backup.transactions.map((t) => t.id).toSet();
      if (transactionIds.length != backup.transactions.length) {
        errors.add('Duplicate transaction IDs found');
      }

      // Check for orphaned transactions
      final orphanedTransactions = backup.transactions
          .where((t) => !customerIds.contains(t.customerId))
          .length;
      if (orphanedTransactions > 0) {
        warnings.add('$orphanedTransactions transactions reference non-existent customers');
      }

      // Check for at least one admin user
      final hasAdmin = backup.users.any((u) => u.role == UserRole.admin);
      if (!hasAdmin) {
        errors.add('Backup must contain at least one admin user');
      }

      print('✅ [RestoreService] Validation complete: ${errors.length} errors, ${warnings.length} warnings');

      return ValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
      );
    } catch (e) {
      print('❌ [RestoreService] Error validating backup: $e');
      return ValidationResult(
        isValid: false,
        errors: ['Validation failed: $e'],
        warnings: [],
      );
    }
  }

  /// Restore data (replace mode - clears existing data)
  Future<void> restoreReplace(BackupData backup) async {
    print('🔄 [RestoreService] Restoring data (replace mode)...');

    try {
      final dbInterface = DatabaseHelper().database;
      
      // Restore is only supported for SQLite
      if (dbInterface is! SqliteDatabase) {
        throw Exception('Restore is only supported for SQLite database');
      }
      
      final db = await dbInterface.database;

      // Start transaction
      await db.transaction((txn) async {
        // Clear existing data
        print('🗑️ [RestoreService] Clearing existing data...');
        await txn.delete('transactions');
        await txn.delete('customers');
        await txn.delete('users');
        await txn.delete('audit_logs');

        // Restore customers
        print('📥 [RestoreService] Restoring ${backup.customers.length} customers...');
        for (final customer in backup.customers) {
          await txn.insert('customers', customer.toMap());
        }

        // Restore transactions
        print('📥 [RestoreService] Restoring ${backup.transactions.length} transactions...');
        for (final transaction in backup.transactions) {
          await txn.insert('transactions', transaction.toMap());
        }

        // Restore users
        print('📥 [RestoreService] Restoring ${backup.users.length} users...');
        for (final user in backup.users) {
          await txn.insert('users', user.toMap());
        }

        // Restore audit logs
        print('📥 [RestoreService] Restoring ${backup.auditLogs.length} audit logs...');
        for (final log in backup.auditLogs) {
          await txn.insert('audit_logs', log.toMap());
        }
      });

      print('✅ [RestoreService] Restore complete (replace mode)');
    } catch (e) {
      print('❌ [RestoreService] Error restoring data: $e');
      rethrow;
    }
  }

  /// Restore data (merge mode - keeps existing data, adds new)
  Future<void> restoreMerge(BackupData backup) async {
    print('🔄 [RestoreService] Restoring data (merge mode)...');

    try {
      final dbInterface = DatabaseHelper().database;
      
      // Restore is only supported for SQLite
      if (dbInterface is! SqliteDatabase) {
        throw Exception('Restore is only supported for SQLite database');
      }
      
      final db = await dbInterface.database;

      // Get existing IDs
      final existingCustomerIds = await _getExistingIds(db, 'customers');
      final existingTransactionIds = await _getExistingIds(db, 'transactions');
      final existingUserIds = await _getExistingIds(db, 'users');

      int customersAdded = 0;
      int transactionsAdded = 0;
      int usersAdded = 0;

      // Start transaction
      await db.transaction((txn) async {
        // Merge customers
        for (final customer in backup.customers) {
          if (!existingCustomerIds.contains(customer.id)) {
            await txn.insert('customers', customer.toMap());
            customersAdded++;
          }
        }

        // Merge transactions
        for (final transaction in backup.transactions) {
          if (!existingTransactionIds.contains(transaction.id)) {
            await txn.insert('transactions', transaction.toMap());
            transactionsAdded++;
          }
        }

        // Merge users (skip if username already exists)
        final existingUsernames = await _getExistingUsernames(db);
        for (final user in backup.users) {
          if (!existingUserIds.contains(user.id) && !existingUsernames.contains(user.username)) {
            await txn.insert('users', user.toMap());
            usersAdded++;
          }
        }

        // Always add audit logs (they have unique timestamps)
        for (final log in backup.auditLogs) {
          await txn.insert('audit_logs', log.toMap());
        }
      });

      print('✅ [RestoreService] Restore complete (merge mode): +$customersAdded customers, +$transactionsAdded transactions, +$usersAdded users');
    } catch (e) {
      print('❌ [RestoreService] Error restoring data: $e');
      rethrow;
    }
  }

  /// Get existing IDs from a table
  Future<Set<String>> _getExistingIds(dynamic db, String table) async {
    final List<Map<String, dynamic>> maps = await db.query(table, columns: ['id']);
    return maps.map((m) => m['id'] as String).toSet();
  }

  /// Get existing usernames
  Future<Set<String>> _getExistingUsernames(dynamic db) async {
    final List<Map<String, dynamic>> maps = await db.query('users', columns: ['username']);
    return maps.map((m) => m['username'] as String).toSet();
  }

  /// Get backup statistics
  BackupStatistics getStatistics(BackupData backup) {
    final totalDebt = backup.transactions
        .where((t) => t.type == TransactionType.CREDIT)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final totalPayments = backup.transactions
        .where((t) => t.type == TransactionType.PAYMENT)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final customersWithDebt = backup.customers.where((c) {
      final customerTransactions = backup.transactions.where((t) => t.customerId == c.id);
      final debt = customerTransactions
          .where((t) => t.type == TransactionType.CREDIT)
          .fold<double>(0, (sum, t) => sum + t.amount);
      final payments = customerTransactions
          .where((t) => t.type == TransactionType.PAYMENT)
          .fold<double>(0, (sum, t) => sum + t.amount);
      return debt > payments;
    }).length;

    return BackupStatistics(
      customerCount: backup.customers.length,
      transactionCount: backup.transactions.length,
      userCount: backup.users.length,
      auditLogCount: backup.auditLogs.length,
      totalDebt: totalDebt,
      totalPayments: totalPayments,
      customersWithDebt: customersWithDebt,
      backupDate: backup.createdAt,
    );
  }
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
}

/// Backup statistics
class BackupStatistics {
  final int customerCount;
  final int transactionCount;
  final int userCount;
  final int auditLogCount;
  final double totalDebt;
  final double totalPayments;
  final int customersWithDebt;
  final DateTime backupDate;

  BackupStatistics({
    required this.customerCount,
    required this.transactionCount,
    required this.userCount,
    required this.auditLogCount,
    required this.totalDebt,
    required this.totalPayments,
    required this.customersWithDebt,
    required this.backupDate,
  });
}
