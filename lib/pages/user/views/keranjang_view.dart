import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/pages/user/controllers/keranjang_controller.dart';
import 'package:e_pasar/pages/user/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_pasar/app/data/models/keranjang_model.dart';

class KeranjangView extends GetView<KeranjangController> {
  const KeranjangView({super.key});

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
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }
              if (controller.errorMessage.isNotEmpty) {
                return _buildErrorState();
              }
              if (controller.keranjangList.isEmpty) {
                return _buildEmptyState();
              }
              return _buildKeranjangList();
            }),
          ),
          // Bottom checkout bar
          Obx(() {
            if (controller.keranjangList.isEmpty) return const SizedBox();
            return _buildCheckoutBar();
          }),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════
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
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
              ),
              const Expanded(
                child: Text(
                  'Keranjang Belanja',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Obx(() {
                final count = controller.keranjangList.length;
                if (count == 0) return const SizedBox();
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4), width: 1),
                  ),
                  child: Text(
                    '$count item',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // KERANJANG LIST
  // ══════════════════════════════════════════════════════════
  Widget _buildKeranjangList() {
    return RefreshIndicator(
      color: const Color(0xFF0077B6),
      onRefresh: controller.fetchKeranjang,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        physics: const BouncingScrollPhysics(),
        itemCount: controller.keranjangList.length,
        itemBuilder: (_, i) {
          return _buildKeranjangCard(controller.keranjangList[i]);
        },
      ),
    );
  }

  Widget _buildKeranjangCard(DataKeranjang item) {
    final produk = item.produk;
    final hargaSatuan = produk?.harga ?? 0;
    final jumlah = int.tryParse(item.jumlah ?? '1') ?? 1;
    final imageUrl = produk?.foto != null
        ? 'http://https://perseveringly-coxal-chandler.ngrok-free.dev/storage/${produk!.foto}'
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Foto ──────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80,
                height: 80,
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _imgPlaceholder(),
                        errorWidget: (_, __, ___) => _imgPlaceholder(),
                      )
                    : _imgPlaceholder(),
              ),
            ),
            const SizedBox(width: 12),

            // ── Info + Qty ─────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama produk
                  Text(
                    produk?.nama ?? 'Produk',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF023E58),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Harga satuan
                  Text(
                    _formatRupiah(hargaSatuan),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6C757D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      // Qty control
                      _buildQtyControl(item, hargaSatuan, jumlah),
                      const Spacer(),
                      // Subtotal
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6C757D),
                            ),
                          ),
                          Text(
                            _formatRupiah(item.hargaTotal ?? 0),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0077B6),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Delete button ──────────────────────────
            GestureDetector(
              onTap: () => _confirmDelete(item),
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 16, color: Color(0xFFFF6B6B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyControl(DataKeranjang item, int hargaSatuan, int jumlah) {
    return Obx(() {
      final isLoading = controller.isActionLoading.value;

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Minus
            GestureDetector(
              onTap: isLoading
                  ? null
                  : () => controller.decrementItem(item, hargaSatuan),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: jumlah <= 1
                      ? const Color(0xFFFFF0F0)
                      : const Color(0xFFF0F7F4),
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(8)),
                ),
                child: Icon(
                  jumlah <= 1
                      ? Icons.delete_outline_rounded
                      : Icons.remove_rounded,
                  size: 14,
                  color: jumlah <= 1
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF0077B6),
                ),
              ),
            ),
            // Jumlah
            SizedBox(
              width: 32,
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF0077B6),
                        ),
                      )
                    : Text(
                        '$jumlah',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF023E58),
                        ),
                      ),
              ),
            ),
            // Plus
            GestureDetector(
              onTap: isLoading
                  ? null
                  : () => controller.incrementItem(item, hargaSatuan),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF0077B6),
                  borderRadius:
                      const BorderRadius.horizontal(right: Radius.circular(8)),
                ),
                child: const Icon(Icons.add_rounded,
                    size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _confirmDelete(DataKeranjang item) {
    Get.dialog(
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
                  color: const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFFF6B6B), size: 28),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hapus Produk?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF023E58),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hapus ${item.produk?.nama ?? 'produk ini'} dari keranjang?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6C757D),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFDEE2E6)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Batal',
                          style: TextStyle(
                              color: Color(0xFF6C757D),
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.deleteKeranjang(item.id!);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Hapus',
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
  }

  // ══════════════════════════════════════════════════════════
  // CHECKOUT BAR
  // ══════════════════════════════════════════════════════════
  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ringkasan harga
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Belanja',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C757D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(() => Text(
                          _formatRupiah(controller.totalHarga),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF023E58),
                            letterSpacing: -0.5,
                          ),
                        )),
                  ],
                ),
                const Spacer(),
                // Item count badge
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F4FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${controller.totalItem} produk',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0077B6),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 14),
            // Tombol checkout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final profileC = Get.find<ProfileController>();
                  final alamat = profileC.dataProfile.value?.alamat;

                  // Cek alamat sudah diset belum
                  if (alamat == null || alamat.alamatLengkap == null) {
                    Get.dialog(
                      AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        title: Row(
                          children: [
                            Icon(Icons.location_off_outlined,
                                color: Color(0xFFFF9800), size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Alamat Belum Diatur',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF023E58),
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          'Anda belum mengatur alamat pengiriman. Atur sekarang?',
                          style: TextStyle(fontSize: 14, height: 1.4),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              foregroundColor: Color(0xFF6C757D),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Color(0xFFDEE2E6)),
                              ),
                            ),
                            child: Text('Nanti',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Get.back(); // Tutup dialog
                              Get.toNamed(AppRoutes
                                  .EDIT_PROFILE); // atau AppRoutes.EDIT_ALAMAT
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF0077B6),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: Text('Atur Sekarang',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  // Navigate ke checkout dengan data keranjang + alamat
                  Get.toNamed(
                    AppRoutes.CHECKOUT,
                    arguments: {
                      'keranjang': controller.keranjangList.toList(),
                      'alamat': alamat,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0077B6), Color(0xFF06D6A0)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Lanjut ke Pembayaran',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // STATES
  // ══════════════════════════════════════════════════════════
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 108,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE9ECEF),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _shimmerBox(width: 140, height: 14),
                    _shimmerBox(width: 80, height: 12),
                    _shimmerBox(width: 100, height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECEF),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0F7FA), Color(0xFFE8F5E9)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                size: 52, color: Color(0xFF90E0EF)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Keranjang Kosong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF023E58),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Yuk tambahkan produk segar\nke keranjangmu!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6C757D),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.storefront_rounded, size: 16),
            label: const Text('Belanja Sekarang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0077B6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 56, color: Color(0xFFADB5BD)),
          const SizedBox(height: 16),
          const Text(
            'Gagal memuat keranjang',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF023E58),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6C757D)),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: controller.fetchKeranjang,
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

  Widget _imgPlaceholder() {
    return Container(
      color: const Color(0xFFE0F7FA),
      child: const Center(
        child:
            Icon(Icons.storefront_rounded, color: Color(0xFF90E0EF), size: 32),
      ),
    );
  }

  String _formatRupiah(int amount) {
    final s = amount.toString();
    final buffer = StringBuffer('Rp');
    final offset = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}
