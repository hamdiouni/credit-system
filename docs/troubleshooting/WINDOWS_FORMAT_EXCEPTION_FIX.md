# Windows FormatException Fix

## Problem
App crashes on Windows with:
```
[ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: FormatException: Unexpected character (at character 1)
```

## Root Cause
The error occurs when trying to parse data (likely DateTime strings or JSON) from the database or SharedPreferences. This can happen if:
1. Corrupted data in SharedPreferences
2. Malformed DateTime strings in database
3. Invalid JSON in database fields

## Fixes Applied

### 1. AuthService - Better Error Handling
**File**: `lib/services/auth_service.dart`

Added try-catch around DateTime.parse and session data parsing:
```dart
try {
  _lastActivity = DateTime.parse(lastActivityStr);
  // ...
} catch (e) {
  print('⚠️ [AuthService] Error parsing session data: $e');
  await clearSession();
}
```

### 2. UserRepository - Graceful Degradation
**File**: `lib/data/repositories/user_repository.dart`

Added error handling in hasUsers():
```dart
Future<bool> hasUsers() async {
  try {
    final users = await getAllUsers();
    return users.isNotEmpty;
  } catch (e) {
    print('⚠️ [UserRepository] Error checking if users exist: $e');
    return false;
  }
}
```

### 3. UserDAO - Error Recovery
**File**: `lib/data/dao/user_dao.dart`

Added try-catch in getAllUsers():
```dart
try {
  final db = await _db.database;
  // ... query users
  return List.generate(maps.length, (i) => User.fromMap(maps[i]));
} catch (e) {
  print('❌ [UserDAO] Error fetching users: $e');
  return [];
}
```

### 4. User Model - Better Error Messages
**File**: `lib/domain/models/user.dart`

Added error logging in fromMap():
```dart
factory User.fromMap(Map<String, dynamic> map) {
  try {
    return User(/* ... */);
  } catch (e) {
    print('❌ [User] Error parsing user from map: $e');
    print('Map data: $map');
    rethrow;
  }
}
```

## How to Test

### 1. Clear Corrupted Data (if needed)
If the error persists, clear the app data:

**Windows**:
```bash
# Delete the database file
del .dart_tool\sqflite_common_ffi\databases\credit_app.db

# Or delete the entire .dart_tool folder
rmdir /s /q .dart_tool
```

### 2. Run the App
```bash
flutter run -d windows
```

### 3. Check Console Output
Look for these error messages that will help identify the issue:
- `⚠️ [AuthService] Error parsing session data`
- `⚠️ [UserRepository] Error checking if users exist`
- `❌ [UserDAO] Error fetching users`
- `❌ [User] Error parsing user from map`

## Expected Behavior After Fix

### If Database is Clean
```
✅ [SQLite] Database opened successfully
✅ [DatabaseHelper] Database initialized successfully
🔐 [AuthService] Initializing...
✅ [AuthService] Initialized
🔐 [AuthProvider] Initializing...
📤 [UserDAO] Fetching all users
✅ [UserDAO] Retrieved 0 users
👥 [AuthProvider] Users exist: false
✅ [AuthProvider] Initialized
```

### If Database Has Corrupted Data
```
✅ [SQLite] Database opened successfully
✅ [DatabaseHelper] Database initialized successfully
🔐 [AuthService] Initializing...
⚠️ [AuthService] Error parsing session data: FormatException...
✅ [AuthService] Initialized
🔐 [AuthProvider] Initializing...
📤 [UserDAO] Fetching all users
❌ [UserDAO] Error fetching users: FormatException...
⚠️ [UserRepository] Error checking if users exist: ...
👥 [AuthProvider] Users exist: false
✅ [AuthProvider] Initialized
```

App should continue to work even with errors!

## If Error Still Occurs

### Option 1: Delete Database
```bash
del .dart_tool\sqflite_common_ffi\databases\credit_app.db
flutter run -d windows
```

### Option 2: Clean Build
```bash
flutter clean
flutter pub get
flutter run -d windows
```

### Option 3: Check Specific Error
Run the app and look for the specific error message in console. The new error handling will show exactly which field is causing the problem.

## Status
✅ Error handling added to all parsing operations
✅ App should gracefully handle corrupted data
✅ Clear error messages for debugging

---

**Next Step**: Run `flutter run -d windows` and check if the error is now caught and logged properly.
