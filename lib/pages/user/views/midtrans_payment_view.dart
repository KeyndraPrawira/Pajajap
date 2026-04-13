import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/pages/user/controllers/payment_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MidtransPaymentView extends StatefulWidget {
  const MidtransPaymentView({super.key});

  @override
  State<MidtransPaymentView> createState() => _MidtransPaymentViewState();
}

class _MidtransPaymentViewState extends State<MidtransPaymentView> {
  final PaymentController _paymentController = Get.find<PaymentController>();

  late final int _orderId;
  late final String _kodePesanan;
  late final int _totalBayar;

  Worker? _paymentWorker;
  bool _isInitialLoading = true;
  bool _hasCompletedFlow = false;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _orderId = args['order_id'] as int? ?? 0;
    _kodePesanan = args['kode_pesanan']?.toString() ?? '';
    _totalBayar = args['total_bayar'] as int? ?? 0;

    _paymentWorker = everAll(
      [
        _paymentController.paymentStatus,
        _paymentController.orderStatus,
      ],
      (_) => _handlePaymentChanges(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePayment();
    });
  }

  Future<void> _initializePayment() async {
    if (_orderId <= 0) {
      Get.back();
      Get.snackbar('Gagal', 'Data pembayaran tidak valid.');
      return;
    }

    _paymentController.prepareForOrder(_orderId);
    await _paymentController.listenPaymentRealtime(_orderId);
    await _paymentController.checkPaymentStatus(_orderId);

    if (!_paymentController.isPaid &&
        (_paymentController.paymentData.value == null ||
            _paymentController.paymentUrl.value.isEmpty)) {
      await _paymentController.createPayment(_orderId);
    }

    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  void _handlePaymentChanges() {
    if (!mounted || _hasCompletedFlow) {
      return;
    }

    if (_paymentController.isPaid) {
      _hasCompletedFlow = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) {
          return;
        }

        if (Get.previousRoute.isNotEmpty) {
          Get.back(result: true);
        } else {
          Get.offNamed(AppRoutes.USER_DELIVERY, arguments: _orderId);
        }
      });
      return;
    }

    if (_paymentController.orderStatus.value == 'dibatalkan') {
      _hasCompletedFlow = true;
      Get.offAllNamed(AppRoutes.USER_HOME);
    }
  }

  Future<void> _copyPaymentLink() async {
    final url = _paymentController.paymentUrl.value.trim();
    if (url.isEmpty) {
      Get.snackbar('Belum Ada Link', 'Link pembayaran belum tersedia.');
      return;
    }

    await Clipboard.setData(ClipboardData(text: url));
    Get.snackbar('Link Disalin', 'Link pembayaran berhasil disalin.');
  }

  Future<void> _refreshPayment() async {
    await _paymentController.checkPaymentStatus(_orderId, showSnackbar: true);
  }

  Future<void> _regeneratePayment() async {
    await _paymentController.createPayment(_orderId);
  }

  String _formatRupiah(int value) {
    final text = value.toString();
    final buffer = StringBuffer('Rp');
    final offset = text.length % 3;

    for (var i = 0; i < text.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(text[i]);
    }

    return buffer.toString();
  }

  String _paymentLabel(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Sudah Dibayar';
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'failed':
        return 'Pembayaran Gagal';
      case 'expired':
        return 'Pembayaran Kedaluwarsa';
      default:
        return status.isEmpty ? 'Menyiapkan Pembayaran' : status;
    }
  }

  Color _paymentColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFF2E7D32);
      case 'pending':
        return const Color(0xFFE65100);
      case 'failed':
      case 'expired':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF1565C0);
    }
  }

  @override
  void dispose() {
    _paymentWorker?.dispose();
    _paymentController.stopPaymentRealtime();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FC),
      appBar: AppBar(
        title: const Text('Pembayaran Midtrans'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final payment = _paymentController.paymentData.value;
        final paymentStatus = _paymentController.paymentStatus.value;
        final paymentColor = _paymentColor(paymentStatus);
        final paymentUrl = _paymentController.paymentUrl.value;
        final totalBayar = payment?.grossAmount ?? _totalBayar;

        if (_isInitialLoading &&
            _paymentController.isCreatingPayment.value &&
            payment == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _kodePesanan.isEmpty ? 'Order #$_orderId' : _kodePesanan,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatRupiah(totalBayar),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _paymentLabel(paymentStatus),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 12, color: paymentColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _paymentLabel(paymentStatus),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: paymentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_paymentController.message.value.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        _paymentController.message.value,
                        style: const TextStyle(color: Color(0xFF546E7A)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Link Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F8FC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD7E3F1)),
                      ),
                      child: SelectableText(
                        paymentUrl.isEmpty
                            ? 'Link pembayaran akan muncul di sini.'
                            : paymentUrl,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF37474F),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: paymentUrl.isEmpty ? null : _copyPaymentLink,
                            icon: const Icon(Icons.copy_all_outlined),
                            label: const Text('Salin Link'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _paymentController.isCheckingStatus.value
                                ? null
                                : _refreshPayment,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Cek Status'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Catatan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Pembayaran Midtrans diselesaikan saat pesanan sudah masuk status dikirim. Setelah bayar berhasil, halaman ini akan kembali ke detail order.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF546E7A),
                        height: 1.5,
                      ),
                    ),
                    if (!_paymentController.isPaid) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _paymentController.isCreatingPayment.value
                              ? null
                              : _regeneratePayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            paymentUrl.isEmpty
                                ? 'Buat Link Pembayaran'
                                : 'Buat Ulang Link Pembayaran',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
