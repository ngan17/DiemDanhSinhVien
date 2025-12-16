import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
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
      print(' Gọi API getEventDetail với eventId: $eventId');
      print(' URL: $baseUrl/events/$eventId');

      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId'),
        headers: await AuthService.headersWithAuth,
      );

      print(' Status code: ${response.statusCode}');
      print(' Response body: ${response.body}');

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
      print(' Lỗi getEventDetail: $e');
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
      print(' Canceling registration: $registrationId');

      final response = await http.delete(
        Uri.parse('$baseUrl/events/register/$registrationId'),
        headers: await AuthService.headersWithAuth,
      );

      print(' Cancel response status: ${response.statusCode}');
      print(' Cancel response body: ${response.body}');

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
      print(' Cancel error: $e');
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Lấy danh sách sự kiện đã đăng ký với phân trang
  static Future<Map<String, dynamic>> getMyRegistrations({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/events/my-registrations?page=$page&per_page=$perPage',
        ),
        headers: await AuthService.headersWithAuth,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
          'pagination': data['pagination'],
        };
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

  /// Kiểm tra điều kiện điểm danh
  /// GET /api/events/attendance/check/{eventDetailId}
  static Future<Map<String, dynamic>> checkAttendanceEligibility(
    int eventDetailId,
  ) async {
    try {
      print(' Checking attendance eligibility for event: $eventDetailId');

      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Chưa đăng nhập'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/events/attendance/check/$eventDetailId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print(' Check attendance status: ${response.statusCode}');
      print(' Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final canAttend = data['canAttend'] ?? false;

        if (canAttend) {
          final methods = data['attendanceMethods'] ?? {};

          final convertedMethods = {
            'face': methods['camera_student'] ?? 0,
            'proof': methods['proof'] ?? 0,
            'barcode': methods['barcode'] ?? 0,
            'camera_IOT': methods['camera_IOT'] ?? 0,
          };

          final currentSchedule = data['currentSchedule'] ?? {};
          final allMethods = (currentSchedule['methods'] as Map?) ?? {};
          final availableMethods = methods;

          final attendedMethods = <String>[];

          if (allMethods['camera_student'] == 1) {
            if (!availableMethods.containsKey('camera_student') ||
                availableMethods['camera_student'] == 0) {
              attendedMethods.add('face');
            }
          }
          if (allMethods['proof'] == 1) {
            if (!availableMethods.containsKey('proof') ||
                availableMethods['proof'] == 0) {
              attendedMethods.add('proof');
            }
          }
          if (allMethods['barcode'] == 1) {
            if (!availableMethods.containsKey('barcode') ||
                availableMethods['barcode'] == 0) {
              attendedMethods.add('barcode');
            }
          }

          // KHÔNG kiểm tra camera_IOT vì nó không bao giờ có trong attendanceMethods
          // (chỉ attendant mới điểm danh được, không phải sinh viên)

          return {
            'success': true,
            'data': {
              'canAttend': true,
              'message': data['message'],
              'attendanceMethods': convertedMethods,
              'attendedMethods': attendedMethods,
              'registrationId': data['registrationId'],
              'currentSchedule': data['currentSchedule'],
              'attendanceProgress': data['attendanceProgress'],
              'allSchedules': data['allSchedules'],
            },
          };
        } else {
          // Không thể điểm danh
          return {
            'success': false,
            'message': data['message'] ?? 'Không thể điểm danh',
            'currentTime': data['currentTime'],
            'validSchedules': data['validSchedules'],
            'attendedTimes': data['attendedTimes'],
            'totalTimes': data['totalTimes'],
            'attendedRecords': data['attendedRecords'],
          };
        }
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              error['message'] ?? 'Không thể kiểm tra điều kiện điểm danh',
        };
      }
    } catch (e) {
      print(' Error checkAttendanceEligibility: $e');
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  /// Điểm danh bằng Proof (chụp ảnh)
  /// POST /api/events/attendance/proof
  static Future<Map<String, dynamic>> attendByProof(
    int registrationId,
    String imagePath,
  ) async {
    try {
      print(' Submitting attendance proof...');
      print('   Registration ID: $registrationId');
      print('   Image: $imagePath');

      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Chưa đăng nhập'};
      }

      var uri = Uri.parse('$baseUrl/events/attendance/proof');
      var request = http.MultipartRequest('POST', uri);

      // Headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Fields
      request.fields['registrationId'] = registrationId.toString();

      // File
      request.files.add(
        await http.MultipartFile.fromPath('proofImage', imagePath),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(' Attend status: ${response.statusCode}');
      print(' Response: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseData = data['data'] ?? {};

        // Backend trả về status: 'attended' (chờ admin duyệt vì có proof)
        return {
          'success': true,
          'message':
              data['message'] ??
              'Gửi minh chứng thành công, chờ admin duyệt để cộng điểm',
          'data': responseData,
          'status': responseData['status'] ?? 'attended',
          'attendanceProgress': responseData['attendanceProgress'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Điểm danh thất bại',
          'currentTime': error['currentTime'],
          'availableSchedules': error['availableSchedules'],
          'method': error['method'],
        };
      }
    } catch (e) {
      print(' Error attendByProof: $e');
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  /// Điểm danh bằng nhận diện khuôn mặt
  /// POST /api/events/attendance/face
  static Future<Map<String, dynamic>> attendByFace(
    int registrationId,
    String studentId,
    double confidence,
    String faceImagePath,
  ) async {
    try {
      print(' Face attendance...');
      print('   Registration ID: $registrationId');
      print('   Student ID: $studentId');
      print('   Confidence: $confidence%');
      print('   Face image: $faceImagePath');

      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Chưa đăng nhập'};
      }

      final url = '$baseUrl/events/attendance/face';
      print(' URL: $url');

      var uri = Uri.parse(url);
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['registrationId'] = registrationId.toString();
      request.fields['studentId'] = studentId;
      request.fields['confidence'] = confidence.toString();

      request.files.add(
        await http.MultipartFile.fromPath('faceImage', faceImagePath),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(' Status: ${response.statusCode}');
      print(' Response: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseData = data['data'] ?? {};
        final conductScoreAdded = responseData['conductScoreAdded'] ?? 0;

        final status = conductScoreAdded > 0 ? 'scored' : 'attended';

        return {
          'success': data['success'] ?? true,
          'message':
              data['message'] ??
              (conductScoreAdded > 0
                  ? 'Điểm danh thành công và đã cộng điểm'
                  : 'Điểm danh thành công, chờ admin duyệt'),
          'data': responseData,
          'status': status,
          'conductScoreAdded': conductScoreAdded,
          'attendanceProgress': responseData['attendanceProgress'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Điểm danh thất bại',
          'currentTime': error['currentTime'],
          'availableSchedules': error['availableSchedules'],
          'method': error['method'],
        };
      }
    } catch (e) {
      print(' Error attendByFace: $e');
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Lấy chi tiết sự kiện từ lịch sử
  static Future<Map<String, dynamic>> getEventDetailHistory(
    int eventDetailId,
  ) async {
    try {
      print(' Getting event detail history: $eventDetailId');

      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventDetailId/history'),
        headers: await AuthService.headersWithAuth,
      );

      print(' Event detail history status: ${response.statusCode}');
      print(' Response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể lấy thông tin sự kiện',
        };
      }
    } catch (e) {
      print(' Error getEventDetailHistory: $e');
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
