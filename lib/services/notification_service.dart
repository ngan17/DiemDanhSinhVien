import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class NotificationService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Lấy danh sách thông báo
  static Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await ApiService.makeAuthenticatedRequest(() async {
        return await http.get(
          Uri.parse('$baseUrl/notifications?page=$page&perPage=$perPage'),
          headers: await ApiService.headersWithAuth,
        );
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Phiên đăng nhập đã hết hạn',
          'requireLogin': true,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể tải danh sách thông báo',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Xóa thông báo
  static Future<Map<String, dynamic>> deleteNotification(int id) async {
    try {
      final response = await ApiService.makeAuthenticatedRequest(() async {
        return await http.delete(
          Uri.parse('$baseUrl/notifications/$id'),
          headers: await ApiService.headersWithAuth,
        );
      });

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Đã xóa thông báo'};
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Phiên đăng nhập đã hết hạn',
          'requireLogin': true,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể xóa thông báo',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Đánh dấu đã đọc
  static Future<Map<String, dynamic>> markAsRead(int id) async {
    try {
      final response = await ApiService.makeAuthenticatedRequest(() async {
        return await http.put(
          Uri.parse('$baseUrl/notifications/$id/read'),
          headers: await ApiService.headersWithAuth,
        );
      });

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Đã đánh dấu đã đọc'};
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Phiên đăng nhập đã hết hạn',
          'requireLogin': true,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể đánh dấu đã đọc',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

 
  static Future<Map<String, dynamic>> saveFcmToken(
    String token,
    String accessToken,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/fcm-token'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'fcmToken': token}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Đã lưu FCM token'};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể lưu FCM token',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
