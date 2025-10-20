class SuKien {
  final int id;
  final String? tenSuKien; // nullable
  final DateTime ngayBD;
  final DateTime ngayKT;
  final String? maSK; // nullable
  final String? noiDung; // nullable

  SuKien({
    required this.id,
    this.tenSuKien,
    required this.ngayBD,
    required this.ngayKT,
    this.maSK,
    this.noiDung,
  });

  factory SuKien.fromJson(Map<String, dynamic> json) {
    return SuKien(
      id: json['id'],
      tenSuKien: json['TenSuKien'],
      ngayBD: DateTime.parse(json['NgayBD']),
      ngayKT: DateTime.parse(json['NgayKT']),
      maSK: json['MaLoaiSK']?.toString(),
      noiDung: json['MoTa'],
    );
  }
}
