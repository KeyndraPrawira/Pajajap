import 'package:e_pasar/app/data/models/produk_model.dart';
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/utils/api.dart';
import 'package:e_pasar/pages/pedagang/controllers/produk_controller.dart';
import 'package:e_pasar/pages/pedagang/views/widgets/pedagang_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProdukListView extends GetView<ProdukController> {
  const ProdukListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Memastikan data di-refresh setiap kali halaman ini dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchProduk();
    });

    return Scaffold(
      backgroundColor: PedagangUi.pageBackground,
      appBar: AppBar(
        title: const Text(
          "Produk Saya",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
        backgroundColor: PedagangUi.darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'pedagang_produk_list_add',
        onPressed: () {
          Get.toNamed(Routes.PRODUK_ADD)?.then((_) => controller.fetchProduk());
        },
        icon: const Icon(Icons.add),
        label: const Text("Tambah Produk"),
        backgroundColor: PedagangUi.midGreen,
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (val) => controller.searchQuery.value = val,
              decoration: InputDecoration(
                hintText: "Cari produk...",
                hintStyle: const TextStyle(color: PedagangUi.textSubtle),
                prefixIcon:
                    const Icon(Icons.search, color: PedagangUi.darkGreen),
                filled: true,
                fillColor: PedagangUi.inputFill,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Jumlah Produk ───────────────────────────────────
          Obx(() => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      "${controller.produkList.length} Produk",
                      style: TextStyle(
                        fontSize: 13,
                        color: PedagangUi.textSubtle,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),

          // ── List ────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.produkList.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: PedagangUi.midGreen),
                );
              }

              if (controller.produkList.isEmpty) {
                return _EmptyState(onRefresh: () => controller.fetchProduk());
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchProduk(),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: controller.produkList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final produk = controller.produkList[index];
                    return _ProdukTile(
                      produk: produk,
                      controller: controller,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ProdukTile extends StatelessWidget {
  final DataProduk produk;
  final ProdukController controller;

  const _ProdukTile({required this.produk, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Jika pakai emulator Android, gunakan 10.0.2.2. Jika HP fisik, gunakan IP Laptop kamu.
    final fotoUrl = produk.foto != null
        ? "${Api.baseImageUrl}${produk.foto}"
        : null;

    final stokHabis = (produk.stok ?? 0) <= 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Get.toNamed('/pedagang/produk/edit/${produk.id}', arguments: produk)
              ?.then((_) => controller.fetchProduk());
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: fotoUrl != null
                    ? Image.network(
                        fotoUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _FotoPlaceholder(),
                      )
                    : _FotoPlaceholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            produk.namaProduk ?? '-',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: PedagangUi.textMain,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (stokHabis)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              "Habis",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(produk.harga),
                      style: const TextStyle(
                        color: PedagangUi.darkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 12, color: PedagangUi.textSubtle),
                        const SizedBox(width: 4),
                        Text(
                          "Stok: ${produk.stok ?? 0}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: PedagangUi.textSubtle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.scale_outlined,
                            size: 12, color: PedagangUi.textSubtle),
                        const SizedBox(width: 4),
                        Text(
                          "${produk.beratSatuan ?? 0} g",
                          style: const TextStyle(
                            fontSize: 12,
                            color: PedagangUi.textSubtle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      Get.toNamed('/pedagang/produk/edit/${produk.id}',
                              arguments: produk)
                          ?.then((_) => controller.fetchProduk());
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: PedagangUi.darkGreen,
                    style: IconButton.styleFrom(
                      backgroundColor: PedagangUi.lightGreen.withOpacity(0.18),
                      minimumSize: const Size(34, 34),
                    ),
                  ),
                  const SizedBox(height: 6),
                  IconButton(
                    onPressed: () async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Text('Hapus Produk'),
        ],
      ),
      content: Text(
        'Anda yakin ingin menghapus "${produk.namaProduk ?? 'produk ini'}"?',
        style: const TextStyle(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(
            'Batal',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );

  if (confirm == true) {
    controller.deleteProduk(produk.id!);
  }
},
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: Colors.red.shade600,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      minimumSize: const Size(34, 34),
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

  String _formatRupiah(int? nominal) {
    if (nominal == null) return 'Rp 0';
    final formatted = nominal.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp $formatted';
  }
}

class _FotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 28),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_mall_directory_outlined,
              size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Belum ada produk",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text("Coba Muat Ulang"),
            style: ElevatedButton.styleFrom(
              backgroundColor: PedagangUi.midGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
