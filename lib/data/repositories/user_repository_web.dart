import '../../domain/models/user.dart';
import '../dao/user_dao_web.dart';

/// Web-specific User Repository using localStorage
class UserRepositoryWeb {
  final UserDAOWeb _userDAO = UserDAOWeb();

  /// Get all users
  Future<List<User>> getAllUsers() async {
    return await _userDAO.getAllUsers();
  }

  /// Get user by ID
  Future<User?> getUserById(String id) async {
    return await _userDAO.getUserById(id);
  }

  /// Get user by username
  Future<User?> getUserByUsername(String username) async {
    return await _userDAO.getUserByUsername(username);
  }

  /// Create a new user (alias for addUser for compatibility)
  Future<String> createUser(User user) async {
    return await addUser(user);
  }

  /// Add a new user
  Future<String> addUser(User user) async {
    // Check if username already exists
    final existing = await getUserByUsername(user.username);
    if (existing != null) {
      throw Exception('Username already exists');
    }
    
    return await _userDAO.addUser(user);
  }

  /// Update user
  Future<void> updateUser(User user) async {
    await _userDAO.updateUser(user);
  }

  /// Delete user
  Future<void> deleteUser(String id) async {
    await _userDAO.deleteUser(id);
  }

  /// Check if any users exist
  Future<bool> hasUsers() async {
    final users = await getAllUsers();
    return users.isNotEmpty;
  }

  /// Get active users only
  Future<List<User>> getActiveUsers() async {
    final allUsers = await getAllUsers();
    return allUsers.where((user) => user.isActive).toList();
  }

  /// Deactivate a user
  Future<void> deactivateUser(String id) async {
    final user = await getUserById(id);
    if (user != null) {
      final updatedUser = user.copyWith(isActive: false);
      await updateUser(updatedUser);
    }
  }

  /// Activate a user
  Future<void> activateUser(String id) async {
    final user = await getUserById(id);
    if (user != null) {
      final updatedUser = user.copyWith(isActive: true);
      await updateUser(updatedUser);
    }
  }
}
