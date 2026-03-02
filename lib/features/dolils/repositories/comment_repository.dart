import 'package:dio/dio.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../shared/models/comment_model.dart';

class CommentRepository {
  final Dio _dio;

  CommentRepository(this._dio);

  Future<List<CommentModel>> getComments(int dolilId) async {
    try {
      final resp = await _dio.get(ApiEndpoints.comments(dolilId));
      final list = resp.data['data'] as List? ?? resp.data as List? ?? [];
      return list.map((j) => CommentModel.fromJson(j)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<CommentModel> addComment(int dolilId, String body, {String? filePath, String? fileName}) async {
    try {
      FormData formData;
      if (filePath != null && fileName != null) {
        formData = FormData.fromMap({
          'body': body,
          'attachment': await MultipartFile.fromFile(filePath, filename: fileName),
        });
      } else {
        formData = FormData.fromMap({'body': body});
      }
      final resp = await _dio.post(ApiEndpoints.comments(dolilId), data: formData);
      return CommentModel.fromJson(resp.data['data'] ?? resp.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteComment(int id) async {
    try {
      await _dio.delete(ApiEndpoints.comment(id));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
