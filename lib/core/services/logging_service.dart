import 'package:flutter/foundation.dart';

/// Servicio centralizado para el manejo de logs en la aplicación.
/// Permite capturar errores y eventos de manera estandarizada.
class LoggingService {
  static void info(String message) {
    debugPrint('[INFO] $message');
  }

  static void warning(String message) {
    debugPrint('[WARNING] $message');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[ERROR] $message');
    if (error != null) {
      debugPrint('Details: $error');
    }
    if (stackTrace != null) {
      debugPrint('Stacktrace: $stackTrace');
    }

    // Aquí se podría integrar con Sentry o Firebase Crashlytics en el futuro.
  }
}
