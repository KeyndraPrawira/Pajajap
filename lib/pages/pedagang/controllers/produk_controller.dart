import 'package:e_pasar/app/data/models/produk_model.dart';
import 'package:e_pasar/app/data/models/kategori_model.dart'; // Import model kategori
import 'package:e_pasar/app/services/produk_services.dart';
import 'package:e_pasar/app/services/kategori_services.dart'; // Asumsi nama servicenya ini

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProdukController extends GetxController {
  final ProdukService _service = ProdukService();
  final KategoriService _katService =
      KategoriService(); // Inisialisasi service kategori

  // ── State ──────────────────────────────────────────────────
  final RxList<DataProduk> produkList = <DataProduk>[].obs;
  final RxList<Datum> kategoriList =
      <Datum>[].obs; // List untuk menampung kategori
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString searchQuery = ''.obs;
  var selectedKategoriId = Rxn<int>(); // null = semua kategori

  @override
  void onInit() {
    super.onInit();
    fetchKategori();
    fetchProduk();
  }

  // ── Methods ────────────────────────────────────────────────

  Future<void> fetchKategori() async {
    try {
      // Ganti dengan method yang sesuai di KategoriService kamu
      final response = await _katService.getKategori();
      if (response?.data != null) {
        kategoriList.assignAll(response!.data!);
      }
    } catch (e) {
      print("Error fetch kategori: $e");
    }
  }

  Future<void> fetchProduk({int? kategoriId, String? search}) async {
    try {
      isLoading(true);
      final response = await _service.getProduk();
      if (response?.data != null) {
        produkList.assignAll(response!.data!);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  // ── Filter by Kategori ─────────────────────────────────────
  void filterByKategori(int? id) {
    // toggle: tap lagi → reset ke semua
    if (selectedKategoriId.value == id) {
      selectedKategoriId.value = null;
      fetchProduk();
    } else {
      selectedKategoriId.value = id;
      fetchProduk(kategoriId: id);
    }
  }

  // ... Method submitCreate, submitUpdate, deleteProduk tetap sama seperti sebelumnya ...
  // Pastikan parameter beratSatuan di submitCreate diubah menjadi int.parse jika di service minta int

  Future<void> deleteProduk(int id) async {
    try {
      isLoading(true);
      await _service.deleteProduk(id);
      fetchProduk();
      Get.snackbar("Berhasil", "Produk dihapus");
    } catch (e) {
      Get.snackbar("Gagal", e.toString());
    } finally {
      isLoading(false);
    }
  }
}
