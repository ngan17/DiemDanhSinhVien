import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../services/face_service.dart';
import '../../services/location_service.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<EventModel> _openEvents = [];
  List<EventRegistrationModel> _myRegistrations = [];
  List<EventRegistrationModel> _historyRegistrations = [];
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadTabData(_tabController.index);
      }
    });
    _loadTabData(0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTabData(int tabIndex) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (tabIndex == 0) {
        await _loadOpenEvents();
      } else if (tabIndex == 1) {
        await _loadMyRegistrations(false);
      } else {
        // Lịch sử - Load history (attended & rejected)
        await _loadMyRegistrations(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadOpenEvents() async {
    try {
      final result = await EventService.getAllEvents();
      if (!mounted) return;

      if (result['success'] == true) {
        final List<dynamic> eventsJson = result['data'] ?? [];
        final allEvents = eventsJson
            .map((json) => EventModel.fromJson(json))
            .toList();

        setState(() {
          _openEvents = allEvents.where((event) => !event.isEnded).toList();
        });
      } else {
        // Hiển thị lỗi từ API
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Không thể tải danh sách sự kiện',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi kết nối: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> _loadMyRegistrations(bool isHistory) async {
    try {
      final result = await EventService.getMyRegistrations();
      if (!mounted) return;

      if (result['success'] == true) {
        final List<dynamic> regsJson = result['data'] ?? [];
        final allRegs = regsJson
            .map((json) => EventRegistrationModel.fromJson(json))
            .toList();

        setState(() {
          if (isHistory) {
            _historyRegistrations = allRegs
                .where(
                  (r) =>
                      r.status == 'attended' ||
                      r.status == 'rejected' ||
                      r.status == 'canceled',
                )
                .toList();
          } else {
            _myRegistrations = allRegs
                .where((r) => r.status == 'pending' || r.status == 'approved')
                .toList();
          }
        });
      } else {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi kết nối: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> _registerEvent(EventModel event) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(eventId: event.id),
      ),
    ).then((_) => _loadTabData(_tabController.index));
  }

  Future<void> _cancelRegistration(EventRegistrationModel registration) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        _loadTabData(_tabController.index);
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

  /// Xử lý điểm danh
  Future<void> _handleAttendance(EventRegistrationModel registration) async {
    print(' Handle attendance for: ${registration.eventName}');
    print('   Event Detail ID: ${registration.eventDetailId}');

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await EventService.checkAttendanceEligibility(
        registration.eventDetailId,
      );

      if (!mounted) return;
      Navigator.pop(context); // Đóng loading

      if (result['success'] == true) {
        final data = result['data'] ?? {};
        final canAttend = data['canAttend'] ?? false;
        final message = data['message'] ?? '';

        if (canAttend) {
          _showAttendanceOptions(registration, data);
        } else {
          _showErrorDialog(message);
        }
      } else {
        _showErrorDialog(result['message'] ?? 'Không thể kiểm tra điều kiện');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog('Lỗi: $e');
      }
    }
  }

  /// Hiển thị dialog chọn phương thức điểm danh
  void _showAttendanceOptions(
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
                  _attendByFace(registration, data);
                },
              ),
            if (attendanceMethods['camera'] == 1 &&
                !attendedMethods.contains('camera'))
              ListTile(
                leading: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.orange,
                ),
                title: const Text('Quét camera'),
                onTap: () {
                  Navigator.pop(context);
                  _showErrorDialog('Tính năng đang phát triển');
                },
              ),
            if (attendanceMethods['barcode'] == 1 &&
                !attendedMethods.contains('barcode'))
              ListTile(
                leading: const Icon(Icons.qr_code, color: Colors.purple),
                title: const Text('Quét mã QR'),
                onTap: () {
                  Navigator.pop(context);
                  _showErrorDialog('Hỗ trợ điểm danh sẽ điểm danh bạn');
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

  /// Điểm danh bằng ảnh minh chứng
  Future<void> _attendByProof(EventRegistrationModel registration) async {
    try {
      // Kiểm tra vị trí và chống fake GPS TRƯỚC KHI cho phép chụp ảnh
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang kiểm tra vị trí...'),
            ],
          ),
        ),
      );

      try {
        await LocationService.checkLocation();
        if (!mounted) return;
        Navigator.pop(context); // Đóng dialog kiểm tra vị trí
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); // Đóng dialog kiểm tra vị trí
        _showErrorDialog(e.toString());
        return;
      }

      // Sau khi vị trí hợp lệ mới cho phép chụp ảnh
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo == null) return;

      if (!mounted) return;

      // Hiển thị loading
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
      Navigator.pop(context); // Đóng loading

      if (result['success'] == true) {
        final data = result['data'] ?? {};
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
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Thời gian: ${data['attendTime'] ?? ''}',
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (currentSchedule != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.green[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Khung giờ ${currentSchedule['index']}: ${currentSchedule['start']} - ${currentSchedule['end']}',
                              style: TextStyle(
                                color: Colors.green[900],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
                  _loadTabData(_tabController.index);
                },
                child: const Text('Đóng'),
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
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog('Lỗi: $e');
      }
    }
  }

  /// Điểm danh bằng nhận diện khuôn mặt
  Future<void> _attendByFace(
    EventRegistrationModel registration,
    Map<String, dynamic> data,
  ) async {
    try {
      // Kiểm tra vị trí và chống fake GPS TRƯỚC KHI cho phép chụp ảnh
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang kiểm tra vị trí...'),
            ],
          ),
        ),
      );

      try {
        await LocationService.checkLocation();
        if (!mounted) return;
        Navigator.pop(context); // Đóng dialog kiểm tra vị trí
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); // Đóng dialog kiểm tra vị trí
        _showErrorDialog(e.toString());
        return;
      }

      // Bước 1: Chụp ảnh
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo == null) return;

      if (!mounted) return;

      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Đang nhận diện khuôn mặt...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );

      // Bước 2: Gọi Python để verify face
      final verifyResult = await FaceService().verifyFace(photo.path);

      if (!mounted) return;

      if (verifyResult['success'] != true) {
        Navigator.pop(context); // Đóng loading
        _showErrorDialog(
          verifyResult['message'] ?? 'Không nhận diện được khuôn mặt',
        );
        return;
      }

      final studentId = verifyResult['student_id'] as String;
      final confidence = verifyResult['confidence'] as double;

      print(' Nhận diện thành công: $studentId, confidence: $confidence%');

      // Bước 3: Gọi Laravel để lưu attendance
      final attendResult = await EventService.attendByFace(
        registration.registrationId,
        studentId,
        confidence,
      );

      if (!mounted) return;
      Navigator.pop(context); // Đóng loading

      if (attendResult['success'] == true) {
        final attendData = attendResult['data'] ?? {};
        final progress = attendData['attendanceProgress'] ?? {};
        final currentSchedule = attendData['currentSchedule'];

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
                  attendResult['message'] ?? 'Điểm danh thành công!',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row(
                      //   children: [
                      //     Icon(Icons.face, color: Colors.green[700], size: 20),
                      //     const SizedBox(width: 8),
                      //     Text(
                      //       'Độ chính xác: ${confidence.toStringAsFixed(1)}%',
                      //       style: TextStyle(
                      //         color: Colors.green[900],
                      //         fontWeight: FontWeight.bold,
                      //         fontSize: 16,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Thời gian: ${attendData['attendTime'] ?? ''}',
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (currentSchedule != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.orange[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Khung giờ ${currentSchedule['index']}: ${currentSchedule['start']} - ${currentSchedule['end']}',
                                style: TextStyle(
                                  color: Colors.orange[900],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
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
                  _loadTabData(_tabController.index);
                },
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      } else {
        // Kiểm tra xem có thông tin khung giờ không
        if (attendResult['availableSchedules'] != null) {
          _showScheduleErrorDialog(
            attendResult['message'] ?? 'Không thể điểm danh',
            attendResult['currentTime'],
            attendResult['availableSchedules'],
            attendResult['method'],
          );
        } else {
          _showErrorDialog(attendResult['message'] ?? 'Điểm danh thất bại');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog('Lỗi: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông báo'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: const Text(
          'Sự kiện',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,

        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2196F3),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: const Color(0xFF2196F3),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Đang mở'),
            Tab(text: 'Đã đăng ký'),
            Tab(text: 'Lịch sử sự kiện'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOpenEventsTab(),
          _buildMyEventsTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildOpenEventsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_openEvents.isEmpty) {
      return _buildEmptyState('Không có sự kiện đang mở');
    }

    return RefreshIndicator(
      onRefresh: () => _loadTabData(0),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _openEvents.length,
        itemBuilder: (context, index) {
          final event = _openEvents[index];
          return _buildOpenEventCard(event);
        },
      ),
    );
  }

  Widget _buildMyEventsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myRegistrations.isEmpty) {
      return _buildEmptyState('Bạn chưa đăng ký sự kiện nào');
    }

    return RefreshIndicator(
      onRefresh: () => _loadTabData(1),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myRegistrations.length,
        itemBuilder: (context, index) {
          final registration = _myRegistrations[index];
          return _buildRegistrationCard(registration);
        },
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_historyRegistrations.isEmpty) {
      return _buildEmptyState('Chưa có lịch sử sự kiện');
    }

    return RefreshIndicator(
      onRefresh: () => _loadTabData(2),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _historyRegistrations.length,
        itemBuilder: (context, index) {
          final registration = _historyRegistrations[index];
          return _buildHistoryCard(registration);
        },
      ),
    );
  }

  Widget _buildOpenEventCard(EventModel event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(eventId: event.id),
            ),
          ).then((_) => _loadTabData(_tabController.index));
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.eventName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.formattedDateRange,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.eventTypeName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EventDetailScreen(eventId: event.id),
                        ),
                      ).then((_) => _loadTabData(_tabController.index));
                    },
                    child: const Text('Chi tiết'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _registerEvent(event),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Đăng ký'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationCard(EventRegistrationModel registration) {
    final statusColor = _getStatusColor(registration.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EventDetailScreen(eventId: registration.eventDetailId),
            ),
          ).then((_) => _loadTabData(_tabController.index));
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          registration.eventName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          registration.statusText,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.event_note, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          registration.session,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          registration.location,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text(
                        '+${registration.conductScore} điểm',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.amber[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Nút điểm danh - chỉ hiện khi approved
                  if (registration.status.toLowerCase() == 'approved') ...[
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
                  ],
                  // Nút hủy - chỉ hiện khi pending
                  if (registration.status.toLowerCase() == 'pending')
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _cancelRegistration(registration),
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Hủy đăng ký'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(EventRegistrationModel registration) {
    final statusColor = _getStatusColor(registration.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EventDetailScreen(eventId: registration.eventDetailId),
            ),
          ).then((_) => _loadTabData(_tabController.index));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      registration.eventName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      registration.statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      registration.formattedCreditDate,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      registration.location,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              if (registration.status == 'attended') ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber[700]),
                    const SizedBox(width: 4),
                    Text(
                      '+${registration.conductScore} điểm',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.amber[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'attended':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'canceled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
