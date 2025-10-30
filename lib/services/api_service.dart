import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Thay đổi URL này theo địa chỉ backend của bạn
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  // Nếu test trên thiết bị thật: 'http://YOUR_IP:8000/api'
  // Nếu test trên Android Emulator: 'http://10.0.2.2:8000/api'

  // Lưu token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  // Lấy token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Xóa token
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  // Lưu thông tin user
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  // Lấy thông tin user
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  // Xóa thông tin user
  static Future<void> removeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  // Headers mặc định
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers có token
  static Future<Map<String, String>> get headersWithAuth async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 1. Login
  static Future<Map<String, dynamic>> login({
    required String identifier, // Thay đổi từ email sang identifier
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: headers,
        body: jsonEncode({
          'identifier': identifier, // Gửi identifier thay vì email
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Lưu token
        if (data['access_token'] != null && data['access_token'] is String) {
          await saveToken(data['access_token'].toString());
        }
        // Lưu thông tin user + profile
        if (data['user'] != null || data['profile'] != null) {
          await saveUserData({
            'user': data['user'],
            'profile': data['profile'],
            'email': data['user']?['email'],
            'user_code': data['user']?['user_code'], // Lưu user_code
            'role': data['user']?['role'],
          });
        }
        return {
          'success': true,
          'data': data,
          'message': 'Đăng nhập thành công',
        };
      } else {
        // Parse error response safely
        try {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message']?.toString() ?? 'Đăng nhập thất bại',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Đăng nhập thất bại (${response.statusCode})',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message':
            'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.',
      };
    }
  }

  // 2. Create User
  static Future<Map<String, dynamic>> createUser({
    required List<Map<String, dynamic>> users,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/create-user'),
        headers: await headersWithAuth,
        body: jsonEncode({'users': users}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Tạo tài khoản thất bại',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // 3. Send OTP Code
  static Future<Map<String, dynamic>> sendCode({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-code'),
        headers: headers,
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return {
            'success': true,
            'message': data['message']?.toString() ?? 'Mã OTP đã được gửi',
          };
        } catch (e) {
          return {'success': true, 'message': 'Mã OTP đã được gửi'};
        }
      } else if (response.statusCode == 500) {
        // Backend error - likely missing email template
        return {
          'success': false,
          'message': 'Backend chưa cấu hình email. Vui lòng liên hệ admin.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Email không tồn tại trong hệ thống',
        };
      } else {
        try {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message']?.toString() ?? 'Gửi mã thất bại',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Gửi mã thất bại (${response.statusCode})',
          };
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  // 4. Verify OTP Code
  static Future<Map<String, dynamic>> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-code'),
        headers: headers,
        body: jsonEncode({'email': email, 'code': code}),
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return {
            'success': true,
            'message': data['message']?.toString() ?? 'Xác thực thành công',
          };
        } catch (e) {
          return {'success': true, 'message': 'Xác thực thành công'};
        }
      } else {
        try {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message']?.toString() ?? 'Mã xác nhận không đúng',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Xác thực thất bại (${response.statusCode})',
          };
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  // 5. Reset Password
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: headers,
        body: jsonEncode({
          'email': email,
          'code': code,
          'newPassword': newPassword,
          'newPassword_confirmation': newPasswordConfirmation,
        }),
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return {
            'success': true,
            'message': data['message']?.toString() ?? 'Đổi mật khẩu thành công',
          };
        } catch (e) {
          return {'success': true, 'message': 'Đổi mật khẩu thành công'};
        }
      } else {
        try {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message']?.toString() ?? 'Đổi mật khẩu thất bại',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Đổi mật khẩu thất bại (${response.statusCode})',
          };
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  // 6. Refresh Token
  static Future<Map<String, dynamic>> refreshToken() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: await headersWithAuth,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['access_token'] != null) {
          await saveToken(data['access_token']);
        }
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Refresh token thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // 7. Logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: await headersWithAuth,
      );

      if (response.statusCode == 200) {
        await removeToken();
        await removeUserData();
        try {
          final data = jsonDecode(response.body);
          return {
            'success': true,
            'message': data['message']?.toString() ?? 'Đăng xuất thành công',
          };
        } catch (e) {
          return {'success': true, 'message': 'Đăng xuất thành công'};
        }
      } else {
        // Even if API fails, remove token locally
        await removeToken();
        await removeUserData();
        try {
          final data = jsonDecode(response.body);
          return {
            'success': true, // Still success because token removed
            'message': data['message']?.toString() ?? 'Đăng xuất thành công',
          };
        } catch (e) {
          return {'success': true, 'message': 'Đăng xuất thành công'};
        }
      }
    } catch (e) {
      // Even if exception, try to remove token
      try {
        await removeToken();
        await removeUserData();
      } catch (_) {}
      return {'success': true, 'message': 'Đăng xuất thành công'};
    }
  }
}
