import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  String _viewMode = 'Tháng'; // 'Ngày', 'Tuần', 'Tháng'

  // Danh sách lịch học mẫu (thay bằng dữ liệu thực tế từ API)
  final List<Map<String, dynamic>> _schedules = [
    {
      'date': DateTime(2025, 7, 13),
      'title': 'Giáo dục thể chất 3 (Thể hình)',
      'period': '1 - 4',
      'room': '656 Tân Kỳ Tân Quý, Bình Hưng Hòa, Bình Tân, TP. HCM',
      'lecturer': 'Lê Văn Thanh',
      'type':
          'Lịch học', // 'Lịch học', 'Lịch thi', 'Lịch trực tuyến', 'Tạm ngưng'
    },
    {
      'date': DateTime(2025, 7, 15),
      'title': 'Lập trình nâng cao',
      'period': '5 - 8',
      'room': 'Phòng A102',
      'lecturer': 'Nguyễn Thị Lan',
      'type': 'Lịch thi',
    },
    {
      'date': DateTime(2025, 7, 20),
      'title': 'Hội thảo AI',
      'period': '9 - 12',
      'room': 'Phòng B303',
      'lecturer': 'Trần Văn Bình',
      'type': 'Lịch trực tuyến',
    },
    // Thêm nhiều lịch khác nếu cần
  ];

  // Sinh danh sách tháng động (ví dụ: cho năm 2025, bạn có thể mở rộng)
  List<DateTime> get _months {
    final List<DateTime> months = [];
    for (int month = 1; month <= 12; month++) {
      months.add(DateTime(2025, month, 1)); // Có thể thay đổi năm động nếu cần
    }
    return months;
  }

  // Lấy danh sách ngày trong tháng
  List<DateTime> get _daysInMonth {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final days = <DateTime>[];
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(_selectedMonth.year, _selectedMonth.month, i));
    }
    return days;
  }

  // Lấy danh sách ngày trong tuần
  List<DateTime> get _daysInWeek {
    final startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    final days = <DateTime>[];
    for (int i = 0; i < 7; i++) {
      days.add(startOfWeek.add(Duration(days: i)));
    }
    return days;
  }

  // Lọc lịch theo ngày
  List<Map<String, dynamic>> _getSchedulesForDate(DateTime date) {
    return _schedules.where((schedule) {
      return schedule['date'].year == date.year &&
          schedule['date'].month == date.month &&
          schedule['date'].day == date.day;
    }).toList();
  }

  // Lọc lịch theo tuần
  List<Map<String, dynamic>> _getSchedulesForWeek() {
    final days = _daysInWeek;
    return _schedules.where((schedule) {
      return days.any(
        (day) =>
            schedule['date'].year == day.year &&
            schedule['date'].month == day.month &&
            schedule['date'].day == day.day,
      );
    }).toList();
  }

  // Lọc lịch theo tháng
  List<Map<String, dynamic>> _getSchedulesForMonth() {
    return _schedules.where((schedule) {
      return schedule['date'].year == _selectedMonth.year &&
          schedule['date'].month == _selectedMonth.month;
    }).toList();
  }

  // Kiểm tra ngày có sự kiện
  bool _hasEvent(DateTime date) {
    return _getSchedulesForDate(date).isNotEmpty;
  }

  // Xử lý swipe cho tuần
  void _handleSwipe(DragEndDetails details) {
    if (details.primaryVelocity! < 0) {
      // Swipe left -> Tuần sau
      setState(() {
        _selectedDate = _selectedDate.add(const Duration(days: 7));
      });
    } else if (details.primaryVelocity! > 0) {
      // Swipe right -> Tuần trước
      setState(() {
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch học/lịch thi'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Column(
        children: [
          // Bộ chọn tháng/tuần/ngày
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<DateTime>(
                  value: _selectedMonth,
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (DateTime? newMonth) {
                    if (newMonth != null) {
                      setState(() {
                        _selectedMonth = newMonth;
                        _selectedDate = DateTime(
                          newMonth.year,
                          newMonth.month,
                          1,
                        ); // Đặt ngày đầu tháng
                      });
                    }
                  },
                  items: _months.map<DropdownMenuItem<DateTime>>((
                    DateTime value,
                  ) {
                    return DropdownMenuItem<DateTime>(
                      value: value,
                      child: Text('Th ${value.month}, ${value.year}'),
                    );
                  }).toList(),
                ),
                ToggleButtons(
                  isSelected: [
                    'Ngày',
                    'Tuần',
                    'Tháng',
                  ].map((mode) => _viewMode == mode).toList(),
                  onPressed: (index) {
                    setState(
                      () => _viewMode = ['Ngày', 'Tuần', 'Tháng'][index],
                    );
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Ngày'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Tuần'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Tháng'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Nội dung theo chế độ xem
          Expanded(child: _buildView()),
          // Chú thích màu
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _legendChip(Colors.green, 'Lịch học'),
                _legendChip(Colors.yellow, 'Lịch thi'),
                _legendChip(Colors.blue, 'Lịch trực tuyến'),
                _legendChip(Colors.red, 'Tạm ngưng'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildView() {
    if (_viewMode == 'Tháng') {
      return _buildMonthView();
    } else if (_viewMode == 'Tuần') {
      return GestureDetector(
        onHorizontalDragEnd: _handleSwipe, // Xử lý swipe
        child: _buildWeekView(),
      );
    } else {
      return _buildDayView();
    }
  }

  Widget _buildMonthView() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount:
                _daysInMonth.length +
                _daysInMonth.first.weekday -
                1, // Thêm khoảng trống đầu tháng
            itemBuilder: (context, index) {
              if (index < _daysInMonth.first.weekday - 1) {
                return const SizedBox.shrink(); // Khoảng trống
              }
              final date =
                  _daysInMonth[index - (_daysInMonth.first.weekday - 1)];
              final hasEvent = _hasEvent(date);
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDate = date);
                  _viewMode = 'Ngày'; // Chuyển sang chế độ ngày khi nhấn
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: date.day == _selectedDate.day ? Colors.blue : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${date.day}'),
                      if (hasEvent)
                        const Icon(Icons.circle, size: 8, color: Colors.yellow),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: _buildAllSchedulesView(_getSchedulesForMonth(), 'Tháng'),
        ),
      ],
    );
  }

  Widget _buildWeekView() {
    final days = _daysInWeek;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: days.map((date) {
            final hasEvent = _hasEvent(date);
            return GestureDetector(
              onTap: () {
                setState(() => _selectedDate = date);
                _viewMode = 'Ngày'; // Chuyển sang chế độ ngày
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: date.day == _selectedDate.day ? Colors.blue : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      date.weekday == 1
                          ? 'Th 2'
                          : date.weekday == 7
                          ? 'CN'
                          : 'Th ${date.weekday + 1}',
                    ),
                    Text('${date.day}'),
                    if (hasEvent)
                      const Icon(Icons.circle, size: 8, color: Colors.yellow),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        Expanded(child: _buildAllSchedulesView(_getSchedulesForWeek(), 'Tuần')),
      ],
    );
  }

  Widget _buildDayView() {
    final schedules = _getSchedulesForDate(_selectedDate);
    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Không có dữ liệu vào ngày này',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        Color? color;
        switch (schedule['type']) {
          case 'Lịch học':
            color = Colors.green;
            break;
          case 'Lịch thi':
            color = Colors.yellow;
            break;
          case 'Lịch trực tuyến':
            color = Colors.blue;
            break;
          case 'Tạm ngưng':
            color = Colors.red;
            break;
        }
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Tiết: ${schedule['period']}'),
                const SizedBox(height: 8),
                Text('Phòng: ${schedule['room']}'),
                const SizedBox(height: 8),
                Text('Giảng viên: ${schedule['lecturer']}'),
                const SizedBox(height: 8),
                Icon(Icons.circle, size: 12, color: color),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget để hiển thị tất cả lịch của tuần hoặc tháng
  Widget _buildAllSchedulesView(
    List<Map<String, dynamic>> schedules,
    String viewType,
  ) {
    if (schedules.isEmpty) {
      return const Center(child: Text('Không có lịch trong  ngày'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        Color? color;
        switch (schedule['type']) {
          case 'Lịch học':
            color = Colors.green;
            break;
          case 'Lịch thi':
            color = Colors.yellow;
            break;
          case 'Lịch trực tuyến':
            color = Colors.blue;
            break;
          case 'Tạm ngưng':
            color = Colors.red;
            break;
        }
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${schedule['date'].day}/${schedule['date'].month}/${schedule['date'].year} - ${schedule['title']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Tiết: ${schedule['period']}'),
                const SizedBox(height: 8),
                Text('Phòng: ${schedule['room']}'),
                const SizedBox(height: 8),
                Text('Giảng viên: ${schedule['lecturer']}'),
                const SizedBox(height: 8),
                Icon(Icons.circle, size: 12, color: color),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _legendChip(Color color, String label) {
    return Row(
      children: [
        Icon(Icons.circle, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
