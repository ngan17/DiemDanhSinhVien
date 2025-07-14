import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  Future<void> changePassword(BuildContext context) async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      _showError(context, "Mật khẩu hiện tại không được để trống");
      return;
    }

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showError(
        context,
        "Mật khẩu mới và xác nhận mật khẩu không được để trống",
      );
      return;
    }

    if (newPassword == currentPassword) {
      _showError(
        context,
        "Mật khẩu mới không được trùng với mật khẩu hiện tại",
      );
      return;
    }

    if (newPassword != confirmPassword) {
      _showError(context, "Mật khẩu mới và xác nhận mật khẩu không khớp");
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      // Gửi yêu cầu đổi mật khẩu đến Supabase
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        throw Exception("Đổi mật khẩu không thành công");
      }

      isLoading = false;
      notifyListeners();

      _showSuccess(context, "Đổi mật khẩu thành công");
      Navigator.pop(context); // Quay lại màn hình trước đó
    } catch (e) {
      isLoading = false;
      notifyListeners();
      _showError(context, "Có lỗi xảy ra: $e");
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.green)),
      ),
    );
  }
}
