import 'package:e_pasar/app/services/auth_services.dart';
import 'package:get/get.dart';

import '../controllers/user_controller.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    // Register AuthService jika belum ada
    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(
        AuthService(),
        permanent: true,
      );
    }
    
    // Register UserController
    Get.lazyPut<UserController>(
      () => UserController(),
    );
  }
}
