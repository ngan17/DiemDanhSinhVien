import 'package:flutter/material.dart';
import '../../models/conduct_score_model.dart';
import '../../services/conduct_score_service.dart';

class TrainingScoreScreen extends StatefulWidget {
  const TrainingScoreScreen({super.key});

  @override
  State<TrainingScoreScreen> createState() => _TrainingScoreScreenState();
}

class _TrainingScoreScreenState extends State<TrainingScoreScreen> {
  Map<String, dynamic>? scoreData;
  bool _isLoading = false;
  String? selectedSemester;
  List<Map<String, dynamic>> semesterOptions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print(' Đang tải điểm rèn luyện...');
      final data = await ConductScoreService.getScoreBySemester();

      print(' Dữ liệu nhận được: $data');

      if (data != null && mounted) {
        final semestersList = data['semesters'] as List<SemesterScore>? ?? [];

        print(' Số học kỳ: ${semestersList.length}');

        // Build semester options from semesters list
        setState(() {
          scoreData = data;
          semesterOptions = semestersList.map((semester) {
            return {
              'id': semester.semesterId,
              'name': semester.semesterName,
              'score': semester.totalScore,
              'eventCount': semester.eventCount,
              'events': semester.events,
            };
          }).toList();

          // Set default selection
          if (semesterOptions.isNotEmpty && selectedSemester == null) {
            selectedSemester = semesterOptions.first['name'];
          }

          print(' Đã tải xong: ${semesterOptions.length} học kỳ');
        });
      } else {
        print(' Không nhận được dữ liệu từ API');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể tải dữ liệu điểm rèn luyện'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print(' Lỗi khi tải dữ liệu: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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

  Map<String, dynamic>? get selectedSemesterData {
    if (selectedSemester == null || semesterOptions.isEmpty) return null;

    try {
      return semesterOptions.firstWhere((s) => s['name'] == selectedSemester);
    } catch (e) {
      return null;
    }
  }

  // Get classification based on total score
  String _getClassification(int score) {
    if (score >= 90) return 'Xuất sắc';
    if (score >= 80) return 'Giỏi';
    if (score >= 65) return 'Khá';
    if (score >= 50) return 'Trung bình';
    if (score >= 35) return 'Yếu';
    return 'Kém';
  }

  // Group events by type and calculate scores
  Map<String, Map<String, dynamic>> _getScoreBreakdown() {
    final semData = selectedSemesterData;
    if (semData == null || semData['events'] == null) {
      return {};
    }

    final events = semData['events'] as List<EventScore>;
    final breakdown = <String, Map<String, dynamic>>{};

    // Group events by type
    for (var event in events) {
      final typeName = event.eventTypeName;
      if (!breakdown.containsKey(typeName)) {
        breakdown[typeName] = {
          'score': 0,
          'maxScore': 30, // Default
          'status': 'Đã duyệt',
          'roman': 'I',
        };
      }
      breakdown[typeName]!['score'] =
          (breakdown[typeName]!['score'] as int) + event.conductScore;
    }

    return breakdown;
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
          'Điểm rèn luyện',
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
          : scoreData == null
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Semester Dropdown
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedSemester,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: semesterOptions.map((semester) {
                                  return DropdownMenuItem<String>(
                                    value: semester['name'],
                                    child: Text(
                                      semester['name'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedSemester = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Total Score Card
                    if (selectedSemesterData != null)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Điểm tổng kết kỳ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${selectedSemesterData!['score']}',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    'Tốt',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    'Tốt',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Score Breakdown Table
                    if (selectedSemesterData != null)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
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
                        child: Column(
                          children: [
                            // Table Header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Tiêu chí',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 60,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Điểm',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 90,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Minh chứng',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Table Rows with real data from API
                            ..._buildScoreRows(),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Summary Footer
                    if (selectedSemesterData != null)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tổng điểm rèn luện: ${selectedSemesterData!['score']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Xếp loại: ${_getClassification(selectedSemesterData!['score'])}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _buildScoreRows() {
    final semData = selectedSemesterData;
    if (semData == null || semData['events'] == null) {
      return [_buildScoreRow('Chưa có dữ liệu', 0, 'Chưa có')];
    }

    final events = semData['events'] as List<EventScore>;
    final rows = <Widget>[];

    // Map event type to Roman numerals
    final typeToRoman = {
      'Học thuật': 'I',
      'Tình nguyện': 'II',
      'Văn hóa': 'II',
      'Thể thao': 'III',
      'Khác': 'IV',
    };

    // Build a row for each event
    for (var event in events) {
      final roman = typeToRoman[event.eventTypeName] ?? 'I';
      final statusText = _getStatusText(event.status);

      rows.add(
        _buildScoreRow(
          '$roman. ${event.eventName}',
          event.conductScore,
          statusText,
        ),
      );
    }

    return rows.isEmpty
        ? [_buildScoreRow('Chưa có sự kiện', 0, 'Chưa có')]
        : rows;
  }

  // Helper method to convert status to Vietnamese
  String _getStatusText(String status) {
    switch (status) {
      case 'attended':
        return 'Đã duyệt';
      case 'approved':
        return 'Đã duyệt';
      case 'pending':
        return 'Chờ duyệt';
      case 'rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }

  Widget _buildScoreRow(String title, int score, String status) {
    return Column(
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              Container(
                width: 60,
                alignment: Alignment.center,
                child: Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                width: 90,
                alignment: Alignment.center,
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    color: status == 'Đã duyệt'
                        ? Colors.grey[600]
                        : Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 200,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Chưa có dữ liệu điểm rèn luyện',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bạn chưa tham gia sự kiện nào\nhoặc chưa được cập nhật điểm',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Làm mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
