import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;
import '../data/database/database_helper.dart';
import '../data/database/sqlite_database.dart';
import '../data/repositories/user_repository.dart';
import '../data/dao/user_dao.dart';
import '../domain/models/customer.dart';
import '../domain/models/transaction.dart';
import '../domain/models/user.dart';
import '../domain/models/audit_log.dart';
import '../services/audit_service.dart';

/// Service for creating and managing backups
class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  /// Create a full backup of all data
  Future<BackupData> createBackup() async {
    print('📦 [BackupService] Creating backup...');

    try {
      final db = DatabaseHelper().database;

      // Get all data
      final customers = await db.getAllCustomers();
      final transactions = await db.getAllTransactions();
      
      // Get users from repository using DatabaseHelper
      final dbForUsers = DatabaseHelper().database;
      
      // User management requires SQLite
      if (dbForUsers is! SqliteDatabase) {
        throw Exception('Backup requires SQLite database');
      }
      
      final userRepo = UserRepository(UserDAO(dbForUsers));
      final users = await userRepo.getAllUsers();
      
      // Get audit logs
      final auditService = AuditService();
      final auditLogs = await auditService.getRecentLogs(limit: 1000);

      final backup = BackupData(
        version: 1,
        createdAt: DateTime.now(),
        customers: customers,
        transactions: transactions,
        users: users,
        auditLogs: auditLogs,
      );

      print('✅ [BackupService] Backup created: ${customers.length} customers, ${transactions.length} transactions');
      return backup;
    } catch (e) {
      print('❌ [BackupService] Error creating backup: $e');
      rethrow;
    }
  }

  /// Save backup to file and download (platform-specific)
  Future<File?> saveBackupToFile(BackupData backup) async {
    print('💾 [BackupService] Saving backup to file...');

    try {
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final filename = 'credit_app_backup_$timestamp.json';
      
      // Convert to JSON
      final json = backup.toJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(json);

      if (kIsWeb) {
        // Web: Trigger download
        print('🌐 [BackupService] Web platform - triggering download');
        final bytes = utf8.encode(jsonString);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = filename;
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
        print('✅ [BackupService] Web download triggered');
        return null; // No file object on web
      } else {
        // Mobile/Desktop: Save to file
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsString(jsonString);
        print('✅ [BackupService] Backup saved: ${file.path}');
        return file;
      }
    } catch (e) {
      print('❌ [BackupService] Error saving backup: $e');
      rethrow;
    }
  }

  /// Download backup (unified method for all platforms)
  Future<void> downloadBackup(BackupData backup) async {
    print('📥 [BackupService] Downloading backup...');

    try {
      final file = await saveBackupToFile(backup);
      
      if (!kIsWeb && file != null) {
        // Mobile/Desktop: Share the file
        await shareBackup(file);
      }
      // Web: Download already triggered in saveBackupToFile
      
      print('✅ [BackupService] Backup download complete');
    } catch (e) {
      print('❌ [BackupService] Error downloading backup: $e');
      rethrow;
    }
  }

  /// Share backup file
  Future<void> shareBackup(File file) async {
    print('📤 [BackupService] Sharing backup...');

    try {
      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        subject: 'Credit App Backup',
        text: 'Backup created on ${DateTime.now().toString()}',
      );

      print('✅ [BackupService] Backup shared');
    } catch (e) {
      print('❌ [BackupService] Error sharing backup: $e');
      rethrow;
    }
  }

  /// Get list of available backups
  Future<List<File>> getAvailableBackups() async {
    print('📋 [BackupService] Getting available backups...');

    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json') && file.path.contains('credit_app_backup'))
          .toList();

      // Sort by date (newest first)
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      print('✅ [BackupService] Found ${files.length} backups');
      return files;
    } catch (e) {
      print('❌ [BackupService] Error getting backups: $e');
      return [];
    }
  }

  /// Delete a backup file
  Future<void> deleteBackup(File file) async {
    print('🗑️ [BackupService] Deleting backup: ${file.path}');

    try {
      if (await file.exists()) {
        await file.delete();
        print('✅ [BackupService] Backup deleted');
      }
    } catch (e) {
      print('❌ [BackupService] Error deleting backup: $e');
      rethrow;
    }
  }

  /// Get backup file size
  Future<int> getBackupSize(File file) async {
    try {
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  /// Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Backup data model
class BackupData {
  final int version;
  final DateTime createdAt;
  final List<Customer> customers;
  final List<Transaction> transactions;
  final List<User> users;
  final List<AuditLog> auditLogs;

  BackupData({
    required this.version,
    required this.createdAt,
    required this.customers,
    required this.transactions,
    required this.users,
    required this.auditLogs,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'createdAt': createdAt.toIso8601String(),
      'customers': customers.map((c) => c.toMap()).toList(),
      'transactions': transactions.map((t) => t.toMap()).toList(),
      'users': users.map((u) => u.toMap()).toList(),
      'auditLogs': auditLogs.map((a) => a.toMap()).toList(),
      'metadata': {
        'customerCount': customers.length,
        'transactionCount': transactions.length,
        'userCount': users.length,
        'auditLogCount': auditLogs.length,
      },
    };
  }

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      version: json['version'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      customers: (json['customers'] as List)
          .map((c) => Customer.fromMap(c as Map<String, dynamic>))
          .toList(),
      transactions: (json['transactions'] as List)
          .map((t) => Transaction.fromMap(t as Map<String, dynamic>))
          .toList(),
      users: (json['users'] as List)
          .map((u) => User.fromMap(u as Map<String, dynamic>))
          .toList(),
      auditLogs: (json['auditLogs'] as List)
          .map((a) => AuditLog.fromMap(a as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'BackupData(version: $version, customers: ${customers.length}, transactions: ${transactions.length}, users: ${users.length})';
  }
}
