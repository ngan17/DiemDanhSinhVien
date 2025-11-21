import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/fcm_service.dart';
import 'services/auth_service.dart';
import 'screens/auth/splash_screen.dart';

// GlobalKey để truy cập Navigator từ bất kỳ đâu
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Get access token from storage
    String? accessToken = await AuthService.getToken();

    if (accessToken != null) {
      await FCMService().initialize(accessToken, navigatorKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Điểm Danh Sinh Viên',
      navigatorKey: navigatorKey,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
