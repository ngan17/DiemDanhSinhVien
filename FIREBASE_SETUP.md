# Hướng dẫn cấu hình Firebase Cloud Messaging

## 1. Tạo Firebase Project

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Tạo project mới hoặc chọn project hiện có
3. Thêm ứng dụng Android vào project

## 2. Cấu hình Android

### Bước 1: Tải file google-services.json
1. Vào Project Settings > General
2. Scroll xuống phần "Your apps"
3. Tải file `google-services.json`
4. Copy file vào thư mục: `android/app/google-services.json`

### Bước 2: Cấu hình AndroidManifest.xml
Thêm các quyền vào file `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Thêm các permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
    
    <application
        android:label="diem_danh_sinh_vien"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Thêm meta-data cho Firebase -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="high_importance_channel" />
            
        <!-- Activity configuration -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:showWhenLocked="true"
            android:turnScreenOn="true"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
```

## 3. Cấu hình iOS (nếu cần)

### Bước 1: Tải file GoogleService-Info.plist
1. Vào Project Settings > General
2. Tải file `GoogleService-Info.plist`
3. Copy file vào thư mục: `ios/Runner/`

### Bước 2: Cấu hình Info.plist
Mở file `ios/Runner/Info.plist` và đảm bảo có:

```xml
<key>FirebaseMessagingAutoInitEnabled</key>
<true/>
```

## 4. Test thông báo

### Gửi test notification từ Firebase Console:
1. Vào Firebase Console > Cloud Messaging
2. Chọn "Send your first message"
3. Nhập title và body
4. Chọn target: Single device hoặc Topic
5. Gửi thông báo test

### Gửi thông báo từ Backend:
Backend sẽ gửi thông báo với payload:

```json
{
  "to": "<FCM_TOKEN>",
  "notification": {
    "title": "Sự kiện mới",
    "body": "Giải bóng đá sinh viên đã được mở đăng ký!"
  },
  "data": {
    "type": "new_event",
    "eventId": "123"
  }
}
```

## 5. Kiểm tra FCM Token

Sau khi chạy app, check console log để xem FCM Token:
```
FCM Token: <your-token-here>
```

Token này sẽ được gửi lên server để backend có thể gửi thông báo.

## 6. Troubleshooting

### Không nhận được thông báo:
1. Kiểm tra file `google-services.json` đã được thêm đúng chưa
2. Kiểm tra permissions trong AndroidManifest.xml
3. Kiểm tra FCM Token có được gửi lên server chưa
4. Kiểm tra log trong console

### Build lỗi:
1. Chạy: `flutter clean`
2. Chạy: `flutter pub get`
3. Rebuild app: `flutter run`

## 7. Note quan trọng

- File `google-services.json` KHÔNG được commit lên git
- Thêm vào `.gitignore`:
```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

- Local Notifications chỉ hoạt động khi được schedule trước
- FCM notifications có thể nhận cả khi app đang đóng
