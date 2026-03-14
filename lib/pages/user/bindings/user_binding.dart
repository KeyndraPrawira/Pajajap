import 'package:e_pasar/pages/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

import 'package:e_pasar/app/services/auth_services.dart';
import 'package:e_pasar/pages/pedagang/controllers/produk_controller.dart';
import 'package:e_pasar/pages/user/controllers/keranjang_controller.dart';
import 'package:e_pasar/pages/user/controllers/produk_controller.dart';
import 'package:e_pasar/pages/user/controllers/profile_controller.dart';
import 'package:e_pasar/pages/user/controllers/pasar_controller.dart';

import '../controllers/user_controller.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KeranjangController>(
      () => KeranjangController(),
    );
    Get.lazyPut<ProdukController>(
      () => ProdukController(),
    );
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

    //Register ProdukController
    Get.lazyPut<UserProdukController>(
      () => UserProdukController(),
    );

    // Register ProfileController
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );

    // Register PasarController
    Get.lazyPut<PasarController>(
      () => PasarController(),
    );

    Get.lazyPut<AuthController>(
      () => AuthController(),
    );
  }
}
