import 'dart:convert';
import 'dart:html' as html;
import '../../domain/models/user.dart';

/// Web-specific User DAO using localStorage
/// Data persists in browser but is lost if user clears browser data
class UserDAOWeb {
  static const String _storageKey = 'credit_app_users';

  /// Get all users from localStorage
  Future<List<User>> getAllUsers() async {
    try {
      final storage = html.window.localStorage;
      final usersJson = storage[_storageKey];
      
      if (usersJson == null || usersJson.isEmpty) {
        print('📤 [UserDAOWeb] No users found in localStorage');
        return [];
      }
      
      final List<dynamic> usersList = jsonDecode(usersJson);
      final users = usersList.map((json) => User.fromMap(json as Map<String, dynamic>)).toList();
      
      print('✅ [UserDAOWeb] Retrieved ${users.length} users from localStorage');
      return users;
    } catch (e) {
      print('❌ [UserDAOWeb] Error fetching users: $e');
      return [];
    }
  }

  /// Add a new user to localStorage
  Future<String> addUser(User user) async {
    try {
      print('📝 [UserDAOWeb] Adding user: ${user.username}');
      
      final users = await getAllUsers();
      users.add(user);
      
      await _saveUsers(users);
      
      print('✅ [UserDAOWeb] User added successfully');
      return user.id;
    } catch (e) {
      print('❌ [UserDAOWeb] Error adding user: $e');
      rethrow;
    }
  }

  /// Get user by username
  Future<User?> getUserByUsername(String username) async {
    try {
      print('🔍 [UserDAOWeb] Fetching user by username: $username');
      
      final users = await getAllUsers();
      final user = users.where((u) => u.username == username).firstOrNull;
      
      return user;
    } catch (e) {
      print('❌ [UserDAOWeb] Error fetching user: $e');
      return null;
    }
  }

  /// Get user by ID
  Future<User?> getUserById(String id) async {
    try {
      print('🔍 [UserDAOWeb] Fetching user by ID: $id');
      
      final users = await getAllUsers();
      final user = users.where((u) => u.id == id).firstOrNull;
      
      return user;
    } catch (e) {
      print('❌ [UserDAOWeb] Error fetching user: $e');
      return null;
    }
  }

  /// Update user
  Future<void> updateUser(User user) async {
    try {
      print('📝 [UserDAOWeb] Updating user: ${user.username}');
      
      final users = await getAllUsers();
      final index = users.indexWhere((u) => u.id == user.id);
      
      if (index != -1) {
        users[index] = user;
        await _saveUsers(users);
        print('✅ [UserDAOWeb] User updated successfully');
      } else {
        print('⚠️ [UserDAOWeb] User not found for update');
      }
    } catch (e) {
      print('❌ [UserDAOWeb] Error updating user: $e');
      rethrow;
    }
  }

  /// Delete user
  Future<void> deleteUser(String id) async {
    try {
      print('🗑️ [UserDAOWeb] Deleting user: $id');
      
      final users = await getAllUsers();
      users.removeWhere((u) => u.id == id);
      
      await _saveUsers(users);
      
      print('✅ [UserDAOWeb] User deleted successfully');
    } catch (e) {
      print('❌ [UserDAOWeb] Error deleting user: $e');
      rethrow;
    }
  }

  /// Save users list to localStorage
  Future<void> _saveUsers(List<User> users) async {
    try {
      final storage = html.window.localStorage;
      final usersJson = jsonEncode(users.map((u) => u.toMap()).toList());
      storage[_storageKey] = usersJson;
    } catch (e) {
      print('❌ [UserDAOWeb] Error saving users: $e');
      rethrow;
    }
  }
}
