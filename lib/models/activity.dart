class Activity {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime registrationDeadline;
  final String location;
  final int maxParticipants;
  final int currentParticipants;
  final double trainingScore;
  final String category;
  final String status; // upcoming, ongoing, completed
  final bool isRegistered;

  Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.registrationDeadline,
    required this.location,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.trainingScore,
    required this.category,
    required this.status,
    this.isRegistered = false,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      registrationDeadline: DateTime.parse(json['registrationDeadline']),
      location: json['location'],
      maxParticipants: json['maxParticipants'],
      currentParticipants: json['currentParticipants'],
      trainingScore: json['trainingScore'].toDouble(),
      category: json['category'],
      status: json['status'],
      isRegistered: json['isRegistered'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'registrationDeadline': registrationDeadline.toIso8601String(),
      'location': location,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'trainingScore': trainingScore,
      'category': category,
      'status': status,
      'isRegistered': isRegistered,
    };
  }

  bool get canRegister {
    return DateTime.now().isBefore(registrationDeadline) &&
        currentParticipants < maxParticipants &&
        !isRegistered;
  }

  int get availableSlots => maxParticipants - currentParticipants;
}
