import 'package:dio/dio.dart';
import 'package:diem_danh_sinh_vien/services/auth_service.dart';

class ApiInterceptor extends Interceptor {
  final AuthService _authService;

  ApiInterceptor(this._authService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _authService.getStoredToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err, // Thay đổi từ DioError sang DioException
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _authService.refreshToken();
      if (refreshed) {
        final token = await _authService.getStoredToken();
        if (token != null) {
          // Tạo một Dio instance mới để tránh vòng lặp vô hạn
          final dio = Dio();
          final options = Options(
            headers: {
              ...err.requestOptions.headers,
              'Authorization': 'Bearer $token',
            },
          );
          final response = await dio.request(
            err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
            options: options,
          );
          return handler.resolve(response);
        }
      }
      await _authService.logout();
    }
    return handler.next(err);
  }
}
