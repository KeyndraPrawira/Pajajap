// lib/pages/user/views/mencari_driver_view.dart

import 'dart:async';
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/order_services.dart';
import 'package:flutter/material.dart';
import 'user_delivery_view.dart';
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

  // ─── Polling state ────────────────────────────────────────
  Timer? _pollingTimer;
  final OrderService _orderService = OrderService();
  int _dotCount = 1;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>?;
    orderId = args?['order_id'] ?? 0;
    kodePesanan = args?['kode_pesanan'] ?? '';

    _setupAnimations();
    _startPolling();
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

  // ─── Polling — cek status order tiap 1 detik ─────────────
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      try {
        final result = await _orderService.detailOrder(orderId);
        final status = result['status']?.toString() ?? '';
        final driverId = result['driver_id'];

if (driverId != null && status == 'dalam_proses') {
          _pollingTimer?.cancel();
          // Driver accept - navigasi ke User DeliveryView
          Get.offAll(() => const UserDeliveryView(), arguments: orderId);
        } else if (status == 'dibatalkan') {
          _pollingTimer?.cancel();
          Get.back();
          Get.snackbar(
            'Order Dibatalkan',
            'Order kamu telah dibatalkan',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      } catch (e) {
        // Gagal poll — lanjut coba lagi
        debugPrint('Polling error: $e');
      }
    });
  }

  // ─── Cancel order ─────────────────────────────────────────
  Future<void> _batalkanOrder() async {
    final confirm = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.cancel_outlined,
                    color: Colors.red, size: 28),
              ),
              const SizedBox(height: 16),
              const Text(
                'Batalkan Order?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF023E58),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Driver belum ditemukan. Kamu yakin ingin membatalkan order ini?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF6C757D)),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFDEE2E6)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Tunggu Dulu',
                          style: TextStyle(
                              color: Color(0xFF6C757D),
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Batalkan',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm != true) return;

    setState(() => _isCancelling = true);
    try {
      await _orderService.requestCancel(
        orderId: orderId,
        reason: 'Driver tidak ditemukan, dibatalkan oleh buyer',
      );
      _pollingTimer?.cancel();
      Get.offAllNamed(AppRoutes.USER_HOME);
      Get.snackbar('Berhasil', 'Order berhasil dibatalkan',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      setState(() => _isCancelling = false);
      Get.snackbar('Gagal', 'Gagal membatalkan order',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
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