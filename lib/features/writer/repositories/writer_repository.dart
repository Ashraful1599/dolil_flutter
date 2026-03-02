import 'package:dio/dio.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../shared/models/user_model.dart';

class WriterRepository {
  final Dio _dio;

  WriterRepository(this._dio);

  Future<UserModel> getWriter(int userId) async {
    try {
      final resp = await _dio.get(ApiEndpoints.writerProfile(userId.toString()));
      final data = resp.data['data'] ?? resp.data;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> bookAppointment(int userId, Map<String, dynamic> data) async {
    try {
      await _dio.post(ApiEndpoints.bookAppointment(userId.toString()), data: data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
