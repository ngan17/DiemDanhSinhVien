import 'package:flutter/material.dart';
import '../services/face_service.dart';
import '../services/auth_service.dart';
import '../screens/face/face_register_screen.dart';
import '../screens/face/face_verify_screen.dart';

class FaceAuthHelper {
  /// Kiểm tra và điều hướng đến màn hình phù hợp dựa trên trạng thái đăng ký khuôn mặt
  ///
  /// Trả về:
  /// - true: Đã đăng ký khuôn mặt
  /// - false: Chưa đăng ký khuôn mặt
  static Future<bool> checkAndNavigateToFaceAuth(BuildContext context) async {
    try {
      // Lấy token từ AuthService
      String? token = await AuthService.getToken();

      if (token == null) {
        _showErrorDialog(
          context,
          'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
        );
        return false;
      }

      // Kiểm tra trạng thái đăng ký khuôn mặt
      FaceService faceService = FaceService();
      bool isRegistered = await faceService.checkStatus(token);

      if (!isRegistered) {
        // Chưa đăng ký -> Hiển thị dialog yêu cầu đăng ký
        if (context.mounted) {
          await _showFaceRegistrationDialog(context, token);
        }
        return false;
      }

      return true;
    } catch (e) {
      print("Lỗi kiểm tra đăng ký khuôn mặt: $e");
      if (context.mounted) {
        _showErrorDialog(
          context,
          'Không thể kiểm tra trạng thái đăng ký khuôn mặt.',
        );
      }
      return false;
    }
  }

  /// Hiển thị dialog yêu cầu đăng ký khuôn mặt (BẮT BUỘC - Không có nút Để sau)
  static Future<void> _showFaceRegistrationDialog(
    BuildContext context,
    String token,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // Không cho phép tắt bằng cách tap ngoài
      builder: (BuildContext dialogContext) => WillPopScope(
        onWillPop: () async => false, // Không cho back
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.face, color: Colors.blue, size: 32),
              SizedBox(width: 12),
              Text('Đăng ký khuôn mặt'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bạn chưa đăng ký khuôn mặt.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              Text(
                'Để sử dụng tính năng điểm danh bằng khuôn mặt, vui lòng đăng ký khuôn mặt của bạn.',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext); // Đóng dialog

                  //  Đợi một chút để dialog đóng hoàn toàn
                  await Future.delayed(const Duration(milliseconds: 300));

                  //  Kiểm tra context vẫn còn mounted
                  if (!context.mounted) return;

                  // Điều hướng đến màn hình đăng ký khuôn mặt
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => FaceRegisterScreen(token: token),
                    ),
                  );

                  // Nếu đăng ký thành công, hiển thị thông báo
                  if (result == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đăng ký khuôn mặt thành công!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1E90FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Đăng ký ngay'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hiển thị dialog lỗi
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Lỗi'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// Điều hướng đến màn hình xác thực khuôn mặt
  static Future<Map<String, dynamic>?> navigateToFaceVerify(
    BuildContext context,
  ) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => FaceVerifyScreen()),
    );

    return result;
  }
}
