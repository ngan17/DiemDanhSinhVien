import 'package:geolocator/geolocator.dart';

class LocationService {
  // static const double targetLat = 10.807350;
  // static const double targetLng = 106.6286126;
  static const double targetLat = 10.749342;
  static const double targetLng = 106.625630;

  // Bán kính cho phép (mét)
  static const double allowedRadius = 200.0;

  static Future<bool> checkLocation() async {
   

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
