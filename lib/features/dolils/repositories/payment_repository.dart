import 'package:dio/dio.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../shared/models/payment_model.dart';

class PaymentRepository {
  final Dio _dio;

  PaymentRepository(this._dio);

  Future<List<PaymentModel>> getPayments(int dolilId) async {
    try {
      final resp = await _dio.get(ApiEndpoints.payments(dolilId));
      final list = resp.data['data'] as List? ?? resp.data as List? ?? [];
      return list.map((j) => PaymentModel.fromJson(j)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<PaymentModel> addPayment(int dolilId, Map<String, dynamic> data) async {
    try {
      final resp = await _dio.post(ApiEndpoints.payments(dolilId), data: data);
      return PaymentModel.fromJson(resp.data['data'] ?? resp.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deletePayment(int id) async {
    try {
      await _dio.delete(ApiEndpoints.payment(id));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
