import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:e_pasar/app/services/payment_realtime_services.dart';
import 'package:e_pasar/pages/driver/controllers/driver_wallet_controller.dart';
import 'package:e_pasar/pages/driver/controllers/order_driver_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_pasar/app/data/models/order_model.dart';
import 'package:e_pasar/app/services/order_services.dart';

class DeliveryController extends GetxController {
  var isUserMode = false.obs;
  final OrderService orderService = Get.find();
  final AuthService _authService = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>()
      : Get.put(AuthService(), permanent: true);

  final Rxn<DataOrder> orderData = Rxn<DataOrder>();
  var isLoading = false.obs;

  // Track status per orderDetail id
  final RxMap<int, String> itemStatus = <int, String>{}.obs;
  var isUpdating = false.obs;
  var loadingItems = <int, bool>{}.obs;
  var isCompletingDelivery = false.obs;
  PaymentRealtimeService? _orderRealtimeService;
  int? _listenedOrderId;
  String? _lastShownStatus;
  String? _lastShownPaymentStatus;
  bool _hasRedirectedAfterCancellation = false;

  @override
  void onInit() {
    super.onInit();
    isUserMode.value = (_authService.getRole() ?? '').toLowerCase() == 'user';
    final orderId = _extractOrderId(Get.arguments);
    if (orderId != null) loadOrder(orderId);
  }

  int? _extractOrderId(dynamic arguments) {
    if (arguments is int) {
      return arguments;
    }

    if (arguments is String) {
      return int.tryParse(arguments);
    }

    if (arguments is Map) {
      final rawOrderId = arguments['order_id'] ?? arguments['id'];
      if (rawOrderId is int) {
        return rawOrderId;
      }
      return int.tryParse(rawOrderId?.toString() ?? '');
    }

    return int.tryParse(Get.parameters['id'] ?? '');
  }

  Future<void> loadOrder(int orderId) async {
    isLoading.value = true;
    _hasRedirectedAfterCancellation = false;
    try {
      final response = await orderService.detailOrder(orderId);
      orderData.value = DataOrder.fromJson(response);
      _lastShownStatus = orderData.value?.status;
      _lastShownPaymentStatus = orderData.value?.paymentStatus;
      _syncItemStatuses(orderData.value);

      if ((orderData.value?.status ?? '').toLowerCase() == 'dibatalkan') {
        await _handleCancelledOrderNavigation(showSnackbar: false);
        return;
      }

      await _startRealtime(orderId);
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
    _syncItemStatuses(mergedOrder);

    final latestStatus = mergedOrder.status ?? '';
    final latestPaymentStatus = mergedOrder.paymentStatus ?? '';

    if (latestStatus.toLowerCase() == 'dibatalkan') {
      _handleCancelledOrderNavigation();
      return;
    }

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

  void setUserMode(bool value) {
    if (isUserMode.value != value) {
      isUserMode.value = value;
    }
  }

  void _syncItemStatuses(DataOrder? order) {
    if (order == null) {
      return;
    }

    itemStatus.clear();
    for (final detail in order.orderDetails ?? <OrderDetail>[]) {
      if (detail.id != null) {
        itemStatus[detail.id!] = detail.status ?? 'pending';
      }
    }
  }

  Future<void> _handleCancelledOrderNavigation({
    bool showSnackbar = true,
  }) async {
    if (_hasRedirectedAfterCancellation) {
      return;
    }

    _hasRedirectedAfterCancellation = true;
    _lastShownStatus = 'dibatalkan';
    await _orderRealtimeService?.disconnect();

    if (showSnackbar) {
      Get.snackbar(
        'Pesanan Dibatalkan',
        'Pesanan ini telah dibatalkan.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }

    final targetRoute = _resolveHomeRoute();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute != targetRoute) {
        Get.offAllNamed(targetRoute);
      }
    });
  }

  String _resolveHomeRoute() {
    switch ((_authService.getRole() ?? '').toLowerCase()) {
      case 'driver':
        return AppRoutes.DRIVER_HOME;
      case 'user':
      default:
        return AppRoutes.USER_HOME;
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

  Future<bool> completeDelivery() async {
    if (isUserMode.value) return false; // User mode: no action
    if (orderData.value == null || isCompletingDelivery.value) return false;

    isCompletingDelivery.value = true;
    try {
      final orderId = orderData.value!.id!;
      await orderService.completeDelivery(orderId);
      _lastShownStatus = 'selesai';
      orderData.update((order) {
        if (order != null) {
          order.status = 'selesai';
        }
      });
      await _orderRealtimeService?.disconnect();

      if (Get.isRegistered<OrderDriverController>()) {
        final orderDriverController = Get.find<OrderDriverController>();
        await orderDriverController.refreshData();
        await orderDriverController.fetchHistory();
      }

      if (Get.isRegistered<DriverWalletController>()) {
        await Get.find<DriverWalletController>().refreshAll();
      }

      Get.snackbar('Sukses', 'Pesanan selesai!');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal selesai delivery: $e');
      return false;
    } finally {
      isCompletingDelivery.value = false;
    }
  }

  @override
  void onClose() {
    _orderRealtimeService?.disconnect();
    super.onClose();
  }
}
