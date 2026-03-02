import 'package:dio/dio.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../shared/models/notification_model.dart';

class NotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  Future<List<NotificationModel>> getNotifications({int perPage = 20}) async {
    try {
      final resp = await _dio.get(ApiEndpoints.notifications, queryParameters: {'per_page': perPage});
      final list = resp.data['data'] as List? ?? [];
      return list.map((j) => NotificationModel.fromJson(j)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final resp = await _dio.get(ApiEndpoints.notificationsUnreadCount);
      return resp.data['count'] ?? 0;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> markAllRead() async {
    try {
      await _dio.post(ApiEndpoints.notificationsMarkAllRead);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> markRead(int id) async {
    try {
      await _dio.post(ApiEndpoints.notificationMarkRead(id));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
