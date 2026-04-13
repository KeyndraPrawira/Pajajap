import 'package:e_pasar/app/data/models/order_model.dart';
import 'package:e_pasar/pages/user/controllers/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UserOrderHistoryView extends GetView<OrderController> {
  const UserOrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isHistoryLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF1976D2)),
        );
      }

      if (controller.historyErrorMessage.isNotEmpty) {
        return _buildErrorState();
      }

      if (controller.historyOrders.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.fetchHistoryOrders,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
            children: const [
              Icon(
                Icons.history_toggle_off_rounded,
                size: 72,
                color: Color(0xFF90A4AE),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'Belum ada order selesai',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF455A64),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  'Riwayat akan muncul setelah pesanan kamu berstatus selesai.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF78909C),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchHistoryOrders,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: controller.historyOrders.length,
          itemBuilder: (context, index) {
            final order = controller.historyOrders[index];
            return _buildHistoryCard(order);
          },
        ),
      );
    });
  }

  Widget _buildHistoryCard(DataOrder order) {
    final finishedAt = order.updatedAt ?? order.createdAt;
    final formattedDate = _formatDate(finishedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFD7E9FF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF78909C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            order.kodePesanan ?? '-',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 8),
          _infoRow(
            Icons.delivery_dining_outlined,
            'Driver',
            order.driver?.name ?? 'Driver tidak tersedia',
          ),
          const SizedBox(height: 8),
          _infoRow(
            Icons.location_on_outlined,
            'Alamat',
            order.alamatPengiriman ?? 'Alamat tidak tersedia',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F9FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF78909C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatRupiah(order.totalHarga),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF607D8B)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF455A64),
                height: 1.45,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: Color(0xFF90A4AE),
            ),
            const SizedBox(height: 16),
            const Text(
              'Riwayat gagal dimuat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF455A64),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.historyErrorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF78909C),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: controller.fetchHistoryOrders,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Muat Ulang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRupiah(int? value) {
    if (value == null) return 'Rp0';

    final raw = value.toString();
    final buffer = StringBuffer('Rp');
    final offset = raw.length % 3;

    for (int i = 0; i < raw.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(raw[i]);
    }

    return buffer.toString();
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
