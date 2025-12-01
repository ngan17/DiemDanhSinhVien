import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

class FaceService {

  static const String pythonBaseUrl = "http://192.168.132.185:8001";


  static const String laravelBaseUrl = AppConfig.baseUrl;


  Future<bool> checkStatus(String token) async {
    try {
      print(' Checking face registration status...');
      print(' URL: $laravelBaseUrl/face-embeddings/check');

 
      final response = await http.get(
        Uri.parse('$laravelBaseUrl/face-embeddings/check'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print(' Status code: ${response.statusCode}');
      print(' Response: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

       
        bool isRegistered = data['registered'] == true;

        print(' Registration status: $isRegistered');
        return isRegistered;
      }

      return false;
    } catch (e) {
      print(" Exception in checkStatus: $e");
      return false;
    }
  }


  Future<Map<String, dynamic>> detectFace(String imagePath) async {
    try {
      print(' Detecting face...');
      print(' URL: $pythonBaseUrl/detect-face');
      print(' Image: $imagePath');

      var uri = Uri.parse('$pythonBaseUrl/detect-face');
      var request = http.MultipartRequest('POST', uri);

      request.headers['Content-Type'] = 'multipart/form-data';
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(' Status: ${response.statusCode}');
      print(' Response: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        //  Wrap response giống web: { data: {...} }
        return {'data': data, 'success': data['success'] ?? false};
      } else {
        return {
          'success': false,
          'message': 'Lỗi server: ${response.statusCode}',
        };
      }
    } catch (e) {
      print(" Exception in detectFace: $e");
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }


  Future<Map<String, dynamic>> registerFace(
    String imagePath,
    String token,
  ) async {
    try {
      // Lấy studentId từ profile
      final profileResult = await AuthService.getProfile();

      if (profileResult['success'] != true || profileResult['data'] == null) {
        return {
          'success': false,
          'message': 'Không lấy được thông tin profile',
        };
      }

      final profileData = profileResult['data'];

      if (profileData['student'] == null) {
        return {'success': false, 'message': 'Không có thông tin sinh viên'};
      }

      final studentId = profileData['student']['id']?.toString();

      if (studentId == null) {
        return {'success': false, 'message': 'Student ID null'};
      }

      print('📝 Registering face for student: $studentId');
      print(' URL: $pythonBaseUrl/register-face');

      var uri = Uri.parse('$pythonBaseUrl/register-face');
      var request = http.MultipartRequest('POST', uri);

      request.fields['student_id'] = studentId;

      // Thêm file
      request.headers['Content-Type'] = 'multipart/form-data';
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(' Status: ${response.statusCode}');
      print(' Response: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        return {
          'data': data,
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Đăng ký thành công',
        };
      } else {
        return {
          'success': false,
          'message': 'Lỗi đăng ký: ${response.statusCode}',
        };
      }
    } catch (e) {
      print(" Exception in registerFace: $e");
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }


  Future<Map<String, dynamic>> verifyFace(String imagePath) async {
    try {
      print(' Verifying face...');
      print(' URL: $pythonBaseUrl/verify-face');

      var uri = Uri.parse('$pythonBaseUrl/verify-face');
      var request = http.MultipartRequest('POST', uri);

      request.headers['Content-Type'] = 'multipart/form-data';
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(' Status: ${response.statusCode}');
      print(' Response: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        
        return {
          'data': data,
          'success': data['success'] ?? false,
          'message': data['message'],
          'student_id': data['student_id'],
          'student_name': data['student_name'],
          'confidence': data['confidence'],
        };
      } else {
        return {
          'success': false,
          'message': 'Lỗi xác thực: ${response.statusCode}',
        };
      }
    } catch (e) {
      print(" Exception in verifyFace: $e");
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }


  Future<Map<String, dynamic>?> getFaceEmbedding(
    String studentId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$laravelBaseUrl/face-embeddings/$studentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print(" Error getFaceEmbedding: $e");
      return null;
    }
  }


  Future<bool> deleteFaceEmbedding(String studentId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$laravelBaseUrl/face-embeddings/$studentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print(" Error deleteFaceEmbedding: $e");
      return false;
    }
  }


  Future<List<dynamic>?> getAllFaceEmbeddings(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$laravelBaseUrl/face-embeddings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return null;
    } catch (e) {
      print(" Error getAllFaceEmbeddings: $e");
      return null;
    }
  }


  Future<Map<String, dynamic>?> getFaceStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$laravelBaseUrl/face-embeddings/stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print(" Error getFaceStats: $e");
      return null;
    }
  }


  Future<List<dynamic>?> getUnregisteredStudents(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$laravelBaseUrl/face-embeddings/unregistered'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return null;
    } catch (e) {
      print(" Error getUnregisteredStudents: $e");
      return null;
    }
  }
}
