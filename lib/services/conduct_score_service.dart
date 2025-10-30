import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conduct_score_model.dart';

class ConductScoreService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Lấy token từ SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Headers với token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  // 1. Lấy tổng điểm
  static Future<ConductScoreTotal?> getTotalScore() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/conduct-score/total'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return ConductScoreTotal.fromJson(data);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  // 2. Lấy điểm theo học kỳ
  static Future<Map<String, dynamic>?> getScoreBySemester({
    int? startYear,
    int? semester,
  }) async {
    try {
      final headers = await _getHeaders();

      // Build query parameters
      String url = '$baseUrl/conduct-score/by-semester';
      List<String> queryParams = [];

      if (startYear != null) {
        queryParams.add('startYear=$startYear');
      }
      if (semester != null) {
        queryParams.add('semester=$semester');
      }

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        // Parse response
        final responseData = data['data'];
        return {
          'studentId': responseData['studentId'],
          'studentName': responseData['studentName'],
          'totalConductScore': responseData['totalConductScore'] ?? 0,
          'semesters': (responseData['semesters'] as List)
              .map((s) => SemesterScore.fromJson(s))
              .toList(),
          'totalEventsAttended': responseData['totalEventsAttended'] ?? 0,
        };
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  // 3. Lấy điểm theo loại sự kiện
  static Future<Map<String, dynamic>?> getScoreByEventType() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/conduct-score/by-event-type'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['data'];
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  // 4. Lấy lịch sử điểm
  static Future<Map<String, dynamic>?> getScoreHistory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/conduct-score/history'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['data'];
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  // 5. Lấy thống kê
  static Future<ScoreStatistics?> getStatistics() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/conduct-score/statistics'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return ScoreStatistics.fromJson(data);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }
}
