import 'package:flutter/material.dart';
import '../../models/conduct_score_model.dart';
import '../../services/conduct_score_service.dart';

class TrainingScoreScreen extends StatefulWidget {
  const TrainingScoreScreen({super.key});

  @override
  State<TrainingScoreScreen> createState() => _TrainingScoreScreenState();
}

class _TrainingScoreScreenState extends State<TrainingScoreScreen> {
  List<SemesterScore> semesters = [];
  String studentName = '';
  int totalConductScore = 0;
  int totalEventsAttended = 0;
  bool _isLoading = false;

  // Lọc theo học kỳ
  String? selectedSemester;
  List<String> availableSemesters = [];

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
      // Gọi API lấy điểm theo học kỳ
      final data = await ConductScoreService.getScoreBySemester();

      if (data != null && mounted) {
        setState(() {
          studentName = data['studentName'] ?? '';
          totalConductScore = data['totalConductScore'] ?? 0;
          totalEventsAttended = data['totalEventsAttended'] ?? 0;
          semesters = data['semesters'] ?? [];

          // Lấy danh sách học kỳ (tên đầy đủ: "HK1 2023-2024")
          final semesterNames = semesters
              .map((s) => s.semesterName)
              .toSet()
              .toList();

          // Sắp xếp học kỳ giảm dần
          semesterNames.sort((a, b) => b.compareTo(a));
          availableSemesters = semesterNames;

          if (availableSemesters.isNotEmpty && selectedSemester == null) {
            selectedSemester = availableSemesters.first;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<SemesterScore> get filteredSemesters {
    if (selectedSemester == null) return semesters;
    return semesters.where((s) => s.semesterName == selectedSemester).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E90FF),
        elevation: 0,
        title: const Text(
          'Điểm rèn luyện',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Column(
                children: [
                  // Semester selector
                  if (availableSemesters.isNotEmpty)
                    Container(
                      color: const Color(0xFF1E90FF),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedSemester,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF1E90FF),
                            ),
                            items: availableSemesters.map((semester) {
                              return DropdownMenuItem<String>(
                                value: semester,
                                child: Text(
                                  semester,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
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
                    ),

                  // Summary card
                  if (filteredSemesters.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1E90FF), Color(0xFF64B5F6)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Tổng điểm trung bình',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _calculateAverageScore().toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '/100 điểm',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getOverallClassification(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Semester scores list
                  Expanded(
                    child: filteredSemesters.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assessment_outlined,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Chưa có điểm rèn luyện',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredSemesters.length,
                            itemBuilder: (context, index) {
                              final semester = filteredSemesters[index];
                              return _buildScoreCard(semester);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildScoreCard(SemesterScore semester) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Chuyển sang màn hình chi tiết với danh sách sự kiện
          _showSemesterDetail(semester);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          semester.semesterName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${semester.eventCount} sự kiện',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        semester.totalScore.toString(),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(semester.totalScore.toDouble()),
                        ),
                      ),
                      Text(
                        'điểm',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getClassificationColor(
                    _getClassification(semester.totalScore),
                  ).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getClassification(semester.totalScore),
                  style: TextStyle(
                    color: _getClassificationColor(
                      _getClassification(semester.totalScore),
                    ),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              // Hiển thị 3 sự kiện đầu tiên
              ...semester.events.take(3).map((event) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.event, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.eventName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${event.conductScore}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getScoreColor(event.conductScore.toDouble()),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (semester.events.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'và ${semester.events.length - 3} sự kiện khác...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Xem chi tiết',
                    style: TextStyle(
                      color: const Color(0xFF1E90FF),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(0xFF1E90FF),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSemesterDetail(SemesterScore semester) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E90FF),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Text(
                        semester.semesterName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tổng điểm: ${semester.totalScore}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: semester.events.length,
                    itemBuilder: (context, index) {
                      final event = semester.events[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getScoreColor(
                              event.conductScore.toDouble(),
                            ),
                            child: Text(
                              '+${event.conductScore}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(
                            event.eventName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event.eventTypeName),
                              Text(
                                'Buổi: ${event.session}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Ngày: ${event.formattedCreditDate}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(event.status),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              event.statusText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double _calculateAverageScore() {
    if (filteredSemesters.isEmpty) return 0;
    final sum = filteredSemesters.fold<double>(
      0,
      (sum, semester) => sum + semester.totalScore,
    );
    return sum / filteredSemesters.length;
  }

  String _getOverallClassification() {
    final avg = _calculateAverageScore();
    return _getClassification(avg.toInt());
  }

  String _getClassification(int score) {
    if (score >= 90) return 'Xuất sắc';
    if (score >= 80) return 'Giỏi';
    if (score >= 70) return 'Khá';
    if (score >= 50) return 'Trung bình';
    return 'Yếu';
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return const Color(0xFF4CAF50);
    if (score >= 80) return const Color(0xFF2196F3);
    if (score >= 70) return const Color(0xFFFF9800);
    if (score >= 50) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  Color _getClassificationColor(String classification) {
    switch (classification) {
      case 'Xuất sắc':
        return const Color(0xFF4CAF50);
      case 'Giỏi':
        return const Color(0xFF2196F3);
      case 'Khá':
        return const Color(0xFFFF9800);
      case 'Trung bình':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFFF44336);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'attended':
        return const Color(0xFF4CAF50);
      case 'approved':
        return const Color(0xFF2196F3);
      case 'pending':
        return const Color(0xFFFF9800);
      case 'rejected':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }
}
