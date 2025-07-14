import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>?> login(
    String maNguoiDung,
    String matKhau,
  ) async {
    try {
      final response = await _client
          .from('NguoiDung')
          .select()
          .eq('MaNguoiDung', maNguoiDung)
          .eq('MatKhau', matKhau)
          .single();
      // Truy cập vào response.data
      if (response != null && response is Map<String, dynamic>) {
        return response;
      } else {
        return null;
      }
    } catch (e) {
      print('Lỗi đăng nhập: $e');
      return null;
    }
  }
}
