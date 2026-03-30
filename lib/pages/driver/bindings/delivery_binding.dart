import 'package:e_pasar/app/services/order_services.dart';
import 'package:e_pasar/pages/user/controllers/pasar_controller.dart';
import 'package:get/get.dart';
import '../controllers/delivery_controller.dart';

class DeliveryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryController>(
      () => DeliveryController(),
    );
    Get.lazyPut(() => PasarController(), fenix: true);

    Get.lazyPut(() => OrderService(), fenix: true);
  }
}


