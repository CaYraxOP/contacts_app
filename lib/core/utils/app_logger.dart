import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger._();

  static void d(String message) {
    if (!kDebugMode) return;
    debugPrint('[D] $message');
  }

  static void e(String message, {Object? error, StackTrace? stackTrace}) {
    debugPrint('[E] $message');
    if (error != null) debugPrint('    error: $error');
    if (stackTrace != null) debugPrint('    stack: $stackTrace');
  }
}
