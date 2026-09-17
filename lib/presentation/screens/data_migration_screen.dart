import 'package:flutter/material.dart';
import '../../utils/data_migration_tool.dart';
import '../../config/database_config.dart';
import '../../data/database/database_helper.dart';

/// Data Migration Screen - UI for migrating data from MongoDB to SQLite
class DataMigrationScreen extends StatefulWidget {
  const DataMigrationScreen({Key? key}) : super(key: key);

  @override
  State<DataMigrationScreen> createState() => _DataMigrationScreenState();
}

class _DataMigrationScreenState extends State<DataMigrationScreen> {
  final DataMigrationTool _migrator = DataMigrationTool();
  bool _isMigrating = false;
  bool _clearSqliteFirst = true;
  final List<String> _logs = [];
  MigrationResult? _result;
  ValidationResult? _validation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Migration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildCurrentDatabaseCard(),
            const SizedBox(height: 16),
            _buildOptionsCard(),
            const SizedBox(height: 16),
            _buildActionButtons(),
            if (_logs.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildLogsCard(),
            ],
            if (_result != null) ...[
              const SizedBox(height: 16),
              _buildResultCard(),
            ],
            if (_validation != null) ...[
              const SizedBox(height: 16),
              _buildValidationCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'About Data Migration',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'This tool helps you migrate your data from MongoDB to SQLite. '
              'SQLite is the recommended database as it works offline and doesn\'t require a server.',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Make sure your MongoDB server is running before starting migration.',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentDatabaseCard() {
    final currentDb = DatabaseHelper.currentDatabaseType;
    final isOfflineFirst = DatabaseConfig.isOfflineFirst;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Database',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  isOfflineFirst ? Icons.storage : Icons.cloud,
                  color: isOfflineFirst ? Colors.green : Colors.blue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentDb.toString().split('.').last.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        isOfflineFirst
                            ? 'Offline-first (No server needed)'
                            : 'Cloud-based (Requires server)',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Migration Options',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Clear SQLite data before migration'),
              subtitle: const Text('Recommended to avoid duplicates'),
              value: _clearSqliteFirst,
              onChanged: _isMigrating
                  ? null
                  : (value) {
                      setState(() {
                        _clearSqliteFirst = value ?? true;
                      });
                    },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isMigrating ? null : _startMigration,
            icon: _isMigrating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            label: Text(_isMigrating ? 'Migrating...' : 'Start Migration'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        if (_result != null && _result!.success) ...[
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _isMigrating ? null : _validateMigration,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Validate'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLogsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Migration Log',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _logs.clear();
                      _result = null;
                      _validation = null;
                    });
                  },
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Text(
                      log,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: log.contains('❌')
                            ? Colors.red.shade700
                            : log.contains('✅')
                                ? Colors.green.shade700
                                : Colors.black87,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    if (_result == null) return const SizedBox.shrink();

    return Card(
      color: _result!.success ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _result!.success ? Icons.check_circle : Icons.error,
                  color: _result!.success ? Colors.green.shade700 : Colors.red.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Migration ${_result!.success ? 'Successful' : 'Failed'}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _result!.success ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildResultRow('Customers migrated', '${_result!.customersCount}'),
            _buildResultRow('Transactions migrated', '${_result!.transactionsCount}'),
            _buildResultRow('Duration', '${_result!.duration.inSeconds}s'),
            if (_result!.hasErrors) ...[
              const Divider(height: 24),
              Text(
                'Errors: ${_result!.totalErrors}',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildValidationCard() {
    if (_validation == null) return const SizedBox.shrink();

    return Card(
      color: _validation!.success ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _validation!.success ? Icons.verified : Icons.warning,
                  color: _validation!.success ? Colors.green.shade700 : Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Validation ${_validation!.success ? 'Passed' : 'Warning'}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _validation!.success ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildValidationRow(
              'Customers',
              _validation!.mongoCustomersCount,
              _validation!.sqliteCustomersCount,
              _validation!.customersMatch,
            ),
            _buildValidationRow(
              'Transactions',
              _validation!.mongoTransactionsCount,
              _validation!.sqliteTransactionsCount,
              _validation!.transactionsMatch,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationRow(String label, int mongoCount, int sqliteCount, bool match) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Text('MongoDB: $mongoCount'),
              const SizedBox(width: 8),
              Text('SQLite: $sqliteCount'),
              const SizedBox(width: 8),
              Icon(
                match ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: match ? Colors.green : Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _startMigration() async {
    setState(() {
      _isMigrating = true;
      _logs.clear();
      _result = null;
      _validation = null;
    });

    try {
      final result = await _migrator.migrateFromMongoToSqlite(
        clearSqliteFirst: _clearSqliteFirst,
        onProgress: (message) {
          setState(() {
            _logs.add(message);
          });
        },
      );

      setState(() {
        _result = result;
        _isMigrating = false;
      });

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Migration completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Migration failed: ${result.generalError}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isMigrating = false;
        _logs.add('❌ Error: $e');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Migration failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _validateMigration() async {
    setState(() {
      _isMigrating = true;
      _logs.add('🔍 Validating migration...');
    });

    try {
      final validation = await _migrator.validateMigration();

      setState(() {
        _validation = validation;
        _isMigrating = false;
        _logs.add(validation.success
            ? '✅ Validation passed!'
            : '⚠️ Validation found mismatches');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            validation.success
                ? '✅ Validation passed!'
                : '⚠️ Validation found mismatches',
          ),
          backgroundColor: validation.success ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      setState(() {
        _isMigrating = false;
        _logs.add('❌ Validation error: $e');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Validation failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
