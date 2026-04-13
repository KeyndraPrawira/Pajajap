import 'package:e_pasar/app/services/auth_services.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Daftarkan AuthService jika belum ada
    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(
        AuthService(),
        permanent: true,
      );
    }

    Get.lazyPut<AuthController>(
      () => AuthController(),
      fenix: true,
    );
  }
}
