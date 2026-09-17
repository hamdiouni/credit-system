import 'package:flutter/material.dart';
import '../../domain/models/audit_log.dart';
import '../../services/audit_service.dart';
import '../../utils/date_formatter.dart';

/// Audit Log Viewer Screen - Admin only
/// View all system activity logs with filtering and search
class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({Key? key}) : super(key: key);

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final AuditService _auditService = AuditService();
  List<AuditLog> _logs = [];
  List<AuditLog> _filteredLogs = [];
  bool _isLoading = true;
  
  String _searchQuery = '';
  AuditAction? _filterAction;
  String? _filterUser;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    
    try {
      final logs = await _auditService.getRecentLogs(limit: 500);
      
      setState(() {
        _logs = logs;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading logs: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _applyFilters() {
    _filteredLogs = _logs.where((log) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!log.username.toLowerCase().contains(query) &&
            !log.action.displayName.toLowerCase().contains(query) &&
            !(log.details?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Action filter
      if (_filterAction != null && log.action != _filterAction) {
        return false;
      }

      // User filter
      if (_filterUser != null && log.username != _filterUser) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search logs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _applyFilters();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
              },
            ),
          ),

          // Active filters
          if (_filterAction != null || _filterUser != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_filterAction != null)
                    Chip(
                      label: Text(_filterAction!.displayName),
                      onDeleted: () {
                        setState(() {
                          _filterAction = null;
                          _applyFilters();
                        });
                      },
                    ),
                  if (_filterUser != null)
                    Chip(
                      label: Text('User: $_filterUser'),
                      onDeleted: () {
                        setState(() {
                          _filterUser = null;
                          _applyFilters();
                        });
                      },
                    ),
                ],
              ),
            ),

          // Logs list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredLogs.isEmpty
                    ? _buildEmptyState()
                    : _buildLogsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _logs.isEmpty ? 'No logs found' : 'No matching logs',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredLogs.length,
      itemBuilder: (context, index) => _buildLogCard(_filteredLogs[index]),
    );
  }

  Widget _buildLogCard(AuditLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getActionColor(log.action).withValues(alpha: 0.2),
          child: Text(
            log.action.icon,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                log.action.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              AppDateFormatter.formatRelative(log.timestamp),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('By: ${log.username}'),
            if (log.entityType != null) ...[
              const SizedBox(height: 2),
              Text(
                '${log.entityType}: ${log.entityId}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
            if (log.details != null) ...[
              const SizedBox(height: 2),
              Text(
                log.details!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        onTap: () => _showLogDetails(log),
      ),
    );
  }

  Color _getActionColor(AuditAction action) {
    switch (action) {
      case AuditAction.login:
      case AuditAction.logout:
        return Colors.blue;
      case AuditAction.loginFailed:
        return Colors.red;
      case AuditAction.customerCreated:
      case AuditAction.transactionCreated:
      case AuditAction.userCreated:
        return Colors.green;
      case AuditAction.customerDeleted:
      case AuditAction.transactionDeleted:
      case AuditAction.userDeleted:
      case AuditAction.dataCleared:
        return Colors.red;
      case AuditAction.customerUpdated:
      case AuditAction.transactionUpdated:
      case AuditAction.userUpdated:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showLogDetails(AuditLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(log.action.icon),
            const SizedBox(width: 8),
            Expanded(child: Text(log.action.displayName)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('User', log.username),
              _buildDetailRow('User ID', log.userId),
              _buildDetailRow('Timestamp', AppDateFormatter.formatDateTime(log.timestamp, 'en')),
              if (log.entityType != null)
                _buildDetailRow('Entity Type', log.entityType!),
              if (log.entityId != null)
                _buildDetailRow('Entity ID', log.entityId!),
              if (log.details != null) ...[
                const SizedBox(height: 8),
                const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(log.details!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Logs'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Action Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<AuditAction?>(
                  initialValue: _filterAction,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'All actions',
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All actions')),
                    ...AuditAction.values.map((action) {
                      return DropdownMenuItem(
                        value: action,
                        child: Text('${action.icon} ${action.displayName}'),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _filterAction = value);
                  },
                ),
                const SizedBox(height: 16),
                const Text('User:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  initialValue: _filterUser,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'All users',
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All users')),
                    ..._logs.map((log) => log.username).toSet().map((username) {
                      return DropdownMenuItem(
                        value: username,
                        child: Text(username),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _filterUser = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _filterAction = null;
                  _filterUser = null;
                });
                this.setState(() => _applyFilters());
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
            ElevatedButton(
              onPressed: () {
                this.setState(() => _applyFilters());
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
