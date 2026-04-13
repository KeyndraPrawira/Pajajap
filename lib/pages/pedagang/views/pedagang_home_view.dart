import 'package:e_pasar/app/data/models/kios_model.dart';
import 'package:e_pasar/app/data/models/kategori_model.dart' as kategori_model;
import 'package:e_pasar/app/data/models/produk_model.dart';
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/utils/api.dart';
import 'package:e_pasar/pages/pedagang/controllers/pedagang_controller.dart';
import 'package:e_pasar/pages/pedagang/controllers/produk_controller.dart';
import 'package:e_pasar/pages/pedagang/views/kios_edit_view.dart';
import 'package:e_pasar/pages/user/views/detail_produk_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PedagangHomeView extends GetView<PedagangController> {
  const PedagangHomeView({super.key});

  static const Color _darkGreen = Color(0xFF0B5D38);
  static const Color _midGreen = Color(0xFF1E8B4B);
  static const Color _lightGreen = Color(0xFF8BCF73);
  static const Color _bgColor = Color(0xFFF4F8F2);
  static const Color _textMain = Color(0xFF1D2B1F);
  static const Color _textSub = Color(0xFF6B7B69);
  static const List<Color> _chartColors = [
    Color(0xFF0B5D38),
    Color(0xFF1E8B4B),
    Color(0xFF55A45C),
    Color(0xFF8BCF73),
    Color(0xFFB7DF9A),
  ];

  @override
  Widget build(BuildContext context) {
    final produkCtrl = Get.find<ProdukController>();

    return Scaffold(
      backgroundColor: _bgColor,
      floatingActionButton: FloatingActionButton(
        heroTag: 'pedagang_home_add_produk',
        onPressed: () => Get.toNamed(Routes.PRODUK_ADD),
        backgroundColor: _midGreen,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 3, color: _midGreen),
          );
        }

        final kios = controller.myKios.value;
        if (kios == null)
          return const Center(child: Text('Data Kios Tidak Tersedia'));

        return RefreshIndicator(
          onRefresh: () async {
            await controller.refreshKios();
            await produkCtrl.fetchKategori();
            await produkCtrl.fetchProduk();
          },
          edgeOffset: 100,
          color: _midGreen,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildModernAppBar(kios),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusCard(kios),
                      const SizedBox(height: 24),
                      _sectionHeader("Ringkasan Bisnis"),
                      const SizedBox(height: 12),
                      _buildStatsCard(produkCtrl),
                      const SizedBox(height: 16),
                      _buildCategoryChartCard(produkCtrl),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionHeader("Katalog Produk"),
                          GestureDetector(
                            onTap: () => produkCtrl.fetchProduk(),
                            child: const Text(
                              "Muat Ulang",
                              style: TextStyle(
                                color: _midGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              _buildProductGrid(produkCtrl),
            ],
          ),
        );
      }),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: _textMain,
      ),
    );
  }

  Widget _buildModernAppBar(DataKios kios) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: _darkGreen,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            kios.fotoKios != null
                ? Image.network(
                    '${Api.baseImageUrl}${kios.fotoKios}',
                    fit: BoxFit.cover,
                  )
                : Container(color: _darkGreen),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xCC0B5D38),
                    Color(0xB31E8B4B),
                    Color(0xA68BCF73),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 22,
              child: SafeArea(
                top: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kios.namaKios ?? 'Kios Saya',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            kios.lokasi ?? 'Lokasi belum tersedia',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Get.to(() => const KiosEditView())
                              ?.then((_) => controller.refreshKios());
                        },
                        child: Ink(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                            size: 20,
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

  Widget _buildStatusCard(DataKios kios) {
    final isOpen = _isStoreOpen(kios.jamBuka, kios.jamTutup);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_darkGreen, _midGreen, _lightGreen],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _midGreen.withOpacity(0.16),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOpen
                  ? Icons.storefront_rounded
                  : Icons.store_mall_directory_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpen ? "Toko Beroperasi" : "Toko Tutup",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Jam Operasional: ${_formatJam(kios.jamBuka)} - ${_formatJam(kios.jamTutup)}",
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              isOpen ? "Aktif" : "Offline",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(ProdukController ctrl) {
    return Obx(() {
      final totalProduk = ctrl.produkList.length;
      final totalStok = ctrl.produkList.fold<int>(
        0,
        (sum, item) => sum + (item.stok ?? 0),
      );

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _midGreen.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: _darkGreen.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _statInfo(
                title: "Produk Aktif",
                value: totalProduk.toString(),
                icon: Icons.inventory_2_outlined,
                color: _midGreen,
              ),
            ),
            Container(width: 1, height: 48, color: _midGreen.withOpacity(0.12)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: _statInfo(
                  title: "Total Stok",
                  value: totalStok.toString(),
                  icon: Icons.layers_outlined,
                  color: _lightGreen,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _statInfo({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textMain,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: _textSub,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChartCard(ProdukController ctrl) {
    return Obx(() {
      if (ctrl.isLoading.value && ctrl.produkList.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: _midGreen),
          ),
        );
      }

      final segments = _buildCategorySegments(ctrl);
      if (segments.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _midGreen.withOpacity(0.08)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Distribusi Kategori",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _textMain,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Belum ada produk untuk dihitung per kategori.",
                style: TextStyle(fontSize: 12, color: _textSub),
              ),
            ],
          ),
        );
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _midGreen.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: _darkGreen.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Distribusi Kategori",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _textMain,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Persentase barang berdasarkan jumlah produk di tiap kategori.",
              style: TextStyle(fontSize: 12, color: _textSub),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 210,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 42,
                        sectionsSpace: 3,
                        borderData: FlBorderData(show: false),
                        sections: segments
                            .map(
                              (segment) => PieChartSectionData(
                                color: segment.color,
                                value: segment.value.toDouble(),
                                radius: 52,
                                title:
                                    '${segment.percentage.toStringAsFixed(0)}%',
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: segments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final segment = segments[index];
                        return Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: segment.color,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    segment.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _textMain,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${segment.value} barang • ${segment.percentage.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: _textSub,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  List<_CategorySegment> _buildCategorySegments(ProdukController ctrl) {
    if (ctrl.produkList.isEmpty) return const [];

    final total = ctrl.produkList.length;
    final grouped = <int?, int>{};

    for (final produk in ctrl.produkList) {
      grouped.update(produk.kategoriId, (value) => value + 1,
          ifAbsent: () => 1);
    }

    final entries = grouped.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return List.generate(entries.length, (index) {
      final entry = entries[index];
      final kategori = _findKategori(ctrl.kategoriList, entry.key);
      final percentage = total == 0 ? 0.0 : (entry.value / total) * 100;

      return _CategorySegment(
        label: kategori?.namaKategori ?? 'Kategori ${entry.key ?? '-'}',
        value: entry.value,
        percentage: percentage,
        color: _chartColors[index % _chartColors.length],
      );
    });
  }

  kategori_model.Datum? _findKategori(
    List<kategori_model.Datum> kategoriList,
    int? kategoriId,
  ) {
    for (final item in kategoriList) {
      if (item.id == kategoriId) {
        return item;
      }
    }
    return null;
  }

  Widget _buildProductGrid(ProdukController ctrl) {
    return Obx(() {
      if (ctrl.isLoading.value && ctrl.produkList.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: _midGreen),
            ),
          ),
        );
      }

      if (ctrl.produkList.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                "Belum ada produk",
                style: TextStyle(color: _textSub),
              ),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) => _productCard(ctrl.produkList[i]),
            childCount: ctrl.produkList.length,
          ),
        ),
      );
    });
  }

  Widget _productCard(DataProduk p) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withOpacity(0.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(() => const DetailProdukView(), arguments: p),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: p.foto != null
                          ? Image.network("${Api.baseImageUrl}${p.foto}",
                              fit: BoxFit.cover)
                          : Container(color: Colors.grey[100]),
                    ),
                    if (p.stok != null && p.stok! <= 5)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4)),
                          child: const Text("Stok Tipis",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.namaProduk ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.2,
                          color: _textMain,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 6),
                    Text(
                      NumberFormat.currency(
                              locale: 'id', symbol: 'Rp', decimalDigits: 0)
                          .format(p.harga ?? 0),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: _darkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 12,
                          color: _textSub,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Stok: ${p.stok ?? 0}",
                          style: const TextStyle(color: _textSub, fontSize: 11),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: _textSub,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Logic isStoreOpen tetap sama ---
  bool _isStoreOpen(String? buka, String? tutup) {
    if (buka == null || tutup == null) return false;
    try {
      final now = DateTime.now();
      final format = DateFormat("HH:mm");
      final openTime = format.parse(_formatJam(buka));
      final closeTime = format.parse(_formatJam(tutup));
      final currentTime = format.parse("${now.hour}:${now.minute}");
      if (closeTime.isBefore(openTime)) {
        return currentTime.isAfter(openTime) || currentTime.isBefore(closeTime);
      }
      return currentTime.isAfter(openTime) && currentTime.isBefore(closeTime);
    } catch (e) {
      return false;
    }
  }

  String _formatJam(String? jam) {
    if (jam == null || jam.isEmpty) return '-';
    return jam.length >= 5 ? jam.substring(0, 5) : jam;
  }
}

class _CategorySegment {
  final String label;
  final int value;
  final double percentage;
  final Color color;

  const _CategorySegment({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
  });
}
