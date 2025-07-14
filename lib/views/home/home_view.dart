import 'package:diem_danh_sinh_vien/views/home/profile_view.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContentScreen(), // Trang chủ
    const ScheduleScreen(), // Lịch học/lịch thi
    const MessageScreen(), // Tin nhắn
    const ProfileView(), // Cá nhân
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          _selectedIndex ==
              0 // Chỉ hiển thị logo khi ở trang Home
          ? AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      'https://th.bing.com/th/id/OIP.iCIltz9NfBmjlHU1ABfKzwHaEK?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3',
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Xin chào, Võ Nhật Ngân',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            )
          : null, // Không hiển thị AppBar ở các trang khác
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Lịch học',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Tin nhắn'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }
}

class HomeContentScreen extends StatelessWidget {
  const HomeContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                Image.asset('assets/schedule.png', height: 50),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lịch hôm nay:',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Text(
                        'Không tìm thấy lịch học/lịch thi',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chức năng',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                'Tùy chỉnh',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 4,
            padding: EdgeInsets.symmetric(horizontal: 10),
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            children: [
              FunctionCard(
                iconPath: 'assets/exam.png',
                label: 'Xem điểm toàn học',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScoreScreen()),
                ),
              ),
              FunctionCard(
                iconPath: 'assets/graduation-hat.png',
                label: 'Thành tích',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AchievementScreen()),
                ),
              ),
              FunctionCard(
                iconPath: 'assets/receipt.png',
                label: 'Phiếu thu tổng hợp',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReceiptScreen()),
                ),
              ),
              FunctionCard(
                iconPath: 'assets/open-book.png',
                label: 'Chương trình khung',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FrameworkScreen()),
                ),
              ),
              FunctionCard(
                iconPath: 'assets/accepted.png',
                label: 'Thống kê điểm',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StatsScreen()),
                ),
              ),
              FunctionCard(
                iconPath: 'assets/calendar.png',
                label: 'Lịch học/ lịch thi',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScheduleScreen()),
                ),
              ),
              FunctionCard(
                iconPath: 'assets/menu.png',
                label: 'Tất cả',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileView()),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Color(0xFF1E90FF),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Text(
                'NẠP TIỀN ĐIỆN THOẠI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Nghỉ gọi thoải ga, không lo hết tiền',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/MobiFone.png', height: 20),
                  SizedBox(width: 5),
                  Image.asset('assets/Viettel.png', height: 20),
                  SizedBox(width: 5),
                  Image.asset('assets/VinaPhone.png', height: 20),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  iconColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Nạp ngay!',
                  style: TextStyle(color: Color(0xFF1E90FF)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FunctionCard extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const FunctionCard({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, height: 40),
            SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder screens for navigation
class ScoreScreen extends StatelessWidget {
  const ScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Xem điểm toàn học')),
      body: Center(child: Text('Nội dung Xem điểm toàn học')),
    );
  }
}

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thành tích')),
      body: Center(child: Text('Nội dung Thành tích')),
    );
  }
}

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phiếu thu tổng hợp')),
      body: Center(child: Text('Nội dung Phiếu thu tổng hợp')),
    );
  }
}

class FrameworkScreen extends StatelessWidget {
  const FrameworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chương trình khung')),
      body: Center(child: Text('Nội dung Chương trình khung')),
    );
  }
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thống kê điểm')),
      body: Center(child: Text('Nội dung Thống kê điểm')),
    );
  }
}

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lịch học/ lịch thi')),
      body: Center(child: Text('Nội dung Lịch học/ lịch thi')),
    );
  }
}

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tin nhắn')),
      body: Center(child: Text('Nội dung Tin nhắn')),
    );
  }
}
