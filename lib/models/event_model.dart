class EventModel {
  final int id;
  final String eventName;
  final String startDate;
  final String endDate;
  final String? description;
  final String eventTypeName;

  EventModel({
    required this.id,
    required this.eventName,
    required this.startDate,
    required this.endDate,
    this.description,
    required this.eventTypeName,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      eventName: json['eventName'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      description: json['description'],
      eventTypeName: json['eventTypeName'],
    );
  }

  // Kiểm tra trạng thái sự kiện
  String get status {
    final now = DateTime.now();
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);

    if (now.isBefore(start)) return 'Sắp diễn ra';
    if (now.isAfter(end)) return 'Đã kết thúc';
    return 'Đang diễn ra';
  }

  bool get isUpcoming => status == 'Sắp diễn ra';
  bool get isOngoing => status == 'Đang diễn ra';
  bool get isEnded => status == 'Đã kết thúc';

  String get formattedDateRange {
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
    } catch (e) {
      return '$startDate - $endDate';
    }
  }
}

class EventSessionModel {
  final int id;
  final String session;
  final int conductScore;
  final String location;
  final String? description;
  final String creditDate;
  final int size;
  final int registered;
  final int availableSlots;
  final bool isFull;

  EventSessionModel({
    required this.id,
    required this.session,
    required this.conductScore,
    required this.location,
    this.description,
    required this.creditDate,
    required this.size,
    required this.registered,
    required this.availableSlots,
    required this.isFull,
  });

  factory EventSessionModel.fromJson(Map<String, dynamic> json) {
    return EventSessionModel(
      id: json['id'],
      session: json['session'],
      conductScore: json['conductScore'],
      location: json['location'],
      description: json['description'],
      creditDate: json['creditDate'],
      size: json['size'],
      registered: json['registered'],
      availableSlots: json['available_slots'],
      isFull: json['is_full'],
    );
  }

  String get formattedCreditDate {
    try {
      final date = DateTime.parse(creditDate);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return creditDate;
    }
  }
}

class EventRegistrationModel {
  final int registrationId;
  final String registerTime;
  final String status;
  final bool useCertificate;
  final bool requireCertificate;
  final int eventId;
  final String eventName;
  final String eventTypeName;
  final int eventDetailId;
  final String session;
  final int conductScore;
  final String location;
  final String creditDate;
  final String? description;

  EventRegistrationModel({
    required this.registrationId,
    required this.registerTime,
    required this.status,
    required this.useCertificate,
    required this.requireCertificate,
    required this.eventId,
    required this.eventName,
    required this.eventTypeName,
    required this.eventDetailId,
    required this.session,
    required this.conductScore,
    required this.location,
    required this.creditDate,
    this.description,
  });

  factory EventRegistrationModel.fromJson(Map<String, dynamic> json) {
    return EventRegistrationModel(
      registrationId: json['registrationId'],
      registerTime: json['registerTime'],
      status: json['status'],
      useCertificate: json['useCertificate'] == 1,
      requireCertificate: json['requireCertificate'] == 1,
      eventId: json['eventId'],
      eventName: json['eventName'],
      eventTypeName: json['eventTypeName'],
      eventDetailId: json['eventDetailId'],
      session: json['session'],
      conductScore: json['conductScore'],
      location: json['location'],
      creditDate: json['creditDate'],
      description: json['description'],
    );
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Chờ duyệt';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Từ chối';
      case 'attended':
        return 'Đã tham gia';
      default:
        return status;
    }
  }

  String get formattedRegisterTime {
    try {
      final date = DateTime.parse(registerTime);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return registerTime;
    }
  }

  String get formattedCreditDate {
    try {
      final date = DateTime.parse(creditDate);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return creditDate;
    }
  }
}
