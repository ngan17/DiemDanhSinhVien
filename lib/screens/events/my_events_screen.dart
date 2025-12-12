import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import 'event_detail_screen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  List<EventRegistrationModel> _registrations = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  final ImagePicker _picker = ImagePicker();

  int _currentPage = 1;
  int _totalPages = 1;
  final int _perPage = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMyRegistrations();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _currentPage < _totalPages) {
        _loadMoreRegistrations();
      }
    }
  }

  Future<void> _loadMyRegistrations() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });

    try {
      print(' Loading my registrations...');
      final result = await EventService.getMyRegistrations(
        page: _currentPage,
        perPage: _perPage,
      );
      print(' API Response: ${result['success']}');

      if (!mounted) return;

      if (result['success'] == true) {
        final List<dynamic> regsJson = result['data'] ?? [];
        final pagination = result['pagination'] ?? {};

        print(' Parsing ${regsJson.length} registrations...');
        print(' Pagination: $pagination');

        setState(() {
          _registrations = regsJson.map((json) {
            print('\n' + '=' * 60);
            print('📥 RAW JSON DATA:');
            print(
              '   eventId (from JSON): ${json['eventId']} (type: ${json['eventId'].runtimeType})',
            );
            print(
              '   eventDetailId (from JSON): ${json['eventDetailId']} (type: ${json['eventDetailId'].runtimeType})',
            );
            print('   eventName: ${json['eventName']}');

            final reg = EventRegistrationModel.fromJson(json);

            print('📦 PARSED MODEL:');
            print(
              '   reg.eventId: ${reg.eventId} (type: ${reg.eventId.runtimeType})',
            );
            print(
              '   reg.eventDetailId: ${reg.eventDetailId} (type: ${reg.eventDetailId.runtimeType})',
            );
            print('   reg.eventName: ${reg.eventName}');
            print('=' * 60 + '\n');
            return reg;
          }).toList();
          _totalPages = pagination['last_page'] ?? 1;
          _isLoading = false;
        });

        print(' Total registrations loaded: ${_registrations.length}');
        print(' Current page: $_currentPage / $_totalPages');
      } else {
        print(' Failed to load: ${result['message']}');
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Không thể tải danh sách đăng ký',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print(' Error loading registrations: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadMoreRegistrations() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;

    setState(() => _isLoadingMore = true);

    try {
      final result = await EventService.getMyRegistrations(
        page: _currentPage + 1,
        perPage: _perPage,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final List<dynamic> regsJson = result['data'] ?? [];
        final pagination = result['pagination'] ?? {};

        setState(() {
          _registrations.addAll(
            regsJson
                .map((json) => EventRegistrationModel.fromJson(json))
                .toList(),
          );
          _currentPage++;
          _totalPages = pagination['last_page'] ?? 1;
          _isLoadingMore = false;
        });

        print(' Loaded more: ${regsJson.length} items');
        print(' Current page: $_currentPage / $_totalPages');
      } else {
        setState(() => _isLoadingMore = false);
      }
    } catch (e) {
      print(' Error loading more: $e');
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _cancelRegistration(EventRegistrationModel registration) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: Text(
          'Bạn có chắc chắn muốn hủy đăng ký sự kiện "${registration.eventName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Hủy đăng ký',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await EventService.cancelRegistration(
        registration.registrationId,
      );

      if (!mounted) return;

      Navigator.pop(context);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Hủy đăng ký thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadMyRegistrations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Hủy đăng ký thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleAttendance(EventRegistrationModel registration) async {
    // Kiểm tra có phương thức điểm danh nào được bật không
    if (registration.isAttendFace == 0 &&
        registration.isAttendProof == 0 &&
        registration.isAttendCamera == 0 &&
        registration.isAttendBarcode == 0) {
      _showErrorDialog('Sự kiện chưa được cấu hình phương thức điểm danh');
      return;
    }

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Kiểm tra điều kiện điểm danh (thời gian, số lần, ...)
      final checkResult = await EventService.checkAttendanceEligibility(
        registration.eventDetailId,
      );

      if (!mounted) return;

      Navigator.pop(context); // Đóng loading

      print('📦 Check result: $checkResult');

      if (checkResult['success'] != true) {
        _showErrorDialog(
          checkResult['message'] ?? 'Không thể kiểm tra điều kiện điểm danh',
        );
        return;
      }

      final data = checkResult['data'];
      final canAttend = data['canAttend'] ?? false;

      if (!canAttend) {
        _showErrorDialog(data['message'] ?? 'Không thể điểm danh');
        return;
      }

      // Hiển thị dialog chọn phương thức
      _showAttendanceMethodDialog(registration, data);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog('Lỗi: $e');
      }
    }
  }

  void _showAttendanceMethodDialog(
    EventRegistrationModel registration,
    Map<String, dynamic> data,
  ) {
    final progress = data['attendanceProgress'] ?? {};
    final attendedMethods = List<String>.from(data['attendedMethods'] ?? []);
    final attendanceMethods = data['attendanceMethods'] ?? {};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn phương thức điểm danh'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tiến độ: ${progress['current']}/${progress['total']} lần',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (attendedMethods.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Đã điểm danh: ${attendedMethods.join(", ")}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Chỉ hiển thị các phương thức CHƯA điểm danh
            if (attendanceMethods['proof'] == 1 &&
                !attendedMethods.contains('proof'))
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Chụp ảnh minh chứng'),
                onTap: () {
                  Navigator.pop(context);
                  _attendByProof(registration);
                },
              ),
            if (attendanceMethods['face'] == 1 &&
                !attendedMethods.contains('face'))
              ListTile(
                leading: const Icon(Icons.face, color: Colors.green),
                title: const Text('Nhận diện khuôn mặt'),
                onTap: () {
                  Navigator.pop(context);
                  _attendByFace(registration);
                },
              ),
            if (attendanceMethods['camera_IOT'] == 1 &&
                !attendedMethods.contains('camera_IOT'))
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.orange),
                title: const Text('Camera IOT'),
                onTap: () {
                  Navigator.pop(context);
                  _showErrorDialog('Hệ thống IOT sẽ điểm danh bạn');
                },
              ),
            if (attendanceMethods['barcode'] == 1 &&
                !attendedMethods.contains('barcode'))
              ListTile(
                leading: const Icon(Icons.qr_code, color: Colors.purple),
                title: const Text('Quét mã Barcode'),
                onTap: () {
                  Navigator.pop(context);
                  _showErrorDialog('Tính năng đang phát triển');
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  Future<void> _attendByProof(EventRegistrationModel registration) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo == null) {
        print(' User cancelled camera');
        return;
      }

      print(' Photo captured: ${photo.path}');

      if (!mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận điểm danh'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(
                File(photo.path),
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),
              const Text('Xác nhận sử dụng ảnh này để điểm danh?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Chụp lại'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'Xác nhận',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        _attendByProof(registration);
        return;
      }

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final result = await EventService.attendByProof(
        registration.registrationId,
        photo.path,
      );

      if (!mounted) return;

      Navigator.pop(context);

      if (result['success'] == true) {
        final data = result['data'];
        final progress = data['attendanceProgress'] ?? {};
        final currentSchedule = data['currentSchedule'];

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Điểm danh thành công!',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result['message'] ?? 'Điểm danh thành công!',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Colors.blue[700],
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Thời gian:',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data['attendTime']}',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      if (currentSchedule != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.green[700],
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Khung giờ ${currentSchedule['index']}:',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${currentSchedule['start']} - ${currentSchedule['end']}',
                          style: TextStyle(
                            color: Colors.green[900],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tiến độ: ${progress['current']}/${progress['total']} lần',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (progress['remaining'] > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Còn lại: ${progress['remaining']} lần',
                    style: TextStyle(color: Colors.orange[700]),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadMyRegistrations();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Kiểm tra xem có thông tin khung giờ không
        if (result['availableSchedules'] != null) {
          _showScheduleErrorDialog(
            result['message'] ?? 'Không thể điểm danh',
            result['currentTime'],
            result['availableSchedules'],
            result['method'],
          );
        } else {
          _showErrorDialog(result['message'] ?? 'Điểm danh thất bại');
        }
      }
    } catch (e) {
      print(' Error attendByProof: $e');
      if (mounted) {
        _showErrorDialog('Lỗi: $e');
      }
    }
  }

  Future<void> _attendByFace(EventRegistrationModel registration) async {
    try {
      // TODO: Implement face recognition
      _showErrorDialog('Tính năng nhận diện khuôn mặt đang phát triển');
    } catch (e) {
      print(' Error attendByFace: $e');
      if (mounted) {
        _showErrorDialog('Lỗi: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Thông báo'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showScheduleErrorDialog(
    String message,
    String? currentTime,
    List<dynamic>? schedules,
    String? method,
  ) {
    String methodName = '';
    if (method == 'proof') {
      methodName = 'minh chứng';
    } else if (method == 'face') {
      methodName = 'khuôn mặt';
    } else if (method == 'barcode') {
      methodName = 'barcode';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange[700], size: 32),
            const SizedBox(width: 12),
            const Expanded(child: Text('Thông báo điểm danh')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (currentTime != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Giờ hiện tại: $currentTime',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (methodName.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.purple[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Phương thức: $methodName',
                          style: TextStyle(
                            color: Colors.purple[900],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (schedules != null && schedules.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Khung giờ điểm danh:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...schedules.map((schedule) {
                  final index = schedule['index'] ?? 0;
                  final start = schedule['start'] ?? '';
                  final end = schedule['end'] ?? '';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.green[700],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$index',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '$start - $end',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[900],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'wait_confirm':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'canceled':
        return Colors.red;
      case 'attended':
        return Colors.green;
      case 'student_canceled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
      ' Build called - isLoading: $_isLoading, registrations: ${_registrations.length}',
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E90FF),
        elevation: 0,
        title: const Text(
          'Sự kiện của tôi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMyRegistrations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _registrations.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadMyRegistrations,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _registrations.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _registrations.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final registration = _registrations[index];
                  return _buildRegistrationCard(registration);
                },
              ),
            ),
    );
  }

  Widget _buildRegistrationCard(EventRegistrationModel registration) {
    final statusColor = _getStatusColor(registration.status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          print('\n' + '🔔' * 30);
          print('🔔 CARD TAPPED!');
          print('🔔 Event Name: ${registration.eventName}');
          print(
            '🔔 registration.eventId = ${registration.eventId} (type: ${registration.eventId.runtimeType})',
          );
          print(
            '🔔 registration.eventDetailId = ${registration.eventDetailId} (type: ${registration.eventDetailId.runtimeType})',
          );
          print(
            '🔔 registration.registrationId = ${registration.registrationId}',
          );

          final eventIdToPass = registration.eventId;
          print('🔔 eventIdToPass variable = $eventIdToPass');
          print(
            '🔔 About to navigate to EventDetailScreen with eventId: $eventIdToPass',
          );
          print('🔔' * 30 + '\n');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                print(
                  '🚀 Building EventDetailScreen with eventId: $eventIdToPass',
                );
                return EventDetailScreen(eventId: eventIdToPass);
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Badge & Event Type
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      registration.statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        registration.eventTypeName,
                        style: TextStyle(
                          color: Colors.purple[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Event Name
              Text(
                registration.eventName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Session
              Row(
                children: [
                  Icon(Icons.event_note, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      registration.session,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Location
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      registration.location,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Time
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      registration.formattedCreditDate,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Points
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  Text(
                    '+${registration.conductScore} điểm',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.amber[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Registered Time
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.app_registration,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Đăng ký lúc: ${registration.formattedRegisterTime}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),

              // Action Buttons
              const SizedBox(height: 12),
              if (registration.status == 'student_canceled') ...[
                // Không hiển thị nút gì với status student_canceled
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Đăng ký đã được hủy',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (registration.status == 'confirmed') ...[
                // Chỉ confirmed mới hiện nút điểm danh
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleAttendance(registration),
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Điểm danh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _cancelRegistration(registration),
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Hủy'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (registration.status == 'wait_confirm') ...[
                // wait_confirm chỉ hiện nút hủy
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _cancelRegistration(registration),
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Hủy đăng ký'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ), // Đóng Padding
      ), // Đóng InkWell
    ); // Đóng Card
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có sự kiện nào',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn chưa đăng ký sự kiện nào',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
