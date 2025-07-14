class NguoiDung {
  final String maNguoiDung;
  final String matKhau;
  final String email;
  final int role;

  NguoiDung({
    required this.maNguoiDung,
    required this.matKhau,
    required this.email,
    required this.role,
  });

  factory NguoiDung.fromJson(Map<String, dynamic> json) {
    return NguoiDung(
      maNguoiDung: json['MaNguoiDung'],
      matKhau: json['MatKhau'],
      email: json['Email'],
      role: json['Role'],
    );
  }
}