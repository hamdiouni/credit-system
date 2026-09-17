import '../../domain/models/user.dart';
import '../dao/user_dao.dart';

/// Repository for managing users
class UserRepository {
  final UserDAO _userDAO;

  UserRepository(this._userDAO);

  /// Create a new user
  Future<String> createUser(User user) async {
    // Check if username already exists
    final existing = await _userDAO.getUserByUsername(user.username);
    if (existing != null) {
      throw UsernameInUseException('Username already exists');
    }

    return await _userDAO.addUser(user);
  }

  /// Get all users
  Future<List<User>> getAllUsers() async {
    return await _userDAO.getAllUsers();
  }

  /// Get active users only
  Future<List<User>> getActiveUsers() async {
    final users = await getAllUsers();
    return users.where((u) => u.isActive).toList();
  }

  /// Get user by ID
  Future<User?> getUserById(String id) async {
    return await _userDAO.getUserById(id);
  }

  /// Get user by username
  Future<User?> getUserByUsername(String username) async {
    return await _userDAO.getUserByUsername(username);
  }

  /// Update user
  Future<void> updateUser(User user) async {
    // If username changed, check for conflicts
    final existing = await getUserById(user.id);
    if (existing != null && existing.username != user.username) {
      final conflict = await getUserByUsername(user.username);
      if (conflict != null && conflict.id != user.id) {
        throw UsernameInUseException('Username already in use by another user');
      }
    }

    await _userDAO.updateUser(user);
  }

  /// Delete user
  Future<void> deleteUser(String id) async {
    await _userDAO.deleteUser(id);
  }

  /// Deactivate user (soft delete)
  Future<void> deactivateUser(String id) async {
    final user = await getUserById(id);
    if (user == null) {
      throw Exception('User not found');
    }

    await updateUser(user.copyWith(isActive: false));
  }

  /// Activate user
  Future<void> activateUser(String id) async {
    final user = await getUserById(id);
    if (user == null) {
      throw Exception('User not found');
    }

    await updateUser(user.copyWith(isActive: true));
  }

  /// Check if any users exist
  Future<bool> hasUsers() async {
    try {
      final users = await getAllUsers();
      return users.isNotEmpty;
    } catch (e) {
      print('⚠️ [UserRepository] Error checking if users exist: $e');
      // If we can't check, assume no users exist
      return false;
    }
  }

  /// Get user count
  Future<int> getUserCount() async {
    final users = await getAllUsers();
    return users.length;
  }

  /// Get active user count
  Future<int> getActiveUserCount() async {
    final users = await getActiveUsers();
    return users.length;
  }
}

/// Exception thrown when username is already in use
class UsernameInUseException implements Exception {
  final String message;
  UsernameInUseException([this.message = 'Username already in use']);

  @override
  String toString() => 'UsernameInUseException: $message';
}
