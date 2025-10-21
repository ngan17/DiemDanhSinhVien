import '../models/activity.dart';
import '../models/training_score.dart';

class MockData {
  // Mock activities data
  static List<Activity> getActivities() {
    final now = DateTime.now();
    return [
      Activity(
        id: '1',
        name: 'Hội thảo khởi nghiệp sinh viên 2025',
        description:
            'Hội thảo cung cấp kiến thức về khởi nghiệp, chia sẻ kinh nghiệm từ các doanh nhân thành công. Sinh viên sẽ được học cách lập kế hoạch kinh doanh, tìm kiếm nguồn vốn và phát triển ý tưởng.',
        startDate: now.add(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 7, hours: 3)),
        registrationDeadline: now.add(const Duration(days: 5)),
        location: 'Hội trường A - Tòa nhà chính',
        maxParticipants: 200,
        currentParticipants: 145,
        trainingScore: 15.0,
        category: 'Học tập',
        status: 'upcoming',
        isRegistered: false,
      ),
      Activity(
        id: '2',
        name: 'Ngày hội tình nguyện "Tiếp sức mùa thi"',
        description:
            'Hoạt động tình nguyện hỗ trợ học sinh THPT trong kỳ thi tốt nghiệp. Sinh viên sẽ tham gia hướng dẫn, phát nước, hỗ trợ thí sinh và phụ huynh.',
        startDate: now.add(const Duration(days: 14)),
        endDate: now.add(const Duration(days: 16)),
        registrationDeadline: now.add(const Duration(days: 10)),
        location: 'Các điểm thi THPT tại TP.HCM',
        maxParticipants: 300,
        currentParticipants: 287,
        trainingScore: 25.0,
        category: 'Tình nguyện',
        status: 'upcoming',
        isRegistered: true,
      ),
      Activity(
        id: '3',
        name: 'Giải bóng đá sinh viên 2025',
        description:
            'Giải đấu bóng đá thường niên dành cho sinh viên các khoa. Khuyến khích tinh thần đoàn kết, rèn luyện sức khỏe.',
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 25)),
        registrationDeadline: now.subtract(const Duration(days: 5)),
        location: 'Sân vận động Trường',
        maxParticipants: 160,
        currentParticipants: 160,
        trainingScore: 20.0,
        category: 'Thể thao',
        status: 'ongoing',
        isRegistered: true,
      ),
      Activity(
        id: '4',
        name: 'Workshop: Kỹ năng phỏng vấn xin việc',
        description:
            'Buổi workshop giúp sinh viên chuẩn bị CV, thư xin việc và luyện tập kỹ năng phỏng vấn với các chuyên gia nhân sự.',
        startDate: now.add(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 3, hours: 4)),
        registrationDeadline: now.add(const Duration(days: 2)),
        location: 'Phòng hội thảo 301',
        maxParticipants: 80,
        currentParticipants: 62,
        trainingScore: 12.0,
        category: 'Kỹ năng mềm',
        status: 'upcoming',
        isRegistered: false,
      ),
      Activity(
        id: '5',
        name: 'Cuộc thi "Sinh viên với An toàn giao thông"',
        description:
            'Cuộc thi tìm hiểu về luật giao thông, tuyên truyền ý thức chấp hành luật giao thông cho sinh viên.',
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now.subtract(const Duration(days: 28)),
        registrationDeadline: now.subtract(const Duration(days: 35)),
        location: 'Hội trường B',
        maxParticipants: 150,
        currentParticipants: 142,
        trainingScore: 18.0,
        category: 'Văn hóa - Xã hội',
        status: 'completed',
        isRegistered: true,
      ),
      Activity(
        id: '6',
        name: 'Chương trình "Hiến máu nhân đạo"',
        description:
            'Chương trình hiến máu tình nguyện hợp tác với Viện Huyết học Truyền máu TP.HCM.',
        startDate: now.add(const Duration(days: 20)),
        endDate: now.add(const Duration(days: 20, hours: 6)),
        registrationDeadline: now.add(const Duration(days: 15)),
        location: 'Khuôn viên trường',
        maxParticipants: 250,
        currentParticipants: 103,
        trainingScore: 30.0,
        category: 'Tình nguyện',
        status: 'upcoming',
        isRegistered: false,
      ),
    ];
  }

  // Mock training scores data
  static List<TrainingScore> getTrainingScores() {
    return [
      TrainingScore(
        id: '1',
        semester: 'HK1',
        academicYear: '2024-2025',
        totalScore: 87.0,
        classification: 'Giỏi',
        categoryScores: {
          'learning': CategoryScore(
            categoryName: 'Ý thức và kết quả học tập',
            score: 23.0,
            maxScore: 25.0,
            details: [
              ScoreDetail(
                activityName: 'Điểm trung bình học tập >= 3.2',
                score: 15.0,
                date: DateTime(2025, 1, 15),
              ),
              ScoreDetail(
                activityName: 'Tham gia hội thảo học thuật',
                score: 8.0,
                date: DateTime(2024, 12, 10),
              ),
            ],
          ),
          'volunteer': CategoryScore(
            categoryName: 'Tham gia hoạt động tình nguyện',
            score: 24.0,
            maxScore: 25.0,
            details: [
              ScoreDetail(
                activityName: 'Tiếp sức mùa thi 2024',
                score: 15.0,
                date: DateTime(2024, 11, 5),
              ),
              ScoreDetail(
                activityName: 'Hiến máu nhân đạo',
                score: 9.0,
                date: DateTime(2024, 10, 20),
              ),
            ],
          ),
          'discipline': CategoryScore(
            categoryName: 'Ý thức chấp hành nội quy',
            score: 20.0,
            maxScore: 20.0,
            details: [
              ScoreDetail(
                activityName: 'Chấp hành tốt nội quy trường',
                score: 20.0,
                date: DateTime(2025, 1, 15),
              ),
            ],
          ),
          'social': CategoryScore(
            categoryName: 'Tham gia hoạt động văn hóa xã hội',
            score: 15.0,
            maxScore: 20.0,
            details: [
              ScoreDetail(
                activityName: 'Giải bóng đá sinh viên',
                score: 10.0,
                date: DateTime(2024, 12, 1),
              ),
              ScoreDetail(
                activityName: 'Ngày hội văn hóa các dân tộc',
                score: 5.0,
                date: DateTime(2024, 11, 15),
              ),
            ],
          ),
          'community': CategoryScore(
            categoryName: 'Quan hệ với cộng đồng',
            score: 5.0,
            maxScore: 10.0,
            details: [
              ScoreDetail(
                activityName: 'Tham gia CLB môi trường',
                score: 5.0,
                date: DateTime(2024, 10, 10),
              ),
            ],
          ),
        },
        updatedAt: DateTime(2025, 1, 20),
      ),
      TrainingScore(
        id: '2',
        semester: 'HK2',
        academicYear: '2023-2024',
        totalScore: 92.0,
        classification: 'Xuất sắc',
        categoryScores: {
          'learning': CategoryScore(
            categoryName: 'Ý thức và kết quả học tập',
            score: 24.0,
            maxScore: 25.0,
            details: [
              ScoreDetail(
                activityName: 'Điểm trung bình học tập >= 3.6',
                score: 18.0,
                date: DateTime(2024, 6, 15),
              ),
              ScoreDetail(
                activityName: 'Đạt giải cuộc thi Olympic tin học',
                score: 6.0,
                date: DateTime(2024, 5, 20),
              ),
            ],
          ),
          'volunteer': CategoryScore(
            categoryName: 'Tham gia hoạt động tình nguyện',
            score: 25.0,
            maxScore: 25.0,
            details: [
              ScoreDetail(
                activityName: 'Mùa hè xanh 2024',
                score: 20.0,
                date: DateTime(2024, 6, 1),
              ),
              ScoreDetail(
                activityName: 'Chương trình từ thiện tại trẻ em mồ côi',
                score: 5.0,
                date: DateTime(2024, 5, 10),
              ),
            ],
          ),
          'discipline': CategoryScore(
            categoryName: 'Ý thức chấp hành nội quy',
            score: 20.0,
            maxScore: 20.0,
            details: [
              ScoreDetail(
                activityName: 'Chấp hành tốt nội quy trường',
                score: 20.0,
                date: DateTime(2024, 6, 15),
              ),
            ],
          ),
          'social': CategoryScore(
            categoryName: 'Tham gia hoạt động văn hóa xã hội',
            score: 18.0,
            maxScore: 20.0,
            details: [
              ScoreDetail(
                activityName: 'Liên hoan văn nghệ khoa',
                score: 12.0,
                date: DateTime(2024, 5, 15),
              ),
              ScoreDetail(
                activityName: 'Giải cầu lông sinh viên',
                score: 6.0,
                date: DateTime(2024, 4, 20),
              ),
            ],
          ),
          'community': CategoryScore(
            categoryName: 'Quan hệ với cộng đồng',
            score: 5.0,
            maxScore: 10.0,
            details: [
              ScoreDetail(
                activityName: 'Chiến dịch làm sạch bãi biển',
                score: 5.0,
                date: DateTime(2024, 4, 10),
              ),
            ],
          ),
        },
        updatedAt: DateTime(2024, 6, 20),
      ),
      TrainingScore(
        id: '3',
        semester: 'HK1',
        academicYear: '2023-2024',
        totalScore: 78.0,
        classification: 'Khá',
        categoryScores: {
          'learning': CategoryScore(
            categoryName: 'Ý thức và kết quả học tập',
            score: 20.0,
            maxScore: 25.0,
            details: [
              ScoreDetail(
                activityName: 'Điểm trung bình học tập >= 2.8',
                score: 12.0,
                date: DateTime(2024, 1, 15),
              ),
              ScoreDetail(
                activityName: 'Tham gia seminar chuyên ngành',
                score: 8.0,
                date: DateTime(2023, 12, 5),
              ),
            ],
          ),
          'volunteer': CategoryScore(
            categoryName: 'Tham gia hoạt động tình nguyện',
            score: 20.0,
            maxScore: 25.0,
            details: [
              ScoreDetail(
                activityName: 'Chương trình mái ấm tình thương',
                score: 12.0,
                date: DateTime(2023, 11, 20),
              ),
              ScoreDetail(
                activityName: 'Dạy học cho trẻ em vùng cao',
                score: 8.0,
                date: DateTime(2023, 10, 15),
              ),
            ],
          ),
          'discipline': CategoryScore(
            categoryName: 'Ý thức chấp hành nội quy',
            score: 18.0,
            maxScore: 20.0,
            details: [
              ScoreDetail(
                activityName: 'Chấp hành nội quy trường',
                score: 18.0,
                date: DateTime(2024, 1, 15),
                note: 'Có 1 lần đi học muộn',
              ),
            ],
          ),
          'social': CategoryScore(
            categoryName: 'Tham gia hoạt động văn hóa xã hội',
            score: 15.0,
            maxScore: 20.0,
            details: [
              ScoreDetail(
                activityName: 'Hội diễn văn nghệ chào tân sinh viên',
                score: 10.0,
                date: DateTime(2023, 10, 1),
              ),
              ScoreDetail(
                activityName: 'Tham gia CLB nhiếp ảnh',
                score: 5.0,
                date: DateTime(2023, 11, 10),
              ),
            ],
          ),
          'community': CategoryScore(
            categoryName: 'Quan hệ với cộng đồng',
            score: 5.0,
            maxScore: 10.0,
            details: [
              ScoreDetail(
                activityName: 'Tuyên truyền bảo vệ môi trường',
                score: 5.0,
                date: DateTime(2023, 12, 15),
              ),
            ],
          ),
        },
        updatedAt: DateTime(2024, 1, 20),
      ),
    ];
  }

  // Get activities by category
  static List<Activity> getActivitiesByCategory(String category) {
    return getActivities()
        .where((activity) => activity.category == category)
        .toList();
  }

  // Get activities by status
  static List<Activity> getActivitiesByStatus(String status) {
    return getActivities()
        .where((activity) => activity.status == status)
        .toList();
  }

  // Get registered activities
  static List<Activity> getRegisteredActivities() {
    return getActivities().where((activity) => activity.isRegistered).toList();
  }

  // Get training score by semester
  static TrainingScore? getTrainingScoreBySemester(
    String academicYear,
    String semester,
  ) {
    try {
      return getTrainingScores().firstWhere(
        (score) =>
            score.academicYear == academicYear && score.semester == semester,
      );
    } catch (e) {
      return null;
    }
  }

  // Get all academic years
  static List<String> getAcademicYears() {
    return getTrainingScores()
        .map((score) => score.academicYear)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
  }

  // Get categories list
  static List<String> getCategories() {
    return [
      'Tất cả',
      'Học tập',
      'Tình nguyện',
      'Thể thao',
      'Kỹ năng mềm',
      'Văn hóa - Xã hội',
    ];
  }
}
