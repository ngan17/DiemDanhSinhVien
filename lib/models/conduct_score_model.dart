class ConductScoreTotal {
  final int studentId;
  final String studentName;
  final int totalConductScore;

  ConductScoreTotal({
    required this.studentId,
    required this.studentName,
    required this.totalConductScore,
  });

  factory ConductScoreTotal.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return ConductScoreTotal(
      studentId: data['studentId'],
      studentName: data['studentName'],
      totalConductScore: data['totalConductScore'] ?? 0,
    );
  }
}

class EventScore {
  final int registrationId;
  final String eventName;
  final String eventTypeName;
  final String session;
  final int conductScore;
  final String creditDate;
  final String status;

  EventScore({
    required this.registrationId,
    required this.eventName,
    required this.eventTypeName,
    required this.session,
    required this.conductScore,
    required this.creditDate,
    required this.status,
  });

  factory EventScore.fromJson(Map<String, dynamic> json) {
    return EventScore(
      registrationId: json['registrationId'],
      eventName: json['eventName'],
      eventTypeName: json['eventTypeName'],
      session: json['session'],
      conductScore: json['conductScore'],
      creditDate: json['creditDate'],
      status: json['status'],
    );
  }

  String get formattedCreditDate {
    try {
      final date = DateTime.parse(creditDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return creditDate;
    }
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Chờ duyệt';
      case 'approved':
        return 'Đã duyệt';
      case 'attended':
        return 'Đã tham gia';
      case 'rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }
}

class SemesterScore {
  final int semesterId;
  final String semesterName;
  final int totalScore;
  final int eventCount;
  final List<EventScore> events;

  SemesterScore({
    required this.semesterId,
    required this.semesterName,
    required this.totalScore,
    required this.eventCount,
    required this.events,
  });

  factory SemesterScore.fromJson(Map<String, dynamic> json) {
    return SemesterScore(
      semesterId: json['semesterId'],
      semesterName: json['semesterName'],
      totalScore: json['totalScore'],
      eventCount: json['eventCount'],
      events: (json['events'] as List)
          .map((e) => EventScore.fromJson(e))
          .toList(),
    );
  }
}

class ScoreStatistics {
  final int studentId;
  final String studentName;
  final int currentScore;
  final int earnedScore;
  final int pendingScore;
  final RegistrationStats registrationStats;

  ScoreStatistics({
    required this.studentId,
    required this.studentName,
    required this.currentScore,
    required this.earnedScore,
    required this.pendingScore,
    required this.registrationStats,
  });

  factory ScoreStatistics.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return ScoreStatistics(
      studentId: data['studentId'],
      studentName: data['studentName'],
      currentScore: data['currentScore'] ?? 0,
      earnedScore: data['earnedScore'] ?? 0,
      pendingScore: data['pendingScore'] ?? 0,
      registrationStats: RegistrationStats.fromJson(data['registrationStats']),
    );
  }
}

class RegistrationStats {
  final int pending;
  final int approved;
  final int attended;
  final int rejected;
  final int total;

  RegistrationStats({
    required this.pending,
    required this.approved,
    required this.attended,
    required this.rejected,
    required this.total,
  });

  factory RegistrationStats.fromJson(Map<String, dynamic> json) {
    return RegistrationStats(
      pending: json['pending'] ?? 0,
      approved: json['approved'] ?? 0,
      attended: json['attended'] ?? 0,
      rejected: json['rejected'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}
