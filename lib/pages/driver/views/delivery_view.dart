import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/delivery_controller.dart';

class DeliveryView extends GetView<DeliveryController> {
  const DeliveryView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.setUserMode(false);

    return Scaffold(
      body: Column(
        children: [
          // AppBar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
                const Expanded(child: SizedBox()),
                const CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      NetworkImage('https://via.placeholder.com/80'),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final order = controller.orderData.value;
              if (order == null) {
                return const Center(child: Text('Order not found'));
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Buyer info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.kodePesanan ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Budi Santoso',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(order.alamatPengiriman ?? '')),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.straighten,
                                  color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              Text('${order.jarakKm ?? ''} km'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Products List
                    Text('Daftar Produk',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.orderDetails?.length ?? 0,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final detail = order.orderDetails![index];

                        return Obx(() {
                          final status = controller.itemStatus[detail.id] ??
                              detail.status ??
                              'pending';
                          final isLoading =
                              controller.loadingItems[detail.id] ?? false;

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: status == 'diambil'
                                  ? Colors.green.shade50
                                  : status == 'tidak_ada'
                                      ? Colors.red.shade50
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // IMAGE
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.image),
                                ),
                                const SizedBox(width: 12),

                                // INFO
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        detail.produkId?.toString() ??
                                            'Produk ${index + 1}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        status == 'diambil'
                                            ? '✅ Sudah diambil'
                                            : status == 'tidak_ada'
                                                ? '❌ Tidak ada'
                                                : 'Menunggu konfirmasi',
                                        style: TextStyle(
                                          color: status == 'diambil'
                                              ? Colors.green
                                              : status == 'tidak_ada'
                                                  ? Colors.red
                                                  : Colors.orange,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                          '${detail.jumlah ?? 0}x · Rp ${detail.hargaSatuan ?? 0}'),
                                    ],
                                  ),
                                ),

                                // ACTIONS
                                if (isLoading)
                                  const SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5),
                                    ),
                                  )
                                else if (status == 'pending')
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // ✅ Tombol diambil
                                      IconButton(
                                        icon: const Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.green),
                                        onPressed: () async {
                                          if (detail.id == null) return;
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              title: const Text(
                                                'Konfirmasi Ambil Pesanan',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              content: const Text(
                                                'Apakah kamu sudah mengambil pesanan ini?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(ctx)
                                                          .pop(false),
                                                  child: const Text(
                                                    'Belum',
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.of(ctx)
                                                          .pop(true),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green,
                                                    foregroundColor:
                                                        Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                  child: const Text('Ya'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            controller.updateItemStatus(
                                                detail.id!, 'diambil');
                                          }
                                        },
                                      ),

                                      // ❌ Tombol tidak ada — satu dialog dengan TextField
                                      IconButton(
                                        icon: const Icon(Icons.cancel_outlined,
                                            color: Colors.red),
                                        onPressed: () async {
                                          if (detail.id == null) return;
                                          await _showTidakAdaDialog(
                                              context, detail.id!);
                                        },
                                      ),
                                    ],
                                  )
                                else if (status == 'diambil')
                                  const Icon(Icons.check_circle,
                                      color: Colors.green, size: 32)
                                else if (status == 'tidak_ada')
                                  const Icon(Icons.cancel,
                                      color: Colors.red, size: 32),
                              ],
                            ),
                          );
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
          ),

          // Bottom Total
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF4CAF50)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Belanja',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    Obx(() => Text(
                          'Rp ${controller.orderData.value?.totalHargaBarang?.toString() ?? '0'}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ongkir',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    Obx(() => Text(
                          'Rp ${controller.orderData.value?.ongkir?.toString() ?? '0'}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    Obx(() => Text(
                          'Rp ${controller.orderData.value?.totalHarga?.toString() ?? '0'}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ElevatedButton(
                    onPressed: controller.sendDelivery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text(
                      'Kirim Pesanan',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E88E5)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog konfirmasi + input alasan untuk status 'tidak_ada'
  Future<void> _showTidakAdaDialog(BuildContext context, int detailId) async {
    final alasanController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Produk Tidak Ada',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Masukkan alasan produk tidak tersedia:'),
            const SizedBox(height: 12),
            TextField(
              controller: alasanController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: stok habis, lapak tutup, dll.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final alasan = alasanController.text.trim();
      controller.updateItemStatus(
        detailId,
        'tidak_ada',
        catatan: alasan.isEmpty ? null : alasan,
      );
    }

    alasanController.dispose();
  }
}
