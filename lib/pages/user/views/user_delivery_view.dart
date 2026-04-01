import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_pasar/pages/driver/controllers/delivery_controller.dart';
import 'package:e_pasar/app/routes/app_pages.dart';

class UserDeliveryView extends GetView<DeliveryController> {
  const UserDeliveryView({super.key});

  @override
  Widget build(BuildContext context) {
    // Force user mode
    controller.isUserMode.value = true;
    
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
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Get.offAllNamed(AppRoutes.USER_HOME),
                ),
                const Expanded(child: SizedBox()),
                const CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      NetworkImage('https://via.placeholder.com/80'),
                  child: Icon(Icons.person),
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
                return const Center(child: Text('Order tidak ditemukan'));
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
                        color: Colors.green.shade50,
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
                            'Status: Driver sudah diterima',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                  child:
                                      Text(order.alamatPengiriman ?? '')),
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

                    // Products List - READ ONLY untuk USER
                    Text('Daftar Produk',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.orderDetails?.length ?? 0,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final detail = order.orderDetails![index];
                        final status = controller.itemStatus[detail.id] ?? 
                                      detail.status ?? 'pending';

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
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
                              const SizedBox(width: 16),

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
                                      _getStatusText(status),
                                      style: TextStyle(
                                        color: _getStatusColor(status)
                                            .computeLuminance() > 0.5 
                                            ? Colors.black87 
                                            : Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                        '${detail.jumlah ?? 0}x · Rp ${detail.hargaSatuan ?? 0}'),
                                  ],
                                ),
                              ),

                              // USER MODE: No action buttons - hanya status icon
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  _getStatusIcon(status),
                                  color: Colors.grey[700],
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ),

          // Bottom Total - User mode
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
                    const Text('Ongkir',
                        style:
                            TextStyle(color: Colors.white, fontSize: 16)),
                    Obx(() => Text(
                          'Rp ${controller.orderData.value?.ongkir?.toStringAsFixed(0) ?? '0'}',
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
                          'Rp ${controller.orderData.value?.totalHarga?.toStringAsFixed(0) ?? '0'}',
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
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // User: Lacak pengiriman atau refresh
                      Get.snackbar(
                        'Tracking',
                        'Fitur tracking akan segera hadir!',
                        backgroundColor: Colors.amber,
                        colorText: Colors.black87,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text(
                      'Lacak Pengiriman',
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

  Color _getStatusColor(String status) {
    return switch (status) {
      'diambil' => Colors.green.shade100,
      'tidak_ada' => Colors.red.shade100,
      'dikirim' => Colors.blue.shade100,
      _ => Colors.grey.shade100,
    };
  }

  String _getStatusText(String status) {
    return switch (status) {
      'diambil' => '✅ Sudah diambil driver',
      'tidak_ada' => '❌ Tidak tersedia',
      'dikirim' => '🚚 Sedang dikirim',
      _ => '⏳ Menunggu',
    };
  }

  IconData _getStatusIcon(String status) {
    return switch (status) {
      'diambil' => Icons.check_circle,
      'tidak_ada' => Icons.cancel,
      'dikirim' => Icons.local_shipping,
      _ => Icons.hourglass_empty,
    };
  }
}
