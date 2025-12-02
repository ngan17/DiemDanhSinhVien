import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/role_selection_screen.dart';
import 'change_password_screen.dart';
import 'barcode_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profileResult = await AuthService.getProfile();

      if (profileResult['success'] == true) {
        final data = profileResult['data'];
        if (mounted) {
          setState(() {
            userData = {'user': data['user'], 'student': data['student']};
            _isLoading = false;
          });
        }
      } else {
        final localData = await AuthService.getUserData();
        if (mounted) {
          setState(() {
            userData = localData;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      final localData = await AuthService.getUserData();
      if (mounted) {
        setState(() {
          userData = localData;
          _isLoading = false;
        });
      }
    }
  }

  String get _userName {
    if (userData == null) return 'Người dùng';
    return userData!['student']?['studentName'] ?? 'Người dùng';
  }

  String get _userCode {
    if (userData == null) return '';
    return userData!['student']?['id'] ?? '';
  }

  String get _userEmail {
    if (userData == null) return '';
    return userData!['user']?['email'] ?? '';
  }

  String get _userRole {
    if (userData == null) return '';
    return userData!['user']?['role'] ?? '';
  }

  String get _classId {
    if (userData == null) return '';
    return userData!['student']?['classId'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2, color: Color(0xFF2196F3)),
            onPressed: _showBarcodeScreen,
            tooltip: 'Tạo barcode',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: ListView(
                children: [
                  const SizedBox(height: 16),

                  // User Profile Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.grey[200],
                                  child: const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _userName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'MSSV: $_userCode',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (_classId.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Lớp: $_classId',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Settings Options
                  _buildSettingsItem(
                    icon: Icons.person_outline,
                    title: 'Thông tin sinh viên',
                    onTap: _showEditProfileDialog,
                  ),
                  _buildSettingsItem(
                    icon: Icons.lock_outline,
                    title: 'Đổi mật khẩu',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.notifications_outlined,
                    title: 'Cài đặt thông báo',
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Chức năng đang phát triển'),
                          ),
                        );
                      },
                      activeColor: const Color(0xFF4CAF50),
                    ),
                    onTap: null,
                  ),
                  _buildSettingsItem(
                    icon: Icons.language,
                    title: 'Ngôn ngữ',
                    subtitle: 'Tiếng Việt',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Chức năng đang phát triển'),
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.info_outline,
                    title: 'Trợ giúp & Phản hồi',
                    onTap: _showAboutDialog,
                  ),

                  const SizedBox(height: 24),

                  // Logout Button
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: _showLogoutDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF5350),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Đăng xuất',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[700], size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              )
            : null,
        trailing:
            trailing ??
            (onTap != null
                ? Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  )
                : null),
        onTap: onTap,
      ),
    );
  }

  void _showBarcodeScreen() {
    if (_userCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy mã sinh viên'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BarcodeScreen(studentId: _userCode, studentName: _userName),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Thông tin cá nhân'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                controller: nameController,
                enabled: false,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'MSSV',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                controller: TextEditingController(text: _userCode),
                enabled: false,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Lớp',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_),
                ),
                controller: TextEditingController(text: _classId),
                enabled: false,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                controller: emailController,
                enabled: false,
              ),
              const SizedBox(height: 12),
              Text(
                'Thông tin không thể chỉnh sửa. Vui lòng liên hệ admin nếu cần thay đổi.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Về ứng dụng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Điểm Danh Sinh Viên',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text('Phiên bản 1.0.0', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Text(
              'Ứng dụng quản lý điểm rèn luyện sinh viên\n\n© 2025 All rights reserved',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Text('Đăng xuất'),
          ],
        ),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => _handleLogout(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    Navigator.pop(context); // Đóng dialog xác nhận

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang đăng xuất...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      await AuthService.logout();
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Đóng loading dialog

      // Quay về RoleSelectionScreen thay vì LoginScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        (route) => false,
      );

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng xuất thành công!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Đóng loading dialog

      // Vẫn quay về RoleSelectionScreen ngay cả khi có lỗi
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        (route) => false,
      );

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã đăng xuất'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }
}
