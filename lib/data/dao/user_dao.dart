import 'package:sqflite/sqflite.dart';
import '../../domain/models/user.dart';
import '../database/sqlite_database.dart';

/// Data Access Object for User operations
class UserDAO {
  final SqliteDatabase _db;

  UserDAO(this._db);

  /// Add a new user
  Future<String> addUser(User user) async {
    final db = await _db.database;
    print('📝 [UserDAO] Adding user: ${user.username}');
    
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    print('✅ [UserDAO] User added successfully');
    return user.id;
  }

  /// Get all users
  Future<List<User>> getAllUsers() async {
    try {
      final db = await _db.database;
      print('📤 [UserDAO] Fetching all users');
      
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        orderBy: 'username ASC',
      );
      
      print('✅ [UserDAO] Retrieved ${maps.length} users');
      return List.generate(maps.length, (i) => User.fromMap(maps[i]));
    } catch (e) {
      print('❌ [UserDAO] Error fetching users: $e');
      // Return empty list on error
      return [];
    }
  }

  /// Get user by ID
  Future<User?> getUserById(String id) async {
    final db = await _db.database;
    print('🔍 [UserDAO] Fetching user by ID: $id');
    
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return User.fromMap(maps[0]);
  }

  /// Get user by username
  Future<User?> getUserByUsername(String username) async {
    final db = await _db.database;
    print('🔍 [UserDAO] Fetching user by username: $username');
    
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    
    if (maps.isEmpty) return null;
    return User.fromMap(maps[0]);
  }

  /// Update user
  Future<void> updateUser(User user) async {
    final db = await _db.database;
    print('📝 [UserDAO] Updating user: ${user.username}');
    
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    
    print('✅ [UserDAO] User updated successfully');
  }

  /// Delete user
  Future<void> deleteUser(String id) async {
    final db = await _db.database;
    print('🗑️ [UserDAO] Deleting user: $id');
    
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    print('✅ [UserDAO] User deleted successfully');
  }
}
