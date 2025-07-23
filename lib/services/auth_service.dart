import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart' as prefs;

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Key để lưu token trong SharedPreferences
  static const String TOKEN_KEY = 'auth_token';
  static const String REFRESH_TOKEN_KEY = 'refresh_token';
  static const String USER_KEY = 'user_data';

  Future<bool> login(String maNguoiDung, String matKhau) async {
    try {
      print('Đang đăng nhập với MaNguoiDung: $maNguoiDung');

      // Gọi Edge Function để đăng nhập
      final response = await _client.functions.invoke(
        'login_postUser',
        body: {'MaNguoiDung': maNguoiDung, 'MatKhau': matKhau},
      );

      print('Response status: ${response.status}');
      print('Response data type: ${response.data.runtimeType}');
      print('Response data: ${response.data}');

      if (response.status != 200) {
        // Parse response data properly
        Map<String, dynamic> errorData;
        if (response.data is String) {
          errorData = jsonDecode(response.data);
        } else {
          errorData = response.data as Map<String, dynamic>;
        }

        final error = errorData['error'] ?? 'Lỗi không xác định';
        throw Exception(error);
      }

      // Parse response data properly
      Map<String, dynamic> data;
      if (response.data is String) {
        data = jsonDecode(response.data);
      } else {
        data = response.data as Map<String, dynamic>;
      }

      final token = data['token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      final user = data['user'] as Map<String, dynamic>?;

      if (token == null || refreshToken == null) {
        throw Exception('Không nhận được token từ server');
      }

      // Lưu token vào SharedPreferences
      final sharedPrefs = await prefs.SharedPreferences.getInstance();
      await sharedPrefs.setString(TOKEN_KEY, token);
      await sharedPrefs.setString(REFRESH_TOKEN_KEY, refreshToken);

      // Lưu thông tin user
      if (user != null) {
        await sharedPrefs.setString(USER_KEY, jsonEncode(user));
      }

      print('Đăng nhập thành công!');
      return true;
    } catch (e) {
      print('Lỗi đăng nhập chi tiết: $e');
      return false;
    }
  }

  // Lấy token đã lưu
  Future<String?> getStoredToken() async {
    try {
      final sharedPrefs = await prefs.SharedPreferences.getInstance();
      return sharedPrefs.getString(TOKEN_KEY);
    } catch (e) {
      print('Lỗi lấy token: $e');
      return null;
    }
  }

  // Lấy thông tin user đã lưu
  Future<Map<String, dynamic>?> getStoredUser() async {
    try {
      final sharedPrefs = await prefs.SharedPreferences.getInstance();
      final userString = sharedPrefs.getString(USER_KEY);
      if (userString != null) {
        return jsonDecode(userString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Lỗi lấy user data: $e');
      return null;
    }
  }

  // Kiểm tra xem đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    final token = await getStoredToken();
    return token != null && token.isNotEmpty;
  }

  // Refresh token (với token tự tạo, có thể return true luôn)
  Future<bool> refreshToken() async {
    try {
      final token = await getStoredToken();
      if (token != null && token.isNotEmpty) {
        // Với token tự tạo, kiểm tra expiry time
        final tokenData = jsonDecode(
          String.fromCharCodes(base64.decode(token)),
        );
        final exp = tokenData['exp'] as int?;

        if (exp != null && exp > DateTime.now().millisecondsSinceEpoch) {
          return true; // Token còn hạn
        }
      }
      return false;
    } catch (e) {
      print('Lỗi refresh token: $e');
      return false;
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    try {
      // Xóa token khỏi SharedPreferences
      final sharedPrefs = await prefs.SharedPreferences.getInstance();
      await sharedPrefs.remove(TOKEN_KEY);
      await sharedPrefs.remove(REFRESH_TOKEN_KEY);
      await sharedPrefs.remove(USER_KEY);

      print('Đăng xuất thành công');
    } catch (e) {
      print('Lỗi đăng xuất: $e');
    }
  }
}
