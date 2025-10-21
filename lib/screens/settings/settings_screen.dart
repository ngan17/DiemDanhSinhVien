import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _darkMode = false;
  String _language = 'Tiếng Việt';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E90FF),
        elevation: 0,
        title: const Text(
          'Cài đặt',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          // User Profile Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: const Color(0xFF1E90FF),
                  child: const Text(
                    'VN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Võ Nhật Ngân',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MSSV: 2021600123',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Công nghệ thông tin',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF1E90FF)),
                  onPressed: () {
                    _showEditProfileDialog();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Account Settings
          _buildSectionHeader('Tài khoản'),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Thông tin cá nhân',
            subtitle: 'Cập nhật thông tin của bạn',
            onTap: () {
              _showEditProfileDialog();
            },
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Đổi mật khẩu',
            subtitle: 'Thay đổi mật khẩu đăng nhập',
            onTap: () {
              _showChangePasswordDialog();
            },
          ),
          _buildSettingsTile(
            icon: Icons.security,
            title: 'Bảo mật',
            subtitle: 'Cài đặt bảo mật tài khoản',
            onTap: () {},
          ),

          const SizedBox(height: 10),

          // Notifications Settings
          _buildSectionHeader('Thông báo'),
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Thông báo',
            subtitle: 'Bật/tắt tất cả thông báo',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                if (!value) {
                  _emailNotifications = false;
                  _pushNotifications = false;
                }
              });
            },
          ),
          _buildSwitchTile(
            icon: Icons.email_outlined,
            title: 'Thông báo Email',
            subtitle: 'Nhận thông báo qua email',
            value: _emailNotifications,
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                  }
                : null,
          ),
          _buildSwitchTile(
            icon: Icons.notifications_active_outlined,
            title: 'Thông báo đẩy',
            subtitle: 'Nhận thông báo trên thiết bị',
            value: _pushNotifications,
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                  }
                : null,
          ),

          const SizedBox(height: 10),

          // App Settings
          _buildSectionHeader('Ứng dụng'),
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: 'Chế độ tối',
            subtitle: 'Giao diện tối cho màn hình',
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng đang phát triển'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'Ngôn ngữ',
            subtitle: _language,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showLanguageDialog();
            },
          ),
          _buildSettingsTile(
            icon: Icons.storage_outlined,
            title: 'Bộ nhớ & Dữ liệu',
            subtitle: 'Quản lý dung lượng ứng dụng',
            onTap: () {},
          ),

          const SizedBox(height: 10),

          // Support & About
          _buildSectionHeader('Hỗ trợ'),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Trợ giúp',
            subtitle: 'Câu hỏi thường gặp',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.feedback_outlined,
            title: 'Phản hồi',
            subtitle: 'Gửi ý kiến đóng góp',
            onTap: () {
              _showFeedbackDialog();
            },
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'Về ứng dụng',
            subtitle: 'Phiên bản 1.0.0',
            onTap: () {
              _showAboutDialog();
            },
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Chính sách bảo mật',
            subtitle: 'Điều khoản & Quyền riêng tư',
            onTap: () {},
          ),

          const SizedBox(height: 10),

          // Logout
          Container(
            color: Colors.white,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout, color: Colors.red, size: 24),
              ),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                _showLogoutDialog();
              },
            ),
          ),

          const SizedBox(height: 30),

          // App Version
          Center(
            child: Text(
              'Student Training Score App v1.0.0',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E90FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1E90FF), size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      color: Colors.white,
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E90FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1E90FF), size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF1E90FF),
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Chỉnh sửa thông tin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: 'Võ Nhật Ngân'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(
                text: 'vonhatngan@student.edu.vn',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: '0901234567'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã cập nhật thông tin')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E90FF),
            ),
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đổi mật khẩu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Mật khẩu cũ',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã đổi mật khẩu thành công')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E90FF),
            ),
            child: const Text(
              'Đổi mật khẩu',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Tiếng Việt'),
              value: 'Tiếng Việt',
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value!;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Gửi phản hồi'),
        content: const TextField(
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Nhập ý kiến đóng góp của bạn...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cảm ơn phản hồi của bạn!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E90FF),
            ),
            child: const Text('Gửi', style: TextStyle(color: Colors.white)),
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
                color: const Color(0xFF1E90FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Student Training Score App',
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Đã đăng xuất')));
            },
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
}
