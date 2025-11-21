import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class AuthService {
  static const String baseUrl = AppConfig.baseUrl;
  static bool _isRefreshing = false;

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  static Future<void> removeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Map<String, String>> get headersWithAuth async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: headers,
        body: jsonEncode({
          'identifier': identifier,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['access_token'] != null && data['access_token'] is String) {
          await saveToken(data['access_token'].toString());
        }
        if (data['user'] != null && data['student'] != null) {
          await saveUserData({
            'user': {
              'id': data['user']?['id'],
              'email': data['user']?['email'],
              'role': data['user']?['role'],
            },
            'student': {
              'id': data['student']?['id'],
              'studentName': data['student']?['studentName'],
              'classId': data['student']?['classId'],
            },
          });
        }
        return {
          'success': true,
          'data': data,
          'message': 'Đăng nhập thành công',
        };
      } else {
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

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/get-profile'),
        headers: await headersWithAuth,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['access_token'] != null) {
          await saveToken(data['access_token']);
        }
        if (data['user'] != null && data['student'] != null) {
          await saveUserData({
            'user': {
              'id': data['user']?['id'],
              'email': data['user']?['email'],
              'role': data['user']?['role'],
            },
            'student': {
              'id': data['student']?['id'],
              'studentName': data['student']?['studentName'],
              'classId': data['student']?['classId'],
            },
          });
        }
        return {
          'success': true,
          'data': data,
          'message': 'Lấy thông tin thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Lấy thông tin thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
static Future<Map<String, dynamic>> changePassword({
  required String currentPassword,
  required String newPassword,
  required String newPasswordConfirmation,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/change-password'), // Đường dẫn API
      headers: await headersWithAuth, // Headers có chứa token
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'newPassword_confirmation': newPasswordConfirmation,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'message': data['message'] ?? 'Đổi mật khẩu thành công',
      };
    } else if (response.statusCode == 400 || response.statusCode == 422) {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'Dữ liệu không hợp lệ',
        'errors': data['errors'] ?? {},
      };
    } else if (response.statusCode == 401) {
      return {
        'success': false,
        'message': 'Vui lòng đăng nhập lại',
      };
    } else {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'Đổi mật khẩu thất bại',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Không thể kết nối đến server: $e',
    };
  }
}
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
      }
    } catch (e) {
      try {
        await removeToken();
        await removeUserData();
      } catch (_) {}
      return {'success': true, 'message': 'Đăng xuất thành công'};
    }
  }


  static Future<http.Response> makeAuthenticatedRequest(
    Future<http.Response> Function() request,
  ) async {
    var response = await request();

    if (response.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        final refreshResult = await refreshToken();

        if (refreshResult['success'] == true) {
       
          response = await request();
        } else {

          await removeToken();
          await removeUserData();
        }
      } catch (e) {
        await removeToken();
        await removeUserData();
      } finally {
        _isRefreshing = false;
      }
    }

    return response;
  }
}
