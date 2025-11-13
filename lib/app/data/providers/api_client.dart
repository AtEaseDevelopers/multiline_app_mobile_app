import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/api_response.dart';
import '../../core/values/api_constants.dart';
import '../services/storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to requests
          final token = await StorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            try {
              print('🌐 REQUEST[${options.method}] => ${options.uri}');
              print('📦 Headers: ${options.headers}');
              print('📦 Data: ${options.data}');
            } catch (e) {
              // Ignore print errors
            }
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            try {
              print(
                '✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}',
              );
              print('📦 Data: ${response.data}');
            } catch (e) {
              // Ignore print errors
            }
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            try {
              print(
                '❌ ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}',
              );
              print('📦 Error: ${error.message}');
              print('📦 Response: ${error.response?.data}');
            } catch (e) {
              // Ignore print errors
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  /// GET Request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);

      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST Request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    bool isFormData = false,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: isFormData ? FormData.fromMap(data) : data,
        queryParameters: queryParameters,
      );

      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST Request with FormData
  Future<ApiResponse<T>> postFormData<T>(
    String path, {
    required Map<String, dynamic> data,
    T Function(dynamic)? fromJson,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap(data);

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );

      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT Request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE Request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio Errors
  Exception _handleError(DioException error) {
    if (kDebugMode) {
      try {
        print('❌ Detailed Error Type: ${error.type}');
        print('❌ Error Message: ${error.message}');
        print('❌ Error: $error');
      } catch (e) {
        // Ignore print errors (e.g., low disk space)
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Connection timeout. Please try again.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _extractErrorMessage(error.response?.data);

        if (statusCode == 401) {
          return UnauthorizedException(message ?? 'Unauthorized access');
        }

        // Check for server-side disk space issues
        if (statusCode == 500 &&
            (message?.toLowerCase().contains('no space left') == true ||
                message?.toLowerCase().contains('disk') == true ||
                message?.toLowerCase().contains('storage') == true)) {
          return ApiException(
            message:
                'Server storage is full. Please contact administrator or try again later.',
            statusCode: statusCode,
            data: error.response?.data,
          );
        }

        return ApiException(
          message: message ?? 'An error occurred',
          statusCode: statusCode,
          data: error.response?.data,
        );

      case DioExceptionType.cancel:
        return ApiException(message: 'Request cancelled');

      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection. Please check your network settings.\n\n'
          'If you\'re connected to WiFi/Data, the server might be using HTTP instead of HTTPS. '
          'Make sure cleartext traffic is enabled in Android settings.',
        );

      case DioExceptionType.unknown:
        // Check if it's a cleartext traffic error
        if (error.message?.contains('CLEARTEXT') == true ||
            error.message?.contains('cleartext') == true) {
          return NetworkException(
            'HTTP connections are blocked for security. '
            'Please contact support or enable cleartext traffic in app settings.',
          );
        }
        return NetworkException(
          'Network error: ${error.message ?? "Unknown error occurred"}',
        );

      default:
        return NetworkException('Network error occurred: ${error.type}');
    }
  }

  /// Extract error message from response
  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      final message = data['message'] as String?;

      // Check if message contains server disk space errors
      if (message != null) {
        if (message.toLowerCase().contains('no space left on device') ||
            message.toLowerCase().contains('write of') &&
                message.contains('failed')) {
          return 'Server is experiencing storage issues. Please try again later or contact support.';
        }

        // Truncate very long error messages
        if (message.length > 200) {
          return '${message.substring(0, 200)}...';
        }
      }

      return message;
    }

    final stringData = data.toString();

    // Check for disk space errors in string response
    if (stringData.toLowerCase().contains('no space left on device')) {
      return 'Server storage is full. Please contact administrator.';
    }

    // Truncate long error messages
    if (stringData.length > 200) {
      return '${stringData.substring(0, 200)}...';
    }

    return stringData;
  }

  /// Clear headers (useful for logout)
  void clearHeaders() {
    _dio.options.headers.remove('Authorization');
  }
}
