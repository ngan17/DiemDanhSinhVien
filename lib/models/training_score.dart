class TrainingScore {
  final String id;
  final String semester; // HK1, HK2, HK3
  final String academicYear; // 2024-2025
  final double totalScore;
  final String classification; // Xuất sắc, Giỏi, Khá, Trung bình, Yếu
  final Map<String, CategoryScore> categoryScores;
  final DateTime updatedAt;

  TrainingScore({
    required this.id,
    required this.semester,
    required this.academicYear,
    required this.totalScore,
    required this.classification,
    required this.categoryScores,
    required this.updatedAt,
  });

  factory TrainingScore.fromJson(Map<String, dynamic> json) {
    Map<String, CategoryScore> categories = {};
    if (json['categoryScores'] != null) {
      (json['categoryScores'] as Map<String, dynamic>).forEach((key, value) {
        categories[key] = CategoryScore.fromJson(value);
      });
    }

    return TrainingScore(
      id: json['id'],
      semester: json['semester'],
      academicYear: json['academicYear'],
      totalScore: json['totalScore'].toDouble(),
      classification: json['classification'],
      categoryScores: categories,
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'semester': semester,
      'academicYear': academicYear,
      'totalScore': totalScore,
      'classification': classification,
      'categoryScores': categoryScores.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CategoryScore {
  final String categoryName;
  final double score;
  final double maxScore;
  final List<ScoreDetail> details;

  CategoryScore({
    required this.categoryName,
    required this.score,
    required this.maxScore,
    required this.details,
  });

  factory CategoryScore.fromJson(Map<String, dynamic> json) {
    return CategoryScore(
      categoryName: json['categoryName'],
      score: json['score'].toDouble(),
      maxScore: json['maxScore'].toDouble(),
      details: (json['details'] as List)
          .map((e) => ScoreDetail.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'score': score,
      'maxScore': maxScore,
      'details': details.map((e) => e.toJson()).toList(),
    };
  }

  double get percentage => (score / maxScore) * 100;
}

class ScoreDetail {
  final String activityName;
  final double score;
  final DateTime date;
  final String? note;

  ScoreDetail({
    required this.activityName,
    required this.score,
    required this.date,
    this.note,
  });

  factory ScoreDetail.fromJson(Map<String, dynamic> json) {
    return ScoreDetail(
      activityName: json['activityName'],
      score: json['score'].toDouble(),
      date: DateTime.parse(json['date']),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activityName': activityName,
      'score': score,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}
