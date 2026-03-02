import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';

class ErrorInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final GoRouter Function() _routerGetter;

  ErrorInterceptor(this._storage, this._routerGetter);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _storage.delete(key: AppConstants.tokenKey);
      try {
        _routerGetter().go('/login');
      } catch (_) {}
    }
    handler.next(err);
  }
}
