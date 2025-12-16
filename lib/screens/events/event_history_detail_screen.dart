import 'package:flutter/material.dart';
import '../../services/event_service.dart';
import 'event_detail_screen.dart';

class EventHistoryDetailScreen extends StatefulWidget {
  final int eventDetailId;
  final int registrationId;

  const EventHistoryDetailScreen({
    Key? key,
    required this.eventDetailId,
    required this.registrationId,
  }) : super(key: key);

  @override
  State<EventHistoryDetailScreen> createState() =>
      _EventHistoryDetailScreenState();
}

class _EventHistoryDetailScreenState extends State<EventHistoryDetailScreen> {
  Map<String, dynamic>? _eventDetail;
  bool _isLoading = true;
  bool _isReregistering = false;

  @override
  void initState() {
    super.initState();
    _loadEventDetail();
  }

  Future<void> _loadEventDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await EventService.getEventDetailHistory(
        widget.eventDetailId,
      );

      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            _eventDetail = result['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Không thể tải thông tin'),
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

  Future<void> _reregisterEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận đăng ký lại'),
        content: Text(
          'Bạn có muốn đăng ký lại sự kiện "${_eventDetail?['eventName']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
            ),
            child: const Text('Đăng ký', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isReregistering = true;
    });

    try {
      final result = await EventService.registerEvent(
        eventDetailId: widget.eventDetailId,
      );

      if (!mounted) return;

      setState(() {
        _isReregistering = false;
      });

      if (result['success'] == true) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                const Text('Thành công'),
              ],
            ),
            content: Text(result['message'] ?? 'Đăng ký lại thành công!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true); // Return to list and refresh
                },
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Đăng ký lại thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isReregistering = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'attended':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      case 'student_cancelled':
        return Colors.grey;
      case 'unattended':
        return Colors.red.shade700;
      case 'scored':
        return Colors.green;
      case 'reject':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'attended':
        return 'Đã tham gia';
      case 'canceled':
        return 'Đã hủy';
      case 'student_cancelled':
        return 'Đã hủy';
      case 'unattended':
        return 'Vắng mặt';
      case 'scored':
        return 'Đã chấm điểm';
      case 'reject':
        return 'Từ chối';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi tiết sự kiện',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _eventDetail == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Không thể tải thông tin sự kiện',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Image
                  if (_eventDetail!['eventImage'] != null &&
                      _eventDetail!['eventImage'].toString().isNotEmpty)
                    Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[200],
                      child: Image.network(
                        _eventDetail!['eventImage'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),

                  // Status Badge
                  if (_eventDetail!['status'] != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          _eventDetail!['status'] ?? '',
                        ).withOpacity(0.1),
                        border: Border(
                          bottom: BorderSide(
                            color: _getStatusColor(
                              _eventDetail!['status'] ?? '',
                            ).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _eventDetail!['status'] == 'attended' ||
                                    _eventDetail!['status'] == 'scored'
                                ? Icons.check_circle
                                : _eventDetail!['status'] == 'student_cancelled'
                                ? Icons.cancel
                                : Icons.warning,
                            color: _getStatusColor(
                              _eventDetail!['status'] ?? '',
                            ),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getStatusText(_eventDetail!['status'] ?? ''),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(
                                _eventDetail!['status'] ?? '',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Event Details
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Name
                        Text(
                          _eventDetail!['eventName'] ?? '',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _eventDetail!['eventTypeName'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Divider(height: 24, thickness: 1),

                        // Session
                        _buildInfoRow(
                          Icons.event_note,
                          'Buổi',
                          'Buổi ${_eventDetail!['session'] ?? ''}',
                        ),
                        const SizedBox(height: 12),

                        // Date
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Ngày diễn ra',
                          _formatDate(_eventDetail!['creditDate']),
                        ),
                        const SizedBox(height: 12),

                        // Location
                        _buildInfoRow(
                          Icons.location_on,
                          'Địa điểm',
                          _eventDetail!['location'] ?? '',
                        ),
                        const SizedBox(height: 12),

                        // Size
                        _buildInfoRow(
                          Icons.people,
                          'Số lượng',
                          '${_eventDetail!['size'] ?? 0} người',
                        ),
                        const SizedBox(height: 12),

                        // Conduct Score
                        if (_eventDetail!['status'] == 'attended' ||
                            _eventDetail!['status'] == 'scored')
                          _buildInfoRow(
                            Icons.star,
                            'Điểm rèn luyện',
                            '+${_eventDetail!['conductScore'] ?? 0} điểm',
                            valueColor: Colors.amber[700],
                            valueWeight: FontWeight.bold,
                          ),
                      ],
                    ),
                  ),

                  // Description
                  if (_eventDetail!['description'] != null &&
                      _eventDetail!['description'].toString().isNotEmpty)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mô tả buổi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _eventDetail!['description'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Event Description
                  if (_eventDetail!['eventDescription'] != null &&
                      _eventDetail!['eventDescription'].toString().isNotEmpty)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Về sự kiện',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _eventDetail!['eventDescription'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Re-register Button (only for student_cancelled)
                  if (_eventDetail!['status'] == 'student_cancelled')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: ElevatedButton(
                        onPressed: _isReregistering ? null : _reregisterEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isReregistering
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.replay, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Đăng ký lại',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    FontWeight? valueWeight,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: valueColor ?? Colors.black87,
                  fontWeight: valueWeight ?? FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    try {
      final date = DateTime.parse(dateString);
      final days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
      final weekday = days[date.weekday % 7];

      return '$weekday, ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
