/// Base class for all application specific exceptions.
abstract class AppException implements Exception {
  final String message;
  final String? prefix;

  AppException(this.message, [this.prefix]);

  @override
  String toString() {
    return "${prefix ?? ''}$message";
  }
}

/// Thrown when there is an issue with the local database.
class AppDatabaseException extends AppException {
  AppDatabaseException(String message)
    : super(message, "Error de Base de Datos: ");
}

/// Thrown when business logic validation fails.
class ValidationException extends AppException {
  ValidationException(String message) : super(message, "Error de Validación: ");
}

/// Thrown when a resource is not found.
class NotFoundException extends AppException {
  NotFoundException(String message) : super(message, "No encontrado: ");
}
