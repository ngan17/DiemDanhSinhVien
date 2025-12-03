import 'package:diem_danh_sinh_vien/config/app_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../screens/events/event_detail_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message received: ${message.messageId}");
  print("Message data: ${message.data}");
}

class FCMService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String baseUrl = AppConfig.baseUrl;
  static GlobalKey<NavigatorState>? navigatorKey;
  static Map<String, dynamic>? pendingNotificationData;
  static String? _lastProcessedEventId;
  static DateTime? _lastProcessedTime;

  Future<void> initialize(
    String accessToken,
    GlobalKey<NavigatorState> navKey,
  ) async {
    navigatorKey = navKey;

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Permission status: ${settings.authorizationStatus}');

    // Get FCM token
    String? token = await _fcm.getToken();
    if (token != null) {
      print('FCM Token: $token');
      await _updateFCMToken(token, accessToken);
    }


    _fcm.onTokenRefresh.listen((newToken) {
      _updateFCMToken(newToken, accessToken);
    });

    
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(
          message.notification!.title ?? 'Thông báo',
          message.notification!.body ?? '',
          message.data,
        );
      }
    });


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
     
      _handleNotificationTap(message.data);
    });

    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
    
      pendingNotificationData = initialMessage.data;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          try {
            final data = json.decode(response.payload!);
            _handleNotificationTap(data);
          } catch (e) {
            print('Error parsing notification payload: $e');
          }
        }
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'Thông báo quan trọng',
      description: 'Kênh này dùng cho các thông báo quan trọng',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _updateFCMToken(String token, String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/fcm-token'),
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
          'Thông báo quan trọng',
          channelDescription: 'Kênh này dùng cho các thông báo quan trọng',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: json.encode(data),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    print('Notification tapped with data: $data');
    print('Navigator context: ${navigatorKey?.currentContext}');

    if (data['type'] == 'new_event' && data['eventId'] != null) {
      final eventId = int.tryParse(data['eventId'].toString());

      if (eventId != null) {
        // Check duplicate navigation
        final now = DateTime.now();
        if (_lastProcessedEventId == eventId.toString() &&
            _lastProcessedTime != null &&
            now.difference(_lastProcessedTime!).inSeconds < 2) {
          print('Skipping duplicate navigation for eventId: $eventId');
          return;
        }

        _lastProcessedEventId = eventId.toString();
        _lastProcessedTime = now;

        print('Attempting to navigate to event detail: $eventId');

        // Navigate to event detail
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (navigatorKey?.currentContext != null) {
            print('Navigating to event detail: $eventId');

            Navigator.of(navigatorKey!.currentContext!).push(
              MaterialPageRoute(
                builder: (context) => EventDetailScreen(eventId: eventId),
              ),
            );
          } else {
            print('Navigator context is null, retrying...');
            Future.delayed(const Duration(milliseconds: 500), () {
              if (navigatorKey?.currentContext != null) {
                print('Navigating to event detail after delay: $eventId');
                Navigator.of(navigatorKey!.currentContext!).push(
                  MaterialPageRoute(
                    builder: (context) => EventDetailScreen(eventId: eventId),
                  ),
                );
              } else {
                print('Navigation completely failed for eventId: $eventId');
              }
            });
          }
        });
      } else {
        print('Failed to parse eventId: ${data['eventId']}');
      }
    }
  }

  
  static void processPendingNotification() {
    if (pendingNotificationData != null &&
        navigatorKey?.currentContext != null) {
      print('Processing pending notification: $pendingNotificationData');
      final data = pendingNotificationData!;
      pendingNotificationData = null;

      if (data['type'] == 'new_event' && data['eventId'] != null) {
        final eventId = int.tryParse(data['eventId'].toString());
        if (eventId != null) {
          // Check duplicate navigation
          final now = DateTime.now();
          if (_lastProcessedEventId == eventId.toString() &&
              _lastProcessedTime != null &&
              now.difference(_lastProcessedTime!).inSeconds < 3) {
            print(
              'Skipping duplicate pending navigation for eventId: $eventId',
            );
            return;
          }

          _lastProcessedEventId = eventId.toString();
          _lastProcessedTime = now;

          Navigator.of(navigatorKey!.currentContext!).push(
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(eventId: eventId),
            ),
          );
        }
      }
    }
  }
}
