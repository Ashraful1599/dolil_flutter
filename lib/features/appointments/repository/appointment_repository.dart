import 'package:dio/dio.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../shared/models/appointment_model.dart';

class AppointmentRepository {
  final Dio _dio;

  AppointmentRepository(this._dio);

  Future<List<AppointmentModel>> getAppointments({String? status}) async {
    try {
      final resp = await _dio.get(ApiEndpoints.appointments, queryParameters: {
        if (status != null) 'status': status,
      });
      final list = resp.data['data'] as List? ?? [];
      return list.map((j) => AppointmentModel.fromJson(j)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<AppointmentModel> updateAppointment(int id, String status) async {
    try {
      final resp = await _dio.patch(ApiEndpoints.appointment(id), data: {'status': status});
      return AppointmentModel.fromJson(resp.data['data'] ?? resp.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
