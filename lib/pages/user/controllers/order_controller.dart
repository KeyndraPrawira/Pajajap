import 'package:e_pasar/app/data/models/order_model.dart';
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/order_services.dart';
import 'package:e_pasar/pages/user/views/user_delivery_view.dart';

import 'package:get/get.dart';

class OrderController extends GetxController {
  var activeOrders = <DataOrder>[].obs;
  //TODO: Implement OrderControllerController

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchActiveOrders() async {
    try {
      final orders = await OrderService().getActiveOrder();
     activeOrders.value = orders.map((o) => DataOrder.fromJson(o)).toList();
       print('📥 [ACTIVE ORDERS] Fetched ${orders.length} active orders');
     return ;
    } catch (e) {
      print('Error fetching active orders: $e');
    }    
  }

  void continueToDelivery(int orderId, String status) {
  if (status=='dalam_proses' ||status == 'dikirim') {
    Get.toNamed(
      AppRoutes.USER_DELIVERY,
      arguments: orderId, // ← pakai orderId dari parameter
    );
    return;
  } else {
    Get.snackbar(
      'Gagal',
      'Status saat ini: $status',
    );
    }
    print('🔍 Continue to delivery for orderId: $orderId with status: $status');
  }
}  
 

