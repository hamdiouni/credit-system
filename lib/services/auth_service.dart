import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/user.dart';
import '../domain/models/audit_log.dart';
import 'audit_service.dart';

/// Authentication service for managing user sessions and PIN authentication
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _currentUserIdKey = 'current_user_id';
  static const String _lastActivityKey = 'last_activity';
  static const String _autoLockTimeoutKey = 'auto_lock_timeout';
  static const int _defaultAutoLockMinutes = 5;

  User? _currentUser;
  DateTime? _lastActivity;
  int _autoLockTimeout = _defaultAutoLockMinutes;

  /// Get the currently logged-in user
  User? get currentUser => _currentUser;

  /// Check if a user is currently logged in
  bool get isLoggedIn => _currentUser != null;

  /// Get auto-lock timeout in minutes
  int get autoLockTimeout => _autoLockTimeout;

  /// Initialize the auth service
  Future<void> initialize() async {
    print('🔐 [AuthService] Initializing...');
    
    try {
      // Load auto-lock timeout
      final prefs = await SharedPreferences.getInstance();
      _autoLockTimeout = prefs.getInt(_autoLockTimeoutKey) ?? _defaultAutoLockMinutes;
      
      // Check if there's a saved session
      final userId = prefs.getString(_currentUserIdKey);
      final lastActivityStr = prefs.getString(_lastActivityKey);
      
      if (userId != null && lastActivityStr != null) {
        try {
          _lastActivity = DateTime.parse(lastActivityStr);
          
          // Check if session has expired
          if (_isSessionExpired()) {
            print('⏰ [AuthService] Session expired, clearing...');
            await clearSession();
          } else {
            print('✅ [AuthService] Valid session found for user: $userId');
            // Note: We don't restore the full user object here
            // The app should require re-authentication on startup
          }
        } catch (e) {
          print('⚠️ [AuthService] Error parsing session data: $e');
          // Clear corrupted session data
          await clearSession();
        }
      }
      
      print('✅ [AuthService] Initialized');
    } catch (e) {
      print('❌ [AuthService] Initialization failed: $e');
      // Continue anyway - auth service should still work
    }
  }

  /// Hash a PIN for secure storage
  String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify a PIN against a hash
  bool verifyPin(String pin, String hash) {
    return hashPin(pin) == hash;
  }

  /// Authenticate a user with PIN
  Future<bool> login(User user, String pin) async {
    print('🔐 [AuthService] Attempting login for: ${user.username}');
    
    try {
      // Verify PIN
      if (!verifyPin(pin, user.pinHash)) {
        print('❌ [AuthService] Invalid PIN');
        
        // Log failed attempt (ignore errors)
        try {
          await AuditService().log(
            userId: user.id,
            username: user.username,
            action: AuditAction.loginFailed,
            details: 'Invalid PIN entered',
          );
        } catch (e) {
          print('⚠️ [AuthService] Could not log failed attempt: $e');
        }
        
        return false;
      }

      // Check if user is active
      if (!user.isActive) {
        print('❌ [AuthService] User is inactive');
        return false;
      }

      // Set current user
      _currentUser = user.copyWith(lastLoginAt: DateTime.now());
      _lastActivity = DateTime.now();

      // Save session (with error handling for corrupted SharedPreferences)
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_currentUserIdKey, user.id);
        await prefs.setString(_lastActivityKey, _lastActivity!.toIso8601String());
      } catch (e) {
        print('⚠️ [AuthService] Could not save session to SharedPreferences: $e');
        // Continue anyway - user is still logged in in memory
      }

      print('✅ [AuthService] Login successful');

      // Log successful login (ignore errors)
      try {
        await AuditService().log(
          userId: user.id,
          username: user.username,
          action: AuditAction.login,
        );
      } catch (e) {
        print('⚠️ [AuthService] Could not log successful login: $e');
      }

      return true;
    } catch (e) {
      print('❌ [AuthService] Login error: $e');
      return false;
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    if (_currentUser == null) return;

    print('🔐 [AuthService] Logging out: ${_currentUser!.username}');

    // Log logout
    await AuditService().log(
      userId: _currentUser!.id,
      username: _currentUser!.username,
      action: AuditAction.logout,
    );

    await clearSession();
  }

  /// Clear the current session
  Future<void> clearSession() async {
    _currentUser = null;
    _lastActivity = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserIdKey);
    await prefs.remove(_lastActivityKey);

    print('🔒 [AuthService] Session cleared');
  }

  /// Update last activity timestamp
  Future<void> updateActivity() async {
    if (_currentUser == null) return;

    _lastActivity = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastActivityKey, _lastActivity!.toIso8601String());
  }

  /// Check if the current session has expired
  bool _isSessionExpired() {
    if (_lastActivity == null) return true;

    final now = DateTime.now();
    final difference = now.difference(_lastActivity!);
    final timeoutDuration = Duration(minutes: _autoLockTimeout);

    return difference > timeoutDuration;
  }

  /// Check if session should be locked (for auto-lock feature)
  bool shouldLock() {
    if (!isLoggedIn) return false;
    return _isSessionExpired();
  }

  /// Set auto-lock timeout in minutes
  Future<void> setAutoLockTimeout(int minutes) async {
    _autoLockTimeout = minutes;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_autoLockTimeoutKey, minutes);

    print('⏰ [AuthService] Auto-lock timeout set to $minutes minutes');
  }

  /// Check if current user has a specific permission
  bool hasPermission(Permission permission) {
    if (_currentUser == null) return false;
    return _currentUser!.role.hasPermission(permission);
  }

  /// Require a specific permission (throws if not authorized)
  void requirePermission(Permission permission) {
    if (!hasPermission(permission)) {
      throw UnauthorizedException(
        'User does not have permission: ${permission.toString().split('.').last}',
      );
    }
  }

  /// Check if current user is admin
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  /// Check if current user is employee
  bool get isEmployee => _currentUser?.role == UserRole.employee;
}

/// Exception thrown when user is not authorized
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => 'UnauthorizedException: $message';
}
