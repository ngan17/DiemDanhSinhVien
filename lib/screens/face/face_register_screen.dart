import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; //  Thay camera bằng image_picker
import '../../services/face_service.dart';
import '../../services/auth_service.dart';
import '../auth/role_selection_screen.dart';

class FaceRegisterScreen extends StatefulWidget {
  final String token;

  const FaceRegisterScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<FaceRegisterScreen> createState() => _FaceRegisterScreenState();
}

class _FaceRegisterScreenState extends State<FaceRegisterScreen> {
  final FaceService _faceService = FaceService();
  final ImagePicker _picker = ImagePicker(); //  Image picker

  String? _capturedPath;
  bool _isDetecting = false;
  bool _isRegistering = false;

  Map<String, dynamic>? _detectResult;

  Future<void> _takePicture() async {
    try {
      print(' Opening camera...');

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera, // Mở camera
        preferredCameraDevice: CameraDevice.front, // Camera trước
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      print(' Camera result: ${photo?.path ?? "null (user cancelled)"}');
      print(' Widget mounted: $mounted');

      if (photo != null) {
        if (mounted) {
          setState(() {
            _capturedPath = photo.path;
            _detectResult = null;
          });
          print(' Picture saved: ${photo.path}');

          //  Tự động kiểm tra quality sau khi chụp
          _checkQuality();
        } else {
          print(' Widget not mounted, cannot setState');
        }
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

  Future<void> _checkQuality() async {
    if (_capturedPath == null) return;

    if (mounted) {
      setState(() => _isDetecting = true);
    }

    final result = await _faceService.detectFace(_capturedPath!);

    if (mounted) {
      setState(() {
        _isDetecting = false;
        //  Lấy data từ response.data giống web
        _detectResult = result['data'] ?? result;
      });
    }

    //  Kiểm tra success từ data
    final success = result['data']?['success'] ?? result['success'] ?? false;

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Lỗi: ${result['data']?['message'] ?? result['message']}",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _register() async {
    if (_capturedPath == null) return;

    if (mounted) {
      setState(() => _isRegistering = true);
    }

    final result = await _faceService.registerFace(
      _capturedPath!,
      widget.token,
    );

    if (mounted) {
      setState(() => _isRegistering = false);
    }

    //  Lấy data từ response.data giống web
    final success = result['data']?['success'] ?? result['success'] ?? false;
    final message =
        result['data']?['message'] ?? result['message'] ?? 'Đăng ký thành công';

    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text(" Thành công!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Thất bại: $message"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text(
          'Bạn cần đăng ký khuôn mặt để sử dụng ứng dụng. Bạn có chắc chắn muốn đăng xuất?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Xóa token và user data
      await AuthService.removeToken();
      await AuthService.removeUserData();

      if (mounted) {
        // Quay về màn hình chọn quyền đăng nhập
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _logout();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Đăng ký khuôn mặt"),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _logout,
          ),
        ),
        body: Column(
          children: [
            //  PREVIEW ẢNH ĐÃ CHỤP
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
                              'Nhấn nút bên dưới để chụp ảnh',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Image.file(File(_capturedPath!), fit: BoxFit.cover),
              ),
            ),

            // KHUNG KẾT QUẢ DETECT
            if (_detectResult != null)
              Container(
                padding: const EdgeInsets.all(10),
                color: _detectResult!['success']
                    ? Colors.green[100]
                    : Colors.red[100],
                child: Row(
                  children: [
                    Icon(
                      _detectResult!['success']
                          ? Icons.check_circle
                          : Icons.error,
                      color: _detectResult!['success']
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _detectResult!['success']
                            ? "Ảnh hợp lệ: ${_detectResult!['num_faces']} khuôn mặt"
                            : "Lỗi: ${_detectResult!['message']}",
                      ),
                    ),
                  ],
                ),
              ),

            // CÁC NÚT ĐIỀU KHIỂN
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_capturedPath == null)
                    //  Nút chụp ảnh (Mở camera hệ thống)
                    ElevatedButton.icon(
                      onPressed: _takePicture,
                      icon: const Icon(Icons.camera_alt, size: 30),
                      label: const Text(
                        'Chụp ảnh',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _capturedPath = null;
                              _detectResult = null;
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text("Chụp lại"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        if (_detectResult == null || !_detectResult!['success'])
                          ElevatedButton.icon(
                            onPressed: _isDetecting ? null : _checkQuality,
                            icon: _isDetecting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.face_retouching_natural),
                            label: const Text("Kiểm tra"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        if (_detectResult != null && _detectResult!['success'])
                          ElevatedButton.icon(
                            onPressed: _isRegistering ? null : _register,
                            icon: _isRegistering
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(_isRegistering ? "Lưu..." : "Đăng ký"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
