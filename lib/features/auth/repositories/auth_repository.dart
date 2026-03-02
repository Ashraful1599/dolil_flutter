import 'package:dio/dio.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/phone_normalizer.dart';
import '../../../shared/models/user_model.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final resp = await _dio.post(ApiEndpoints.login, data: {
        'login': PhoneNormalizer.normalize(identifier),
        'password': password,
      });
      return resp.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final resp = await _dio.post(ApiEndpoints.register, data: data);
      return resp.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<UserModel> getUser() async {
    try {
      final resp = await _dio.get(ApiEndpoints.user);
      final data = resp.data['data'] ?? resp.data;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> lookupAccount(String identifier) async {
    try {
      final resp = await _dio.post(ApiEndpoints.lookupAccount, data: {
        'identifier': PhoneNormalizer.normalize(identifier),
      });
      return resp.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> sendResetOtp(String identifier, String method) async {
    try {
      await _dio.post(ApiEndpoints.sendResetOtp, data: {
        'identifier': PhoneNormalizer.normalize(identifier),
        'method': method,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> verifyResetOtp(String identifier, String otp) async {
    try {
      final resp = await _dio.post(ApiEndpoints.verifyResetOtp, data: {
        'identifier': PhoneNormalizer.normalize(identifier),
        'otp': otp,
      });
      return resp.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> resetPassword(String token, String password, String passwordConfirmation) async {
    try {
      await _dio.post(ApiEndpoints.resetPassword, data: {
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> resendVerification() async {
    try {
      await _dio.post(ApiEndpoints.resendVerification);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> resendByEmail(String email) async {
    try {
      await _dio.post(ApiEndpoints.resendByEmail, data: {'email': email});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> sendPhoneOtp() async {
    try {
      await _dio.post(ApiEndpoints.sendPhoneOtp);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> verifyPhone(String otp) async {
    try {
      await _dio.post(ApiEndpoints.verifyPhone, data: {'otp': otp});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
