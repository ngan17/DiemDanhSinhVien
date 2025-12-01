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
  final int eventDetailId;
  final String eventName;
  final String eventTypeName;
  final String session;
  final String location;
  final String creditDate;
  final int conductScore;
  final String registerTime;
  final String status; //  Thêm trường này
  final String? semesterName;
  final int isAttendFace; //  Thêm
  final int isAttendProof; //  Thêm
  final int isAttendCamera; //  Thêm
  final int isAttendBarcode; //  Thêm

  EventRegistrationModel({
    required this.registrationId,
    required this.eventDetailId,
    required this.eventName,
    required this.eventTypeName,
    required this.session,
    required this.location,
    required this.creditDate,
    required this.conductScore,
    required this.registerTime,
    required this.status, //  Thêm
    this.semesterName,
    this.isAttendFace = 0, //  Thêm
    this.isAttendProof = 0, //  Thêm
    this.isAttendCamera = 0, //  Thêm
    this.isAttendBarcode = 0, //  Thêm
  });

  factory EventRegistrationModel.fromJson(Map<String, dynamic> json) {
    return EventRegistrationModel(
      registrationId: json['registrationId'] ?? 0,
      eventDetailId: json['eventDetailId'] ?? 0,
      eventName: json['eventName'] ?? '',
      eventTypeName: json['eventTypeName'] ?? '',
      session: json['session'] ?? '',
      location: json['location'] ?? '',
      creditDate: json['creditDate'] ?? '',
      conductScore: json['conductScore'] ?? 0,
      registerTime: json['registerTime'] ?? '',
      status: json['status']?.toString() ?? 'pending', //  Thêm
      semesterName: json['semesterName'],
      isAttendFace: json['isAttendFace'] ?? 0, //  Thêm
      isAttendProof: json['isAttendProof'] ?? 0, //  Thêm
      isAttendCamera: json['isAttendCamera'] ?? 0, //  Thêm
      isAttendBarcode: json['isAttendBarcode'] ?? 0, //  Thêm
    );
  }

  String get formattedCreditDate {
    try {
      final date = DateTime.parse(creditDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return creditDate;
    }
  }

  String get formattedRegisterTime {
    try {
      final date = DateTime.parse(registerTime);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return registerTime;
    }
  }

  //  Thêm getter cho statusText
  String get statusText {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Đã duyệt';
      case 'pending':
        return 'Chờ duyệt';
      case 'rejected':
        return 'Từ chối';
      case 'attended':
        return 'Đã điểm danh';
      default:
        return status;
    }
  }
}
