import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

abstract final class AppLogger {
  static void debug(String message, {String? tag}) {
    if (!kDebugMode) {
      return;
    }

    developer.log(message, name: tag ?? 'SmartCourier');
  }

  static void info(String message, {String? tag}) {
    debug(message, tag: tag);
  }

  static void warning(String message, {String? tag}) {
    debug('WARNING: $message', tag: tag);
  }

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) {
      return;
    }

    developer.log(
      message,
      name: tag ?? 'SmartCourier',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
