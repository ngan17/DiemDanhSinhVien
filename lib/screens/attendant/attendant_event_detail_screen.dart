import 'package:flutter/material.dart';
import '../../services/attendant_service.dart';
import 'barcode_scanner_screen.dart';

class AttendantEventDetailScreen extends StatefulWidget {
  final int eventId;
  final String eventName;

  const AttendantEventDetailScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<AttendantEventDetailScreen> createState() =>
      _AttendantEventDetailScreenState();
}

class _AttendantEventDetailScreenState
    extends State<AttendantEventDetailScreen> {
  Map<String, dynamic>? _eventDetail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEventDetail();
  }

  Future<void> _loadEventDetail() async {
    setState(() => _isLoading = true);
    try {
      final detail = await AttendantService.getEventDetail(widget.eventId);
      setState(() {
        _eventDetail = detail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải chi tiết sự kiện: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventName),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEventDetail,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildScanButton(), _buildEventInfo()],
                ),
              ),
            ),
    );
  }

  Widget _buildScanButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: () => _navigateToScanner(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.qr_code_scanner, size: 32),
            SizedBox(height: 4),
            Text(
              'Quét mã điểm danh',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventInfo() {
    if (_eventDetail == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.event, color: Colors.blue, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Thông tin sự kiện',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            Icons.event,
            'Tên sự kiện',
            _eventDetail!['eventName']?.toString() ?? 'Không có tên',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.calendar_today,
            'Thời gian bắt đầu',
            _eventDetail!['startDate']?.toString() ?? 'Chưa có thông tin',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.calendar_month,
            'Thời gian kết thúc',
            _eventDetail!['endDate']?.toString() ?? 'Chưa có thông tin',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.category,
            'Loại sự kiện',
            _eventDetail!['eventTypeName']?.toString() ?? 'Chưa có thông tin',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.info_outline,
            'Trạng thái',
            _getStatusText(_eventDetail!['status']?.toString() ?? ''),
            statusColor: _getStatusColor(_eventDetail!['status']?.toString() ?? ''),
          ),
          if (_eventDetail!['description'] != null &&
              _eventDetail!['description'].toString().isNotEmpty) ...[
            const Divider(height: 24),
            _buildInfoRow(
              Icons.description,
              'Mô tả',
              _eventDetail!['description'],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? statusColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: statusColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToScanner() {
    if (_eventDetail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa tải được thông tin sự kiện'),
          backgroundColor: Colors.red,
        ),
      );
      return ;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerScreen(
          eventDetailId: widget.eventId,
          eventName: widget.eventName,
          session: _eventDetail!['session']?.toString(),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Colors.blue;
      case 'ongoing':
        return Colors.green;
      case 'completed':
      case 'ended':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String? status) {
    if (status == null || status.isEmpty) return 'Không xác định';
    switch (status.toLowerCase()) {
      case 'upcoming':
        return 'Sắp diễn ra';
      case 'ongoing':
        return 'Đang diễn ra';
      case 'completed':
      case 'ended':
        return 'Đã kết thúc';
      default:
        return status;
    }
  }
}
