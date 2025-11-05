import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  List<EventRegistrationModel> _registrations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyRegistrations();
  }

  Future<void> _loadMyRegistrations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await EventService.getMyRegistrations();

      if (!mounted) return;

      if (result['success'] == true) {
        final List<dynamic> regsJson = result['data'] ?? [];
        setState(() {
          _registrations = regsJson
              .map((json) => EventRegistrationModel.fromJson(json))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
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
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _cancelRegistration(EventRegistrationModel registration) async {
    // Show confirmation dialog
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

    // Show loading
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

      // Close loading dialog
      Navigator.pop(context);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Hủy đăng ký thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload list
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
        // Close loading dialog
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }




  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'attended':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.all(16),
                itemCount: _registrations.length,
                itemBuilder: (context, index) {
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
                  '+${registration.conductScore} điểm rèn luyện',
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
                Icon(Icons.app_registration, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Đăng ký lúc: ${registration.formattedRegisterTime}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            // Registered Time
            const SizedBox(height: 6),
            Row(
              children: [
                // Cancel Button (only for pending status)
                if (registration.status == 'pending')
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
          ],
        ),
      ),
    );
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
