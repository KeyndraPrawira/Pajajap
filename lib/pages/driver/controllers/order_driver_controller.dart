import 'dart:async';

import 'package:e_pasar/app/data/models/order_model.dart';
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/order_services.dart';
import 'package:e_pasar/pages/driver/views/delivery_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

class OrderDriverController extends GetxController {
  final OrderService orderService = Get.find<OrderService>();
  var pendingOrders = <Map<String, dynamic>>[].obs;
  final RxMap<int, bool> loadingOrders = <int, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    setupRealTime();  // CUMA INI YANG DIBUTUHKAN!
    loadPendingOrders();
    loadActiveOrders(); // Sekali aja buat initial load
  }

  // 🔥 REAL-TIME ONLY (No Polling!)
  void setupRealTime() {
    orderService.initRealTime(_handleRealTimeUpdate);
    orderService.connectRealTime();
  }
  
  void _handleRealTimeUpdate(Map<String, dynamic> updatedOrder) {
    final orderId = updatedOrder['id'] as int;
    
    if (updatedOrder['status'] == 'menunggu_driver') {
      // NEW ORDER
      if (!pendingOrders.any((o) => o['id'] == orderId)) {
        pendingOrders.insert(0, updatedOrder);
        Get.snackbar('🚚 New Order!', '#${updatedOrder['kode_pesanan']}');
      }
    } else {
      // ORDER DIAMBIL / UPDATE
      final index = pendingOrders.indexWhere((o) => o['id'] == orderId);
      if (index != -1) {
        pendingOrders.removeAt(index);
        Get.snackbar('⏰ Order Taken!', 'Diambil driver lain');
      }
    }

    // Orderan yang telah diterima
    if (updatedOrder['status'] == 'dalam_proses' || updatedOrder['status'] == 'dikirim') {
      if (updatedOrder['status']=='dalam_proses') {
        Get.toNamed(AppRoutes.DELIVERY_CHECK, arguments: orderId);
      }else if (updatedOrder['status']=='dikirim') {
        Get.toNamed(AppRoutes.DELIVERY_SEND, arguments: orderId);
      }
    }
  }

  // Initial load sekali aja
  Future<void> loadPendingOrders() async {
    try {
      final orders = await orderService.getPendingOrders();
      pendingOrders.value = orders
          .where((o) => o['status'] == 'menunggu_driver')
          .cast<Map<String, dynamic>>()
          .toList();
    } catch (e) {
      print('Initial load error: $e');
    }
  }

  Future<void> loadActiveOrders() async {
    try {
      final orders = await orderService.getActiveOrder();
      pendingOrders.value = orders
          .where((o) => o['status'] == 'menunggu_driver')
          .cast<Map<String, dynamic>>()
          .toList();
    } catch (e) {
      print('Initial load error: $e');
    }
  }


  Future<void> acceptOrder(int id) async {
    loadingOrders[id] = true;
    try {
      await orderService.acceptOrder(id);
      // Real-time AUTO remove dari list!
      Get.offAllNamed(AppRoutes.DELIVERY_CHECK, arguments: id);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      loadingOrders.remove(id);
    }
    loadingOrders.refresh();
  }

  @override
  void onClose() {
    orderService.disconnectRealTime();
    super.onClose();
  }
}
