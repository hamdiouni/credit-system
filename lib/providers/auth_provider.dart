import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../domain/models/user.dart';
import '../services/auth_service.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/user_repository_web_stub.dart'
    if (dart.library.html) '../data/repositories/user_repository_web.dart';
import '../data/dao/user_dao.dart';
import '../data/database/database_helper.dart';
import '../data/database/sqlite_database.dart';

/// Provider for authentication state management
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  dynamic _userRepository; // Can be UserRepository or UserRepositoryWeb

  User? _currentUser;
  bool _isInitialized = false;
  bool _hasUsers = false;
  bool _isWebPlatform = false;

  AuthProvider() {
    _isWebPlatform = kIsWeb;
    
    // Initialize user repository based on platform
    try {
      if (_isWebPlatform) {
        // Use web-specific repository with localStorage
        _userRepository = UserRepositoryWeb();
        print('ℹ️ [AuthProvider] Web platform - using localStorage for users');
      } else {
        // Use SQLite repository for desktop/mobile
        final db = DatabaseHelper().database;
        if (db is SqliteDatabase) {
          _userRepository = UserRepository(UserDAO(db));
        }
      }
    } catch (e) {
      print('⚠️ [AuthProvider] Could not initialize user repository: $e');
    }
  }

  /// Get the currently logged-in user
  User? get currentUser => _currentUser;

  /// Check if a user is logged in
  bool get isLoggedIn => _currentUser != null;

  /// Check if the provider is initialized
  bool get isInitialized => _isInitialized;

  /// Check if any users exist in the system
  bool get hasUsers => _hasUsers;

  /// Check if current user is admin
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  /// Check if current user is employee
  bool get isEmployee => _currentUser?.role == UserRole.employee;

  /// Initialize the auth provider
  Future<void> initialize() async {
    print('🔐 [AuthProvider] Initializing...');

    try {
      // Initialize auth service
      await _authService.initialize();

      // Check if any users exist (works for both web and desktop)
      if (_userRepository != null) {
        _hasUsers = await _userRepository.hasUsers();
        print('👥 [AuthProvider] Users exist: $_hasUsers');
      }

      // Get current user from auth service
      _currentUser = _authService.currentUser;

      _isInitialized = true;
      notifyListeners();

      print('✅ [AuthProvider] Initialized');
    } catch (e) {
      print('❌ [AuthProvider] Initialization error: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Login with username and PIN
  Future<bool> login(String username, String pin) async {
    print('🔐 [AuthProvider] Attempting login: $username');

    if (_userRepository == null) {
      print('⚠️ [AuthProvider] User repository not initialized');
      return false;
    }

    try {
      // Get user by username
      final user = await _userRepository!.getUserByUsername(username);

      if (user == null) {
        print('❌ [AuthProvider] User not found');
        return false;
      }

      // Attempt login
      final success = await _authService.login(user, pin);

      if (success) {
        _currentUser = _authService.currentUser;
        notifyListeners();
        print('✅ [AuthProvider] Login successful');
      }

      return success;
    } catch (e) {
      print('❌ [AuthProvider] Login error: $e');
      return false;
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    print('🔐 [AuthProvider] Logging out');

    await _authService.logout();
    _currentUser = null;
    notifyListeners();

    print('✅ [AuthProvider] Logged out');
  }

  /// Check if current user has a specific permission
  bool hasPermission(Permission permission) {
    return _authService.hasPermission(permission);
  }

  /// Require a specific permission (throws if not authorized)
  void requirePermission(Permission permission) {
    _authService.requirePermission(permission);
  }

  /// Check if session should be locked
  bool shouldLock() {
    return _authService.shouldLock();
  }

  /// Update activity timestamp
  Future<void> updateActivity() async {
    await _authService.updateActivity();
  }

  /// Get auto-lock timeout in minutes
  int get autoLockTimeout => _authService.autoLockTimeout;

  /// Set auto-lock timeout in minutes
  Future<void> setAutoLockTimeout(int minutes) async {
    await _authService.setAutoLockTimeout(minutes);
    notifyListeners();
  }

  /// Get all users for login screen (no permission check needed)
  Future<List<User>> getAllUsersForLogin() async {
    if (_userRepository == null) {
      return [];
    }
    return await _userRepository!.getActiveUsers();
  }

  /// Get all users (admin only)
  Future<List<User>> getAllUsers() async {
    if (_userRepository == null) {
      throw Exception('User management not available on this platform');
    }
    requirePermission(Permission.manageUsers);
    return await _userRepository!.getAllUsers();
  }

  /// Get active users only (admin only)
  Future<List<User>> getActiveUsers() async {
    if (_userRepository == null) {
      throw Exception('User management not available on this platform');
    }
    requirePermission(Permission.manageUsers);
    return await _userRepository!.getActiveUsers();
  }

  /// Check if running on web platform
  bool get isWebPlatform => _isWebPlatform;

  /// Create the first admin user (no permission check - for initial setup)
  Future<String> createFirstUser({
    required String username,
    required String pin,
  }) async {
    if (_userRepository == null) {
      throw Exception('User management not available on this platform');
    }

    // Check if any users exist
    final hasExistingUsers = await _userRepository!.hasUsers();
    if (hasExistingUsers) {
      throw Exception('Users already exist. Use createUser instead.');
    }

    final pinHash = _authService.hashPin(pin);
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      pinHash: pinHash,
      role: UserRole.admin, // First user is always admin
      createdAt: DateTime.now(),
    );

    final userId = await _userRepository!.createUser(user);
    _hasUsers = true;
    notifyListeners();

    return userId;
  }

  /// Create a new user (admin only)
  Future<String> createUser({
    required String username,
    required String pin,
    required UserRole role,
  }) async {
    if (_userRepository == null) {
      throw Exception('User management not available on this platform');
    }
    requirePermission(Permission.manageUsers);

    final pinHash = _authService.hashPin(pin);
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      pinHash: pinHash,
      role: role,
      createdAt: DateTime.now(),
    );

    final userId = await _userRepository!.createUser(user);
    notifyListeners();

    return userId;
  }

  /// Update a user (admin only)
  Future<void> updateUser(User user) async {
    if (_userRepository == null) {
      throw Exception('User management not available on this platform');
    }
    requirePermission(Permission.manageUsers);
    await _userRepository!.updateUser(user);
    notifyListeners();
  }

  /// Delete a user (admin only)
  Future<void> deleteUser(String userId) async {
    if (_userRepository == null) {
      throw Exception('User management not available on this platform');
    }
    requirePermission(Permission.manageUsers);

    // Prevent deleting yourself
    if (_currentUser?.id == userId) {
      throw Exception('Cannot delete your own account');
    }

    await _userRepository!.deleteUser(userId);
    notifyListeners();
  }

  /// Deactivate a user (admin only)
  Future<void> deactivateUser(String userId) async {
    if (_userRepository == null) {
      throw Exception('User management not available on this platform');
    }
    requirePermission(Permission.manageUsers);

    // Prevent deactivating yourself
    if (_currentUser?.id == userId) {
      throw Exception('Cannot deactivate your own account');
    }

    await _userRepository!.deactivateUser(userId);
    notifyListeners();
  }

  /// Activate a user (admin only)
  Future<void> activateUser(String userId) async {
    if (_userRepository == null) {
      throw Exception('User management not available on this platform');
    }
    requirePermission(Permission.manageUsers);
    await _userRepository!.activateUser(userId);
    notifyListeners();
  }

  /// Change PIN for current user
  Future<bool> changePin(String oldPin, String newPin) async {
    if (_currentUser == null || _userRepository == null) return false;

    // Verify old PIN
    if (!_authService.verifyPin(oldPin, _currentUser!.pinHash)) {
      return false;
    }

    // Hash new PIN
    final newPinHash = _authService.hashPin(newPin);

    // Update user
    final updatedUser = _currentUser!.copyWith(pinHash: newPinHash);
    await _userRepository!.updateUser(updatedUser);

    _currentUser = updatedUser;
    notifyListeners();

    return true;
  }

  /// Reset PIN for a user (admin only)
  Future<void> resetUserPin(String userId, String newPin) async {
    if (_userRepository == null) {
      throw Exception('User management not available on this platform');
    }
    requirePermission(Permission.manageUsers);

    final user = await _userRepository!.getUserById(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    final newPinHash = _authService.hashPin(newPin);
    final updatedUser = user.copyWith(pinHash: newPinHash);

    await _userRepository!.updateUser(updatedUser);
    notifyListeners();
  }
}
