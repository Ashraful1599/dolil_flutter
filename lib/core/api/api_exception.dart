class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiException({required this.message, this.statusCode, this.errors});

  @override
  String toString() => 'ApiException($statusCode): $message';

  factory ApiException.fromDioError(dynamic error) {
    if (error?.response != null) {
      final data = error.response!.data;
      final msg = data is Map ? (data['message'] ?? 'An error occurred') : 'An error occurred';
      Map<String, dynamic>? errs;
      if (data is Map && data['errors'] != null) {
        errs = Map<String, dynamic>.from(data['errors']);
      }
      return ApiException(
        message: msg.toString(),
        statusCode: error.response!.statusCode,
        errors: errs,
      );
    }
    return const ApiException(message: 'Network error. Please check your connection.');
  }
}
