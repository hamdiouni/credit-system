import '../../domain/models/user.dart';

/// Stub for UserRepositoryWeb on non-web platforms
/// This file is used when compiling for mobile/desktop
class UserRepositoryWeb {
  UserRepositoryWeb() {
    throw UnsupportedError('UserRepositoryWeb is only available on web platform');
  }

  Future<List<User>> getAllUsers() async {
    throw UnsupportedError('UserRepositoryWeb is only available on web platform');
  }

  Future<User?> getUserById(String id) async {
    throw UnsupportedError('UserRepositoryWeb is only available on web platform');
  }

  Future<User?> getUserByUsername(String username) async {
    throw UnsupportedError('UserRepositoryWeb is only available on web platform');
  }

  Future<String> createUser(User user) async {
    throw UnsupportedError('UserRepositoryWeb is only available on web platform');
  }

  Future<String> addUser(User user) async {
    throw UnsupportedError('UserRepositoryWeb is only available on web platform');
  }

  Future<void> updateUser(User user) async {
    throw UnsupportedError('UserRepositoryWeb is only available on web platform');
  }

  Future<void> deleteUser(String id) async {
    throw UnsupportedError('UserRepositoryWeb is only available on web platform');
  }

  Future<bool> hasUsers() async {
    throw UnsupportedError('UserRepositoryWeb is only available on web platform');
  }

  Future<List<User>> getActiveUsers() async {
    throw UnsupportedError('UserRepositoryWeb is only available on web platform');
  }

  Future<void> deactivateUser(String id) async {
    throw UnsupportedError('UserRepositoryWeb is only available on web platform');
  }

  Future<void> activateUser(String id) async {
    throw UnsupportedError('UserRepositoryWeb is only available on web platform');
  }
}
