import 'package:dio/dio.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../shared/models/dolil_model.dart';
import '../../../shared/models/activity_model.dart';

class DolilRepository {
  final Dio _dio;

  DolilRepository(this._dio);

  Future<Map<String, dynamic>> getDolils({
    String? search,
    String? status,
    String? from,
    String? to,
    String? sort = 'created_at',
    String? dir = 'desc',
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final resp = await _dio.get(ApiEndpoints.dolils, queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null) 'status': status,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
        'sort': sort,
        'dir': dir,
        'page': page,
        'per_page': perPage,
      });
      final data = resp.data;
      final list = data['data'] as List? ?? [];
      return {
        'dolils': list.map((j) => DolilModel.fromJson(j)).toList(),
        'total': data['meta']?['total'] ?? data['total'] ?? list.length,
        'last_page': data['meta']?['last_page'] ?? data['last_page'] ?? 1,
        'current_page': data['meta']?['current_page'] ?? data['current_page'] ?? 1,
      };
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<DolilModel> getDolil(int id) async {
    try {
      final resp = await _dio.get(ApiEndpoints.dolil(id));
      return DolilModel.fromJson(resp.data['data'] ?? resp.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<DolilModel> createDolil(Map<String, dynamic> data) async {
    try {
      final resp = await _dio.post(ApiEndpoints.dolils, data: data);
      return DolilModel.fromJson(resp.data['data'] ?? resp.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<DolilModel> updateDolil(int id, Map<String, dynamic> data) async {
    try {
      final resp = await _dio.put(ApiEndpoints.dolil(id), data: data);
      return DolilModel.fromJson(resp.data['data'] ?? resp.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteDolil(int id) async {
    try {
      await _dio.delete(ApiEndpoints.dolil(id));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<ActivityModel>> getActivities(int id) async {
    try {
      final resp = await _dio.get(ApiEndpoints.dolilActivities(id));
      final list = resp.data['data'] as List? ?? resp.data as List? ?? [];
      return list.map((j) => ActivityModel.fromJson(j)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
