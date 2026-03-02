import 'package:dio/dio.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../shared/models/review_model.dart';

class ReviewRepository {
  final Dio _dio;

  ReviewRepository(this._dio);

  Future<List<ReviewModel>> getReviews(int dolilId) async {
    try {
      final resp = await _dio.get(ApiEndpoints.reviews(dolilId));
      final list = resp.data['data'] as List? ?? resp.data as List? ?? [];
      return list.map((j) => ReviewModel.fromJson(j)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ReviewModel> addReview(int dolilId, int rating, String? comment) async {
    try {
      final resp = await _dio.post(ApiEndpoints.reviews(dolilId), data: {
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      });
      return ReviewModel.fromJson(resp.data['data'] ?? resp.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
