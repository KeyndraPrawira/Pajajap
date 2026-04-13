import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_pasar/app/data/models/produk_model.dart';
import 'package:e_pasar/app/utils/api.dart';
import 'package:e_pasar/pages/user/controllers/keranjang_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DetailProdukView extends StatelessWidget {
  const DetailProdukView({super.key});

  static const Color _darkGreen = Color(0xFF0B5D38);
  static const Color _midGreen = Color(0xFF1E8B4B);
  static const Color _lightGreen = Color(0xFF8BCF73);
  static const Color _bgColor = Color(0xFFF4F8F2);
  static const Color _textMain = Color(0xFF1D2B1F);
  static const Color _textSub = Color(0xFF6B7B69);

  @override
  Widget build(BuildContext context) {
    final DataProduk produk = Get.arguments as DataProduk;
    final jumlahObs = 1.obs;
    final canAddToCart = Get.isRegistered<KeranjangController>();

    final imageUrl = (produk.foto != null && produk.foto!.isNotEmpty)
        ? '${Api.baseImageUrl}${produk.foto}'
        : null;

    final namaKios = produk.kios?.namaKios ?? 'Kios Tidak Diketahui';
    final lokasiKios = produk.kios?.lokasi ?? '-';
    final jamBuka = produk.kios?.jamBuka ?? '-';
    final jamTutup = produk.kios?.jamTutup ?? '-';

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero Foto ──────────────────────────────────────
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: _darkGreen,
                elevation: 0,
                automaticallyImplyLeading: false,
                leading: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Foto produk
                      imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => _imagePlaceholder(),
                              errorWidget: (_, __, ___) => _imagePlaceholder(),
                            )
                          : _imagePlaceholder(),

                      // Gradient gelap di bawah foto
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xB30B5D38),
                              Color(0x801E8B4B),
                              Color(0x668BCF73),
                            ],
                          ),
                        ),
                      ),

                      // Badge stok hampir habis
                      if ((produk.stok ?? 0) < 5)
                        Positioned(
                          top: 56,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD64545),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Stok Hampir Habis!',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 20,
                        child: SafeArea(
                          top: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  namaKios,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                produk.namaProduk ?? 'Produk',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Konten ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    20,
                    16,
                    canAddToCart ? 120 : 28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Nama & Harga ──────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              produk.namaProduk ?? 'Produk',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: _textMain,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_darkGreen, _midGreen, _lightGreen],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _formatRupiah(produk.harga ?? 0),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ── Info chips ────────────────────────────
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _infoChip(
                            icon: Icons.scale_outlined,
                            label: '${produk.beratSatuan ?? 0} gram',
                            color: _midGreen,
                          ),
                          _infoChip(
                            icon: Icons.inventory_2_outlined,
                            label: 'Stok: ${produk.stok ?? 0}',
                            color: (produk.stok ?? 0) < 5
                                ? const Color(0xFFD64545)
                                : _lightGreen,
                          ),
                          _infoChip(
                            icon: Icons.category_outlined,
                            label: 'Kategori #${produk.kategoriId ?? '-'}',
                            color: _darkGreen,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(
                              'Rincian Produk',
                              Icons.inventory_2_outlined,
                            ),
                            const SizedBox(height: 14),
                            _detailRow(
                                'Harga', _formatRupiah(produk.harga ?? 0)),
                            _detailRow(
                              'Berat Satuan',
                              '${produk.beratSatuan ?? 0} gram',
                            ),
                            _detailRow('Stok', '${produk.stok ?? 0}'),
                            _detailRow('ID Produk', '${produk.id ?? '-'}'),
                            _detailRow(
                              'Kategori ID',
                              '${produk.kategoriId ?? '-'}',
                            ),
                            _detailRow('Kios ID', '${produk.kiosId ?? '-'}'),
                            _detailRow(
                              'Diperbarui',
                              produk.updatedAt != null
                                  ? DateFormat(
                                      'dd MMM yyyy, HH:mm',
                                    ).format(produk.updatedAt!)
                                  : '-',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Deskripsi ─────────────────────────────
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(
                                'Deskripsi Produk', Icons.description_outlined),
                            const SizedBox(height: 10),
                            Text(
                              produk.deskripsi?.isNotEmpty == true
                                  ? produk.deskripsi!
                                  : 'Tidak ada deskripsi.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: _textSub,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Info Kios ──────────────────────────────
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(
                                'Info Kios', Icons.storefront_rounded),
                            const SizedBox(height: 12),
                            _kiosInfoRow(
                              icon: Icons.store_outlined,
                              label: 'Nama Kios',
                              value: namaKios,
                            ),
                            const SizedBox(height: 10),
                            _kiosInfoRow(
                              icon: Icons.location_on_outlined,
                              label: 'Lokasi',
                              value: lokasiKios,
                            ),
                            const SizedBox(height: 10),
                            _kiosInfoRow(
                              icon: Icons.access_time_rounded,
                              label: 'Jam Operasional',
                              value:
                                  '${_formatJam(jamBuka)} – ${_formatJam(jamTutup)}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom Bar: Qty + Tambah Keranjang ────────────────
          if (canAddToCart)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(context, produk, jumlahObs),
            ),
        ],
      ),
    );
  }

  // ── Bottom action bar ──────────────────────────────────────
  Widget _buildBottomBar(
      BuildContext context, DataProduk produk, RxInt jumlahObs) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() {
        final jumlah = jumlahObs.value;
        final total = jumlah * (produk.harga ?? 0);

        return Row(
          children: [
            // ── Qty control ──
            Container(
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _qtyBtn(
                    icon: Icons.remove_rounded,
                    onTap: () {
                      if (jumlahObs.value > 1) jumlahObs.value--;
                    },
                    enabled: jumlah > 1,
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: SizedBox(
                      key: ValueKey(jumlah),
                      width: 38,
                      child: Center(
                        child: Text(
                          '$jumlah',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: _textMain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _qtyBtn(
                    icon: Icons.add_rounded,
                    onTap: () {
                      if (jumlahObs.value < (produk.stok ?? 99)) {
                        jumlahObs.value++;
                      }
                    },
                    enabled: jumlah < (produk.stok ?? 99),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ── Tombol tambah keranjang ──
            Expanded(
              child: _AddToCartButton(
                produk: produk,
                jumlahObs: jumlahObs,
                total: total,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _qtyBtn({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? _midGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _midGreen.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? Colors.white : const Color(0xFFADB5BD),
        ),
      ),
    );
  }

  // ── Helpers UI ─────────────────────────────────────────────
  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFE3F1E8),
      child: const Center(
        child: Icon(
          Icons.storefront_rounded,
          color: Color(0xFF8BCF73),
          size: 80,
        ),
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_darkGreen, _midGreen, _lightGreen],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: _textMain,
          ),
        ),
      ],
    );
  }

  Widget _kiosInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: _midGreen),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: _textSub,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textMain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Format helpers ─────────────────────────────────────────
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: _textSub,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                color: _textMain,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRupiah(int amount) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(amount);
  }

  String _formatJam(String jam) {
    // "08:00:00" → "08.00"
    if (jam.length >= 5) return jam.substring(0, 5);
    return jam;
  }
}

// ── Tombol Add to Cart (handle loading state) ──────────────
class _AddToCartButton extends StatelessWidget {
  final DataProduk produk;
  final RxInt jumlahObs;
  final int total;

  const _AddToCartButton({
    required this.produk,
    required this.jumlahObs,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final keranjangCtrl = Get.find<KeranjangController>();

    return Obx(() {
      final isLoading = keranjangCtrl.isActionLoading.value;

      return GestureDetector(
        onTap: isLoading
            ? null
            : () async {
                await keranjangCtrl.addToKeranjang(
                  produkId: produk.id.toString(),
                  jumlah: jumlahObs.value,
                  hargaTotal: total,
                );
                Get.back();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          decoration: BoxDecoration(
            gradient: isLoading
                ? const LinearGradient(
                    colors: [Color(0xFFADB5BD), Color(0xFFADB5BD)])
                : const LinearGradient(
                    colors: [
                      DetailProdukView._darkGreen,
                      DetailProdukView._midGreen,
                      DetailProdukView._lightGreen,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isLoading
                ? []
                : [
                    BoxShadow(
                      color: DetailProdukView._midGreen.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_shopping_cart_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tambah ke Keranjang',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            _formatRupiah(total),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      );
    });
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
