import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Danh Sách Sự Kiện Sinh Viên',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: EventListScreen(),
    );
  }
}

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Danh sách sự kiện mẫu
  static const List<Map<String, dynamic>> events = [
    {
      'title': 'Hội Thảo Công Nghệ 2025',
      'code': 'TECH2025',
      'date': '20/07/2025',
      'location': 'Hội trường A, Đại học XYZ',
      'organizer': 'Khoa Công nghệ Thông tin',
      'description':
          'Một hội thảo về công nghệ mới dành cho sinh viên, với các diễn giả nổi tiếng và cơ hội networking.',
    },
    {
      'title': 'Workshop Lập Trình AI',
      'code': 'AI2025',
      'date': '25/07/2025',
      'location': 'Phòng Lab B, Đại học XYZ',
      'organizer': 'Câu lạc bộ AI',
      'description':
          'Học cách xây dựng mô hình AI cơ bản với Python và TensorFlow.',
    },
    {
      'title': 'Ngày Hội Sinh Viên',
      'code': 'SV2025',
      'date': '01/08/2025',
      'location': 'Sân trường Đại học XYZ',
      'organizer': 'Đoàn Thanh niên',
      'description':
          'Các hoạt động vui chơi, giao lưu và quà tặng dành cho sinh viên.',
    },
  ];

  List<Map<String, dynamic>> registeredEvents = [];
  List<Map<String, dynamic>> filteredEvents = List.from(events);
  String searchQuery = '';
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _registerEvent(Map<String, dynamic> event) {
    setState(() {
      registeredEvents.add(event);
    });
  }

  void _filterEvents() {
    setState(() {
      filteredEvents = events.where((event) {
        final query = searchQuery.toLowerCase();
        final matchesSearch =
            event['title'].toString().toLowerCase().contains(query) ||
            event['code'].toString().toLowerCase().contains(query) ||
            event['organizer'].toString().toLowerCase().contains(query);
        final matchesDate =
            selectedDate == null ||
            DateFormat('dd/MM/yyyy')
                .parse(event['date'])
                .isAtSameMomentAs(
                  DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                  ),
                );

        return matchesSearch && matchesDate;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Sách Sự Kiện'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sự Kiện'),
            Tab(text: 'Đã Đăng Ký'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Sự Kiện
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Thanh tìm kiếm chung
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Tìm kiếm (tên, mã, bộ phận tổ chức)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.blue[50],
                      ),
                      onChanged: (value) {
                        searchQuery = value;
                        _filterEvents();
                      },
                    ),
                    SizedBox(height: 16),
                    // Bộ lọc ngày (Calendar)
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Chọn ngày diễn ra sự kiện',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.calendar_today),
                        filled: true,
                        fillColor: Colors.blue[50],
                      ),
                      controller: TextEditingController(
                        text: selectedDate != null
                            ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                            : '',
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2025),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                            _filterEvents();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = filteredEvents[index];
                    return Card(
                      color: Colors.blue[50],
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['title'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Mã: ${event['code']}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  event['date'],
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  event['location'],
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Bộ phận tổ chức: ${event['organizer']}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              event['description'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EventRegistrationScreen(
                                            eventTitle: event['title'],
                                            onRegister: () =>
                                                _registerEvent(event),
                                          ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Đăng Ký',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Tab Đã Đăng Ký
          registeredEvents.isEmpty
              ? Center(child: Text('Chưa có sự kiện nào được đăng ký'))
              : ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: registeredEvents.length,
                  itemBuilder: (context, index) {
                    final event = registeredEvents[index];
                    return Card(
                      color: Colors.green[50],
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['title'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Mã: ${event['code']}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  event['date'],
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  event['location'],
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Bộ phận tổ chức: ${event['organizer']}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              event['description'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class EventRegistrationScreen extends StatefulWidget {
  final String eventTitle;
  final VoidCallback onRegister;

  const EventRegistrationScreen({
    super.key,
    required this.eventTitle,
    required this.onRegister,
  });

  @override
  _EventRegistrationScreenState createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _studentId = '';
  String _class = '';
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng Ký Sự Kiện'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sự Kiện: ${widget.eventTitle}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Ngày: 20/07/2025',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Địa điểm: Hội trường A, Đại học XYZ',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Mô tả: Một hội thảo về công nghệ mới dành cho sinh viên, với các diễn giả nổi tiếng và cơ hội networking.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Đăng Ký Tham Gia',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Họ và Tên',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.blue[50],
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Vui lòng nhập họ tên' : null,
                    onSaved: (value) => _name = value!,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.blue[50],
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Vui lòng nhập email' : null,
                    onSaved: (value) => _email = value!,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Mã Sinh Viên',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.school),
                      filled: true,
                      fillColor: Colors.blue[50],
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Vui lòng nhập mã sinh viên' : null,
                    onSaved: (value) => _studentId = value!,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Lớp',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.class_),
                      filled: true,
                      fillColor: Colors.blue[50],
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Vui lòng nhập lớp' : null,
                    onSaved: (value) => _class = value!,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Ngày Tham Gia Sự Kiện',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.calendar_today),
                      filled: true,
                      fillColor: Colors.blue[50],
                    ),
                    controller: TextEditingController(
                      text: _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : '',
                    ),
                    validator: (value) =>
                        _selectedDate == null ? 'Vui lòng chọn ngày' : null,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        widget.onRegister();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đăng ký thành công!')),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Đăng Ký Ngay', style: TextStyle(fontSize: 18)),
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
