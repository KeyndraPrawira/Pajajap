import 'package:e_pasar/app/routes/app_pages.dart';
import 'dart:async';
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:e_pasar/app/services/order_services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

class DriverController extends GetxController {
  final AuthService _authService = Get.find();
  final OrderService orderService = Get.put(OrderService());

  // Dummy data for driver home
  var balance = 'Rp 250.000'.obs;
  var incomeSpots = <FlSpot>[].obs;
  var pendingOrders = <dynamic>[].obs;
  Timer? _pollTimer;
  
  @override
  void onInit() {
    super.onInit();
    generateDummyIncomeData();
    startPolling();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  void startPolling() {
    pollPendingOrders();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => pollPendingOrders());
  }

  Future<void> pollPendingOrders() async {
    try {
      final orders = await orderService.getPendingOrders();
      pendingOrders.value = orders.where((order) => order['status'] == 'menunggu_driver').toList();
    } catch (e) {
      print('Polling error: $e');
    }
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

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

    Future<void> acceptOrder(int orderId) async {
  try {
      await orderService.acceptOrder(orderId);
      Get.snackbar('Success', 'Order diterima!');
      pollPendingOrders(); // Refresh list
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
    }

  }



