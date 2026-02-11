import 'package:e_pasar/app/services/auth_services.dart';
import 'package:get/get.dart';

import '../controllers/pedagang_controller.dart';

class PedagangBinding extends Bindings {
  @override
  void dependencies() {
    // Register AuthService jika belum ada
    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(
        AuthService(),
        permanent: true,
      );
    }
    
    Get.lazyPut<PedagangController>(
      () => PedagangController(),
    );
  }
}
