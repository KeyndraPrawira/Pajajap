import 'package:e_pasar/app/services/order_realtime_services.dart';
import 'package:e_pasar/pages/user/controllers/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'user_delivery_view.dart';

class MencariDriverView extends StatefulWidget {
  const MencariDriverView({super.key});

  @override
  State<MencariDriverView> createState() => _MencariDriverViewState();
}

class _MencariDriverViewState extends State<MencariDriverView>
    with TickerProviderStateMixin {
  // ─── Data dari arguments ──────────────────────────────────
  late int orderId;
  late String kodePesanan;

  // ─── Animation controllers ────────────────────────────────
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _dotController;

  late Animation<double> _pulse1;
  late Animation<double> _pulse2;
  late Animation<double> _pulse3;
  late Animation<double> _rotate;

  // ─── Realtime state ────────────────────────────────────────
  final OrderController orderController = Get.find<OrderController>();
  OrderRealTimeService? _realtimeService;
  int _dotCount = 1;
  bool _isCancelling = false;
  bool _hasHandledEvent = false;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>?;
    orderId = args?['order_id'] ?? 0;
    kodePesanan = args?['kode_pesanan'] ?? '';

    _setupAnimations();
    _startRealtimeListener();
  }

  void _startRealtimeListener() {
    _realtimeService = OrderRealTimeService(
      onOrderUpdate: _handleOrderUpdate,
      path: 'orders/$orderId',
    );
    _realtimeService!.connect();
  }

  void _handleOrderUpdate(Map<String, dynamic> orderData) {
    if (_hasHandledEvent) {
      return;
    }

    final status = orderData['status']?.toString() ?? '';
    final driverId = orderData['driver_id'];

    if (driverId != null && status == 'dalam_proses') {
      _hasHandledEvent = true;
      _realtimeService?.disconnect();
      Get.offAll(() => const UserDeliveryView(), arguments: orderId);
      return;
    }

    if (status == 'dibatalkan') {
      _hasHandledEvent = true;
      _realtimeService?.disconnect();
      Get.back();
      Get.snackbar(
        'Pesanan Dibatalkan',
        'Pesanan kamu telah dibatalkan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _setupAnimations() {
    // Pulse utama — 3 gelombang lingkaran
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _pulse1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _pulse2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
      ),
    );
    _pulse3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Rotasi icon GPS
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _rotate = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    // Animasi titik-titik "Mencari driver..."
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _dotCount = _dotCount >= 3 ? 1 : _dotCount + 1);
          _dotController.reset();
          _dotController.forward();
        }
      });
    _dotController.forward();
  }

  Future<void> _batalkanOrder() async {
    final confirm = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Batalkan order?'),
            content: const Text(
              'Pesanan akan dibatalkan dan kamu akan kembali ke halaman pesanan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Tidak'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Batalkan'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm != true) return;

    setState(() => _isCancelling = true);
    try {
      await orderController.cancelOrder(
        orderId,
        reason: 'Dibatalkan oleh buyer',
      );
      _realtimeService?.disconnect();
    } catch (e) {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
      Get.snackbar('Gagal', e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    }
  }

  @override
  void dispose() {
    _realtimeService?.disconnect();
    _pulseController.dispose();
    _rotateController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF06D6A0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    const SizedBox(width: 48),
                    Expanded(
                      child: Text(
                        kodePesanan.isNotEmpty ? kodePesanan : 'Mencari Driver',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),

              // ── Animasi GPS ─────────────────────────────
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pulse circles + icon
                      SizedBox(
                        width: 260,
                        height: 260,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Gelombang 3
                            AnimatedBuilder(
                              animation: _pulse3,
                              builder: (_, __) => _buildPulseCircle(
                                scale: _pulse3.value,
                                opacity: (1 - _pulse3.value) * 0.15,
                                size: 260,
                              ),
                            ),
                            // Gelombang 2
                            AnimatedBuilder(
                              animation: _pulse2,
                              builder: (_, __) => _buildPulseCircle(
                                scale: _pulse2.value,
                                opacity: (1 - _pulse2.value) * 0.25,
                                size: 200,
                              ),
                            ),
                            // Gelombang 1
                            AnimatedBuilder(
                              animation: _pulse1,
                              builder: (_, __) => _buildPulseCircle(
                                scale: _pulse1.value,
                                opacity: (1 - _pulse1.value) * 0.35,
                                size: 140,
                              ),
                            ),

                            // Lingkaran dalam
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1.5),
                              ),
                            ),

                            // Icon GPS berputar
                            AnimatedBuilder(
                              animation: _rotate,
                              builder: (_, child) => Transform.rotate(
                                angle: _rotate.value * 2 * 3.14159,
                                child: child,
                              ),
                              child: const Icon(
                                Icons.gps_fixed_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Teks
                      Text(
                        'Mencari Driver${'.' * _dotCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Mohon tunggu, kami sedang\nmencari driver terdekat untukmu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF06D6A0),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Order sedang diproses',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Tombol Batalkan ─────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _isCancelling ? null : _batalkanOrder,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                            color: Colors.white.withOpacity(0.4), width: 1.5),
                      ),
                    ),
                    child: _isCancelling
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Batalkan Order',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPulseCircle({
    required double scale,
    required double opacity,
    required double size,
  }) {
    return Transform.scale(
      scale: 0.3 + (scale * 0.7),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
          border: Border.all(
            color: Colors.white.withOpacity(opacity * 2),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
