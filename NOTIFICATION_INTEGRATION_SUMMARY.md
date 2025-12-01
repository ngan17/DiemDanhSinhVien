# Tổng kết tích hợp Thông báo

##  Đã hoàn thành

### 1. Cài đặt Dependencies
-  firebase_core: ^2.24.2
-  firebase_messaging: ^14.7.9
-  flutter_local_notifications: ^16.3.0
-  timezone: ^0.9.2

### 2. Tạo Services
-  `lib/services/fcm_service.dart` - Xử lý Firebase Cloud Messaging
-  `lib/services/local_notification_service.dart` - Xử lý Local Notifications
-  `lib/services/notification_service.dart` - API lấy danh sách thông báo

### 3. Tạo Screens
-  `lib/screens/notifications/notification_screen.dart` - Màn hình hiển thị danh sách thông báo

### 4. Cập nhật Files
-  `lib/main.dart` - Khởi tạo Firebase và Notifications
-  `lib/services/event_service.dart` - Thêm logic đặt lịch thông báo khi đăng ký sự kiện
-  `android/app/build.gradle.kts` - Thêm Google Services plugin
-  `android/build.gradle.kts` - Thêm Google Services classpath

### 5. Tài liệu
-  `FIREBASE_SETUP.md` - Hướng dẫn cấu hình Firebase

## 📋 Các bước tiếp theo

### Bước 1: Cấu hình Firebase
1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Tạo project mới hoặc chọn project hiện có
3. Thêm ứng dụng Android:
   - Package name: `com.example.diem_danh_sinh_vien`
   - Tải file `google-services.json`
   - Copy vào `android/app/google-services.json`

### Bước 2: Cấu hình AndroidManifest.xml
Thêm permissions vào `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>

<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="high_importance_channel" />
```

### Bước 3: Thêm Navigation
Thêm link điều hướng đến `NotificationScreen` trong các màn hình:

#### Trong Dashboard:
```dart
IconButton(
  icon: const Icon(Icons.notifications_outlined),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationScreen(),
      ),
    );
  },
),
```

### Bước 4: Test
1. Chạy app: `flutter run`
2. Check console log để lấy FCM Token
3. Test gửi thông báo từ Firebase Console
4. Test đăng ký sự kiện để kiểm tra Local Notification

## 🔄 Luồng hoạt động

### 1. Thông báo sự kiện mới (FCM)
```
Admin tạo sự kiện
    ↓
Backend gửi FCM notification
    ↓
FCMService nhận notification
    ↓
Hiển thị Local Notification
    ↓
User tap notification → Navigate to event detail
```

### 2. Nhắc nhở sự kiện sắp diễn ra (Local Notification)
```
User đăng ký sự kiện
    ↓
Backend trả về thông tin localNotification
    ↓
EventService đặt lịch Local Notification (trước 1 ngày)
    ↓
Đến thời gian → Hiển thị notification
    ↓
User tap notification → Navigate to event detail
```

### 3. Xem lịch sử thông báo
```
User mở NotificationScreen
    ↓
Call API /notifications
    ↓
Hiển thị danh sách thông báo
    ↓
User có thể:
  - Swipe để xóa
  - Tap để xem chi tiết
```

## 🎯 Tính năng đã tích hợp

### FCM (Firebase Cloud Messaging)
-  Nhận thông báo khi app đang chạy (foreground)
-  Nhận thông báo khi app ở background
-  Nhận thông báo khi app đã đóng (terminated)
-  Tự động gửi FCM Token lên server
-  Xử lý navigation khi tap vào notification

### Local Notifications
-  Đặt lịch thông báo trước 1 ngày
-  Hủy thông báo
-  Timezone support (Asia/Ho_Chi_Minh)
-  Custom notification channel

### Notification Screen
-  Hiển thị danh sách thông báo
-  Pull to refresh
-  Swipe to delete
-  Empty state
-  Error handling

## ⚠️ Lưu ý quan trọng

1. **File google-services.json**
   - KHÔNG commit lên git
   - Thêm vào `.gitignore`

2. **Permissions**
   - Android 13+ yêu cầu POST_NOTIFICATIONS permission
   - Cần request permission runtime

3. **Exact Alarms**
   - Android 12+ yêu cầu SCHEDULE_EXACT_ALARM permission
   - Local notifications cần exact alarm để hoạt động chính xác

4. **Background Execution**
   - iOS có giới hạn về background tasks
   - Test kỹ trên cả Android và iOS

## 🐛 Troubleshooting

### Không nhận được FCM notification:
1. Check file `google-services.json`
2. Check FCM Token trong console log
3. Check backend có gửi đúng format không
4. Test với Firebase Console

### Local notification không hiển thị:
1. Check permissions trong AndroidManifest.xml
2. Check timezone configuration
3. Check scheduled time có đúng không
4. Check notification channel đã được tạo chưa

### Build lỗi:
```bash
flutter clean
flutter pub get
flutter run
```

## 📚 Tài liệu tham khảo

- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Timezone](https://pub.dev/packages/timezone)

##  Hoàn thành!

Hệ thống thông báo đã được tích hợp hoàn chỉnh. Bạn có thể:
1. Nhận thông báo khi có sự kiện mới từ server (FCM)
2. Nhận nhắc nhở trước 1 ngày khi sự kiện sắp diễn ra (Local Notification)
3. Xem lịch sử thông báo trong app
4. Xóa thông báo không cần thiết

Nếu có vấn đề gì, hãy check file `FIREBASE_SETUP.md` để biết thêm chi tiết!
