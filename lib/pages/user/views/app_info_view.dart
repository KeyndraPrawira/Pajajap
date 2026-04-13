// lib/pages/user/views/pasar_list_view.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_pasar/pages/user/controllers/pasar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppInfoView extends StatelessWidget {
  const AppInfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PasarController controller = Get.find<PasarController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Pasar'),
        backgroundColor: const Color(0xFF0077B6),
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.pasarList.isEmpty) {
          return const Center(
            child: Text('Tidak ada pasar tersedia'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.pasarList.length,
          itemBuilder: (context, index) {
            final pasar = controller.pasarList[index];
            final distance = controller.getDistanceToPasar(pasar);
            final formattedDistance = controller.getFormattedDistance(pasar);
            final estimatedTime = controller.getEstimatedTime(pasar);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  // TODO: Navigate to pasar detail or product list
                  Get.snackbar('Info', 'Navigasi ke pasar ${pasar.namaPasar}');
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Gambar pasar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: pasar.fotoPasar != null
                              ? CachedNetworkImage(
                                  imageUrl:
                                      'https://perseveringly-coxal-chandler.ngrok-free.dev/storage/${pasar.fotoPasar}',
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: const Color(0xFFE8F5F9),
                                    child: const Icon(
                                      Icons.storefront,
                                      color: Color(0xFF0077B6),
                                      size: 32,
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: const Color(0xFFE8F5F9),
                                    child: const Icon(
                                      Icons.storefront,
                                      color: Color(0xFF0077B6),
                                      size: 32,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: const Color(0xFFE8F5F9),
                                  child: const Icon(
                                    Icons.storefront,
                                    color: Color(0xFF0077B6),
                                    size: 32,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Info pasar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nama pasar
                            Text(
                              pasar.namaPasar ?? 'Nama Pasar',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF023E58),
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Alamat
                            Text(
                              pasar.alamat ?? 'Alamat tidak tersedia',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),

                            // Jarak dan estimasi waktu
                            if (controller.userLatitude.value != 0.0 &&
                                controller.userLongitude.value != 0.0)
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: const Color(0xFF0077B6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedDistance,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF0077B6),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    estimatedTime,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),

                            // Ongkir
                            if (pasar.ongkir != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Ongkir: Rp ${pasar.ongkir}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Icon panah
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
