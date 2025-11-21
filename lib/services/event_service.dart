import 'dart:convert';
import 'package:diem_danh_sinh_vien/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class EventService {
  static const String baseUrl = AppConfig.baseUrl;

  static Future<Map<String, dynamic>> getAllEvents({String? status}) async {
    try {
      var uri = Uri.parse('$baseUrl/events');

      if (status != null) {
        uri = Uri.parse('$baseUrl/events?status=$status');
      }

      final response = await http.get(uri, headers: AuthService.headers);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data'], 'total': data['total']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Lỗi khi lấy danh sách sự kiện',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Lấy chi tiết sự kiện
  static Future<Map<String, dynamic>> getEventDetail(int eventId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId'),
        headers: AuthService.headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không tìm thấy sự kiện',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Đăng ký sự kiện
  static Future<Map<String, dynamic>> registerEvent({
    required int eventDetailId,
    bool? useCertificate,
    bool? requireCertificate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/register'),
        headers: await AuthService.headersWithAuth,
        body: jsonEncode({
          'eventDetailId': eventDetailId,
          if (useCertificate != null) 'useCertificate': useCertificate,
          if (requireCertificate != null)
            'requireCertificate': requireCertificate,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Thông báo nhắc nhở trước 1 ngày sẽ được xử lý bởi server
        // Server sẽ gửi FCM notification vào đúng thời điểm
        print('Đăng ký thành công. Server sẽ gửi thông báo nhắc nhở.');

        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng ký thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Hủy đăng ký sự kiện
  static Future<Map<String, dynamic>> cancelRegistration(
    int registrationId,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/events/register/$registrationId'),
        headers: await AuthService.headersWithAuth,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Hủy đăng ký thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Lấy danh sách sự kiện đã đăng ký
  static Future<Map<String, dynamic>> getMyRegistrations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/my-registrations'),
        headers: await AuthService.headersWithAuth,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data'], 'total': data['total']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Lỗi khi lấy danh sách',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
