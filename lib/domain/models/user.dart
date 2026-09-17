/// User model for authentication and authorization
class User {
  final String id;
  final String username;
  final String pinHash; // Hashed PIN for security
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;

  User({
    required this.id,
    required this.username,
    required this.pinHash,
    required this.role,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
  });

  User copyWith({
    String? id,
    String? username,
    String? pinHash,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      pinHash: pinHash ?? this.pinHash,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'pinHash': pinHash,
      'role': role.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    try {
      return User(
        id: map['id'] as String,
        username: map['username'] as String,
        pinHash: map['pinHash'] as String,
        role: UserRole.values.firstWhere(
          (e) => e.toString().split('.').last == map['role'],
          orElse: () => UserRole.employee,
        ),
        createdAt: DateTime.parse(map['createdAt'] as String),
        lastLoginAt: map['lastLoginAt'] != null
            ? DateTime.parse(map['lastLoginAt'] as String)
            : null,
        isActive: (map['isActive'] as int) == 1,
      );
    } catch (e) {
      print('❌ [User] Error parsing user from map: $e');
      print('Map data: $map');
      rethrow;
    }
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, role: $role, isActive: $isActive)';
  }
}

/// User roles with different permission levels
enum UserRole {
  admin,    // Full access - can manage users, delete data, change settings
  employee, // Limited access - can add/edit customers and transactions
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.employee:
        return 'Employee';
    }
  }

  String get description {
    switch (this) {
      case UserRole.admin:
        return 'Full access to all features';
      case UserRole.employee:
        return 'Can manage customers and transactions';
    }
  }

  /// Check if this role has permission for an action
  bool hasPermission(Permission permission) {
    switch (this) {
      case UserRole.admin:
        return true; // Admin has all permissions
      case UserRole.employee:
        return _employeePermissions.contains(permission);
    }
  }

  static const _employeePermissions = {
    Permission.viewCustomers,
    Permission.addCustomer,
    Permission.editCustomer,
    Permission.viewTransactions,
    Permission.addTransaction,
    Permission.editTransaction,
    Permission.exportData,
  };
}

/// Granular permissions for different actions
enum Permission {
  // Customer permissions
  viewCustomers,
  addCustomer,
  editCustomer,
  deleteCustomer,

  // Transaction permissions
  viewTransactions,
  addTransaction,
  editTransaction,
  deleteTransaction,

  // Data management
  exportData,
  importData,
  clearAllData,

  // User management
  manageUsers,
  changeSettings,

  // System
  viewAuditLog,
}
