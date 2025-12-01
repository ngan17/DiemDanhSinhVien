import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

class AttendantService {
  static const String baseUrl = AppConfig.baseUrl;

  static Future<List<Map<String, dynamic>>> getEvents({String? status}) async {
    try {
      String url = '$baseUrl/events?per_page=100';
      if (status != null && status != 'all') {
        url += '&status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: AuthService.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final events = List<Map<String, dynamic>>.from(data['data'] ?? []);
        return events;
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      print('Error fetching events: $e');
      rethrow;
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

  static Future<Map<String, dynamic>> attendByBarcode({
    required int eventDetailId,
    required String barcode,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Phiên đăng nhập hết hạn'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/support-attendance/attend'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'eventDetailId': eventDetailId, 'barcode': barcode}),
      );

      print('Attend by barcode response status: ${response.statusCode}');
      print('Attend by barcode response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Điểm danh thành công',
          'studentId': data['studentId'],
          'studentName': data['studentName'],
          'eventName': data['eventName'],
          'session': data['session'],
          'attendanceId': data['attendanceId'],
          'attendTime': data['attendTime'],
          'attendanceProgress': data['attendanceProgress'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Điểm danh thất bại',
          'studentId': data['studentId'],
          'studentName': data['studentName'],
          'attendTime': data['attendTime'],
        };
      }
    } catch (e) {
      print('Error attending by barcode: $e');
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }
}
