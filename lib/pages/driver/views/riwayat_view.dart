import 'package:e_pasar/app/data/models/order_model.dart';
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/pages/driver/controllers/order_driver_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RiwayatView extends GetView<OrderDriverController> {
  const RiwayatView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return _buildLoading();
              if (controller.errorMessage.isNotEmpty) return _buildError();
              if (controller.orderList.isEmpty) return _buildEmpty();
              return _buildList();
            }),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF06D6A0)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
              ),
              const Expanded(
                child: Text(
                  'Riwayat Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Obx(() => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4), width: 1),
                    ),
                    child: Text(
                      '${controller.orderList.length} order',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // ── List ──────────────────────────────────────────────────
  Widget _buildList() {
    return RefreshIndicator(
      color: const Color(0xFF0077B6),
      onRefresh: controller.fetchHistory,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        physics: const BouncingScrollPhysics(),
        itemCount: controller.orderList.length,
        itemBuilder: (_, i) => _buildCard(controller.orderList[i]),
      ),
    );
  }

  Widget _buildCard(DataOrder order) {
    final status = order.status ?? '';
    final statusColor = controller.statusColor(status);
    final createdAt = order.createdAt;
    final tanggal = _formatDate(createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0077B6).withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Top bar status ──────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  controller.statusLabel(status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                Text(
                  tanggal,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6C757D),
                  ),
                ),
              ],
            ),
          ),

          // ── Content ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kode order
                Row(
                  children: [
                    const Icon(Icons.receipt_outlined,
                        size: 14, color: Color(0xFF0077B6)),
                    const SizedBox(width: 6),
                    Text(
                      order.kodePesanan ?? '-',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF023E58),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Nama customer
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 14, color: Color(0xFF6C757D)),
                    const SizedBox(width: 6),
                    Text(
                      order.buyer?.name ?? '-',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6C757D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Total harga + tombol detail
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6C757D),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controller.formatRupiah(order.totalHarga),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0077B6),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),

                    // Tombol lihat detail
                    GestureDetector(
                      onTap: () => Get.toNamed(
                        AppRoutes.orderHistoryDetail(order.id!),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0077B6), Color(0xFF06D6A0)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Lihat Detail',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 10, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── States ────────────────────────────────────────────────
  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0F7FA), Color(0xFFE8F5E9)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_outlined,
                size: 48, color: Color(0xFF90E0EF)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum Ada Riwayat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF023E58),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Riwayat order akan muncul\nsetelah order selesai',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6C757D),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 56, color: Color(0xFFADB5BD)),
          const SizedBox(height: 16),
          const Text(
            'Gagal memuat riwayat',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF023E58),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: controller.fetchHistory,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0077B6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '-';

    try {
      return DateFormat('dd MMM yyyy, HH:mm', 'id').format(value);
    } catch (_) {
      return DateFormat('dd MMM yyyy, HH:mm').format(value);
    }
  }
}
