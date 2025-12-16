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
          semesters = result['semesters'] ?? [];
          selectedSemesterId = result['currentSemesterId'];
        });

        if (selectedSemesterId != null) {
          await _loadScoreBySemester(selectedSemesterId!);
        }
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

  String _getScoreRating(int score) {
    if (score >= 90) return 'Xuất sắc';
    if (score >= 80) return 'Tốt';
    if (score >= 65) return 'Khá';
    if (score >= 50) return 'Trung bình';
    return 'Yếu';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButton<int>(
                    value: selectedSemesterId,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: semesters.map((semester) {
                      return DropdownMenuItem<int>(
                        value: semester['id'],
                        child: Text(semester['semesterName'] ?? ''),
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

                if (selectedSemesterScore != null)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
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
                                      '${selectedSemesterScore!['totalScore'] ?? 70}',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Text(
                                      _getScoreRating(
                                        selectedSemesterScore!['totalScore'] ??
                                            70,
                                      ),
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

                          const Text(
                            'Sự kiện đã tham gia:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          if (selectedSemesterScore!['events'] != null &&
                              (selectedSemesterScore!['events'] as List)
                                  .isNotEmpty)
                            ...(() {
                            
                              final events =
                                  selectedSemesterScore!['events'] as List;
                              final uniqueEvents = <String, dynamic>{};
                              for (var event in events) {

                                final registrationId = event['registrationId'];
                                final key = registrationId != null
                                    ? registrationId.toString()
                                    : '${event['eventDetailId']}_${event['eventName']}_${event['session']}';

                                if (!uniqueEvents.containsKey(key)) {
                                  uniqueEvents[key] = event;
                                }
                              }
                              return uniqueEvents.values.toList();
                            })().map((event) {
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event['eventName'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Điểm: ${event['conductScore'] ?? 0} | Buổi: ${event['session'] ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Địa điểm: ${event['location'] ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Ngày: ${event['creditDate'] ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList()
                          else
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'Chưa tham gia sự kiện nào',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
