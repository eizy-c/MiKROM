import 'package:dio/dio.dart';
import '../errors/network_exception.dart';
import 'server_config.dart';

/// Centralized Dio API Client for MiKROM.
class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: 5000),
        receiveTimeout: const Duration(milliseconds: 5000),
        sendTimeout: const Duration(milliseconds: 5000),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final baseUrl = await ServerConfig.getBaseUrl();
          options.baseUrl = baseUrl;
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          final networkEx = NetworkException.fromDioError(e);
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: networkEx,
              message: networkEx.message,
            ),
          );
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (e.error is NetworkException) {
        throw e.error as NetworkException;
      }
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (e.error is NetworkException) {
        throw e.error as NetworkException;
      }
      throw NetworkException.fromDioError(e);
    }
  }
}
