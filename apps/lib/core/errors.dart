/// Base application exception with optional cause.
class AppException implements Exception {
  final String message;
  final Object? cause;

  AppException(this.message, {this.cause});

  @override
  String toString() => 'AppException: $message${cause != null ? ' ($cause)' : ''}';
}

/// Guards can wrap async operations and translate errors to [AppException].
Future<T> guard<T>(Future<T> Function() op, {String? label}) async {
  try {
    return await op();
  } catch (e) {
    throw AppException(label ?? 'Operation failed', cause: e);
  }
}

