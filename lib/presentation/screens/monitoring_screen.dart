import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/error_logger.dart';
import '../../services/performance_tracker.dart';
import '../../services/health_check_service.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/confirmation_dialog.dart';

/// Monitoring Screen - View errors, performance, and health
class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({Key? key}) : super(key: key);

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  HealthStatus? _healthStatus;
  bool _isLoadingHealth = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _runHealthCheck();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _runHealthCheck() async {
    setState(() => _isLoadingHealth = true);
    
    try {
      final status = await HealthCheckService().checkHealth();
      setState(() {
        _healthStatus = status;
        _isLoadingHealth = false;
      });
    } catch (e) {
      setState(() => _isLoadingHealth = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Monitoring'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.error_outline), text: 'Errors'),
            Tab(icon: Icon(Icons.speed), text: 'Performance'),
            Tab(icon: Icon(Icons.health_and_safety), text: 'Health'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildErrorsTab(),
          _buildPerformanceTab(),
          _buildHealthTab(),
        ],
      ),
    );
  }

  Widget _buildErrorsTab() {
    final errors = ErrorLogger.getRecentErrors(limit: 100);

    return Column(
      children: [
        if (errors.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
            child: Row(
              children: [
                Icon(Icons.error, color: Colors.red.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${errors.length} error(s) logged',
                    style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton.icon(
                  onPressed: _clearErrors,
                  icon: const Icon(Icons.delete),
                  label: const Text('Clear'),
                ),
                TextButton.icon(
                  onPressed: _exportErrors,
                  icon: const Icon(Icons.share),
                  label: const Text('Export'),
                ),
              ],
            ),
          ),
        Expanded(
          child: errors.isEmpty
              ? _buildEmptyState('No errors logged', Icons.check_circle, Colors.green)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: errors.length,
                  itemBuilder: (context, index) => _buildErrorCard(errors[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(ErrorLog error) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red.shade100,
          child: Icon(Icons.error, color: Colors.red.shade700),
        ),
        title: Text(
          error.context ?? 'Error',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          AppDateFormatter.formatRelative(error.timestamp),
          style: const TextStyle(fontSize: 12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Error:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(error.error),
                if (error.stackTrace != null) ...[
                  const SizedBox(height: 12),
                  const Text('Stack Trace:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      error.stackTrace!.split('\n').take(10).join('\n'),
                      style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    final metrics = PerformanceTracker.getAllMetrics();
    final slowOps = PerformanceTracker.getSlowOperations();

    return Column(
      children: [
        if (slowOps.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.orange.shade50,
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${slowOps.length} slow operation(s) detected',
                    style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton.icon(
                  onPressed: _clearMetrics,
                  icon: const Icon(Icons.delete),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ),
        Expanded(
          child: metrics.isEmpty
              ? _buildEmptyState('No performance data', Icons.speed, Colors.blue)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (slowOps.isNotEmpty) ...[
                      const Text(
                        'Slow Operations',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...slowOps.map((m) => _buildMetricCard(m, isSlow: true)),
                      const SizedBox(height: 24),
                    ],
                    const Text(
                      'All Operations',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...metrics.values.map((m) => _buildMetricCard(m)),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(PerformanceMetrics metrics, {bool isSlow = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSlow ? Colors.orange.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSlow ? Colors.orange.shade100 : Colors.blue.shade100,
          child: Icon(
            isSlow ? Icons.warning : Icons.speed,
            color: isSlow ? Colors.orange.shade700 : Colors.blue.shade700,
          ),
        ),
        title: Text(metrics.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Count: ${metrics.count}'),
            Text('Average: ${PerformanceTracker.formatDuration(metrics.average)}'),
            Text('Min: ${PerformanceTracker.formatDuration(metrics.min)} | Max: ${PerformanceTracker.formatDuration(metrics.max)}'),
          ],
        ),
        trailing: Text(
          PerformanceTracker.formatDuration(metrics.recent),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSlow ? Colors.orange.shade700 : Colors.blue.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildHealthTab() {
    return RefreshIndicator(
      onRefresh: _runHealthCheck,
      child: _isLoadingHealth
          ? const Center(child: CircularProgressIndicator())
          : _healthStatus == null
              ? _buildEmptyState('Run health check', Icons.health_and_safety, Colors.blue)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildHealthOverview(_healthStatus!),
                    const SizedBox(height: 24),
                    const Text(
                      'System Checks',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._healthStatus!.checks.values.map((check) => _buildHealthCheckCard(check)),
                  ],
                ),
    );
  }

  Widget _buildHealthOverview(HealthStatus status) {
    final color = status.isHealthy
        ? Colors.green
        : status.hasWarnings
            ? Colors.orange
            : Colors.red;

    return Card(
      color: color.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              status.isHealthy ? Icons.check_circle : Icons.warning,
              size: 64,
              color: color.shade700,
            ),
            const SizedBox(height: 16),
            Text(
              status.overallStatus.displayName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last checked: ${AppDateFormatter.formatRelative(status.timestamp)}',
              style: TextStyle(color: color.shade700),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusCount('Healthy', status.healthyCount, Colors.green),
                _buildStatusCount('Warnings', status.warningCount, Colors.orange),
                _buildStatusCount('Errors', status.errorCount, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCount(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }

  Widget _buildHealthCheckCard(HealthCheck check) {
    final color = check.status == CheckStatus.healthy
        ? Colors.green
        : check.status == CheckStatus.warning
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.shade100,
          child: Text(check.status.icon, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(check.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(check.message),
        trailing: Text(
          check.status.displayName,
          style: TextStyle(color: color.shade700, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: color.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 18, color: color.withValues(alpha: 0.6))),
        ],
      ),
    );
  }

  Future<void> _clearErrors() async {
    final confirmed = await ConfirmationDialog.showWarning(
      context: context,
      title: 'Clear Errors',
      message: 'Are you sure you want to clear all error logs?',
      confirmText: 'Clear',
      cancelText: 'Cancel',
    );

    if (!confirmed) return;

    ErrorLogger.clearCache();
    await ErrorLogger.deleteLogFile();
    
    setState(() {});
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error logs cleared')),
      );
    }
  }

  Future<void> _exportErrors() async {
    final logPath = await ErrorLogger.getLogFilePath();
    
    if (logPath == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No log file found')),
        );
      }
      return;
    }

    try {
      final file = XFile(logPath);
      await Share.shareXFiles([file], subject: 'Error Logs');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing logs: $e')),
        );
      }
    }
  }

  Future<void> _clearMetrics() async {
    final confirmed = await ConfirmationDialog.showWarning(
      context: context,
      title: 'Clear Metrics',
      message: 'Are you sure you want to clear all performance metrics?',
      confirmText: 'Clear',
      cancelText: 'Cancel',
    );

    if (!confirmed) return;

    PerformanceTracker.clearMetrics();
    
    setState(() {});
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Performance metrics cleared')),
      );
    }
  }
}
