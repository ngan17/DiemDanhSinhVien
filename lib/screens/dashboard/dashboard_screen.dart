import 'package:diem_danh_sinh_vien/screens/events/event_detail_screen.dart';
import 'package:diem_danh_sinh_vien/screens/notifications/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../services/fcm_service.dart';
import '../../main.dart';

import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../utils/face_auth_helper.dart';
import '../settings/settings_screen.dart';
import '../events/event_list_screen.dart';
import 'training_score_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<EventModel> upcomingEvents = [];
  List<EventRegistrationModel> myRegistrations = [];
  Map<String, dynamic>? userData;
  String? studentName;
  String? studentId;
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
    _checkFaceRegistration();
  }

  Future<void> _checkFaceRegistration() async {
    // Đợi 500ms để màn hình load xong
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    await FaceAuthHelper.checkAndNavigateToFaceAuth(context);
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
      final profileResult = await AuthService.getProfile();

      if (profileResult['success'] == true) {
        final data = profileResult['data'];
        if (data != null) {
          final student = data['student'];
          final user = data['user'];
          print('user Info: $user');
          print('student Info: $student');

          setState(() {
            userData = {'user': user, 'student': student};
            studentName = student?['studentName'];
            studentId = student?['id'];
            userRole = user?['role'];
          });
        }
      } else {
        print('Failed to get profile: ${profileResult['message']}');

        final localData = await AuthService.getUserData();
        if (localData != null) {
          final student = localData['student'];
          final user = localData['user'];

          setState(() {
            userData = localData;
            studentName = student?['studentName'];
            studentId = student?['id'];
            userRole = user?['role'];
          });
        }
      }

      final eventsResult = await EventService.getAllEvents();
     // final regsResult = await EventService.getMyRegistrations();

      if (mounted) {
        setState(() {
          if (eventsResult['success'] == true) {
            final List<dynamic> eventsJson = eventsResult['data'] ?? [];
            final allEvents = eventsJson
                .map((json) => EventModel.fromJson(json))
                .toList();

            upcomingEvents = allEvents
                .where((event) => !event.isEnded)
                .take(3)
                .toList();
          }

     
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
        return const EventListScreen();
      case 2:
        return const TrainingScoreScreen();
      case 3:
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
            _buildFeatureCards(),
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
    return WillPopScope(
      onWillPop: () async {
        // Chặn nút back
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: _selectedIndex == 0
            ? AppBar(
                backgroundColor: Colors.white,
                elevation: 0.5,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(
                        Icons.person,
                        color: Colors.grey,
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
                            'Xin chào, ${studentName ?? 'Sinh viên'}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'MSSV: ${studentId ?? '----'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
              )
            : _selectedIndex == 2
            ? AppBar(
                backgroundColor: Colors.white,
                elevation: 0.5,
                automaticallyImplyLeading: false,
                title: const Text(
                  'Điểm rèn luyện',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
              )
            : null,
        body: _buildCurrentScreen(),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color(0xFF2196F3),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event),
              label: 'Sự kiện',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Điểm rèn luyện',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Cài đặt',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildFeatureCard(
              title: 'Đăng ký Sự kiện',
              icon: Icons.calendar_today,
              color: const Color(0xFF42A5F5),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildFeatureCard(
              title: 'Điểm rèn luyện',
              icon: Icons.bar_chart,
              color: const Color(0xFF66BB6A),
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sự kiện sắp diễn ra',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (upcomingEvents.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Chưa có sự kiện nào',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ...upcomingEvents.map((event) => _buildEventCard(event)),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(eventId: event.id),
          ),
        );
      },
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
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    event.status,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event.eventName,
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
                    event.formattedDateRange,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
