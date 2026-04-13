import 'package:e_pasar/app/data/models/order_model.dart';
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/order_services.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:get/get.dart';

import 'user_controller.dart';

class OrderController extends GetxController {
  final OrderService orderService = Get.find<OrderService>();
  final AuthService _authService = Get.find<AuthService>();

  final RxList<DataOrder> activeOrders = <DataOrder>[].obs;
  final RxList<DataOrder> historyOrders = <DataOrder>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isHistoryLoading = false.obs;
  final RxString historyErrorMessage = ''.obs;
  final Map<int, String> _lastStatusByOrder = {};
  final Map<int, String> _lastPaymentStatusByOrder = {};

  static const Set<String> _activeStatuses = {
    'menunggu_driver',
    'dalam_proses',
    'dikirim',
  };
  static const Set<String> _historyStatuses = {
    'selesai',
  };
  @override
  void onInit() {
    super.onInit();
    _setupRealTime();
    fetchActiveOrders();
    fetchHistoryOrders();
  }

  void _setupRealTime() {
    orderService.initRealTime(_handleRealTimeUpdate);
    orderService.connectRealTime();
  }

  Future<void> fetchActiveOrders() async {
    isLoading.value = true;

    try {
      final orders = await orderService.getActiveOrders();
      activeOrders.assignAll(
        orders
            .map((order) => DataOrder.fromJson(order as Map<String, dynamic>))
            .toList(),
      );
      _syncNotificationCache();
      _sortActiveOrders();
      print('[ACTIVE ORDERS][USER] fetched ${activeOrders.length} orders');
      print('📥 [ACTIVE ORDERS] Fetched ${orders.length} active orders');
      return;
    } catch (e) {
      print('Error fetching active orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchHistoryOrders() async {
    isHistoryLoading.value = true;
    historyErrorMessage.value = '';

    try {
      final orders = await orderService.getOrderHistory();
      final parsedOrders = orders
          .map((order) => DataOrder.fromJson(order as Map<String, dynamic>))
          .where((order) => _historyStatuses.contains(order.status))
          .toList();

      parsedOrders.sort((a, b) {
        final aTime = a.updatedAt ??
            a.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.updatedAt ??
            b.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      historyOrders.assignAll(parsedOrders);
    } catch (e) {
      historyErrorMessage.value = e.toString().replaceAll('Exception: ', '');
      historyOrders.clear();
    } finally {
      isHistoryLoading.value = false;
    }
  }

  Future<void> fetchOrderDetailAndUpsert(int orderId) async {
    try {
      final previous = findTrackedOrderById(orderId);
      final result = await orderService.detailOrder(orderId);
      final order = DataOrder.fromJson(result);

      if (_activeStatuses.contains(order.status)) {
        _upsertActiveOrder(order);
        historyOrders.removeWhere((item) => item.id == orderId);
        _notifyOrderTransition(previous: previous, current: order);
      } else if (_historyStatuses.contains(order.status)) {
        activeOrders.removeWhere((item) => item.id == orderId);
        _upsertHistoryOrder(order);
        _notifyOrderTransition(previous: previous, current: order);
      } else {
        activeOrders.removeWhere((item) => item.id == orderId);
        historyOrders.removeWhere((item) => item.id == orderId);
      }
    } catch (e) {
      print('Error fetching detail order $orderId: $e');
    }
  }

  DataOrder? findActiveOrderById(int orderId) {
    try {
      return activeOrders.firstWhere((order) => order.id == orderId);
    } catch (_) {
      return null;
    }
  }

  DataOrder? findHistoryOrderById(int orderId) {
    try {
      return historyOrders.firstWhere((order) => order.id == orderId);
    } catch (_) {
      return null;
    }
  }

  DataOrder? findTrackedOrderById(int orderId) {
    return findActiveOrderById(orderId) ?? findHistoryOrderById(orderId);
  }

  Future<void> cancelOrder(
    int orderId, {
    String reason = 'Dibatalkan oleh buyer',
  }) async {
    await orderService.requestCancel(orderId: orderId, reason: reason);
    activeOrders.removeWhere((order) => order.id == orderId);
    historyOrders.removeWhere((order) => order.id == orderId);
    activeOrders.refresh();
    historyOrders.refresh();

    await Get.offAllNamed(AppRoutes.USER_HOME);

    if (Get.isRegistered<UserController>()) {
      Get.find<UserController>().changePage(1);
    }

    Get.snackbar(
      'Berhasil',
      'Order berhasil dibatalkan',
    );
  }

  void _handleRealTimeUpdate(Map<String, dynamic> updatedOrder) {
    final rawId = updatedOrder['id'];
    final orderId =
        rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');

    if (orderId == null) {
      return;
    }

    if (!_belongsToCurrentUser(updatedOrder, orderId)) {
      return;
    }

    if (updatedOrder['_deleted'] == true) {
      activeOrders.removeWhere((order) => order.id == orderId);
      historyOrders.removeWhere((order) => order.id == orderId);
      return;
    }

    final status = updatedOrder['status']?.toString();
    if (status == null) {
      fetchOrderDetailAndUpsert(orderId);
      return;
    }

    if (!_activeStatuses.contains(status)) {
      activeOrders.removeWhere((order) => order.id == orderId);
      if (_historyStatuses.contains(status)) {
        final existingTrackedOrder = findTrackedOrderById(orderId);

        if (existingTrackedOrder == null) {
          fetchOrderDetailAndUpsert(orderId);
          return;
        }

        final mergedJson = existingTrackedOrder.toJson()..addAll(updatedOrder);
        final mergedOrder = DataOrder.fromJson(mergedJson);
        _upsertHistoryOrder(mergedOrder);
        _notifyOrderTransition(
            previous: existingTrackedOrder, current: mergedOrder);
      } else {
        historyOrders.removeWhere((order) => order.id == orderId);
      }
      return;
    }

    final existingOrder = findActiveOrderById(orderId);
    if (existingOrder == null) {
      fetchOrderDetailAndUpsert(orderId);
      return;
    }

    final mergedJson = existingOrder.toJson()..addAll(updatedOrder);
    final mergedOrder = DataOrder.fromJson(mergedJson);
    _upsertActiveOrder(mergedOrder);
    _notifyOrderTransition(previous: existingOrder, current: mergedOrder);
  }

  bool _belongsToCurrentUser(Map<String, dynamic> updatedOrder, int orderId) {
    final currentUserId = _authService.getUserId();
    final buyerId = updatedOrder['buyer_id'];
    final existingOrder = findTrackedOrderById(orderId);

    if (existingOrder != null) {
      return true;
    }

    if (currentUserId == null) {
      return false;
    }

    if (buyerId is int) {
      return buyerId == currentUserId;
    }

    return int.tryParse(buyerId?.toString() ?? '') == currentUserId;
  }

  void _upsertActiveOrder(DataOrder order) {
    final index = activeOrders.indexWhere((item) => item.id == order.id);

    if (index >= 0) {
      activeOrders[index] = order;
    } else {
      activeOrders.insert(0, order);
    }

    _sortActiveOrders();
    if (order.id != null) {
      _lastStatusByOrder[order.id!] = order.status ?? '';
      _lastPaymentStatusByOrder[order.id!] = order.paymentStatus ?? '';
    }
    activeOrders.refresh();
  }

  void _notifyOrderTransition({
    required DataOrder? previous,
    required DataOrder current,
  }) {
    final orderId = current.id;
    if (orderId == null) {
      return;
    }

    final previousStatus =
        (previous?.status ?? _lastStatusByOrder[orderId] ?? '').trim();
    final currentStatus = (current.status ?? '').trim();
    final previousPaymentStatus =
        (previous?.paymentStatus ?? _lastPaymentStatusByOrder[orderId] ?? '')
            .trim();
    final currentPaymentStatus = (current.paymentStatus ?? '').trim();

    if (currentPaymentStatus.isNotEmpty &&
        currentPaymentStatus != previousPaymentStatus) {
      if (currentPaymentStatus == 'paid') {
        Get.snackbar(
          'Pembayaran Berhasil',
          'Pesanan ${current.kodePesanan ?? ''} siap diproses.',
        );
      }
    }

    if (currentStatus.isNotEmpty && currentStatus != previousStatus) {
      switch (currentStatus) {
        case 'menunggu_driver':
          Get.snackbar(
            'Mencari Driver',
            'Pesanan ${current.kodePesanan ?? ''} sedang dicarikan driver.',
          );
          break;
        case 'dalam_proses':
          Get.snackbar(
            'Driver Menerima Order',
            'Driver sedang berbelanja untuk pesanan kamu.',
          );
          break;
        case 'dikirim':
          if ((current.metodePembayaran ?? '').toLowerCase() == 'midtrans' &&
              (current.paymentStatus ?? '').toLowerCase() != 'paid') {
            Get.snackbar(
              'Waktunya Bayar',
              'Pesanan sedang dikirim. Lanjutkan pembayaran Midtrans sekarang.',
            );
          } else {
            Get.snackbar(
              'Pesanan Dikirim',
              'Driver sedang menuju alamat pengiriman.',
            );
          }
          break;
        case 'selesai':
          Get.snackbar(
            'Pesanan Selesai',
            'Pesanan ${current.kodePesanan ?? ''} sudah masuk ke riwayat.',
          );
          break;
        case 'dibatalkan':
          Get.snackbar(
            'Pesanan Dibatalkan',
            'Silakan cek detail order untuk info lanjut.',
          );
          break;
      }
    }

    _lastStatusByOrder[orderId] = currentStatus;
    _lastPaymentStatusByOrder[orderId] = currentPaymentStatus;
  }

  void _upsertHistoryOrder(DataOrder order) {
    final index = historyOrders.indexWhere((item) => item.id == order.id);

    if (index >= 0) {
      historyOrders[index] = order;
    } else {
      historyOrders.insert(0, order);
    }

    _sortHistoryOrders();
    historyOrders.refresh();
  }

  void _syncNotificationCache() {
    _lastStatusByOrder
      ..clear()
      ..addEntries(
        activeOrders
            .where((order) => order.id != null)
            .map((order) => MapEntry(order.id!, order.status ?? '')),
      );
    _lastPaymentStatusByOrder
      ..clear()
      ..addEntries(
        activeOrders
            .where((order) => order.id != null)
            .map((order) => MapEntry(order.id!, order.paymentStatus ?? '')),
      );
  }

  void _sortActiveOrders() {
    activeOrders.sort((a, b) {
      final aTime =
          a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime =
          b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
  }

  void _sortHistoryOrders() {
    historyOrders.sort((a, b) {
      final aTime =
          a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime =
          b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
  }

  void continueToDelivery(int orderId, String status) {
    if (status == 'dalam_proses' || status == 'dikirim') {
      Get.toNamed(
        AppRoutes.USER_DELIVERY,
        arguments: {'order_id': orderId}, // ← pakai orderId dari parameter
      );
      return;
    } else if (status == 'menunggu_driver') {
      Get.toNamed(
        AppRoutes.MENCARI_DRIVER,
        arguments: {'order_id': orderId}, // ← pakai orderId dari parameter
      );
      return;
    } else {
      Get.snackbar('Error', 'Status order tidak valid');
    }
    print('🔍 Continue to delivery for orderId: $orderId with status: $status');
  }

  @override
  void onClose() {
    orderService.disconnectRealTime();
    super.onClose();
  }
}
