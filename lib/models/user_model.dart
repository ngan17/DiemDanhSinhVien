class UserModel {
  final int id;
  final String email;
  final String role;

  UserModel({required this.id, required this.email, required this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'], email: json['email'], role: json['role']);
  }
}

class StudentModel {
  final String id;
  final String studentname;
  final String classId;
  StudentModel({
    required this.id,
    required this.studentname,
    required this.classId,
  });
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      studentname: json['studentname'],
      classId: json['classId'],
    );
  }
}





