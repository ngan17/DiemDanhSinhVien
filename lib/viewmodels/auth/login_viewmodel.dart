import 'package:flutter/material.dart';
import 'package:diem_danh_sinh_vien/services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Future<bool> login(String maNguoiDung, String matKhau) async {
    final user = await _authService.login(maNguoiDung, matKhau);
    if (user != null) {
      print('Thông tin người dùng: $user');
      return true;
    } else {
      return false;
    }
  }
}