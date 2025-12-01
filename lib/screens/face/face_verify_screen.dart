import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import '../../services/face_service.dart';

class FaceVerifyScreen extends StatefulWidget {
  const FaceVerifyScreen({Key? key}) : super(key: key);

  @override
  State<FaceVerifyScreen> createState() => _FaceVerifyScreenState();
}

class _FaceVerifyScreenState extends State<FaceVerifyScreen> {
  final FaceService _faceService = FaceService();
  final ImagePicker _picker = ImagePicker(); 
  String? _capturedPath;
  bool _isVerifying = false;


  Future<void> _takePicture() async {
    try {
      print(' Opening camera for verification...');

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera, // Mở camera
        preferredCameraDevice: CameraDevice.front, // Camera trước
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      print(' Camera result: ${photo?.path ?? "null (user cancelled)"}');

      if (photo != null) {
        if (mounted) {
          setState(() => _capturedPath = photo.path);
        }
        print(' Picture saved: ${photo.path}');
      } else {
        print(' User cancelled camera');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bạn đã hủy chụp ảnh'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print(' Take picture error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi mở camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Hàm xác thực
  Future<void> _verify() async {
    if (_capturedPath == null) return;

    if (mounted) {
      setState(() => _isVerifying = true);
    }

    // Gọi API Verify
    final result = await _faceService.verifyFace(_capturedPath!);

    if (mounted) {
      setState(() => _isVerifying = false);
    }

    if (!mounted) return;

    // Hiển thị kết quả
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              result['success'] ? Icons.check_circle : Icons.error,
              color: result['success'] ? Colors.green : Colors.red,
              size: 32,
            ),
            SizedBox(width: 12),
            Text(result['success'] ? "Thành công" : "Thất bại"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result['success']) ...[
              _buildInfoRow("Sinh viên:", result['student_name'] ?? 'N/A'),
              SizedBox(height: 8),
              _buildInfoRow("Mã SV:", result['student_id'] ?? 'N/A'),
              SizedBox(height: 8),
              _buildInfoRow(
                "Độ chính xác:",
                "${result['confidence'] ?? 0}%",
                color: Colors.green,
              ),
            ] else ...[
              Text(
                "Lỗi: ${result['message'] ?? 'Không xác định được khuôn mặt'}",
                style: TextStyle(fontSize: 15, color: Colors.red[700]),
              ),
              if (result['confidence'] != null) ...[
                SizedBox(height: 12),
                Text(
                  "Độ khớp: ${result['confidence']}% (Dưới chuẩn)",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (result['success']) {
                // Nếu thành công, quay về màn hình trước
                Navigator.pop(context, result);
              } else {
                // Nếu thất bại, cho phép chụp lại
                setState(() => _capturedPath = null);
              }
            },
            child: Text(result['success'] ? "Đóng" : "Thử lại"),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: color ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Xác thực điểm danh"),
        backgroundColor: const Color(0xFF1E90FF),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // KHUNG PREVIEW ẢNH
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: _capturedPath == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 80,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nhấn nút bên dưới để chụp ảnh xác thực',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : Image.file(File(_capturedPath!), fit: BoxFit.cover),
            ),
          ),

          // CÁC NÚT ĐIỀU KHIỂN
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: _capturedPath == null
                ? Center(
                    // Nút Chụp
                    child: FloatingActionButton.large(
                      onPressed: _takePicture,
                      backgroundColor: const Color(0xFF1E90FF),
                      child: const Icon(Icons.camera_alt, size: 32),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Nút Chụp lại
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => setState(() => _capturedPath = null),
                          icon: const Icon(Icons.refresh),
                          label: const Text("Chụp lại"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Nút Xác thực
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isVerifying ? null : _verify,
                          icon: _isVerifying
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_circle),
                          label: Text(
                            _isVerifying ? "Đang xử lý..." : "Xác thực",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
