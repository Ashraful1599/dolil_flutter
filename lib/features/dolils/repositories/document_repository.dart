import 'package:dio/dio.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../shared/models/document_model.dart';

class DocumentRepository {
  final Dio _dio;

  DocumentRepository(this._dio);

  Future<List<DocumentModel>> getDocuments(int dolilId) async {
    try {
      final resp = await _dio.get(ApiEndpoints.documents(dolilId));
      final list = resp.data['data'] as List? ?? resp.data as List? ?? [];
      return list.map((j) => DocumentModel.fromJson(j)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<DocumentModel> uploadDocument(int dolilId, String filePath, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final resp = await _dio.post(ApiEndpoints.documents(dolilId), data: formData);
      return DocumentModel.fromJson(resp.data['data'] ?? resp.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteDocument(int id) async {
    try {
      await _dio.delete(ApiEndpoints.document(id));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<int>> downloadDocument(int id) async {
    try {
      final resp = await _dio.get(ApiEndpoints.documentDownload(id), options: Options(responseType: ResponseType.bytes));
      return resp.data as List<int>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
