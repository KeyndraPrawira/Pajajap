import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/payment_realtime_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_pasar/app/data/models/order_model.dart';
import 'package:e_pasar/app/services/order_services.dart';

class DeliveryController extends GetxController {
  var isUserMode = false.obs;
  final OrderService orderService = Get.find();

  final Rxn<DataOrder> orderData = Rxn<DataOrder>();
  var isLoading = false.obs;

  // Track status per orderDetail id
  final RxMap<int, String> itemStatus = <int, String>{}.obs;
  var isUpdating = false.obs;
  var loadingItems = <int, bool>{}.obs;
  PaymentRealtimeService? _orderRealtimeService;
  int? _listenedOrderId;
  String? _lastShownStatus;
  String? _lastShownPaymentStatus;

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
      _lastShownStatus = orderData.value?.status;
      _lastShownPaymentStatus = orderData.value?.paymentStatus;
      await _startRealtime(orderId);
      itemStatus.clear();
      // Load item status from order details
      for (var detail in orderData.value!.orderDetails ?? []) {
        if (detail.id != null) {
          itemStatus[detail.id!] = detail.status ?? 'pending';
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal load order: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _startRealtime(int orderId) async {
    if (_listenedOrderId == orderId && _orderRealtimeService != null) {
      return;
    }

    await _orderRealtimeService?.disconnect();
    _listenedOrderId = orderId;
    _orderRealtimeService = PaymentRealtimeService(
      orderId: orderId,
      onOrderUpdate: _handleRealtimeOrderUpdate,
    );
    await _orderRealtimeService!.connect();
  }

  void _handleRealtimeOrderUpdate(Map<String, dynamic> updatedOrder) {
    final currentOrder = orderData.value;
    if (currentOrder == null) {
      return;
    }

    final mergedJson = currentOrder.toJson()..addAll(updatedOrder);
    final mergedOrder = DataOrder.fromJson(mergedJson);
    orderData.value = mergedOrder;

    final latestStatus = mergedOrder.status ?? '';
    final latestPaymentStatus = mergedOrder.paymentStatus ?? '';

    if (latestStatus != _lastShownStatus) {
      if (isUserMode.value &&
          latestStatus == 'dikirim' &&
          (mergedOrder.metodePembayaran ?? '').toLowerCase() == 'midtrans' &&
          latestPaymentStatus.toLowerCase() != 'paid') {
        Get.snackbar(
          'Waktunya Bayar',
          'Pesanan sedang dikirim. Silakan lanjutkan pembayaran Midtrans.',
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade900,
        );
      } else if (!isUserMode.value && latestStatus == 'dikirim') {
        Get.snackbar(
          'Lanjut Antar',
          'Pesanan sudah masuk status dikirim. Antar ke alamat pembeli.',
        );
      }
      _lastShownStatus = latestStatus;
    }

    if (latestPaymentStatus != _lastShownPaymentStatus &&
        latestPaymentStatus.toLowerCase() == 'paid') {
      Get.snackbar(
        'Pembayaran Berhasil',
        'Pembayaran order ini sudah diterima.',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
      _lastShownPaymentStatus = latestPaymentStatus;
    } else if (latestPaymentStatus != _lastShownPaymentStatus) {
      _lastShownPaymentStatus = latestPaymentStatus;
    }
  }

  Future<void> onItemTap(OrderDetail detail) async {
    if (isUserMode.value) return; // User mode: read-only
    if (detail.id == null) return;
    final current = itemStatus[detail.id] ?? '';
    if (current == 'diambil') return;
    await updateItemStatus(detail.id!, 'diambil');
  }

  Future<void> checkActiveOrder() async {
    final activeOrder = await orderService.getActiveOrders();
    if (activeOrder.isNotEmpty) {
      final status = orderData.value?.status;
      final driverId = orderData.value?.driverId;

      if ((status == 'dalam_proses') && driverId != null) {
        Get.offAllNamed('/delivery-check', arguments: orderData.value?.id);
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
    if (isUserMode.value) return; // User mode: no updates
    loadingItems[id] = true;
    try {
      await orderService.updateItemStatus(id, newStatus, catatan: catatan);
      itemStatus[id] = newStatus;
      catatan != null ? Get.snackbar('Catatan', catatan) : null;
    } catch (e) {
      print('Error: $e');
    } finally {
      loadingItems[id] = false;
    }
  }

  Future<void> sendDelivery() async {
    if (isUserMode.value) return; // User mode: no action
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
    if (isUserMode.value) return; // User mode: no action
    if (orderData.value == null) return;
    try {
      await orderService.completeDelivery(orderData.value!.id!);
      Get.snackbar('Sukses', 'Delivery selesai!');
      Get.offAllNamed(AppRoutes.DRIVER_HOME);
    } catch (e) {
      Get.snackbar('Error', 'Gagal selesai delivery: $e');
    }
  }

  @override
  void onClose() {
    _orderRealtimeService?.disconnect();
    super.onClose();
  }
}
