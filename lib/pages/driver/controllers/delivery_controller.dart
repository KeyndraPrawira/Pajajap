import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/pages/driver/views/delivery_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_pasar/app/data/models/order_model.dart';
import 'package:e_pasar/app/services/order_services.dart';

class DeliveryController extends GetxController {
  final OrderService orderService = Get.find();

  final Rxn<DataOrder> orderData = Rxn<DataOrder>();
  var isLoading = false.obs;

  // Track status per orderDetail id
  final RxMap<int, String> itemStatus = <int, String>{}.obs;
  var isUpdating = false.obs;
  var loadingItems = <int, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final orderId = Get.arguments as int?;
    if (orderId != null) loadOrder(orderId);
  }

  Future<void> loadOrder(int orderId) async {
    isLoading.value = true;
    try {
      final response = await orderService.detailOrder(orderId);
      orderData.value = DataOrder.fromJson(response);
    } catch (e) {
      Get.snackbar('Error', 'Gagal load order: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onItemTap(OrderDetail detail) async {
    if (detail.id == null) return;
    final current = itemStatus[detail.id] ?? '';
    if (current == 'diambil') return;
    await updateItemStatus(detail.id!, 'diambil');
  }

  Future<void> checkActiveOrder() async {
    final activeOrder = await orderService.getActiveOrder();
    if (activeOrder.isNotEmpty) {
      final status = orderData.value?.status;
      final driverId = orderData.value?.driverId;

      if ((status == 'dalam_proses') && driverId != null) {
        Get.offAll(() => const DeliveryView(), arguments: orderData.value?.id);
      } else if (status == 'dikirim') {
        Get.toNamed(AppRoutes.DELIVERY_SEND, arguments: orderData.value!.id!);
      } else {
        Get.snackbar('Gagal', 'Tidak ada pesanan aktif yang dapat ditampilkan');
      }
    }
  }

  /// [catatan] opsional, diisi saat status = 'tidak_ada'
  Future<void> updateItemStatus(int id, String newStatus,
      {String? catatan}) async {
    loadingItems[id] = true;
    try {
      await orderService.updateItemStatus(id, newStatus,  catatan: catatan);
      itemStatus[id] = newStatus;
      catatan != null ? Get.snackbar('Catatan', catatan) : null;
    } catch (e) {
      print('Error: $e');
    } finally {
      loadingItems[id] = false;
    }
  }

  Future<void> sendDelivery() async {
    if (orderData.value == null) return;
    final details = orderData.value!.orderDetails ?? [];
    final adaPending = details.any((d) {
      final status = itemStatus[d.id] ?? d.status ?? 'pending';
      return status == 'pending';
    });
    if (adaPending) {
      Get.snackbar(
        'Belum selesai',
        'Semua barang harus dicek dulu sebelum melanjutkan',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return;
    }
    try {
      final orderId = orderData.value!.id!;
      await orderService.sendDelivery(orderId);
      await loadOrder(orderId);
      Get.snackbar('Sukses', 'Pesanan sedang dikirim! 🚚');
      Get.toNamed(AppRoutes.deliverySend(orderId));
    } catch (e) {
      Get.snackbar('Gagal', e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> completeDelivery() async {
    if (orderData.value == null) return;
    try {
      await orderService.completeDelivery(orderData.value!.id!);
      Get.snackbar('Sukses', 'Delivery selesai!');
      Get.offAllNamed(AppRoutes.DRIVER_HOME);
    } catch (e) {
      Get.snackbar('Error', 'Gagal selesai delivery: $e');
    }
  }
}