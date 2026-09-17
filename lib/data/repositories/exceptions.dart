class PhoneInUseException implements Exception {
  final String message;
  PhoneInUseException([this.message = 'Phone number already in use']);

  @override
  String toString() => message;
}
