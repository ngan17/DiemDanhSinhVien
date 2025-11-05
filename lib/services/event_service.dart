import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'local_notification_service.dart';

class EventService {
  static const String baseUrl = ApiService.baseUrl;

  static Future<Map<String, dynamic>> getAllEvents({String? status}) async {
    try {
      var uri = Uri.parse('$baseUrl/events');

      if (status != null) {
        uri = Uri.parse('$baseUrl/events?status=$status');
      }

      final response = await http.get(uri, headers: ApiService.headers);

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

  // 2. Lấy chi tiết sự kiện
  static Future<Map<String, dynamic>> getEventDetail(int eventId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId'),
        headers: ApiService.headers,
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

  static Future<Map<String, dynamic>> registerEvent({
    required int eventDetailId,
    bool? useCertificate,
    bool? requireCertificate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/register'),
        headers: await ApiService.headersWithAuth,
        body: jsonEncode({
          'eventDetailId': eventDetailId,
          if (useCertificate != null) 'useCertificate': useCertificate,
          if (requireCertificate != null)
            'requireCertificate': requireCertificate,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Đặt lịch local notification nếu có thông tin
        if (data['data'] != null && data['data']['localNotification'] != null) {
          final localNotif = data['data']['localNotification'];
          try {
            await LocalNotificationService().scheduleEventReminder(
              id: localNotif['id'],
              title: localNotif['title'],
              body: localNotif['body'],
              scheduledTime: DateTime.parse(localNotif['scheduledTime']),
              payload: localNotif['payload'],
            );
            print('Đã đặt lịch nhắc nhở trước 1 ngày');
          } catch (e) {
            print('Error scheduling notification: $e');
          }
        }

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

  static Future<Map<String, dynamic>> cancelRegistration(
    int registrationId,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/events/register/$registrationId'),
        headers: await ApiService.headersWithAuth,
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

  static Future<Map<String, dynamic>> getMyRegistrations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/my-registrations'),
        headers: await ApiService.headersWithAuth,
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
