import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/backup_service.dart';
import '../../services/restore_service.dart';
import '../../services/audit_service.dart';
import '../../domain/models/audit_log.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../utils/date_formatter.dart';

/// Backup & Restore Screen
/// Allows users to create backups and restore from them
class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({Key? key}) : super(key: key);

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final BackupService _backupService = BackupService();
  final RestoreService _restoreService = RestoreService();
  final AuditService _auditService = AuditService();

  List<File> _availableBackups = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableBackups();
  }

  Future<void> _loadAvailableBackups() async {
    setState(() => _isLoading = true);
    
    try {
      final backups = await _backupService.getAvailableBackups();
      setState(() {
        _availableBackups = backups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showError('Error loading backups: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAvailableBackups,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBackupSection(),
                  const SizedBox(height: 32),
                  _buildRestoreSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildBackupSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.backup, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            const Text(
              'Create Backup',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Export all your data to a backup file. You can share it or save it for later.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _createBackup,
            icon: const Icon(Icons.backup),
            label: const Text('Create Backup Now'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestoreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.restore, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text(
              'Restore from Backup',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Restore your data from a previous backup file.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickAndRestoreBackup,
                icon: const Icon(Icons.file_upload),
                label: const Text('Choose File'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.orange,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (_availableBackups.isNotEmpty) ...[
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.history, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              const Text(
                'Recent Backups',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._availableBackups.map((file) => _buildBackupCard(file)),
        ],
      ],
    );
  }

  Widget _buildBackupCard(File file) {
    final filename = file.path.split(Platform.pathSeparator).last;
    final lastModified = file.lastModifiedSync();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.backup, color: Colors.blue.shade700),
        ),
        title: Text(
          filename,
          style: const TextStyle(fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: FutureBuilder<int>(
          future: _backupService.getBackupSize(file),
          builder: (context, snapshot) {
            final size = snapshot.data ?? 0;
            return Text(
              '${AppDateFormatter.formatDateTime(lastModified, 'en')} • ${_backupService.formatFileSize(size)}',
              style: const TextStyle(fontSize: 12),
            );
          },
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'restore') {
              await _restoreFromFile(file);
            } else if (value == 'share') {
              await _shareBackup(file);
            } else if (value == 'delete') {
              await _deleteBackup(file);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'restore',
              child: Row(
                children: [
                  Icon(Icons.restore, size: 20),
                  SizedBox(width: 12),
                  Text('Restore'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, size: 20),
                  SizedBox(width: 12),
                  Text('Share'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBackup() async {
    setState(() => _isLoading = true);

    try {
      // Create backup
      final backup = await _backupService.createBackup();
      
      // Download backup (works on all platforms)
      await _backupService.downloadBackup(backup);
      
      setState(() => _isLoading = false);

      if (mounted) {
        // Show success dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 12),
                Text('Backup Downloaded'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your backup has been downloaded successfully!'),
                const SizedBox(height: 16),
                Text('Customers: ${backup.customers.length}'),
                Text('Transactions: ${backup.transactions.length}'),
                Text('Users: ${backup.users.length}'),
                const SizedBox(height: 16),
                const Text(
                  'The backup file has been saved to your device.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        );

        // Log audit
        await _auditService.log(
          userId: 'system',
          username: 'System',
          action: AuditAction.dataExported,
          details: 'Backup created: ${backup.customers.length} customers, ${backup.transactions.length} transactions',
        );

        // Refresh list
        await _loadAvailableBackups();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showError('Error creating backup: $e');
      }
    }
  }

  Future<void> _shareBackup(File file) async {
    try {
      await _backupService.shareBackup(file);
    } catch (e) {
      if (mounted) {
        _showError('Error sharing backup: $e');
      }
    }
  }

  Future<void> _deleteBackup(File file) async {
    final confirmed = await ConfirmationDialog.showDeleteConfirmation(
      context: context,
      title: 'Delete Backup',
      message: 'Are you sure you want to delete this backup file?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );

    if (!confirmed) return;

    try {
      await _backupService.deleteBackup(file);
      await _loadAvailableBackups();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Error deleting backup: $e');
      }
    }
  }

  Future<void> _pickAndRestoreBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.first.path!);
      await _restoreFromFile(file);
    } catch (e) {
      if (mounted) {
        _showError('Error picking file: $e');
      }
    }
  }

  Future<void> _restoreFromFile(File file) async {
    setState(() => _isLoading = true);

    try {
      // Load backup
      final backup = await _restoreService.loadBackupFromFile(file);
      
      // Validate backup
      final validation = await _restoreService.validateBackup(backup);
      
      setState(() => _isLoading = false);

      if (!validation.isValid) {
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Invalid Backup'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('This backup file has errors:'),
                  const SizedBox(height: 8),
                  ...validation.errors.map((e) => Text('• $e', style: const TextStyle(color: Colors.red))),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Show restore options
      if (mounted) {
        await _showRestoreDialog(backup, validation);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showError('Error loading backup: $e');
      }
    }
  }

  Future<void> _showRestoreDialog(BackupData backup, ValidationResult validation) async {
    final stats = _restoreService.getStatistics(backup);

    final mode = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Backup contains:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('• ${stats.customerCount} customers'),
              Text('• ${stats.transactionCount} transactions'),
              Text('• ${stats.userCount} users'),
              Text('• ${stats.auditLogCount} audit logs'),
              const SizedBox(height: 16),
              if (validation.hasWarnings) ...[
                const Text('Warnings:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                const SizedBox(height: 4),
                ...validation.warnings.map((w) => Text('• $w', style: const TextStyle(color: Colors.orange, fontSize: 12))),
                const SizedBox(height: 16),
              ],
              const Text('Choose restore mode:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Replace: Delete all current data and restore from backup', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              const Text('Merge: Keep current data and add backup data', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'merge'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Merge'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'replace'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Replace'),
          ),
        ],
      ),
    );

    if (mode == null) return;

    // Confirm destructive action
    if (mode == 'replace') {
      final confirmed = await ConfirmationDialog.showWarning(
        context: context,
        title: 'Replace All Data',
        message: 'This will DELETE all your current data and replace it with the backup.\n\nThis action cannot be undone!\n\nAre you sure?',
        confirmText: 'Yes, Replace',
        cancelText: 'Cancel',
      );

      if (!confirmed) return;
    }

    // Perform restore
    setState(() => _isLoading = true);

    try {
      if (mode == 'replace') {
        await _restoreService.restoreReplace(backup);
      } else {
        await _restoreService.restoreMerge(backup);
      }

      // Log audit
      await _auditService.log(
        userId: 'system',
        username: 'System',
        action: AuditAction.dataImported,
        details: 'Backup restored ($mode mode): ${stats.customerCount} customers, ${stats.transactionCount} transactions',
      );

      setState(() => _isLoading = false);

      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 12),
                Text('Restore Complete'),
              ],
            ),
            content: const Text('Your data has been restored successfully!\n\nPlease restart the app to see the changes.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to settings
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showError('Error restoring backup: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
