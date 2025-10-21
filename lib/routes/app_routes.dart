import 'package:flutter/material.dart';
import '../screens/dashboard/dashboard_screen.dart';

class AppRoutes {
  static const String dashboard = '/dashboard';

  static Map<String, WidgetBuilder> getRoutes() {
    return {dashboard: (context) => const DashboardScreen()};
  }
}
