import 'package:dio/dio.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../shared/models/location_model.dart';

class LocationRepository {
  final Dio _dio;

  LocationRepository(this._dio);

  List _parseList(dynamic data) {
    if (data is List) return data;
    if (data is Map) return data['data'] ?? data['items'] ?? [];
    return [];
  }

  Future<List<DivisionModel>> getDivisions() async {
    try {
      final resp = await _dio.get(ApiEndpoints.divisions);
      return _parseList(resp.data).map((j) => DivisionModel.fromJson(j)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<DistrictModel>> getDistricts(int divisionId) async {
    try {
      final resp = await _dio.get(ApiEndpoints.districtsByDivision(divisionId.toString()));
      return _parseList(resp.data).map((j) => DistrictModel.fromJson(j)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<UpazilaModel>> getUpazilas(int districtId) async {
    try {
      final resp = await _dio.get(ApiEndpoints.upazilasByDistrict(districtId.toString()));
      return _parseList(resp.data).map((j) => UpazilaModel.fromJson(j)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
