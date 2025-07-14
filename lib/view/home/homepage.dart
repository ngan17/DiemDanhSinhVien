import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:diem_danh_sinh_vien/view/sukien/sukien.dart';
import 'package:diem_danh_sinh_vien/view/lophoc/lophoc.dart';
import 'package:diem_danh_sinh_vien/view/animation/animation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF1E90FF),
        scaffoldBackgroundColor: Colors.white,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF1E90FF),
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    MyHomePage(),
    SchedulePage(),
    EventListScreen(),
    ForumPage(),
    PersonalPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Lịch học',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Sự kiện'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Diễn đàn'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final iconHeight = screenSize.height * 0.04;
    final fontSizeTitle = screenSize.width * 0.05;
    final fontSizeSubtitle = screenSize.width * 0.035;
    final padding = screenSize.width * 0.04;

    final List<Map<String, dynamic>> carriers = [
      {
        'name': 'MobiFone',
        'image': 'assets/MobiFone.png',
        'description': 'Nạp MobiFone, gọi thả ga!',
      },
      {
        'name': 'Viettel',
        'image': 'assets/Viettel.png',
        'description': 'Viettel luôn kết nối mọi nhà.',
      },
      {
        'name': 'VinaPhone',
        'image': 'assets/VinaPhone.png',
        'description': 'VinaPhone - Không lo hết tiền.',
      },
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenSize.height * 0.1),
        child: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          flexibleSpace: Container(
            padding: EdgeInsets.only(
              top: screenSize.height * 0.04,
              left: padding,
              right: padding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: screenSize.width * 0.06,
                      backgroundImage: NetworkImage(
                        'https://th.bing.com/th/id/OIP.iCIltz9NfBmjlHU1ABfKzwHaEK?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3',
                      ),
                    ),
                    SizedBox(width: screenSize.width * 0.03),
                    Text(
                      'Xin chào, Võ Nhật Ngân',
                      style: TextStyle(
                        fontSize: fontSizeTitle,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: screenSize.width * 0.08,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ScheduleCard(context),
            Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chức năng',
                    style: TextStyle(
                      fontSize: fontSizeTitle,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    'Tùy chỉnh',
                    style: TextStyle(
                      fontSize: fontSizeSubtitle,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            GridView.count(
              crossAxisCount: 4,
              padding: EdgeInsets.symmetric(horizontal: padding),
              crossAxisSpacing: screenSize.width * 0.02,
              mainAxisSpacing: screenSize.height * 0.01,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 0.8,
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
                    MaterialPageRoute(
                      builder: (context) => AchievementScreen(),
                    ),
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
                    MaterialPageRoute(builder: (context) => SchedulePage()),
                  ),
                ),
                FunctionCard(
                  iconPath: 'assets/menu.png',
                  label: 'Tất cả',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: padding),
              child: Column(
                children: [
                  carousel.CarouselSlider(
                    options: carousel.CarouselOptions(
                      height:
                          screenSize.height *
                          0.28, // Increased height to avoid overflow
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                      enlargeCenterPage: true,
                      viewportFraction: 0.9,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                    items: carriers.map((carrier) {
                      return Container(
                        width: screenSize.width * 0.95,
                        margin: EdgeInsets.symmetric(horizontal: padding * 0.5),
                        padding: EdgeInsets.all(
                          padding * 0.8,
                        ), // Reduced padding
                        decoration: BoxDecoration(
                          color: Color(0xFF1E90FF),
                          borderRadius: BorderRadius.circular(
                            screenSize.width * 0.04,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'NẠP TIỀN ${carrier['name'].toString().toUpperCase()}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      fontSizeTitle * 0.9, // Slightly smaller
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.005),
                            Flexible(
                              child: Text(
                                carrier['description'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSizeSubtitle * 0.7,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.01),
                            Image.asset(
                              carrier['image'],
                              height:
                                  iconHeight * 0.8, // Slightly smaller image
                            ),
                            SizedBox(height: screenSize.height * 0.01),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    screenSize.width * 0.05,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: padding * 0.5,
                                  vertical: padding * 0.3,
                                ),
                              ),
                              child: Text(
                                'Nạp ngay!',
                                style: TextStyle(
                                  color: Color(0xFF1E90FF),
                                  fontSize: fontSizeSubtitle * 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: carriers.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () => setState(() => _currentIndex = entry.key),
                        child: Container(
                          width: 8.0,
                          height: 8.0,
                          margin: EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentIndex == entry.key
                                ? Color(0xFF1E90FF)
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      );
                    }).toList(),
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
    final screenSize = MediaQuery.of(context).size;
    final iconHeight = screenSize.height * 0.045;
    final fontSize = screenSize.width * 0.025;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(screenSize.width * 0.04),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenSize.width * 0.04),
        ),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, height: iconHeight),
            SizedBox(height: screenSize.height * 0.005),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: fontSize, color: Colors.black),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tất cả')),
      body: Center(child: Text('Nội dung Tất cả')),
    );
  }
}

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Diễn đàn')),
      body: Center(child: Text('Nội dung Diễn đàn')),
    );
  }
}

class PersonalPage extends StatelessWidget {
  const PersonalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cá nhân')),
      body: Center(child: Text('Nội dung Cá nhân')),
    );
  }
}

Widget ScheduleCard(BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
  final padding = screenSize.width * 0.04;
  final fontSizeTitle = screenSize.width * 0.04;
  final fontSizeSub = screenSize.width * 0.032;

  // Danh sách lịch học mẫu (có thể thay bằng dữ liệu thực tế)
  final List<Map<String, dynamic>> schedules = [
    {
      'subject': 'Toán Cao Cấp',
      'time': '08:00 - 10:00',
      'location': 'Phòng A101',
    },
    {
      'subject': 'Lập Trình Flutter',
      'time': '10:30 - 12:30',
      'location': 'Phòng B202',
    },
    {
      'subject': 'Tiếng Anh Chuyên Ngành',
      'time': '14:00 - 16:00',
      'location': 'Phòng C303',
    },
    {
      'subject': 'Vật Lý Đại Cương',
      'time': '16:30 - 18:30',
      'location': 'Phòng D404',
    },
    {
      'subject': 'Hóa Học Cơ Bản',
      'time': '19:00 - 21:00',
      'location': 'Phòng E505',
    },
    {
      'subject': 'Lịch Sử Đảng',
      'time': '21:30 - 23:30',
      'location': 'Phòng F606',
    },
  ];

  // Hàm tính toán thời gian bắt đầu từ chuỗi 'HH:MM'
  DateTime parseStartTime(String timeStr) {
    final startTimeStr = timeStr.split(' - ')[0]; // Lấy phần bắt đầu
    final parts = startTimeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  // Sắp xếp lịch học theo thời gian bắt đầu gần giờ hiện tại nhất
  schedules.sort((a, b) {
    final timeA = parseStartTime(a['time']);
    final timeB = parseStartTime(b['time']);
    final now = DateTime.now();
    return timeA.difference(now).abs().compareTo(timeB.difference(now).abs());
  });

  // Chỉ lấy 3 lịch học gần nhất
  List<Map<String, dynamic>> topSchedules = schedules.take(3).toList();

  // Nếu ít hơn 3, thêm thẻ rỗng
  while (topSchedules.length < 3) {
    topSchedules.add({
      'subject': 'Không có lịch',
      'time': '--:-- - --:--',
      'location': '--',
    });
  }

  // Chiều cao cho thẻ
  final cardHeight = 100.0;

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
    child: SizedBox(
      height: cardHeight, // Chỉ hiển thị chiều cao của một thẻ đầy đủ
      child: carousel.CarouselSlider.builder(
        itemCount: topSchedules.length,
        itemBuilder: (context, index, realIndex) {
          final schedule = topSchedules[index];
          return Container(
            padding: EdgeInsets.all(padding * 0.8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue[300]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blue[700], size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        schedule['subject'],
                        style: TextStyle(
                          fontSize: fontSizeTitle * 0.9,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Thời gian: ${schedule['time']}',
                        style: TextStyle(
                          fontSize: fontSizeSub * 0.9,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        'Địa điểm: ${schedule['location']}',
                        style: TextStyle(
                          fontSize: fontSizeSub * 0.9,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        options: carousel.CarouselOptions(
          height: cardHeight,
          scrollDirection: Axis.vertical, // Di chuyển dọc (kéo lên/xuống)
          enlargeCenterPage: false,
          viewportFraction: 1.0, // Chỉ hiển thị một thẻ đầy đủ
          initialPage: 0,
          enableInfiniteScroll: false, // Không loop vô hạn
          reverse: false,
          autoPlay: false, // Không auto play
        ),
      ),
    ),
  );
}
