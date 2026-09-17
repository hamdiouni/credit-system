import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Platform-specific FFI initialization for non-web platforms
void initializeFfiImpl() {
  // Initialize FFI for desktop platforms (Windows, macOS, Linux)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    print('🔧 [SQLite] FFI initialized for desktop platform');
  }
}
