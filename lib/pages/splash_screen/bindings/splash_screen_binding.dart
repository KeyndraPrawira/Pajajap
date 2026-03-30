// lib/app/modules/splash/bindings/splash_binding.dart
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:e_pasar/pages/splash_screen/controllers/splash_screen_controller.dart';
import 'package:get/get.dart';


class SplashScreenBinding extends Bindings {
  @override
  void dependencies() {
    print('🔵 SplashScreenBinding - Loading AuthService');
    // AuthService permanent supaya bisa dipake di seluruh app
    print('🔵 SplashScreenBinding - Loading SplashScreenController');
    Get.put(SplashScreenController());
    print('🔵 SplashScreenBinding - Done');
  }
}