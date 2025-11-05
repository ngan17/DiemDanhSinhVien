import 'package:flutter/material.dart';
import '../../services/conduct_score_service.dart';

class TrainingScoreScreen extends StatefulWidget {
  const TrainingScoreScreen({super.key});

  @override
  State<TrainingScoreScreen> createState() => _TrainingScoreScreenState();
}

class _TrainingScoreScreenState extends State<TrainingScoreScreen> {
  List<dynamic> semesters = [];
  Map<String, dynamic>? selectedSemesterScore;
  int? selectedSemesterId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSemesters();
  }

  Future<void> _loadSemesters() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ConductScoreService.getSemesters();
      if (result != null) {
        setState(() {
          semesters = result['semesters'];
          selectedSemesterId = result['currentSemesterId'];
        });

        // Tự động tải điểm của học kỳ hiện tại
        await _loadScoreBySemester(selectedSemesterId!);
      }
    } catch (e) {
      print('Error loading semesters: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadScoreBySemester(int semesterId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ConductScoreService.getScoreBySemesterId(semesterId);
      if (result != null) {
        setState(() {
          selectedSemesterScore = result;
        });
      }
    } catch (e) {
      print('Error loading score: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          : Column(
              children: [
                // Dropdown chọn học kỳ
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButton<int>(
                    value: selectedSemesterId,
                    isExpanded: true,
                    items: semesters.map((semester) {
                      return DropdownMenuItem<int>(
                        value: semester['id'],
                        child: Text(semester['semesterName']),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (value != null) {
                        setState(() {
                          selectedSemesterId = value;
                        });
                        await _loadScoreBySemester(value);
                      }
                    },
                  ),
                ),

                // Hiển thị điểm rèn luyện
                if (selectedSemesterScore != null)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Điểm tổng kết kỳ
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Điểm tổng kết kỳ',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${selectedSemesterScore!['conductScore']}',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Text(
                                      'Tốt',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Danh sách tiêu chí và sự kiện
                          const Text(
                            'Sự kiện đã tham gia:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...selectedSemesterScore!['eventsByType'].map((
                            eventType,
                          ) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                ...eventType['events'].map((event) {
                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event['eventName'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Điểm: ${event['conductScore']} | Buổi: ${event['session']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Địa điểm: ${event['location']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Ngày: ${event['creditDate']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
