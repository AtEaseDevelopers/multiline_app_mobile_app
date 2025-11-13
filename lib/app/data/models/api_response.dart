/// Base API Response Model
class ApiResponse<T> {
  final T? data;
  final String message;
  final bool status;

  ApiResponse({this.data, required this.message, required this.status});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      message: json['message'] ?? '',
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data, 'message': message, 'status': status};
  }

  bool get isSuccess => status;
  bool get isError => !status;
}

/// API Error Model
class ApiError {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiError({required this.message, this.statusCode, this.data});

  @override
  String toString() => message;
}

/// API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => message;
}

/// Network Exception
class NetworkException implements Exception {
  final String message;

  NetworkException([this.message = 'Network error occurred']);

  @override
  String toString() => message;
}

/// Timeout Exception
class TimeoutException implements Exception {
  final String message;

  TimeoutException([this.message = 'Request timeout']);

  @override
  String toString() => message;
}

/// Unauthorized Exception
class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException([this.message = 'Unauthorized access']);

  @override
  String toString() => message;
}
