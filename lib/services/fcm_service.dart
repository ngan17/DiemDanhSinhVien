import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message: ${message.messageId}");
}

class FCMService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String baseUrl = 'http://10.0.2.2:8000/api';

  Future<void> initialize(String accessToken) async {
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Permission status: ${settings.authorizationStatus}');

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          _handleNotificationTap(json.decode(details.payload!));
        }
      },
    );

    // Get FCM token
    String? token = await _fcm.getToken();
    if (token != null) {
      print('FCM Token: $token');
      await _updateFCMToken(token, accessToken);
    }

    // Listen to token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      _updateFCMToken(newToken, accessToken);
    });

    // Background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');

      if (message.notification != null) {
        _showLocalNotification(
          message.notification!.title ?? '',
          message.notification!.body ?? '',
          message.data,
        );
      }
    });

    // Message opened from background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data);
    });

    // Check if app was opened from terminated state
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage.data);
    }
  }

  Future<void> _updateFCMToken(String token, String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/fcm-token'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'fcmToken': token}),
      );

      if (response.statusCode == 200) {
        print('FCM token updated successfully');
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  Future<void> _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'Thông báo quan trọng',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: json.encode(data),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    print('Notification tapped: $data');

    if (data['type'] == 'new_event') {
      // Navigate to event detail
      String eventId = data['eventId'];
      // TODO: Navigator.push to event detail page
    } else if (data['type'] == 'event_reminder') {
      // Navigate to event detail
      String eventDetailId = data['eventDetailId'];
      // TODO: Navigator.push to event detail page
    }
  }
}
