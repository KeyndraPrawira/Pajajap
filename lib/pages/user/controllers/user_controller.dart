import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final AuthService _authService = Get.find();

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  final currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }
}
