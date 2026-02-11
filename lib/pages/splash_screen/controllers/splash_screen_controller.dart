// lib/app/modules/splash/controllers/splash_controller.dart
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:get/get.dart';


class SplashScreenController extends GetxController {
  late AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    print('🔵 SplashScreenController - onInit');
    _authService = Get.find();
    print('🔵 SplashScreenController - AuthService found');
  }

  @override
  void onReady() {
    super.onReady();
    print('🔵 SplashScreenController - onReady');
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    print('🔵 SplashScreenController - _checkAuth START');
    // Delay untuk splash screen
    await Future.delayed(const Duration(seconds: 2));
    print('🔵 SplashScreenController - Delay done');

    // Cek apakah user sudah login (dari local storage)
    final token = _authService.getToken();
    print('🔵 SplashScreenController - Token: $token');

    if (token != null && token.isNotEmpty) {
      // User sudah login, check berdasarkan role
      final role = _authService.getRole();
      print('🔵 SplashScreenController - Role: $role');
      if (role != null && role.isNotEmpty) {
        print('🔵 SplashScreenController - Navigating to Home');
        _navigateToHome(role);
      } else {
        // Tidak ada role, ke login
        print('🔵 SplashScreenController - No role, navigating to LOGIN');
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    } else {
      // User belum login
      print('🔵 SplashScreenController - No token, navigating to LOGIN');
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  void _navigateToHome(String role) {
    switch (role.toLowerCase()) {
      case 'pedagang':
        Get.offAllNamed(AppRoutes.PEDAGANG_HOME);
        break;
      case 'driver':
        Get.offAllNamed(AppRoutes.DRIVER_HOME);
        break;
      case 'user':
      default:
        Get.offAllNamed(AppRoutes.USER_HOME);
        break;
    }
  }
}