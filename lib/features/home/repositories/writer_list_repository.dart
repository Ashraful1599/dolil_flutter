import 'package:dio/dio.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../shared/models/user_model.dart';

class WriterListRepository {
  final Dio _dio;

  WriterListRepository(this._dio);

  Future<Map<String, dynamic>> getWriters({
    String? search,
    int? divisionId,
    int? districtId,
    int? upazilaId,
    int page = 1,
  }) async {
    try {
      final resp = await _dio.get(ApiEndpoints.dolilWriters, queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (divisionId != null) 'division_id': divisionId,
        if (districtId != null) 'district_id': districtId,
        if (upazilaId != null) 'upazila_id': upazilaId,
        'page': page,
        'per_page': 12,
      });
      final data = resp.data;
      final list = data['data'] as List? ?? [];
      return {
        'writers': list.map((j) => UserModel.fromJson(j)).toList(),
        'total': data['meta']?['total'] ?? data['total'] ?? list.length,
        'last_page': data['meta']?['last_page'] ?? data['last_page'] ?? 1,
        'current_page': data['meta']?['current_page'] ?? data['current_page'] ?? 1,
      };
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
