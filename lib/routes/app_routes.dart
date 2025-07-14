import 'package:diem_danh_sinh_vien/main.dart';
import 'package:flutter/material.dart';
import '../views/auth/login_view.dart';
import '../views/home/home_view.dart';
import '../views/home/profile_view.dart';
import 'package:diem_danh_sinh_vien/views/auth/change_password_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String main = '/main'; // Route chính
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginView(),
      main: (context) => const MainNavigation(), // Added this route
      profile: (context) => const ProfileView(),
    };
  }
}
