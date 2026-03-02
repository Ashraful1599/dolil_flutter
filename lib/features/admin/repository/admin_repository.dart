import 'package:dio/dio.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/dolil_model.dart';

class AdminRepository {
  final Dio _dio;

  AdminRepository(this._dio);

  Future<Map<String, dynamic>> getStats() async {
    try {
      final resp = await _dio.get(ApiEndpoints.adminStats);
      return Map<String, dynamic>.from(resp.data['data'] ?? resp.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getUsers({String? search, String? role, int page = 1}) async {
    try {
      final resp = await _dio.get(ApiEndpoints.adminUsers, queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (role != null) 'role': role,
        'page': page,
        'per_page': 20,
      });
      final data = resp.data;
      final list = data['data'] as List? ?? [];
      return {
        'users': list.map((j) => UserModel.fromJson(j)).toList(),
        'total': data['meta']?['total'] ?? data['total'] ?? list.length,
        'last_page': data['meta']?['last_page'] ?? data['last_page'] ?? 1,
      };
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<UserModel> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final resp = await _dio.put(ApiEndpoints.adminUser(id), data: data);
      return UserModel.fromJson(resp.data['data'] ?? resp.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getDolils({String? search, String? status, int page = 1}) async {
    try {
      final resp = await _dio.get(ApiEndpoints.adminDolils, queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null) 'status': status,
        'page': page,
        'per_page': 20,
      });
      final data = resp.data;
      final list = data['data'] as List? ?? [];
      return {
        'dolils': list.map((j) => DolilModel.fromJson(j)).toList(),
        'total': data['meta']?['total'] ?? data['total'] ?? list.length,
        'last_page': data['meta']?['last_page'] ?? data['last_page'] ?? 1,
      };
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
