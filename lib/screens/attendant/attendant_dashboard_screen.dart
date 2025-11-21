import 'package:diem_danh_sinh_vien/screens/notifications/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../services/fcm_service.dart';
import '../../main.dart';

import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../services/attendant_service.dart';
import '../settings/settings_screen.dart';
import 'attendant_events_screen.dart';
import 'attendant_event_detail_screen.dart';

class AttendantDashboardScreen extends StatefulWidget {
  const AttendantDashboardScreen({super.key});

  @override
  State<AttendantDashboardScreen> createState() =>
      _AttendantDashboardScreenState();
}

class _AttendantDashboardScreenState extends State<AttendantDashboardScreen> {
  List<Map<String, dynamic>> upcomingEvents = [];
  Map<String, dynamic>? userData;
  String? attendantName;
  String? attendantId;
  String? userRole;
  bool _isLoading = true;
  int _selectedIndex = 0;
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initializeFCM();
    _loadUnreadNotificationCount();
  }

  Future<void> _loadUnreadNotificationCount() async {
    final result = await NotificationService.getNotifications(
      page: 1,
      perPage: 100,
    );

    if (result['success'] == true && mounted) {
      final notifications = result['data'] as List;
      setState(() {
        _unreadNotificationCount = notifications
            .where((n) => n['isRead'] == 0)
            .length;
      });
    }
  }

  Future<void> _initializeFCM() async {
    String? accessToken = await AuthService.getToken();
    if (accessToken != null) {
      await FCMService().initialize(accessToken, navigatorKey);
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get profile
      final profileResult = await AuthService.getProfile();

      if (profileResult['success'] == true) {
        final data = profileResult['data'];
        if (data != null) {
          final user = data['user'];

          setState(() {
            userData = data;
            attendantName = user?['username'];
            attendantId = user?['id']?.toString();
            userRole = user?['role'];
          });
        }
      } else {
        // Fallback to local data
        final localData = await AuthService.getUserData();
        if (localData != null) {
          final user = localData['user'];

          setState(() {
            userData = localData;
            attendantName = user?['username'];
            attendantId = user?['id']?.toString();
            userRole = user?['role'];
          });
        }
      }

      // Get upcoming events for attendant
      final events = await AttendantService.getEvents(status: 'upcoming');

      if (mounted) {
        setState(() {
          upcomingEvents = events.take(3).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    // Save FCM token
    if (attendantId != null) {
      String? accessToken = await AuthService.getToken();
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (accessToken != null && fcmToken != null) {
        await NotificationService.saveFcmToken(fcmToken, accessToken);
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return const AttendantEventsScreen();
      case 2:
        return const SettingsScreen();
      default:
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildFeatureCard(),
            const SizedBox(height: 24),
            _buildUpcomingEvents(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: _selectedIndex == 0
            ? Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.green[100],
                    child: const Icon(
                      Icons.person,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Xin chào, ${attendantName ?? 'Cán bộ'}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Hỗ trợ điểm danh',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Text(
                _selectedIndex == 1 ? 'Hỗ trợ điểm danh' : 'Cài đặt',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                  _loadUnreadNotificationCount();
                },
              ),
              if (_unreadNotificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _unreadNotificationCount > 99
                          ? '99+'
                          : _unreadNotificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined),
            activeIcon: Icon(Icons.qr_code_scanner),
            label: 'Điểm danh',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = 1;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 140,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hỗ trợ điểm danh',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Quét mã QR để điểm danh cho sinh viên',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sự kiện sắp diễn ra',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (upcomingEvents.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có sự kiện nào',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            ...upcomingEvents.map((event) => _buildEventCard(event)),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final status = event['status']?.toString().toLowerCase() ?? 'unknown';
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AttendantEventDetailScreen(
                eventId: event['id'],
               
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.qr_code_scanner,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                event['eventName'] ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Từ ${event['startDate']} đến ${event['endDate']}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return Colors.blue;
      case 'ongoing':
        return Colors.green;
      case 'ended':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'upcoming':
        return 'Sắp diễn ra';
      case 'ongoing':
        return 'Đang diễn ra';
      case 'ended':
        return 'Đã kết thúc';
      default:
        return status;
    }
  }
}
