// lib/app/modules/splash/controllers/splash_controller.dart
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:get/get.dart';

class SplashScreenController extends GetxController {
  late AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    print('SplashScreenController - onInit');
    _authService = Get.find();
    print('SplashScreenController - AuthService found');
  }

  @override
  void onReady() {
    super.onReady();
    print('SplashScreenController - onReady');
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    final token = _authService.getToken();
    if (token == null || token.isEmpty) {
      Get.offAllNamed(AppRoutes.LOGIN);
      return;
    }

    if (_authService.isProfileIncomplete) {
      Get.offAllNamed(AppRoutes.COMPLETE_PROFILE);
      return;
    }

    final role = _authService.getRole();
    if (role == null || role.isEmpty) {
      Get.offAllNamed(AppRoutes.LOGIN);
      return;
    }

    await _navigateToHome(role);
  }

  Future<void> _navigateToHome(String role) async {
    switch (role.toLowerCase()) {
      case 'driver':
        Get.offAllNamed(AppRoutes.DRIVER_HOME);
        break;
      case 'pedagang':
        Get.offAllNamed(AppRoutes.PEDAGANG_HOME);
        break;
      case 'user':
      default:
        Get.offAllNamed(AppRoutes.USER_HOME);
        break;
    }
  }
}
