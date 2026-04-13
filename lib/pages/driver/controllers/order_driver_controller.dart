import 'dart:async';
import 'package:e_pasar/app/data/models/order_model.dart';
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/order_services.dart';
import 'package:e_pasar/app/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderDriverController extends GetxController {
  final OrderService orderService = Get.find<OrderService>();
  final UserService userService = Get.find<UserService>();

  var pendingOrders = <Map<String, dynamic>>[].obs;
  final RxList<DataOrder> activeOrders = <DataOrder>[].obs;
  final RxList<DataOrder> orderList = <DataOrder>[].obs;
  final Rxn<DataOrder> selectedOrder = Rxn<DataOrder>();
  final RxBool isLoading = false.obs;
  final RxMap<int, bool> loadingOrders = <int, bool>{}.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxString errorMessage = ''.obs;
  var currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  var isOnline = false.obs;

  void toggleOnline() async {
    final isOnline = await userService.setActive(!this.isOnline.value);
    this.isOnline.value = isOnline['data']['is_online'] as bool;
  }

  @override
  void onInit() {
    super.onInit();
    setupRealTime();
    loadPendingOrders();
    loadActiveOrders();
    fetchHistory();
  }

  void setupRealTime() {
    orderService.initRealTime(_handleRealTimeUpdate);
    orderService.connectRealTime();
  }

  void _handleRealTimeUpdate(Map<String, dynamic> updatedOrder) {
    final rawId = updatedOrder['id'];
    final orderId =
        rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
    final status = updatedOrder['status']?.toString();

    if (orderId == null || status == null) {
      return;
    }

    if (status == 'menunggu_driver') {
      if (!pendingOrders.any((o) => o['id'] == orderId)) {
        pendingOrders.insert(0, updatedOrder);
        Get.snackbar('🚚 New Order!', '#${updatedOrder['kode_pesanan']}');
      }
    } else if (status == 'dalam_proses') {
      pendingOrders.removeWhere((o) => o['id'] == orderId);
      if (!activeOrders.any((o) => o.id == orderId)) {
        activeOrders.insert(0, DataOrder.fromJson(updatedOrder));
      }
    } else if (status == 'dikirim') {
      final idx = activeOrders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        activeOrders[idx] = DataOrder.fromJson(updatedOrder);
        activeOrders.refresh();
      }
    } else if (status == 'selesai' || status == 'dibatalkan') {
      pendingOrders.removeWhere((o) => o['id'] == orderId);
      activeOrders.removeWhere((o) => o.id == orderId);
      if (status == 'selesai') {
        fetchHistory();
      } else {
        orderList.removeWhere((order) => order.id == orderId);
      }
    }
  }

  Future<void> loadPendingOrders() async {
    try {
      final orders = await orderService.getPendingOrders();
      pendingOrders.value = orders
          .where((o) => o['status'] == 'menunggu_driver')
          .cast<Map<String, dynamic>>()
          .toList();
      pendingOrders.refresh();
    } catch (e) {
      print('Load pending error: $e');
    }
  }

  Future<void> loadActiveOrders() async {
    try {
      final orders = await orderService
          .getActiveOrders(); // ← ganti getActiveOrder() → getActiveOrders()
      activeOrders.value = orders.cast<DataOrder>().toList();
      activeOrders.refresh();
    } catch (e) {
      print('Load active error: $e');
    }
  }

  Future<void> continueToDelivery(int orderId, String status) async {
    if (status == 'dalam_proses') {
      Get.toNamed(AppRoutes.DELIVERY_CHECK, arguments: orderId);
    } else if (status == 'dikirim') {
      Get.toNamed(AppRoutes.DELIVERY_SEND, arguments: orderId);
    } else {
      Get.snackbar('Error', 'Status order tidak valid');
    }
  }

  Future<void> ignoreOrder(int orderId) async {
    pendingOrders.removeWhere((order) => order['id'] == orderId);
    pendingOrders.refresh();
    Get.snackbar('✅ Diabaikan', 'Order dihapus dari daftar');
  }

  Future<void> refreshData() async {
    await Future.wait([
      loadPendingOrders(),
      loadActiveOrders(),
    ]);
  }

  Future<void> acceptOrder(int id) async {
    loadingOrders[id] = true;
    loadingOrders.refresh();

    try {
      await orderService.acceptOrder(id);
      Get.offAllNamed(AppRoutes.DELIVERY_CHECK, arguments: id);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      loadingOrders.remove(id);
      loadingOrders.refresh();
    }
  }

  // ─── GET ALL HISTORY ──────────────────────────────────────
  Future<void> fetchHistory() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await orderService.getOrderHistory();
      final histories = result
          .map((e) => DataOrder.fromJson(e as Map<String, dynamic>))
          .where((order) => order.status == 'selesai')
          .toList()
        ..sort((a, b) {
          final aTime = a.updatedAt ??
              a.createdAt ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.updatedAt ??
              b.createdAt ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });

      orderList.assignAll(histories);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      orderList.clear();
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── GET DETAIL HISTORY ───────────────────────────────────
  Future<void> fetchDetail(int id) async {
    try {
      isLoadingDetail.value = true;

      final result = await orderService.getOrderHistoryDetail(id);
      selectedOrder.value = DataOrder.fromJson(result);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingDetail.value = false;
    }
  }

  // ─── Helper format rupiah ─────────────────────────────────
  String formatRupiah(int? value) {
    if (value == null) return 'Rp0';
    final s = value.toString();
    final buffer = StringBuffer('Rp');
    final offset = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  // ─── Helper status label & color ─────────────────────────
  String statusLabel(String? status) {
    return switch (status) {
      'selesai' => 'Selesai',
      'dibatalkan' => 'Dibatalkan',
      'dikirim' => 'Dikirim',
      'dalam_proses' => 'Dalam Proses',
      _ => status ?? '-',
    };
  }

  Color statusColor(String? status) {
    return switch (status) {
      'selesai' => const Color(0xFF06D6A0),
      'dibatalkan' => const Color(0xFFFF6B6B),
      'dikirim' => const Color(0xFF0077B6),
      'dalam_proses' => const Color(0xFFFF9800),
      _ => const Color(0xFF6C757D),
    };
  }

  @override
  void onClose() {
    orderService.disconnectRealTime();
    super.onClose();
  }
}
