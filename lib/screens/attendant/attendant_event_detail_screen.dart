import 'package:flutter/material.dart';
import '../../services/event_service.dart';
import 'barcode_scanner_screen.dart';

class AttendantEventDetailScreen extends StatefulWidget {
  final int eventId;

  const AttendantEventDetailScreen({super.key, required this.eventId});

  @override
  State<AttendantEventDetailScreen> createState() =>
      _AttendantEventDetailScreenState();
}

class _AttendantEventDetailScreenState
    extends State<AttendantEventDetailScreen> {
  Map<String, dynamic>? _eventDetail;
  List<dynamic> _sessions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEventDetail();
  }

  Future<void> _loadEventDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Loading event detail for eventId: ${widget.eventId}');

      final result = await EventService.getEventDetail(widget.eventId);

      print('Full result: $result');

      if (!mounted) return;

      // Parse giống như event_detail_screen.dart
      if (result != null && result['success'] == true) {
        final data = result['data'];
        print('Data from result: $data');

        setState(() {
          _eventDetail = data['event'] as Map<String, dynamic>?;
          _sessions = data['sessions'] as List<dynamic>? ?? [];
          _isLoading = false;
        });

        print('Event detail loaded: $_eventDetail');
        print('Sessions loaded: ${_sessions.length} sessions');
      } else {
        setState(() {
          _error = result?['message'] ?? 'Không thể tải thông tin sự kiện';
          _isLoading = false;
        });
        print('Load failed with message: $_error');
      }
    } catch (e) {
      print('Error loading event detail: $e');
      if (mounted) {
        setState(() {
          _error = 'Lỗi: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToScanner(Map<String, dynamic> session) {
    final eventName = _eventDetail?['eventName']?.toString() ?? 'Sự kiện';
    final sessionName = session['session']?.toString();
    final eventDetailId = session['id'] as int;

    print('Navigate to scanner:');
    print('  EventDetailId: $eventDetailId');
    print('  EventName: $eventName');
    print('  Session: $sessionName');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerScreen(
          eventDetailId: eventDetailId,
          eventName: eventName,
          session: sessionName,
        ),
      ),
    );
  }

  // Hàm kiểm tra xem session có đang diễn ra không dựa trên creditDate
  bool _isSessionOngoing(String? creditDate) {
    if (creditDate == null) return false;

    try {
      // creditDate format: "2025-11-22 00:00:00"
      final sessionDate = DateTime.parse(creditDate.split(' ')[0]);
      final today = DateTime.now();

      // So sánh chỉ ngày
      return sessionDate.year == today.year &&
          sessionDate.month == today.month &&
          sessionDate.day == today.day;
    } catch (e) {
      print('Error parsing creditDate: $e');
      return false;
    }
  }

  Color _getSessionStatusColor(bool isOngoing) {
    return isOngoing ? Colors.green : Colors.orange;
  }

  String _getSessionStatusText(bool isOngoing) {
    return isOngoing ? 'Đang diễn ra' : 'Sắp diễn ra';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Chi tiết sự kiện',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadEventDetail,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadEventDetail,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thông tin sự kiện
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _eventDetail?['eventName']?.toString() ??
                                'Không có tên',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (_eventDetail?['eventTypeName'] != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _eventDetail!['eventTypeName'].toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.calendar_today,
                            'Thời gian',
                            '${_eventDetail?['startDate']?.toString() ?? ''} - ${_eventDetail?['endDate']?.toString() ?? ''}',
                          ),
                          if (_eventDetail?['description'] != null &&
                              _eventDetail!['description']
                                  .toString()
                                  .isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.description,
                              'Mô tả',
                              _eventDetail!['description'].toString(),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Danh sách các buổi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Danh sách buổi điểm danh',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${_sessions.length} buổi',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_sessions.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Chưa có buổi nào',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _sessions.length,
                        itemBuilder: (context, index) {
                          final session = _sessions[index];
                          final creditDate = session['creditDate']?.toString();
                          final isOngoing = _isSessionOngoing(creditDate);
                          final isFull = session['is_full'] == true;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isOngoing
                                    ? Colors.green.withValues(alpha: 0.3)
                                    : Colors.grey.withValues(alpha: 0.1),
                                width: isOngoing ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          session['session']?.toString() ??
                                              'Buổi ${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getSessionStatusColor(
                                            isOngoing,
                                          ).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          _getSessionStatusText(isOngoing),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _getSessionStatusColor(
                                              isOngoing,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          creditDate ?? '',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          session['location']?.toString() ??
                                              'Chưa có địa điểm',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber[700],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '+${session['conductScore']?.toString() ?? '0'} điểm rèn luyện',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.people,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Đăng ký: ${session['registered']?.toString() ?? '0'}/${session['size']?.toString() ?? '0'}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: LinearProgressIndicator(
                                          value: (session['size'] ?? 0) > 0
                                              ? (session['registered'] ?? 0) /
                                                    session['size']
                                              : 0,
                                          backgroundColor: Colors.grey[200],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                isFull
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (session['description'] != null &&
                                      session['description']
                                          .toString()
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      session['description'].toString(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  if (isFull) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info,
                                          size: 18,
                                          color: Colors.red[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Đã đầy',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (isOngoing && !isFull) ...[
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _navigateToScanner(session),
                                        icon: const Icon(
                                          Icons.qr_code_scanner,
                                          size: 20,
                                        ),
                                        label: const Text(
                                          'Điểm danh',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          elevation: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (!isOngoing) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 18,
                                          color: Colors.orange[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Chưa đến giờ điểm danh',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.orange[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.blue[700]),
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
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
