class UserModel {
  final int id;
  final String email;
  final String role;
  final String? name;
  final String? studentCode;
  final String? className;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.studentCode,
    this.className,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      name: json['name'],
      studentCode: json['student_code'],
      className: json['class_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'name': name,
      'student_code': studentCode,
      'class_name': className,
    };
  }
}
