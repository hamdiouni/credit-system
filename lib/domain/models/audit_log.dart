/// Audit log entry for tracking user actions
class AuditLog {
  final String id;
  final String userId;
  final String username;
  final AuditAction action;
  final String? entityType; // e.g., 'customer', 'transaction', 'user'
  final String? entityId;
  final String? details;
  final DateTime timestamp;

  AuditLog({
    required this.id,
    required this.userId,
    required this.username,
    required this.action,
    this.entityType,
    this.entityId,
    this.details,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'action': action.toString().split('.').last,
      'entityType': entityType,
      'entityId': entityId,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AuditLog.fromMap(Map<String, dynamic> map) {
    return AuditLog(
      id: map['id'] as String,
      userId: map['userId'] as String,
      username: map['username'] as String,
      action: AuditAction.values.firstWhere(
        (e) => e.toString().split('.').last == map['action'],
        orElse: () => AuditAction.other,
      ),
      entityType: map['entityType'] as String?,
      entityId: map['entityId'] as String?,
      details: map['details'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  @override
  String toString() {
    return 'AuditLog(user: $username, action: $action, entity: $entityType, time: $timestamp)';
  }
}

/// Types of actions that can be audited
enum AuditAction {
  // Authentication
  login,
  logout,
  loginFailed,

  // Customer actions
  customerCreated,
  customerUpdated,
  customerDeleted,
  customerViewed,

  // Transaction actions
  transactionCreated,
  transactionUpdated,
  transactionDeleted,

  // Data management
  dataExported,
  dataImported,
  dataCleared,
  dataMigrated,

  // User management
  userCreated,
  userUpdated,
  userDeleted,

  // Settings
  settingsChanged,

  // Other
  other,
}

extension AuditActionExtension on AuditAction {
  String get displayName {
    switch (this) {
      case AuditAction.login:
        return 'Logged in';
      case AuditAction.logout:
        return 'Logged out';
      case AuditAction.loginFailed:
        return 'Login failed';
      case AuditAction.customerCreated:
        return 'Created customer';
      case AuditAction.customerUpdated:
        return 'Updated customer';
      case AuditAction.customerDeleted:
        return 'Deleted customer';
      case AuditAction.customerViewed:
        return 'Viewed customer';
      case AuditAction.transactionCreated:
        return 'Created transaction';
      case AuditAction.transactionUpdated:
        return 'Updated transaction';
      case AuditAction.transactionDeleted:
        return 'Deleted transaction';
      case AuditAction.dataExported:
        return 'Exported data';
      case AuditAction.dataImported:
        return 'Imported data';
      case AuditAction.dataCleared:
        return 'Cleared all data';
      case AuditAction.dataMigrated:
        return 'Migrated data';
      case AuditAction.userCreated:
        return 'Created user';
      case AuditAction.userUpdated:
        return 'Updated user';
      case AuditAction.userDeleted:
        return 'Deleted user';
      case AuditAction.settingsChanged:
        return 'Changed settings';
      case AuditAction.other:
        return 'Other action';
    }
  }

  String get icon {
    switch (this) {
      case AuditAction.login:
      case AuditAction.logout:
        return '🔐';
      case AuditAction.loginFailed:
        return '❌';
      case AuditAction.customerCreated:
      case AuditAction.customerUpdated:
        return '👤';
      case AuditAction.customerDeleted:
        return '🗑️';
      case AuditAction.customerViewed:
        return '👁️';
      case AuditAction.transactionCreated:
      case AuditAction.transactionUpdated:
        return '💰';
      case AuditAction.transactionDeleted:
        return '🗑️';
      case AuditAction.dataExported:
        return '📤';
      case AuditAction.dataImported:
        return '📥';
      case AuditAction.dataCleared:
      case AuditAction.dataMigrated:
        return '🔄';
      case AuditAction.userCreated:
      case AuditAction.userUpdated:
      case AuditAction.userDeleted:
        return '👥';
      case AuditAction.settingsChanged:
        return '⚙️';
      case AuditAction.other:
        return '📝';
    }
  }
}
