import 'package:e_pasar/pages/user/controllers/keranjang_controller.dart';
import 'package:e_pasar/pages/user/views/keranjang_view.dart';
import 'package:e_pasar/pages/user/views/pasar_list_view.dart';
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
  
  IconData _iconForKategori(String? nama) {
    final n = (nama ?? '').toLowerCase();
    if (n.contains('sayur') || n.contains('hijau')) return Icons.eco_rounded;
    if (n.contains('buah')) return Icons.local_florist_rounded;
    if (n.contains('daging') || n.contains('ayam') || n.contains('ikan'))
      return Icons.set_meal_rounded;
    if (n.contains('bumbu') || n.contains('rempah'))
      return Icons.soup_kitchen_rounded;
    if (n.contains('minuman') || n.contains('minum'))
      return Icons.local_drink_rounded;
    if (n.contains('snack') || n.contains('camilan'))
      return Icons.cookie_rounded;
    if (n.contains('beras') || n.contains('biji') || n.contains('kering'))
      return Icons.grass_rounded;
    if (n.contains('susu') || n.contains('telur') || n.contains('olahan'))
      return Icons.egg_alt_rounded;
    return Icons.storefront_rounded;
  }

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
    final imageUrl = produk.foto != null
        ? 'http://localhost:8000/storage/${produk.foto}'
        : null;

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
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle bar ─────────────────────────────
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDEE2E6),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              // ── Header ────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Row(
                  children: [
                    const Text(
                      'Tambah ke Keranjang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF023E58),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F7F4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 18, color: Color(0xFF6C757D)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Product Info Row ───────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 88,
                        height: 88,
                        child: imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: const Color(0xFFE8F5F9),
                                  child: const Icon(Icons.image_outlined,
                                      color: Color(0xFF90E0EF), size: 32),
                                ),
                                errorWidget: (_, __, ___) =>
                                    _modalPlaceholder(),
                              )
                            : _modalPlaceholder(),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            produk.namaProduk ?? 'Produk',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF023E58),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.scale_outlined,
                                  size: 12, color: Colors.grey[400]),
                              const SizedBox(width: 4),
                              Text(
                                '${produk.beratSatuan ?? 0} gram/satuan',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[400]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Harga satuan
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F4FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatRupiah(hargaSatuan),
                              style: const TextStyle(
                                fontSize: 15,
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

              const SizedBox(height: 20),

              // ── Divider ───────────────────────────────
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 16),

              // ── Jumlah Input ──────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    // Decrement
                    _qtyButton(
                      icon: Icons.remove_rounded,
                      onTap: () {
                        if (jumlahObs.value > 1) jumlahObs.value--;
                      },
                      enabled: jumlah > 1,
                    ),
                    // Angka jumlah
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: SizedBox(
                        key: ValueKey(jumlah),
                        width: 52,
                        child: Center(
                          child: Text(
                            '$jumlah',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF023E58),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Increment
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

              const SizedBox(height: 16),

              // ── Total Harga ───────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0F7FA), Color(0xFFE8F5E9)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
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
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0077B6),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Action Buttons ────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  children: [
                    // Cancel
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6C757D),
                          side: const BorderSide(
                              color: Color(0xFFDEE2E6), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                    const SizedBox(width: 10),
                    // Lanjut
                    Expanded(
                      flex: 3,
                      child: _LanjutButton(
                        produk: produk,
                        jumlahObs: jumlahObs,
                        totalHarga: totalHarga,
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF0077B6) : const Color(0xFFE9ECEF),
          borderRadius: BorderRadius.circular(10),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF0077B6).withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? Colors.white : const Color(0xFFADB5BD),
        ),
      ),
    );
  }

  Widget _modalPlaceholder() {
    return Container(
      color: const Color(0xFFE0F7FA),
      child: const Center(
        child: Icon(Icons.storefront_rounded,
            color: Color(0xFF90E0EF), size: 36),
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
              SliverToBoxAdapter(child: _buildBannerPromo()),
              SliverToBoxAdapter(
                  child: _buildSectionHeader('Kategori', onSeeAll: null)),
              SliverToBoxAdapter(child: _buildKategoriGrid()),
              SliverToBoxAdapter(
                  child:
                      _buildSectionHeader('Semua Produk', onSeeAll: null)),
              _buildProdukGrid(context),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
          _buildFloatingCart(),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SLIVER APP BAR
  // ══════════════════════════════════════════════════════════
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 130,
      backgroundColor: const Color(0xFF0077B6),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF06D6A0)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'e-Pasar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Belanja segar, langsung dari pasar 🌿',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Get.to(() => const PasarListView());
                    },
                    icon: const Icon(Icons.location_on_outlined,
                        color: Colors.white, size: 24),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          color: const Color(0xFF0077B6),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: _buildSearchBar(),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onSubmitted: (value) => controller.fetchProduk(search: value),
        decoration: InputDecoration(
          hintText: 'Cari produk segar...',
          hintStyle:
              const TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              color: Color(0xFF00B4D8), size: 20),
          suffixIcon: IconButton(
            icon: const Icon(Icons.tune_rounded,
                color: Color(0xFF0077B6), size: 18),
            onPressed: () {},
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // BANNER PROMO
  // ══════════════════════════════════════════════════════════
  Widget _buildBannerPromo() {
    final List<Map<String, dynamic>> banners = [
      {
        'title': 'Sayur Segar\nLangsung dari Kebun',
        'subtitle': 'Diskon s/d 30%',
        'icon': Icons.eco_rounded,
        'gradient': [const Color(0xFF06D6A0), const Color(0xFF0077B6)],
      },
      {
        'title': 'Gratis Ongkir\nPembelian Pertama',
        'subtitle': 'Min. belanja Rp25.000',
        'icon': Icons.local_shipping_rounded,
        'gradient': [const Color(0xFF00B4D8), const Color(0xFF06D6A0)],
      },
      {
        'title': 'Promo Pagi\nHarga Spesial Buah',
        'subtitle': 'Berlaku 06:00 - 10:00',
        'icon': Icons.wb_sunny_rounded,
        'gradient': [const Color(0xFF38B000), const Color(0xFF00B4D8)],
      },
    ];

    return SizedBox(
      height: 150,
      child: PageView.builder(
        controller: _pageController,
        itemCount: banners.length,
        itemBuilder: (_, i) {
          final b = banners[i];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: (b['gradient'] as List<Color>),
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (b['gradient'] as List<Color>)[0].withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 10,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(b['icon'] as IconData,
                        color: Colors.white, size: 36),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        b['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          b['subtitle'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SECTION HEADER
  // ══════════════════════════════════════════════════════════
  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
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
              fontSize: 16,
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
  // KATEGORI GRID
  // ══════════════════════════════════════════════════════════
  Widget _buildKategoriGrid() {
    return Obx(() {
      if (controller.isLoading.value && controller.kategoriList.isEmpty) {
        return const SizedBox(
          height: 90,
          child: Center(
              child: CircularProgressIndicator(color: Color(0xFF00B4D8))),
        );
      }

      final list = controller.kategoriList;
      final selectedId = controller.selectedKategoriId.value;

      return SizedBox(
        height: 92,
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
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(isSelected ? 0.4 : 0.1),
                      blurRadius: isSelected ? 10 : 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: isSelected ? color : color.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _iconForKategori(kat.namaKategori),
                      color: isSelected ? Colors.white : color,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      kat.namaKategori ?? '-',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF023E58),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ══════════════════════════════════════════════════════════
  // PRODUK GRID  — now passes context for modal
  // ══════════════════════════════════════════════════════════
  Widget _buildProdukGrid(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(color: Color(0xFF00B4D8)),
                  SizedBox(height: 12),
                  Text('Memuat produk...',
                      style: TextStyle(color: Color(0xFF6C757D))),
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
            (_, i) =>
                _buildProdukCard(context, controller.produkList[i]),
            childCount: controller.produkList.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
        ),
      );
    });
  }

  Widget _buildProdukCard(BuildContext context, DataProduk produk) {
    final imageUrl = produk.foto != null
        ? 'http://localhost:8000/storage/${produk.foto}'
        : null;

    return GestureDetector(
      onTap: () {
        // Get.toNamed('/produk-detail', arguments: produk);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0077B6).withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: const Color(0xFFE8F5F9),
                              child: const Center(
                                child: Icon(Icons.image_outlined,
                                    color: Color(0xFF90E0EF), size: 40),
                              ),
                            ),
                            errorWidget: (_, __, ___) =>
                                _produkPlaceholder(),
                          )
                        : _produkPlaceholder(),
                  ),
                  if ((produk.stok ?? 0) < 5)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Hampir habis',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produk.namaProduk ?? 'Produk',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
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
                    const Spacer(),
                    Text(
                      _formatRupiah(produk.harga ?? 0),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0077B6),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // ── Tombol + Keranjang → buka modal ──
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _showAddToCartModal(context, produk),
                        icon: const Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 14),
                        label: const Text(
                          '+ Keranjang',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0077B6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
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
      height: 140,
      color: const Color(0xFFE0F7FA),
      child: const Center(
        child: Icon(Icons.storefront_rounded,
            color: Color(0xFF90E0EF), size: 50),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // EMPTY & ERROR STATE
  // ══════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return SizedBox(
      height: 260,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0F7FA), Color(0xFFE8F5E9)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded,
                size: 44, color: Color(0xFF90E0EF)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Produk tidak ditemukan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF023E58),
            ),
          ),
          const SizedBox(height: 6),
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
      height: 260,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 56, color: Color(0xFFADB5BD)),
          const SizedBox(height: 12),
          const Text(
            'Gagal memuat produk',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF023E58),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: controller.fetchProduk,
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

  // ══════════════════════════════════════════════════════════
  // FLOATING CART
  // ══════════════════════════════════════════════════════════
  Widget _buildFloatingCart() {
    final keranjangCtrl = Get.find<KeranjangController>();

    return Positioned(
      bottom: 24,
      right: 20,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0077B6), Color(0xFF06D6A0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0077B6).withOpacity(0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
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
                        color: Colors.white, size: 26),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B6B),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            count > 99 ? '99+' : '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
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
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatRupiah(total),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
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
    // Ambil KeranjangController — pastikan sudah di-register di binding
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
                Get.back(); // tutup modal setelah berhasil
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          decoration: BoxDecoration(
            gradient: isLoading
                ? const LinearGradient(
                    colors: [Color(0xFFADB5BD), Color(0xFFADB5BD)])
                : const LinearGradient(
                    colors: [Color(0xFF0077B6), Color(0xFF06D6A0)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isLoading
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF0077B6).withOpacity(0.35),
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
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_checkout_rounded,
                          color: Colors.white, size: 16),
                      SizedBox(width: 6),
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