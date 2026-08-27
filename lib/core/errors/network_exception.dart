import 'package:dio/dio.dart';

/// Structured network exception for MiKROM HTTP layer.
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  NetworkException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  factory NetworkException.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Tiempo de espera agotado al conectar con el router.',
          originalError: dioError,
        );
      case DioExceptionType.badResponse:
        final status = dioError.response?.statusCode;
        final data = dioError.response?.data;
        String errMsg = 'Error del servidor ($status)';
        if (data is Map && data.containsKey('detail')) {
          errMsg = data['detail'].toString();
        } else if (data is Map && data.containsKey('message')) {
          errMsg = data['message'].toString();
        }
        return NetworkException(
          message: errMsg,
          statusCode: status,
          originalError: dioError,
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'No se pudo conectar con el servidor local del router. Verifica la IP y el puerto.',
          originalError: dioError,
        );
      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Operación cancelada.',
          originalError: dioError,
        );
      default:
        return NetworkException(
          message: 'Error inesperado de comunicación de red: ${dioError.message}',
          originalError: dioError,
        );
    }
  }

  @override
  String toString() => message;
}
