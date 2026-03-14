import 'package:e_pasar/app/data/models/kios_model.dart';
import 'package:e_pasar/app/data/models/produk_model.dart';
import 'package:e_pasar/pages/pedagang/controllers/pedagang_controller.dart';
import 'package:e_pasar/pages/pedagang/controllers/produk_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PedagangHomeView extends GetView<PedagangController> {
  const PedagangHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color lightGreen = Color(0xFFE8F5E9);
    const Color accentGreen = Color(0xFF4CAF50);
    const Color scaffoldBg = Color(0xFFF1F8E9);
    
    final produkCtrl = Get.find<ProdukController>();

    return Scaffold(
      backgroundColor: scaffoldBg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/produk-add'),
        backgroundColor: primaryGreen,
        icon: const Icon(Icons.add_box, color: Colors.white),
        label: const Text("Tambah Produk", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: primaryGreen));
        }

        final kios = controller.myKios.value;
        if (kios == null) {
          return const Center(child: Text('Data Kios tidak ditemukan'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.refreshKios();
            await produkCtrl.fetchProduk();
          },
          color: primaryGreen,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- HEADER DASHBOARD ---
              _buildModernHeader(kios, primaryGreen),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- KARTU STATUS OPERASIONAL ---
                      _buildOperationalStatus(kios, primaryGreen, lightGreen),
                      
                      const SizedBox(height: 20),
                      
                      // --- RINGKASAN BISNIS (QUICK STATS) ---
                      const Text(
                        "Ringkasan Bisnis",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      _buildBusinessStats(produkCtrl, primaryGreen),
                      
                      const SizedBox(height: 24),
                      
                      // --- SECTION DAFTAR PRODUK ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Katalog Produk",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          TextButton(
                            onPressed: () => produkCtrl.fetchProduk(),
                            child: const Text("Refresh", style: TextStyle(color: primaryGreen)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // --- GRID PRODUK ---
              _buildProductGrid(produkCtrl, primaryGreen),

              // --- FOOTER / LOGOUT ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Divider(),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => controller.logout(),
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text("Keluar dari Dashboard", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.red)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 80), // Space for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildModernHeader(DataKios kios, Color primaryColor) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dashboard Pedagang", style: TextStyle(fontSize: 10, color: Colors.white70, letterSpacing: 1.5)),
            Text(
              kios.namaKios ?? 'Kios Saya',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            kios.fotoKios != null
                ? Image.network(
                    'http://localhost:8000/storage/${kios.fotoKios}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: primaryColor),
                  )
                : Container(color: primaryColor),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationalStatus(DataKios kios, Color primary, Color light) {
    final isOpen = _isStoreOpen(kios.jamBuka, kios.jamTutup);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: primary.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isOpen ? light : Colors.red.shade50,
            child: Icon(Icons.store, color: isOpen ? primary : Colors.red),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpen ? "Toko Sedang Beroperasi" : "Toko Sedang Tutup",
                  style: TextStyle(fontWeight: FontWeight.bold, color: isOpen ? primary : Colors.red),
                ),
                Text(
                  "Jam Kerja: ${kios.jamBuka ?? '00:00'} - ${kios.jamTutup ?? '00:00'}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.settings_outlined, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildBusinessStats(ProdukController produkCtrl, Color primary) {
    return Row(
      children: [
        _statCard("Total Produk", produkCtrl.produkList.length.toString(), Icons.inventory_2, Colors.blue),
        const SizedBox(width: 12),
        _statCard("Poin Kios", "1,250", Icons.stars, Colors.orange),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(ProdukController produkCtrl, Color primaryColor) {
    return Obx(() {
      if (produkCtrl.isLoading.value) {
        return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())));
      }
      if (produkCtrl.produkList.isEmpty) {
        return const SliverToBoxAdapter(
          child: Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Belum ada produk di katalog"))),
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final p = produkCtrl.produkList[index];
              return _buildDashboardProductCard(p, primaryColor);
            },
            childCount: produkCtrl.produkList.length,
          ),
        ),
      );
    });
  }

  Widget _buildDashboardProductCard(DataProduk p, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: p.foto != null
                      ? Image.network(
                          "http://localhost:8000/storage/${p.foto}",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey[100], child: const Icon(Icons.broken_image)),
                        )
                      : Container(color: Colors.grey[50], child: const Icon(Icons.image_outlined, color: Colors.grey)),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                    child: Text("Stok: ${p.stok}", style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.namaProduk ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(p.harga ?? 0),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.edit_note, size: 18, color: color.withOpacity(0.7)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isStoreOpen(String? buka, String? tutup) {
    if (buka == null || tutup == null) return false;
    try {
      final now = DateTime.now();
      final format = DateFormat("HH:mm");
      final openTime = format.parse(buka);
      final closeTime = format.parse(tutup);
      final currentTime = format.parse("${now.hour}:${now.minute}");
      if (closeTime.isBefore(openTime)) {
        return currentTime.isAfter(openTime) || currentTime.isBefore(closeTime);
      }
      return currentTime.isAfter(openTime) && currentTime.isBefore(closeTime);
    } catch (e) {
      return false;
    }
  }
}