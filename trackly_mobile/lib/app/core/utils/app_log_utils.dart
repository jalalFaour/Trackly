import 'package:flutter/foundation.dart';

abstract class AppLogUtils {
  static void debugLog({String? message}) {
    if (!kDebugMode) {
      // TODO: Send to FirebaseCrashlytics, Sentry
    }

    debugPrint(message);
  }

  static void infoLog({String? message}) {
    if (!kDebugMode) {
      // TODO: Send to FirebaseCrashlytics, Sentry
    }

    debugPrint(message);
  }

  static void errorLog({
    dynamic exception,
    StackTrace? stackTrace,
    String? message,
  }) {
    if (!kDebugMode) {
      // TODO: Send to FirebaseCrashlytics, Sentry
    }

    final output = message ?? exception?.toString() ?? stackTrace?.toString();

    debugPrint(output);
  }
}
