// AuthController hanya sisa ini
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final box = GetStorage();

  void checkLogin() {
    final token = box.read('token');
    final role = box.read('role');
    if (token != null && token.toString().isNotEmpty) {
      _navigateBasedOnRole(role ?? 'user');
    } else {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  void _navigateBasedOnRole(String role) {
    switch (role.toLowerCase()) {
      case 'pedagang': Get.offAllNamed(AppRoutes.PEDAGANG_HOME); break;
      case 'driver': Get.offAllNamed(AppRoutes.DRIVER_HOME); break;
      default: Get.offAllNamed(AppRoutes.USER_HOME);
    }
  }
}