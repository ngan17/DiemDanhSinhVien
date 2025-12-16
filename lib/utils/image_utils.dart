class ImageUtils {
  
  static String getImageUrl(String? imagePath) {
    // Backend chỉ trả về URL Cloudinary đầy đủ
    return imagePath ?? '';
  }

  /// Kiểm tra xem có phải là URL Cloudinary không
  static bool isCloudinaryUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return false;
    }
    return imagePath.contains('cloudinary.com');
  }
}
