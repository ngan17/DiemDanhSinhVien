import 'package:flutter/material.dart';
import '../../models/training_score.dart';
import '../../utils/mock_data.dart';
import 'score_detail_screen.dart';

class TrainingScoreScreen extends StatefulWidget {
  const TrainingScoreScreen({super.key});

  @override
  State<TrainingScoreScreen> createState() => _TrainingScoreScreenState();
}

class _TrainingScoreScreenState extends State<TrainingScoreScreen> {
  List<TrainingScore> scores = [];
  String selectedAcademicYear = '';
  List<String> academicYears = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      scores = MockData.getTrainingScores();
      academicYears = MockData.getAcademicYears();
      if (academicYears.isNotEmpty) {
        selectedAcademicYear = academicYears.first;
      }
    });
  }

  List<TrainingScore> get filteredScores {
    return scores
        .where((score) => score.academicYear == selectedAcademicYear)
        .toList();
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
      body: Column(
        children: [
          // Academic year selector
          Container(
            color: const Color(0xFF1E90FF),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedAcademicYear,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF1E90FF),
                  ),
                  items: academicYears.map((year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(
                        'Năm học $year',
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
                        selectedAcademicYear = value;
                      });
                    }
                  },
                ),
              ),
            ),
          ),

          // Summary card
          if (filteredScores.isNotEmpty)
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
                    style: TextStyle(color: Colors.white70, fontSize: 16),
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
            child: filteredScores.isEmpty
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
                    itemCount: filteredScores.length,
                    itemBuilder: (context, index) {
                      final score = filteredScores[index];
                      return _buildScoreCard(score);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(TrainingScore score) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScoreDetailScreen(score: score),
            ),
          );
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        score.semester,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Năm học ${score.academicYear}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        score.totalScore.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(score.totalScore),
                        ),
                      ),
                      Text(
                        '/100',
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
                    score.classification,
                  ).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  score.classification,
                  style: TextStyle(
                    color: _getClassificationColor(score.classification),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              ...score.categoryScores.entries.take(3).map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.value.categoryName,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: entry.value.score / entry.value.maxScore,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getScoreColor(entry.value.percentage),
                              ),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${entry.value.score.toStringAsFixed(0)}/${entry.value.maxScore.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }),
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

  double _calculateAverageScore() {
    if (filteredScores.isEmpty) return 0;
    final sum = filteredScores.fold<double>(
      0,
      (sum, score) => sum + score.totalScore,
    );
    return sum / filteredScores.length;
  }

  String _getOverallClassification() {
    final avg = _calculateAverageScore();
    if (avg >= 90) return 'Xuất sắc';
    if (avg >= 80) return 'Giỏi';
    if (avg >= 70) return 'Khá';
    if (avg >= 50) return 'Trung bình';
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
}
