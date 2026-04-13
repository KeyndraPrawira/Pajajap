import 'package:e_pasar/app/services/order_services.dart';
import 'package:get/get.dart';

import 'package:e_pasar/app/services/auth_services.dart';
import 'package:e_pasar/app/services/user_services.dart';
import 'package:e_pasar/pages/driver/controllers/delivery_controller.dart';
import 'package:e_pasar/pages/driver/controllers/driver_wallet_controller.dart';
import 'package:e_pasar/pages/driver/controllers/order_driver_controller.dart';

import '../controllers/driver_controller.dart';

class DriverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderDriverController>(() => OrderDriverController(),
        fenix: true);

    // Register AuthService jika belum ada
    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(
        AuthService(),
        permanent: true,
      );
    }

    Get.lazyPut<DeliveryController>(() => DeliveryController(), fenix: true);

    Get.lazyPut<DriverController>(() => DriverController(), fenix: true);
    Get.lazyPut<DriverWalletController>(
      () => DriverWalletController(),
      fenix: true,
    );
    Get.put(UserService(), permanent: true);
    Get.lazyPut(() => OrderService(), fenix: true);
  }
}
