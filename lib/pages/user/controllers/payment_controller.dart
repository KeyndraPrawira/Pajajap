import 'package:e_pasar/app/data/models/midtrans_model.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:e_pasar/app/services/midtrans_services.dart';
import 'package:e_pasar/app/services/payment_realtime_services.dart';
import 'package:e_pasar/app/utils/api.dart';
import 'package:e_pasar/pages/driver/controllers/driver_wallet_controller.dart';
import 'package:e_pasar/pages/user/controllers/order_controller.dart';
import 'package:get/get.dart';

class PaymentController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  late final MidtransService _midtransService;

  final RxBool isCreatingPayment = false.obs;
  final RxBool isCheckingStatus = false.obs;
  final RxBool isListeningRealtime = false.obs;
  final Rxn<MidtransPaymentData> paymentData = Rxn<MidtransPaymentData>();
  final RxString paymentStatus = ''.obs;
  final RxString paymentUrl = ''.obs;
  final RxString orderStatus = ''.obs;
  final RxString message = ''.obs;
  final RxString errorMessage = ''.obs;

  int? _activeOrderId;
  PaymentRealtimeService? _paymentRealtimeService;
  String? _lastNotifiedPaymentStatus;
  String? _lastNotifiedOrderStatus;

  bool get isPaid => paymentStatus.value == 'paid';
  bool get isPending => paymentStatus.value == 'pending';

  @override
  void onInit() {
    super.onInit();
    _midtransService = MidtransService(
      baseUrl: Api.baseUrl,
      token: _authService.getToken() ?? '',
    );
  }

  Future<MidtransPaymentResponse?> createPayment(int orderId) async {
    isCreatingPayment.value = true;
    errorMessage.value = '';

    try {
      await listenPaymentRealtime(orderId);
      final response = await _midtransService.createPayment(orderId);
      _activeOrderId = orderId;
      _applyPaymentResponse(response);

      if (response.message.isNotEmpty) {
        Get.snackbar('Pembayaran', response.message);
      }

      return response;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar('Gagal', errorMessage.value);
      return null;
    } finally {
      isCreatingPayment.value = false;
    }
  }

  Future<MidtransPaymentResponse?> checkPaymentStatus(
    int orderId, {
    bool showSnackbar = false,
  }) async {
    isCheckingStatus.value = true;
    errorMessage.value = '';

    try {
      final response = await _midtransService.getPaymentStatus(orderId);
      _activeOrderId = orderId;
      _applyPaymentResponse(response);

      if (showSnackbar && response.message.isNotEmpty) {
        Get.snackbar('Status Pembayaran', response.message);
      }

      return response;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      if (showSnackbar) {
        Get.snackbar('Gagal', errorMessage.value);
      }
      return null;
    } finally {
      isCheckingStatus.value = false;
    }
  }

  Future<void> listenPaymentRealtime(int orderId) async {
    await stopPaymentRealtime();
    _activeOrderId = orderId;
    isListeningRealtime.value = true;
    _paymentRealtimeService = PaymentRealtimeService(
      orderId: orderId,
      onOrderUpdate: _handleRealtimeOrderUpdate,
    );
    await _paymentRealtimeService!.connect();
  }

  Future<void> stopPaymentRealtime() async {
    await _paymentRealtimeService?.disconnect();
    _paymentRealtimeService = null;
    isListeningRealtime.value = false;
  }

  Future<void> refreshCurrentPayment() async {
    final orderId = _activeOrderId;
    if (orderId == null) {
      return;
    }

    await checkPaymentStatus(orderId);
  }

  void prepareForOrder(int orderId) {
    if (_activeOrderId != orderId) {
      paymentData.value = null;
      paymentStatus.value = '';
      paymentUrl.value = '';
      orderStatus.value = '';
      message.value = '';
      errorMessage.value = '';
      _lastNotifiedPaymentStatus = null;
      _lastNotifiedOrderStatus = null;
    }
    _activeOrderId = orderId;
  }

  void _handleRealtimeOrderUpdate(Map<String, dynamic> orderData) {
    final realtimeOrderId = _tryParseInt(orderData['id']);
    if (_activeOrderId != null &&
        realtimeOrderId != null &&
        realtimeOrderId != _activeOrderId) {
      return;
    }

    final latestPaymentStatus = orderData['payment_status']?.toString();
    final latestPaymentUrl = orderData['payment_url']?.toString();
    final latestOrderStatus = orderData['status']?.toString();
    final latestPaidAt = orderData['paid_at']?.toString();

    if (latestPaymentStatus != null && latestPaymentStatus.isNotEmpty) {
      paymentStatus.value = latestPaymentStatus;
    }

    if (latestPaymentUrl != null && latestPaymentUrl.isNotEmpty) {
      paymentUrl.value = latestPaymentUrl;
    }

    if (latestOrderStatus != null && latestOrderStatus.isNotEmpty) {
      orderStatus.value = latestOrderStatus;
      message.value = 'Order update: $latestOrderStatus';
    }

    final currentPayment = paymentData.value;
    if (currentPayment != null) {
      paymentData.value = MidtransPaymentData(
        orderId: currentPayment.orderId,
        kodePesanan: currentPayment.kodePesanan,
        midtransOrderId: currentPayment.midtransOrderId,
        paymentMethod: currentPayment.paymentMethod,
        paymentStatus: latestPaymentStatus ?? currentPayment.paymentStatus,
        paymentType:
            orderData['payment_type']?.toString() ?? currentPayment.paymentType,
        paymentToken: currentPayment.paymentToken,
        paymentUrl: latestPaymentUrl ?? currentPayment.paymentUrl,
        grossAmount: currentPayment.grossAmount,
        paidAt: latestPaidAt ?? currentPayment.paidAt,
        clientKey: currentPayment.clientKey,
      );
    }

    if (isPaid) {
      _refreshRelatedControllers();
    }

    _notifyRealtimeChanges();
  }

  void _applyPaymentResponse(MidtransPaymentResponse response) {
    paymentData.value = response.data;
    paymentStatus.value = response.data.paymentStatus ?? '';
    paymentUrl.value = response.data.paymentUrl ?? '';
    message.value = response.message;

    if (isPaid) {
      _refreshRelatedControllers();
    }

    _notifyRealtimeChanges();
  }

  void _refreshRelatedControllers() {
    if (Get.isRegistered<OrderController>()) {
      Get.find<OrderController>().fetchActiveOrders();
    }

    if (Get.isRegistered<DriverWalletController>()) {
      Get.find<DriverWalletController>().refreshAll();
    }
  }

  int? _tryParseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }

  void _notifyRealtimeChanges() {
    final normalizedPaymentStatus = paymentStatus.value.trim().toLowerCase();
    final normalizedOrderStatus = orderStatus.value.trim().toLowerCase();

    if (normalizedPaymentStatus.isNotEmpty &&
        normalizedPaymentStatus != _lastNotifiedPaymentStatus) {
      switch (normalizedPaymentStatus) {
        case 'paid':
          Get.snackbar('Pembayaran Berhasil', 'Pembayaran Midtrans sudah masuk.');
          break;
        case 'pending':
          Get.snackbar(
            'Menunggu Pembayaran',
            'Link pembayaran Midtrans sudah siap digunakan.',
          );
          break;
        case 'failed':
        case 'cancelled':
        case 'expired':
          Get.snackbar(
            'Pembayaran Belum Selesai',
            'Silakan coba cek ulang atau buat pembayaran baru.',
          );
          break;
      }
      _lastNotifiedPaymentStatus = normalizedPaymentStatus;
    }

    if (normalizedOrderStatus.isNotEmpty &&
        normalizedOrderStatus != _lastNotifiedOrderStatus) {
      switch (normalizedOrderStatus) {
        case 'dalam_proses':
          Get.snackbar(
            'Driver Ditemukan',
            'Driver sudah menerima pesanan kamu.',
          );
          break;
        case 'dikirim':
          Get.snackbar(
            'Pesanan Dikirim',
            'Barang sedang diantar. Selesaikan pembayaran Midtrans bila diminta.',
          );
          break;
        case 'dibatalkan':
          Get.snackbar(
            'Order Dibatalkan',
            'Pesanan ini telah dibatalkan.',
          );
          break;
      }
      _lastNotifiedOrderStatus = normalizedOrderStatus;
    }
  }

  @override
  void onClose() {
    stopPaymentRealtime();
    super.onClose();
  }
}
