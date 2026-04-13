import 'package:e_pasar/app/data/models/keranjang_model.dart';
import 'package:e_pasar/pages/user/controllers/checkout_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  void _showConfirmDialog() {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.shopping_bag_rounded, color: Color(0xFF0077B6), size: 24),
            SizedBox(width: 12),
            Text(
              'Konfirmasi Pesanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF023E58),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${controller.keranjangList.length} item${controller.keranjangList.length > 1 ? 's' : ''}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Total: ${controller.formatRupiah(controller.totalBayar)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0077B6),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Lanjutkan pembuatan pesanan?',
              style: TextStyle(fontSize: 14, color: Color(0xFF6C757D)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF6C757D),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Color(0xFFDEE2E6)),
              ),
            ),
            child: Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          SizedBox(
            width: 120,
            child: ElevatedButton(
              onPressed: controller.isLoading.value 
                ? null 
                : controller.prosesCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0077B6), Color(0xFF06D6A0)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Lanjut',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              child: Column(
                children: [
                  _buildSectionBarang(),
                  const SizedBox(height: 12),
                  _buildSectionAlamat(),
                  const SizedBox(height: 12),
                  _buildSectionMetodePembayaran(),
                  const SizedBox(height: 12),
                  _buildSectionRincian(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
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
                  'Checkout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                ),
                child: Text(
                  '${controller.keranjangList.length} item',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionBarang() {
    return _buildCard(
      icon: Icons.shopping_bag_outlined,
      title: 'Barang Pesanan',
      child: Column(
        children: controller.keranjangList
            .map((item) => _buildItemRow(item))
            .toList(),
      ),
    );
  }

  Widget _buildItemRow(DataKeranjang item) {
    final produk = item.produk;
    final jumlah = int.tryParse(item.jumlah ?? '1') ?? 1;
    final imageUrl = produk?.foto != null
        ? 'https://perseveringly-coxal-chandler.ngrok-free.dev/storage/${produk!.foto}'
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 64,
              height: 64,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produk?.nama ?? 'Produk',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF023E58),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  controller.formatRupiah(produk?.harga ?? 0),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6C757D),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F4FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'x$jumlah',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0077B6),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                controller.formatRupiah(item.hargaTotal ?? 0),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0077B6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionAlamat() {
    final alamat = controller.alamat;
    return _buildCard(
      icon: Icons.location_on_outlined,
      title: 'Alamat Pengiriman',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.home_outlined, size: 18, color: Color(0xFF0077B6)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alamat.alamatLengkap ?? 'Alamat belum diset',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF023E58),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.straighten, size: 14, color: Color(0xFF6C757D)),
                    const SizedBox(width: 4),
                    Text(
                      '${alamat.jarakKm?.toStringAsFixed(1) ?? '0'} km dari pasar',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C757D),
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

  Widget _buildSectionMetodePembayaran() {
    return _buildCard(
      icon: Icons.payment_outlined,
      title: 'Metode Pembayaran',
      child: Obx(() => Column(
        children: [
          GestureDetector(
            onTap: () => controller.pilihMetodePembayaran('cod'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: controller.metodePembayaran.value == 'cod'
                    ? const Color(0xFFE0F4FF)
                    : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: controller.metodePembayaran.value == 'cod'
                      ? const Color(0xFF0077B6)
                      : const Color(0xFFDEE2E6),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0077B6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.money,
                        color: Color(0xFF0077B6), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bayar di Tempat (COD)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF023E58),
                            
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Bayar saat barang tiba',
                          style: TextStyle(fontSize: 11, color: Color(0xFF6C757D)),
                        ),
                      ],
                    ),
                  ),
                  if (controller.metodePembayaran.value == 'cod')
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF0077B6), size: 22),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => controller.pilihMetodePembayaran('midtrans'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: controller.metodePembayaran.value == 'midtrans'
                    ? const Color(0xFFE0F4FF)
                    : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: controller.metodePembayaran.value == 'midtrans'
                      ? const Color(0xFF0077B6)
                      : const Color(0xFFDEE2E6),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.credit_card,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QRIS (Midtrans)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF023E58),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Midtrans - Instant & secure',
                          style: TextStyle(fontSize: 11, color: Color(0xFF6C757D)),
                        ),
                      ],
                    ),
                  ),
                  if (controller.metodePembayaran.value == 'midtrans')
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF0077B6), size: 22),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildSectionRincian() {
    return _buildCard(
      icon: Icons.receipt_long_outlined,
      title: 'Rincian Biaya',
      child: Column(
        children: [
          _buildBiayaRow(
            label: 'Subtotal Produk',
            value: controller.formatRupiah(controller.subtotalProduk),
          ),
          const SizedBox(height: 10),

          _buildBiayaRow(
            label: 'Biaya Ongkir',
            value: controller.formatRupiah(controller.biayaJarak),
            sublabel:
                '(${controller.alamat.jarakKm?.ceil() ?? 0} km × ${controller.formatRupiah(controller.pasar.ongkir ?? 0)})',
          ),
          const SizedBox(height: 10),

          _buildBiayaRow(
            label: 'Biaya Layanan',
            value: controller.formatRupiah(controller.biayaLayanan),
          ),
          const SizedBox(height: 10),

          if (controller.tampilkanBiayaBerat) ...[
            _buildBiayaRow(
              label: 'Biaya Berat',
              value: controller.formatRupiah(controller.biayaBerat),
              sublabel:
                  '(${(controller.totalBerat - 10).toStringAsFixed(1)} kg × ${controller.formatRupiah(controller.pasar.biayaBeratBarang ?? 0)})',
              valueColor: const Color(0xFFE07B00),
            ),
            const SizedBox(height: 10),
          ],

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F4FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Ongkir',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0077B6),
                  ),
                ),
                Text(
                  controller.formatRupiah(controller.ongkir),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0077B6),
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE9ECEF), thickness: 1.5),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF023E58),
                ),
              ),
              Text(
                controller.formatRupiah(controller.totalBayar),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0077B6),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBiayaRow({
    required String label,
    required String value,
    String? sublabel,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6C757D),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (sublabel != null)
              Text(
                sublabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFADB5BD),
                ),
              ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF023E58),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
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
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C757D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.formatRupiah(controller.totalBayar),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF023E58),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7F4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Ongkir ${controller.formatRupiah(controller.ongkir)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF06D6A0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : () => _showConfirmDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: controller.isLoading.value
                            ? const LinearGradient(
                                colors: [Color(0xFFADB5BD), Color(0xFFADB5BD)])
                            : const LinearGradient(
                                colors: [Color(0xFF0077B6), Color(0xFF06D6A0)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: controller.isLoading.value
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  ),
                                  SizedBox(width: 10),
                                  Text('Memproses...',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15)),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.shopping_bag_rounded,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text('Buat Pesanan',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          letterSpacing: 0.2)),
                                ],
                              ),
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 8),
          ],
        ),
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
                  letterSpacing: 0.2,
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

  Widget _imgPlaceholder() {
    return Container(
      color: const Color(0xFFE0F7FA),
      child: const Center(
        child: Icon(Icons.storefront_rounded,
            color: Color(0xFF90E0EF), size: 28),
      ),
    );
  }
}
