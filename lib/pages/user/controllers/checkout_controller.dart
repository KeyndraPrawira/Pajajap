// lib/pages/user/controllers/checkout_controller.dart

import 'package:e_pasar/app/data/models/keranjang_model.dart';
import 'package:e_pasar/app/data/models/pasar_model.dart';
import 'package:e_pasar/app/data/models/profile_model.dart';
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/order_services.dart';
import 'package:e_pasar/pages/user/controllers/pasar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckoutController extends GetxController {
  final OrderService _orderService = OrderService();

  // ─── State ───────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxString metodePembayaran = 'cod'.obs;

  // Data dari arguments
  late List<DataKeranjang> keranjangList;
  late Alamat alamat;
  late DataPasar pasar;

  // Batas berat gratis hardcode sama dengan backend
  static const double _batasBeratGratis = 10.0;

  // ─── Computed — Berat ────────────────────────────────────
  double get totalBerat => keranjangList.fold(0.0, (sum, item) {
        final berat = item.produk?.berat_satuan ?? 0.0;
        final jumlah = int.tryParse(item.jumlah ?? '0') ?? 0;
        return sum + (berat / 1000 * jumlah);
      });

  bool get tampilkanBiayaBerat => totalBerat > _batasBeratGratis;

  // ─── Computed — Biaya ────────────────────────────────────
  int get subtotalProduk =>
      keranjangList.fold(0, (sum, item) => sum + (item.hargaTotal ?? 0));

  int get biayaJarak {
    final jarak = alamat.jarakKm ?? 0.0;
    final perKm = pasar.ongkir ?? 0;
    if (jarak <= 1) return 0;
    final sisaKm = jarak - 1;
    return (sisaKm * perKm).ceil();
  }

  int get biayaLayanan => pasar.biayaLayanan ?? 0;

  int get biayaBerat {
    if (!tampilkanBiayaBerat) return 0;
    final beratKena = totalBerat - _batasBeratGratis;
    return (beratKena.ceil() * (pasar.biayaBeratBarang ?? 0)).toInt();
  }

  int get ongkir =>
      (pasar.minimalOngkir ?? 0) + biayaJarak + biayaLayanan + biayaBerat;

  int get totalBayar => subtotalProduk + ongkir;

  // ─── Lifecycle ───────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;
    if (args == null) {
      Get.back();
      Get.snackbar('Error', 'Data checkout tidak ditemukan',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    keranjangList = args['keranjang'] as List<DataKeranjang>;
    alamat = args['alamat'] as Alamat;

    // Ambil dari PasarController yang sudah di-fetch sebelumnya
    final pasarC = Get.find<PasarController>();
    if (pasarC.pasarList.isEmpty) {
      Get.back();
      Get.snackbar('Error', 'Data pasar tidak ditemukan',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    pasar = pasarC.pasarList.first;
  }

  // ─── Metode Pembayaran ────────────────────────────────────
  void pilihMetodePembayaran(String metode) {
    metodePembayaran.value = metode;
  }

  // ─── Format Rupiah ────────────────────────────────────────
  String formatRupiah(int value) {
    final s = value.toString();
    final buffer = StringBuffer('Rp');
    final offset = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

// ─── prosesCheckout() ─────────────────────────────────────
  void prosesCheckout() {
    Get.back(); // Tutup dialog
    checkout(); // Jalankan checkout asli
  }

  // ─── CHECKOUT ─────────────────────────────────────────────
  Future<void> checkout() async {
    try {
      isLoading.value = true;
      final result = await _orderService.checkout(metodePembayaran.value);
      if (result['success'] == true) {
        final orderData = result['data'] as Map<String, dynamic>? ?? {};
        final orderId = orderData['id'] as int?;
        final kodePesanan = orderData['kode_pesanan']?.toString() ?? '';

        Get.snackbar(
          'Berhasil!',
          'Order berhasil dibuat',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        await Future.delayed(const Duration(seconds: 1));

        if (orderId == null) {
          throw Exception('ID order tidak ditemukan');
        }

        Get.offNamed(
          AppRoutes.MENCARI_DRIVER,
          arguments: {
            'order_id': orderId,
            'kode_pesanan': kodePesanan,
          },
        );
      }
    } catch (e) {
      String pesan = e.toString().replaceAll('Exception: ', '');
      if (pesan.contains('Keranjang kosong'))
        pesan = 'Keranjang kamu sudah kosong';
      if (pesan.contains('Alamat'))
        pesan = 'Silakan set alamat terlebih dahulu';
      Get.snackbar('Gagal', pesan,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }
}
