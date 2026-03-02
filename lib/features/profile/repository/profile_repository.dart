import 'package:dio/dio.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../shared/models/user_model.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final resp = await _dio.put(ApiEndpoints.profile, data: data);
      return UserModel.fromJson(resp.data['data'] ?? resp.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<UserModel> uploadAvatar(String filePath, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final resp = await _dio.post(ApiEndpoints.avatar, data: formData);
      return UserModel.fromJson(resp.data['data'] ?? resp.data['user'] ?? resp.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getReferrals() async {
    try {
      final resp = await _dio.get(ApiEndpoints.referrals);
      return Map<String, dynamic>.from(resp.data['data'] ?? resp.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
