import 'package:flutter/material.dart';

class StudentInfoView extends StatelessWidget {
  const StudentInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final studentData = {
      "Trạng thái": "Đang học",
      "MSSV": "2001223265",
      "Khoa": "Khoa Công nghệ Thông tin",
      "Lớp": "13DHTH04-13DHTH04",
      "Bậc đào tạo": "Đại học",
      "Loại hình đào tạo": "Chính quy",
      "Khóa học": "2022",
      "Ngành": "Công nghệ thông tin",
      "Chuyên ngành": "Công nghệ phần mềm",
      "Ngày sinh": "26/01/2004",
      "Giới tính": "Nam",
      "Nơi sinh": "Thành phố Hồ Chí Minh",
      "Địa chỉ thường trú":
          "138 Ấp Tân Quang 2, xã Đông Thạnh, Cần Giuộc, Long An, Xã Đông Thạnh, Huyện Cần Giuộc, Tỉnh Long An",
      "Số điện thoại": "0908396962",
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Nền màu xanh
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Color(0xFF1877F2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),

          // Nội dung cuộn được
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Thông tin sinh viên',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Avatar + Nội dung
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // Khối thông tin bo tròn
                      Container(
                        margin: const EdgeInsets.only(top: 60),
                        padding: const EdgeInsets.only(top: 70, left: 16, right: 16, bottom: 20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Võ Trường Nhật",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Danh sách thông tin
                            Column(
                              children: studentData.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          entry.key,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        " : ",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          entry.value,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      // Avatar hình tròn
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 46,
                          backgroundImage: AssetImage('assets/images/avatar.png'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
