import 'package:e_pasar/app/data/models/order_model.dart';
import 'package:e_pasar/pages/user/controllers/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UserOrderHistoryDetailView extends StatefulWidget {
  const UserOrderHistoryDetailView({
    super.key,
    required this.orderId,
  });

  final int orderId;

  @override
  State<UserOrderHistoryDetailView> createState() =>
      _UserOrderHistoryDetailViewState();
}

class _UserOrderHistoryDetailViewState
    extends State<UserOrderHistoryDetailView> {
  late final OrderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OrderController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchHistoryDetail(widget.orderId);
    });
  }

  @override
  void dispose() {
    _controller.clearHistoryDetail();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FC),
      appBar: AppBar(
        title: const Text('Detail Riwayat Order'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final order = _controller.selectedHistoryOrder.value;
        final isLoading = _controller.isHistoryDetailLoading.value;
        final error = _controller.historyDetailErrorMessage.value;

        if (isLoading && order == null) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1565C0)),
          );
        }

        if (order == null) {
          return _buildErrorState(
            message: error.isEmpty ? 'Detail order tidak ditemukan.' : error,
          );
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => _controller.fetchHistoryDetail(widget.orderId),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeroCard(order),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Informasi Order',
                    icon: Icons.receipt_long_outlined,
                    child: Column(
                      children: [
                        _buildInfoRow('Kode Pesanan', order.kodePesanan ?? '-'),
                        _buildInfoRow(
                          'Status Order',
                          _orderStatusLabel(order.status),
                          valueColor: _orderStatusColor(order.status),
                          valueWeight: FontWeight.w700,
                        ),
                        _buildInfoRow(
                          'Tanggal Order',
                          _formatDate(order.createdAt),
                        ),
                        _buildInfoRow(
                          'Selesai Pada',
                          _formatDate(order.updatedAt ?? order.createdAt),
                        ),
                        _buildInfoRow(
                          'Driver',
                          order.driver?.name ?? 'Driver tidak tersedia',
                        ),
                        _buildInfoRow(
                          'Alamat',
                          order.alamatPengiriman ?? '-',
                        ),
                        _buildInfoRow(
                          'Jarak',
                          order.jarakKm == null ? '-' : '${order.jarakKm} km',
                        ),
                        if ((order.catatan?.toString().trim() ?? '').isNotEmpty)
                          _buildInfoRow(
                            'Catatan',
                            order.catatan.toString(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Daftar Barang',
                    icon: Icons.shopping_bag_outlined,
                    child: (order.orderDetails == null ||
                            order.orderDetails!.isEmpty)
                        ? const Text(
                            'Detail barang belum tersedia.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF78909C),
                            ),
                          )
                        : Column(
                            children: order.orderDetails!
                                .map(_buildItemCard)
                                .toList(),
                          ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Ringkasan Pembayaran',
                    icon: Icons.account_balance_wallet_outlined,
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'Metode',
                          _paymentMethodLabel(order.metodePembayaran),
                        ),
                        _buildInfoRow(
                          'Status Pembayaran',
                          _paymentStatusLabel(order.paymentStatus),
                          valueColor: _paymentStatusColor(order.paymentStatus),
                          valueWeight: FontWeight.w700,
                        ),
                        _buildInfoRow(
                          'Tipe Pembayaran',
                          _formatTextFallback(order.paymentType),
                        ),
                        _buildInfoRow(
                          'Referensi',
                          _formatTextFallback(order.paymentReference),
                        ),
                        _buildInfoRow(
                          'Dibayar Pada',
                          _formatDynamicDate(order.paidAt),
                        ),
                        if ((order.paymentUrl?.toString().trim() ?? '')
                            .isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F9FF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFD7E9FF),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Link Pembayaran',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF607D8B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SelectableText(
                                  order.paymentUrl.toString(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF37474F),
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _copyText(
                                      order.paymentUrl.toString(),
                                      'Link pembayaran disalin.',
                                    ),
                                    icon: const Icon(Icons.copy_rounded),
                                    label: const Text('Salin Link'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Total Biaya',
                    icon: Icons.payments_outlined,
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'Subtotal Produk',
                          _formatRupiah(order.totalHargaBarang),
                        ),
                        _buildInfoRow(
                          'Ongkir',
                          _formatRupiah(order.ongkir),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(color: Color(0xFFE3EDF7), height: 1),
                        ),
                        _buildInfoRow(
                          'Total Pembayaran',
                          _formatRupiah(order.totalHarga),
                          valueColor: const Color(0xFF1565C0),
                          valueWeight: FontWeight.w800,
                        ),
                      ],
                    ),
                  ),
                  if (error.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFCC80)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFFE65100),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Menampilkan data terakhir yang tersedia. Detail terbaru gagal dimuat: $error',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6D4C41),
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isLoading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  color: Color(0xFF1565C0),
                  backgroundColor: Color(0xFFD7E9FF),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildHeroCard(DataOrder order) {
    final paymentColor = _paymentStatusColor(order.paymentStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.kodePesanan ?? 'Order #${widget.orderId}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pesanan selesai dan tersimpan di riwayat.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(
                label: _orderStatusLabel(order.status),
                backgroundColor: Colors.white.withOpacity(0.18),
                textColor: Colors.white,
              ),
              _buildBadge(
                label: _paymentStatusLabel(order.paymentStatus),
                backgroundColor: paymentColor.withOpacity(0.18),
                textColor: Colors.white,
                borderColor: Colors.white.withOpacity(0.22),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatRupiah(order.totalHarga),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF1565C0)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D47A1),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE3EDF7), height: 1),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildItemCard(OrderDetail detail) {
    final statusLabel = _itemStatusLabel(detail.status);
    final statusColor = _itemStatusColor(detail.status);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7E9FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.produk?.namaProduk ?? 'Produk #${detail.produkId}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF263238),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${detail.jumlah ?? 0} x ${_formatRupiah(detail.hargaSatuan)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF607D8B),
                      ),
                    ),
                    if ((detail.produk?.kios?.namaKios?.trim() ?? '')
                        .isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          detail.produk!.kios!.namaKios!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF78909C),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatRupiah(detail.subtotalHarga),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBadge(
                    label: statusLabel,
                    backgroundColor: statusColor.withOpacity(0.12),
                    textColor: statusColor,
                    borderColor: statusColor.withOpacity(0.18),
                  ),
                ],
              ),
            ],
          ),
          if ((detail.catatanDriver?.toString().trim() ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE3EDF7)),
              ),
              child: Text(
                'Catatan driver: ${detail.catatanDriver}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF546E7A),
                  height: 1.45,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color valueColor = const Color(0xFF263238),
    FontWeight valueWeight = FontWeight.w600,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF78909C),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: valueColor,
                fontWeight: valueWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: borderColor == null ? null : Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildErrorState({required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 68,
              color: Color(0xFF90A4AE),
            ),
            const SizedBox(height: 16),
            const Text(
              'Detail order belum tersedia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF455A64),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF78909C),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _controller.fetchHistoryDetail(widget.orderId),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Muat Ulang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyText(String value, String message) async {
    await Clipboard.setData(ClipboardData(text: value));
    Get.snackbar('Berhasil', message);
  }

  String _paymentMethodLabel(String? value) {
    final normalized = value?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty) {
      return '-';
    }
    if (normalized == 'cod') {
      return 'COD';
    }
    if (normalized == 'midtrans') {
      return 'Midtrans';
    }
    return value!;
  }

  String _paymentStatusLabel(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'paid':
        return 'Sudah Dibayar';
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'failed':
        return 'Pembayaran Gagal';
      case 'expired':
        return 'Pembayaran Kedaluwarsa';
      case 'cancelled':
        return 'Pembayaran Dibatalkan';
      default:
        return (value?.trim().isEmpty ?? true) ? '-' : value!;
    }
  }

  Color _paymentStatusColor(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'paid':
        return const Color(0xFF2E7D32);
      case 'pending':
        return const Color(0xFFE65100);
      case 'failed':
      case 'expired':
      case 'cancelled':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF607D8B);
    }
  }

  String _orderStatusLabel(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      case 'dikirim':
        return 'Dikirim';
      case 'dalam_proses':
        return 'Dalam Proses';
      case 'menunggu_driver':
        return 'Menunggu Driver';
      default:
        return (value?.trim().isEmpty ?? true) ? '-' : value!;
    }
  }

  Color _orderStatusColor(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'selesai':
        return const Color(0xFF2E7D32);
      case 'dibatalkan':
        return const Color(0xFFC62828);
      case 'dikirim':
        return const Color(0xFF1565C0);
      case 'dalam_proses':
        return const Color(0xFFEF6C00);
      case 'menunggu_driver':
        return const Color(0xFF6A1B9A);
      default:
        return const Color(0xFF607D8B);
    }
  }

  String _itemStatusLabel(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'diambil':
        return 'Diambil';
      case 'tidak_ada':
        return 'Tidak Ada';
      case 'menunggu_pengganti':
        return 'Menunggu Pengganti';
      case 'diganti':
        return 'Diganti';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return (value?.trim().isEmpty ?? true) ? '-' : value!;
    }
  }

  Color _itemStatusColor(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'diambil':
      case 'diganti':
        return const Color(0xFF2E7D32);
      case 'tidak_ada':
      case 'dibatalkan':
        return const Color(0xFFC62828);
      case 'menunggu_pengganti':
        return const Color(0xFFEF6C00);
      default:
        return const Color(0xFF607D8B);
    }
  }

  String _formatRupiah(int? value) {
    if (value == null) {
      return 'Rp0';
    }

    final raw = value.toString();
    final buffer = StringBuffer('Rp');
    final offset = raw.length % 3;

    for (var i = 0; i < raw.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(raw[i]);
    }

    return buffer.toString();
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '-';
    }

    try {
      return DateFormat('dd MMM yyyy, HH:mm', 'id').format(value);
    } catch (_) {
      return DateFormat('dd MMM yyyy, HH:mm').format(value);
    }
  }

  String _formatDynamicDate(dynamic value) {
    if (value == null) {
      return '-';
    }

    if (value is DateTime) {
      return _formatDate(value);
    }

    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) {
      return value.toString();
    }

    return _formatDate(parsed);
  }

  String _formatTextFallback(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? '-' : text;
  }
}
