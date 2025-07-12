import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1877F2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage('assets/avatar.jpg'), // Đổi thành ảnh thật
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Võ Trường Nhật",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "MSSV: 2001223265",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Options List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 8),

                _buildTile(Icons.badge, "Thông tin sinh viên"),
                _buildTile(Icons.lock_outline, "Đổi mật khẩu"),
                _buildTile(Icons.description_outlined, "Điều khoản và chính sách sử dụng"),
                _buildTile(Icons.feedback_outlined, "Góp ý ứng dụng"),
                _buildTileWithSwitch("Thông báo"),
                _buildTile(Icons.logout, "Đăng xuất", iconColor: Colors.red),
              ],
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "Phiên bản 1.4.8",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, {Color? iconColor}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate
        },
      ),
    );
  }

  Widget _buildTileWithSwitch(String title) {
    bool isOn = true; // bạn có thể dùng state management để control

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.notifications_active, color: Colors.orange),
        title: Text(title),
        trailing: Switch(
          value: isOn,
          onChanged: (value) {
            // TODO: Handle switch toggle
          },
        ),
      ),
    );
  }
}
