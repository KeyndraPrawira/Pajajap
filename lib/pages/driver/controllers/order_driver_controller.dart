import 'dart:async';

import 'package:e_pasar/app/data/models/order_model.dart';
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/order_services.dart';
import 'package:e_pasar/pages/driver/views/delivery_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

class OrderDriverController extends GetxController {
  final OrderService orderService = Get.put(OrderService());
    final Rxn<DataOrder> orderData = Rxn<DataOrder>();

  // Dummy data for driver home
  var balance = 'Rp 250.000'.obs;
  


  var incomeSpots = <FlSpot>[].obs;
  var pendingOrders = <dynamic>[].obs;   // menunggu_driver
  var activeOrders = <DataOrder>[].obs;    // dalam_proses / dikirim
  var buyer = <Buyer>[].obs;
  Timer? _pollTimer;
@override
  void onInit() {
    super.onInit();
    generateDummyIncomeData();
    startPolling(); // for pending
    startActivePolling(); // for active
  }

@override
  void onClose() {
    _pollTimer?.cancel();
    _activePollTimer?.cancel();
    super.onClose();
  }

  void startPolling() {
    pollPendingOrders();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => pollPendingOrders());
  }

  Future<void> pollPendingOrders() async {
  try {
    final orders = await orderService.getPendingOrders();
    pendingOrders.value = orders
        .where((o) => o['status'] == 'menunggu_driver')
        .toList();
  } catch (e) {
    print('Polling error: $e');
  }
} 

      Future<void> pollActiveOrders() async {
      try {
        final rawOrders = await orderService.getActiveOrder();
        if (rawOrders.isNotEmpty) {
          // Parse setiap item lewat DataOrder supaya kode_pesanan → String
          activeOrders.value = rawOrders
              .map((item) => DataOrder.fromJson(item as Map<String, dynamic>))
              .toList();

        } else {
          activeOrders.value = [];
        }
      } catch (e) {
        print('Polling active orders error: $e');
      }
    }

  Timer? _activePollTimer;

  void startActivePolling() {
    pollActiveOrders();
    _activePollTimer = Timer.periodic(const Duration(seconds: 10), (_) => pollActiveOrders());
  }

  void continueToDelivery(int orderId, String status) {
  if (status == 'dikirim') {
    Get.toNamed(
      AppRoutes.DELIVERY_SEND,
      arguments: orderId, // ← pakai orderId dari parameter
    );
    return;
  } else if (status == 'dalam_proses') {
    Get.to(() => const DeliveryView(), arguments: orderId);
  } else {
    Get.snackbar(
      'Gagal',
      'Status saat ini: $status',
    );
    }
    print('🔍 Continue to delivery for orderId: $orderId with status: $status');
  }

  Future<void> ignoreOrder(int orderId) async {
    // Remove from local list (no backend ignore, just dismiss)
    pendingOrders.removeWhere((order) => order['id'] == orderId);
    Get.snackbar('Ignored', 'Order diabaikan');
  }

  void generateDummyIncomeData() {
    incomeSpots.clear();
    final now = DateTime.now();
    for (int hour = 8; hour <= 18; hour++) {
      final time = now.add(Duration(hours: hour - now.hour));
      final value = (50 + (hour * 20) + (20 * (hour.remainder(5)))).toDouble() * 1000;
      incomeSpots.add(FlSpot(time.hour.toDouble(), value));
    }
    incomeSpots.refresh();
  }

  void refreshData() {
    balance.value = 'Rp ${250000 + (10000 * DateTime.now().millisecond ~/ 1000 % 10)}';
    generateDummyIncomeData();
    pollPendingOrders();
  }

  Future<void> acceptOrder(int id) async {
  try {
      await orderService.acceptOrder(id);
      Get.snackbar('Success', 'Order diterima!'
      
      );
      print('🔍 Get.arguments: ${Get.arguments}');
     print('🔍 orderId: $id');
      pollPendingOrders();
      Get.offAllNamed(AppRoutes.DELIVERY_CHECK, arguments:id); // Refresh list
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
    }

}
