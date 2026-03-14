import 'package:get/get.dart';

import 'package:e_pasar/app/services/auth_services.dart';
import 'package:e_pasar/app/services/kios_services.dart';
import 'package:e_pasar/pages/pedagang/controllers/produk_controller.dart';
import 'package:e_pasar/pages/pedagang/controllers/produk_form_controller.dart';

import '../controllers/pedagang_controller.dart';

class PedagangBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ProdukFormController>(
      ProdukFormController(),
    );
    Get.put<ProdukController>(
      ProdukController(),
    );
    // Register AuthService jika belum ada
    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(
        AuthService(),
        permanent: true,
      );
    }

    // Register KiosService jika belum ada
    if (!Get.isRegistered<KiosService>()) {
      Get.put<KiosService>(
        KiosService(),
        permanent: true,
      );
    }

    // Register PedagangController
    Get.lazyPut<PedagangController>(
      () => PedagangController(),
    );


  }
}
