/// Platform-specific FFI initialization for web platform
/// Web doesn't support FFI, so this is a no-op
void initializeFfiImpl() {
  // No-op for web platform
  print('⚠️ [SQLite] Web platform - FFI not supported, using InMemoryDatabase');
}
