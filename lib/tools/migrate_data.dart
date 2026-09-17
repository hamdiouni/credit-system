import 'package:flutter/material.dart';
import '../utils/data_migration_tool.dart';

/// Simple CLI tool to migrate data from MongoDB to SQLite
/// 
/// Run with: flutter run lib/tools/migrate_data.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('');
  print('═══════════════════════════════════════════════════════════');
  print('  📦 Data Migration Tool - MongoDB → SQLite');
  print('═══════════════════════════════════════════════════════════');
  print('');

  final migrator = DataMigrationTool();

  try {
    // Run migration
    final result = await migrator.migrateFromMongoToSqlite(
      clearSqliteFirst: true,
      onProgress: (message) => print(message),
    );

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('  📊 Migration Summary');
    print('═══════════════════════════════════════════════════════════');
    print(result.toString());

    // Validate migration
    if (result.success) {
      print('');
      print('🔍 Validating migration...');
      final validation = await migrator.validateMigration();
      print(validation.toString());

      if (validation.success) {
        print('');
        print('✅ Migration completed successfully and validated!');
      } else {
        print('');
        print('⚠️ Migration completed but validation found mismatches.');
        print('   Please review the data manually.');
      }
    }

  } catch (e, stackTrace) {
    print('');
    print('❌ Migration failed with error:');
    print(e);
    print('');
    print('Stack trace:');
    print(stackTrace);
  }

  print('');
  print('═══════════════════════════════════════════════════════════');
  print('  Done!');
  print('═══════════════════════════════════════════════════════════');
  print('');
}
