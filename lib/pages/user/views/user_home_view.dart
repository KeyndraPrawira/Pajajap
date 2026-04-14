import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/pages/user/controllers/keranjang_controller.dart';
import 'package:e_pasar/pages/user/views/app_info_view.dart';
import 'package:e_pasar/pages/user/views/keranjang_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:e_pasar/app/data/models/produk_model.dart';
import 'package:e_pasar/app/utils/api.dart';
import 'package:e_pasar/pages/user/controllers/produk_controller.dart';
import 'package:e_pasar/app/data/models/keranjang_model.dart';

class UserHomeView extends GetView<UserProdukController> {
  UserHomeView({super.key});

  final _pageController = PageController(viewportFraction: 0.92);

  Color _accentForIndex(int i) {
    const List<Color> accents = [
      Color(0xFF00B4D8),
      Color(0xFF06D6A0),
      Color(0xFF48CAE4),
      Color(0xFF1B9AAA),
      Color(0xFF38B000),
      Color(0xFF80B918),
      Color(0xFF0077B6),
      Color(0xFF23B5D3),
    ];
    return accents[i % accents.length];
  }

  // ══════════════════════════════════════════════════════════
  // MODAL ADD TO CART
  // ══════════════════════════════════════════════════════════
  void _showAddToCartModal(BuildContext context, DataProduk produk) {
    final jumlahObs = 1.obs;
    final hargaSatuan = produk.harga ?? 0;
    final imageUrl = Image.network('${Api.baseImageUrl}${produk.foto}').image;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Obx(() {
        final jumlah = jumlahObs.value;
        final totalHarga = jumlah * hargaSatuan;

        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle bar ─────────────────────────────
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDEE2E6),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              // ── Header ────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
                child: Row(
                  children: [
                    const Text(
                      'Tambah ke Keranjang',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF023E58),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F7F4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: Color(0xFF6C757D)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Product Info Row ───────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: CachedNetworkImage(
                          imageUrl: '${Api.baseImageUrl}${produk.foto}',
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: const Color(0xFFE8F5F9),
                            child: const Icon(Icons.image_outlined,
                                color: Color(0xFF90E0EF), size: 28),
                          ),
                          errorWidget: (_, __, ___) => _modalPlaceholder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            produk.namaProduk ?? 'Produk',
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
                          Row(
                            children: [
                              Icon(Icons.scale_outlined,
                                  size: 11, color: Colors.grey[400]),
                              const SizedBox(width: 3),
                              Text(
                                '${produk.beratSatuan ?? 0} gram/satuan',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey[400]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F4FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatRupiah(hargaSatuan),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0077B6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 12),

              // ── Jumlah Input ──────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Jumlah',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF023E58),
                      ),
                    ),
                    const Spacer(),
                    _qtyButton(
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
                        width: 48,
                        child: Center(
                          child: Text(
                            '$jumlah',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF023E58),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _qtyButton(
                      icon: Icons.add_rounded,
                      onTap: () {
                        final stok = produk.stok ?? 99;
                        if (jumlahObs.value < stok) jumlahObs.value++;
                      },
                      enabled: jumlah < (produk.stok ?? 99),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Total Harga ───────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0F7FA), Color(0xFFE8F5E9)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00B4D8).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Harga',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6C757D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$jumlah × ${_formatRupiah(hargaSatuan)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6C757D),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _formatRupiah(totalHarga),
                        key: ValueKey(totalHarga),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0077B6),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Action Buttons ────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Row(
                  children: [
                    // Cancel
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6C757D),
                            side: const BorderSide(
                                color: Color(0xFFDEE2E6), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Lanjut
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 46,
                        child: _LanjutButton(
                          produk: produk,
                          jumlahObs: jumlahObs,
                          totalHarga: totalHarga,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF0077B6) : const Color(0xFFE9ECEF),
          borderRadius: BorderRadius.circular(9),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF0077B6).withOpacity(0.25),
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

  Widget _modalPlaceholder() {
    return Container(
      color: const Color(0xFFE0F7FA),
      child: const Center(
        child:
            Icon(Icons.storefront_rounded, color: Color(0xFF90E0EF), size: 32),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                  child: _buildSectionHeader('Kategori', onSeeAll: null)),
              SliverToBoxAdapter(child: _buildKategoriScroll()),
              SliverToBoxAdapter(
                  child: _buildSectionHeader('Semua Produk', onSeeAll: null)),
              _buildProdukGrid(context),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          _buildFloatingCart(),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SLIVER APP BAR — title row + search bar di bottom
  // ══════════════════════════════════════════════════════════
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 0,
      // Semua konten masuk ke flexibleSpace, expandedHeight = tinggi total
      expandedHeight: 100,
      collapsedHeight: 110,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF06D6A0)],
          ),
        ),
        child: SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 9),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Baris e-Pasar + ikon ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'e-Pasar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Belanja segar, langsung dari pasar 🌿',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _appBarIconButton(
                      icon: Icons.info,
                      onTap: () => Get.to(() => const AppInfoView()),
                    ),
                    
                  ],
                ),
                const SizedBox(height: 10),
                // ── Search bar ──
                _buildSearchBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBarIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onSubmitted: (value) => controller.fetchProduk(search: value),
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Cari produk segar...',
          hintStyle: const TextStyle(color: Color(0xFFADB5BD), fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded,
              color: Color(0xFF00B4D8), size: 18),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          isDense: true,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SECTION HEADER
  // ══════════════════════════════════════════════════════════
  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0077B6), Color(0xFF06D6A0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF023E58),
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF00B4D8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // KATEGORI — horizontal scroll yang proper
  // ══════════════════════════════════════════════════════════
  Widget _buildKategoriScroll() {
    return Obx(() {
      if (controller.isLoading.value && controller.kategoriList.isEmpty) {
        return const SizedBox(
          height: 44,
          child: Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF00B4D8), strokeWidth: 2)),
        );
      }

      final list = controller.kategoriList;
      final selectedId = controller.selectedKategoriId.value;

      return SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          physics: const BouncingScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final kat = list[i];
            final color = _accentForIndex(i);
            final isSelected = selectedId == kat.id;

            return GestureDetector(
              onTap: () => controller.filterByKategori(kat.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(isSelected ? 0.35 : 0.1),
                      blurRadius: isSelected ? 8 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: isSelected ? color : color.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    kat.namaKategori ?? '-',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color:
                          isSelected ? Colors.white : const Color(0xFF023E58),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ══════════════════════════════════════════════════════════
  // PRODUK GRID
  // ══════════════════════════════════════════════════════════
  Widget _buildProdukGrid(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return SliverToBoxAdapter(
          child: SizedBox(
            height: 300,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(color: Color(0xFF00B4D8)),
                  SizedBox(height: 10),
                  Text('Memuat produk...',
                      style: TextStyle(color: Color(0xFF6C757D), fontSize: 13)),
                ],
              ),
            ),
          ),
        );
      }

      if (controller.errorMessage.isNotEmpty) {
        return SliverToBoxAdapter(child: _buildErrorState());
      }

      if (controller.produkList.isEmpty) {
        return SliverToBoxAdapter(child: _buildEmptyState());
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (_, i) => _buildProdukCard(context, controller.produkList[i]),
            childCount: controller.produkList.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.78,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
        ),
      );
    });
  }

  Widget _buildProdukCard(BuildContext context, DataProduk produk) {
    final imageUrl =
        produk.foto != null ? '${Api.baseImageUrl}${produk.foto}' : null;

    // Nama kios — sesuaikan dengan field model Anda (misalnya produk.kios?.namaKios)
    // Ganti 'produk.kios?.namaKios' dengan field yang sesuai di model Anda
    final namaKios = produk.kios?.namaKios ?? 'Kios Tidak Diketahui';

    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.produkDetail(produk.id!), arguments: produk);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0077B6).withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Foto ──────────────────────────────────
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  SizedBox(
                    height: 110,
                    width: double.infinity,
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: const Color(0xFFE8F5F9),
                              child: const Center(
                                child: Icon(Icons.image_outlined,
                                    color: Color(0xFF90E0EF), size: 36),
                              ),
                            ),
                            errorWidget: (_, __, ___) => _produkPlaceholder(),
                          )
                        : _produkPlaceholder(),
                  ),
                  // Badge stok hampir habis
                  if ((produk.stok ?? 0) < 5)
                    Positioned(
                      top: 7,
                      left: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Hampir habis',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Info produk ────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 7, 9, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama produk
                    Text(
                      produk.namaProduk ?? 'Produk',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF023E58),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Berat
                    Row(
                      children: [
                        Icon(Icons.scale_outlined,
                            size: 10, color: Colors.grey[400]),
                        const SizedBox(width: 2),
                        Text(
                          '${produk.beratSatuan ?? 0} gram/satuan',
                          style:
                              TextStyle(fontSize: 9, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // ── Info Kios ──────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7F4),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF06D6A0).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.storefront_rounded,
                            size: 10,
                            color: Color(0xFF06D6A0),
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              namaKios,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B9AAA),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Harga
                    Text(
                      _formatRupiah(produk.harga ?? 0),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0077B6),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // ── Tombol + Keranjang ─────────────
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddToCartModal(context, produk),
                        icon: const Icon(Icons.add_shopping_cart_rounded,
                            size: 13),
                        label: const Text(
                          '+ Keranjang',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0077B6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _produkPlaceholder() {
    return Container(
      height: 110,
      color: const Color(0xFFE0F7FA),
      child: const Center(
        child:
            Icon(Icons.storefront_rounded, color: Color(0xFF90E0EF), size: 44),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // EMPTY & ERROR STATE
  // ══════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return SizedBox(
      height: 240,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0F7FA), Color(0xFFE8F5E9)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded,
                size: 38, color: Color(0xFF90E0EF)),
          ),
          const SizedBox(height: 14),
          const Text(
            'Produk tidak ditemukan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF023E58),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Coba kategori atau kata kunci lain',
            style: TextStyle(fontSize: 12, color: Color(0xFF6C757D)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return SizedBox(
      height: 240,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 50, color: Color(0xFFADB5BD)),
          const SizedBox(height: 10),
          const Text(
            'Gagal memuat produk',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF023E58),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: controller.fetchProduk,
              icon: const Icon(Icons.refresh_rounded, size: 15),
              label: const Text('Coba Lagi', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0077B6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // FLOATING CART
  // ══════════════════════════════════════════════════════════
  Widget _buildFloatingCart() {
    final keranjangCtrl = Get.find<KeranjangController>();

    return Positioned(
      bottom: 20,
      right: 16,
      child: Obx(() {
        final count = keranjangCtrl.keranjangList.length;
        final total = keranjangCtrl.totalHarga;

        if (count == 0) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => Get.to(
            () => const KeranjangView(),
            transition: Transition.downToUp,
            duration: const Duration(milliseconds: 300),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0077B6), Color(0xFF06D6A0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0077B6).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_basket_rounded,
                        color: Colors.white, size: 24),
                    Positioned(
                      top: -5,
                      right: -5,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B6B),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            count > 99 ? '99+' : '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$count item',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatRupiah(total),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ══════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════
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

// ══════════════════════════════════════════════════════════
// TOMBOL LANJUT — stateful untuk handle loading
// ══════════════════════════════════════════════════════════
class _LanjutButton extends StatelessWidget {
  final DataProduk produk;
  final RxInt jumlahObs;
  final int totalHarga;

  const _LanjutButton({
    required this.produk,
    required this.jumlahObs,
    required this.totalHarga,
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
                  hargaTotal: totalHarga,
                );

                // Tampilkan snackbar sukses sebelum tutup modal
                Get.snackbar(
                  '✅ Berhasil!',
                  '${produk.namaProduk ?? 'Produk'} ditambahkan ke keranjang',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Color(0xFF10B981).withOpacity(0.95),
                  colorText: Colors.white,
                  icon: Icon(Icons.check_circle_rounded, color: Colors.white),
                  duration: Duration(seconds: 2),
                  margin: EdgeInsets.all(16),
                  borderRadius: 12,
                );

                // Delay agar snackbar kelihatan sebelum modal tutup
                await Future.delayed(Duration(milliseconds: 500));
                Get.back();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          // Tinggi tombol yang proporsional — diatur dari parent SizedBox(height: 46)
          decoration: BoxDecoration(
            gradient: isLoading
                ? const LinearGradient(
                    colors: [Color(0xFFADB5BD), Color(0xFFADB5BD)])
                : const LinearGradient(
                    colors: [Color(0xFF0077B6), Color(0xFF06D6A0)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isLoading
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF0077B6).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_checkout_rounded,
                          color: Colors.white, size: 15),
                      SizedBox(width: 5),
                      Text(
                        'Lanjut',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
    });
  }
}
