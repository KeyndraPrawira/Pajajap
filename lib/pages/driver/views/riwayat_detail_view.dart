import 'package:e_pasar/app/data/models/order_model.dart';
import 'package:e_pasar/pages/driver/controllers/order_driver_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderHistoryDetailView extends GetView<OrderDriverController> {
  const OrderHistoryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil id dari route parameter
    final idParam = Get.parameters['id'];
    final id = int.tryParse(idParam ?? '');
    if (id != null && controller.selectedOrder.value?.id != id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchDetail(id);
      });
    }

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
              if (controller.isLoadingDetail.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0077B6)),
                );
              }
              final order = controller.selectedOrder.value;
              if (order == null) {
                return const Center(child: Text('Data tidak ditemukan'));
              }
              return _buildDetail(order);
            }),
          ),
        ],
      ),
    );
  }

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
              Expanded(
                child: Obx(() => Text(
                      controller.selectedOrder.value?.kodePesanan ??
                          'Detail Order',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(DataOrder order) {
    final createdAt = order.createdAt;
    final tanggal = _formatDate(createdAt);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Info Order ──────────────────────────────────
          _buildCard(
            icon: Icons.info_outline,
            title: 'Info Order',
            child: Column(
              children: [
                _buildInfoRow('Kode Order', order.kodePesanan ?? '-'),
                _buildInfoRow('Customer', order.buyer?.name ?? '-'),
                _buildInfoRow('Tanggal', tanggal),
                _buildInfoRow('Alamat', order.alamatPengiriman ?? '-'),
                _buildInfoRow('Jarak', '${order.jarakKm ?? 0} km'),
                const SizedBox(height: 8),
                // Status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Status',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xFF6C757D))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: controller
                            .statusColor(order.status)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: controller.statusColor(order.status),
                            width: 1),
                      ),
                      child: Text(
                        controller.statusLabel(order.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: controller.statusColor(order.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Daftar Barang ───────────────────────────────
          _buildCard(
            icon: Icons.shopping_bag_outlined,
            title: 'Daftar Barang',
            child: Column(
              children: (order.orderDetails ?? [])
                  .map((detail) => _buildItemRow(detail))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),

          // ── Ringkasan Biaya ─────────────────────────────
          _buildCard(
            icon: Icons.receipt_long_outlined,
            title: 'Ringkasan Biaya',
            child: Column(
              children: [
                _buildInfoRow('Subtotal Produk',
                    controller.formatRupiah(order.totalHargaBarang)),
                _buildInfoRow('Ongkir', controller.formatRupiah(order.ongkir)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Color(0xFFE9ECEF), thickness: 1.5),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF023E58),
                      ),
                    ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderDetail detail) {
    final status = detail.status ?? '';
    final isAda = status == 'diambil';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAda ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAda
              ? const Color(0xFF06D6A0).withOpacity(0.3)
              : const Color(0xFFFF6B6B).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isAda
                  ? const Color(0xFF06D6A0).withOpacity(0.15)
                  : const Color(0xFFFF6B6B).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isAda ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 20,
              color: isAda ? const Color(0xFF06D6A0) : const Color(0xFFFF6B6B),
            ),
          ),
          const SizedBox(width: 12),

          // Info produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.produk?.namaProduk ?? 'Produk #${detail.produkId}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF023E58),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${detail.jumlah ?? 0}x · ${_fmt(detail.hargaSatuan)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6C757D),
                  ),
                ),
              ],
            ),
          ),

          // Subtotal + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _fmt(detail.subtotalHarga),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0077B6),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isAda
                      ? const Color(0xFF06D6A0).withOpacity(0.15)
                      : const Color(0xFFFF6B6B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isAda ? 'Diambil' : 'Tidak Ada',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isAda
                        ? const Color(0xFF06D6A0)
                        : const Color(0xFFFF6B6B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6C757D),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF023E58),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0077B6).withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF0077B6)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF023E58),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0xFFF0F0F0), thickness: 1),
          ),
          child,
        ],
      ),
    );
  }

  String _fmt(int? value) {
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

  String _formatDate(DateTime? value) {
    if (value == null) return '-';

    try {
      return DateFormat('dd MMMM yyyy, HH:mm', 'id').format(value);
    } catch (_) {
      return DateFormat('dd MMMM yyyy, HH:mm').format(value);
    }
  }
}
