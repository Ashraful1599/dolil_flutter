import 'package:dio/dio.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';

class DashboardRepository {
  final Dio _dio;

  DashboardRepository(this._dio);

  Future<Map<String, dynamic>> getStats({String? from, String? to}) async {
    try {
      final resp = await _dio.get(ApiEndpoints.dashboardStats, queryParameters: {
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      });
      return Map<String, dynamic>.from(resp.data['data'] ?? resp.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
