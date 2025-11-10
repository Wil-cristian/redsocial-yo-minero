class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({String? message, super.originalError})
      : super(
          message: message ?? 'Error de conexión. Verifica tu internet.',
          code: 'NETWORK_ERROR',
        );
}

class AuthException extends AppException {
  AuthException({String? message, super.originalError})
      : super(
          message: message ?? 'Error de autenticación',
          code: 'AUTH_ERROR',
        );
}

class DatabaseException extends AppException {
  DatabaseException({String? message, super.originalError})
      : super(
          message: message ?? 'Error al acceder a la base de datos',
          code: 'DATABASE_ERROR',
        );
}

class ValidationException extends AppException {
  ValidationException({required super.message})
      : super(
          code: 'VALIDATION_ERROR',
        );
}

class NotFoundException extends AppException {
  NotFoundException({String? message})
      : super(
          message: message ?? 'Recurso no encontrado',
          code: 'NOT_FOUND',
        );
}
