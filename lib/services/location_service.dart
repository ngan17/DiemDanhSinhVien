import 'package:geolocator/geolocator.dart';

class LocationService {
  // static const double defaultLat = 10.807547; lê trọng tấn 140
  // static const double defaultLng = 106.628616;
  static const double defaultLat = 10.749246;
   static const double defaultLng = 106.625484;
  // Bán kính cho phép (mét)
  static const double allowedRadius = 200.0;

  static Map<String, double> _getTargetCoordinates(String? location) {
    if (location == null || location.isEmpty) {
      return {'lat': defaultLat, 'lng': defaultLng};
    }

    final locationLower = location.toLowerCase();

    // Kiểm tra 263 Lê Trọng Tấn 
    if (locationLower.contains('263')) {
      return {'lat': 10.807089, 'lng': 106.622563};
    }

    // Kiểm tra 140 Lê Trọng Tấn
    if (locationLower.contains('140')) {
      return {'lat': 10.807547, 'lng': 106.628616};
    }

    return {'lat': defaultLat, 'lng': defaultLng};
  }

  static Future<bool> checkLocation({String? location}) async {
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print(" KIỂM TRA VỊ TRÍ");
    print(" Location từ sự kiện: ${location ?? 'NULL/EMPTY'}");

    final coordinates = _getTargetCoordinates(location);
    final targetLat = coordinates['lat']!;
    final targetLng = coordinates['lng']!;

    print(" Tọa độ mục tiêu đã chọn:");
    print("   Latitude:  $targetLat");
    print("   Longitude: $targetLng");
    final locationLower = location?.toLowerCase() ?? '';
    if (locationLower.contains('263') || locationLower.contains('sân trường')) {
      print("    Đã chọn: 263 Lê Trọng Tấn (Sân trường)");
    } else if (locationLower.contains('140')) {
      print("    Đã chọn: 140 Lê Trọng Tấn");
    } else {
      print("    Mặc định: 140 Lê Trọng Tấn");
    }
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print(" GPS Service: ${serviceEnabled ? 'BẬT' : 'TẮT'}");
    if (!serviceEnabled) {
      throw 'Vui lòng bật GPS (Vị trí) trên điện thoại.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Bạn cần cấp quyền Vị trí để điểm danh.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Quyền vị trí bị chặn vĩnh viễn. Vào Cài đặt máy để mở lại.';
    }

    print(" Đang lấy vị trí GPS...");
    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
    print(" Đã lấy được vị trí:");
    print("    Lat: ${currentPosition.latitude}");
    print("    Lng: ${currentPosition.longitude}");
    print("    Accuracy: ${currentPosition.accuracy}m");
    print("    Altitude: ${currentPosition.altitude}m");
    print("    Speed: ${currentPosition.speed}m/s");
    print("    isMocked: ${currentPosition.isMocked}");

    if (currentPosition.isMocked) {
      print(" PHÁT HIỆN GIAN LẬN: isMocked = true");
      throw ' GIAN LẬN PHÁT HIỆN!\n\nHệ thống phát hiện bạn đang sử dụng giả lập vị trí (Fake GPS).\n\nVui lòng TẮT ứng dụng Fake GPS và thử lại.';
    }
    print(" Kiểm tra Fake GPS: PASS (isMocked = false)");

    print(" VỊ TRÍ HỢP LỆ - KHÔNG PHÁT HIỆN FAKE GPS ");

    double distanceInMeters = Geolocator.distanceBetween(
      targetLat,
      targetLng,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    double distanceInKm = distanceInMeters / 1000;

    print(
      " Vị trí SV: ${currentPosition.latitude}, ${currentPosition.longitude}",
    );
    print(
      " Khoảng cách: ${distanceInMeters.toStringAsFixed(1)}m (${distanceInKm.toStringAsFixed(2)}km)",
    );
    print(
      " Fake GPS Check: ${currentPosition.isMocked ? 'BỊ BẮT' : 'AN TOÀN'}",
    );

    if (distanceInMeters <= allowedRadius) {
      return true;
    } else {
      throw 'Bạn đang ở cách điểm danh ${distanceInMeters.toStringAsFixed(0)}m (${distanceInKm.toStringAsFixed(2)}km).\n\nYêu cầu phải ở trong khu vực trường (bán kính ${allowedRadius.toInt()}m).';
    }
  }
}
