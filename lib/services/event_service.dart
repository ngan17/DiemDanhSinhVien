import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class EventService {
  static const String baseUrl = ApiService.baseUrl;

  // 1. Lấy tất cả sự kiện (không cần token)
  static Future<Map<String, dynamic>> getAllEvents({String? status}) async {
    try {
      var uri = Uri.parse('$baseUrl/events');

      // Thêm query parameter nếu có
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

  // 3. Đăng ký sự kiện (cần token)
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

  // 4. Hủy đăng ký
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

  // 5. Lấy danh sách sự kiện đã đăng ký
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

  // 6. Gửi feedback
  static Future<Map<String, dynamic>> submitFeedback({
    required int registeredEventId,
    required String content,
    String? proof,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/feedback'),
        headers: await ApiService.headersWithAuth,
        body: jsonEncode({
          'registeredEventId': registeredEventId,
          'content': content,
          if (proof != null) 'proof': proof,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gửi feedback thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
