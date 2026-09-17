import 'package:path_provider/path_provider.dart';
import '../data/database/database_helper.dart';

/// Health Check Service - Monitor system health
class HealthCheckService {
  static final HealthCheckService _instance = HealthCheckService._internal();
  factory HealthCheckService() => _instance;
  HealthCheckService._internal();

  /// Perform comprehensive health check
  Future<HealthStatus> checkHealth() async {
    print('🏥 [HealthCheckService] Running health check...');

    final checks = <String, HealthCheck>{};

    // Check database
    checks['database'] = await _checkDatabase();

    // Check storage
    checks['storage'] = await _checkStorage();

    // Check memory
    checks['memory'] = await _checkMemory();

    // Determine overall status
    final hasError = checks.values.any((c) => c.status == CheckStatus.error);
    final hasWarning = checks.values.any((c) => c.status == CheckStatus.warning);

    final overallStatus = hasError
        ? CheckStatus.error
        : hasWarning
            ? CheckStatus.warning
            : CheckStatus.healthy;

    print('✅ [HealthCheckService] Health check complete: $overallStatus');

    return HealthStatus(
      overallStatus: overallStatus,
      checks: checks,
      timestamp: DateTime.now(),
    );
  }

  /// Check database health
  Future<HealthCheck> _checkDatabase() async {
    try {
      final db = DatabaseHelper().database;
      
      // Try to query database
      final customers = await db.getAllCustomers();
      
      return HealthCheck(
        name: 'Database',
        status: CheckStatus.healthy,
        message: 'Database is operational (${customers.length} customers)',
      );
    } catch (e) {
      return HealthCheck(
        name: 'Database',
        status: CheckStatus.error,
        message: 'Database error: $e',
      );
    }
  }

  /// Check storage health
  Future<HealthCheck> _checkStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      
      // Check if directory is accessible
      if (!await directory.exists()) {
        return HealthCheck(
          name: 'Storage',
          status: CheckStatus.error,
          message: 'Storage directory not accessible',
        );
      }

      // Check available space (if possible)
      try {
        await directory.stat();
        return HealthCheck(
          name: 'Storage',
          status: CheckStatus.healthy,
          message: 'Storage is accessible',
        );
      } catch (e) {
        return HealthCheck(
          name: 'Storage',
          status: CheckStatus.healthy,
          message: 'Storage is accessible (space check unavailable)',
        );
      }
    } catch (e) {
      return HealthCheck(
        name: 'Storage',
        status: CheckStatus.error,
        message: 'Storage error: $e',
      );
    }
  }

  /// Check memory health
  Future<HealthCheck> _checkMemory() async {
    try {
      // Basic memory check - just verify we can allocate
      final testList = List.generate(1000, (i) => i);
      testList.clear();
      
      return HealthCheck(
        name: 'Memory',
        status: CheckStatus.healthy,
        message: 'Memory is available',
      );
    } catch (e) {
      return HealthCheck(
        name: 'Memory',
        status: CheckStatus.error,
        message: 'Memory error: $e',
      );
    }
  }

  /// Quick health check (database only)
  Future<bool> isHealthy() async {
    try {
      final db = DatabaseHelper().database;
      await db.getAllCustomers();
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Health status
class HealthStatus {
  final CheckStatus overallStatus;
  final Map<String, HealthCheck> checks;
  final DateTime timestamp;

  HealthStatus({
    required this.overallStatus,
    required this.checks,
    required this.timestamp,
  });

  bool get isHealthy => overallStatus == CheckStatus.healthy;
  bool get hasWarnings => overallStatus == CheckStatus.warning;
  bool get hasErrors => overallStatus == CheckStatus.error;

  int get healthyCount => checks.values.where((c) => c.status == CheckStatus.healthy).length;
  int get warningCount => checks.values.where((c) => c.status == CheckStatus.warning).length;
  int get errorCount => checks.values.where((c) => c.status == CheckStatus.error).length;

  @override
  String toString() {
    return 'HealthStatus(overall: $overallStatus, healthy: $healthyCount, warnings: $warningCount, errors: $errorCount)';
  }
}

/// Individual health check
class HealthCheck {
  final String name;
  final CheckStatus status;
  final String message;

  HealthCheck({
    required this.name,
    required this.status,
    required this.message,
  });

  @override
  String toString() {
    return 'HealthCheck(name: $name, status: $status, message: $message)';
  }
}

/// Check status
enum CheckStatus {
  healthy,
  warning,
  error,
}

extension CheckStatusExtension on CheckStatus {
  String get displayName {
    switch (this) {
      case CheckStatus.healthy:
        return 'Healthy';
      case CheckStatus.warning:
        return 'Warning';
      case CheckStatus.error:
        return 'Error';
    }
  }

  String get icon {
    switch (this) {
      case CheckStatus.healthy:
        return '✅';
      case CheckStatus.warning:
        return '⚠️';
      case CheckStatus.error:
        return '❌';
    }
  }
}
