// lib/app/modules/driver/controllers/driver_home_controller.dart
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:get/get.dart';


class DriverController extends GetxController {
  final AuthService _authService = Get.find();

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.LOGIN);
  }
}