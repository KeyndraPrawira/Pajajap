import 'package:flutter/material.dart';
import 'package:e_pasar/app/data/models/kategori_model.dart';
import 'package:e_pasar/app/data/models/produk_model.dart';
import 'package:e_pasar/app/services/kategori_services.dart';
import 'package:e_pasar/app/services/produk_services.dart';
import 'package:get/get.dart';

class UserProdukController extends GetxController {
  final ProdukService _service = ProdukService();
  final KategoriService _katService = KategoriService();

  // ── Observables ────────────────────────────────────────────
  var produkList = <DataProduk>[].obs;
  var kategoriList = <Datum>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Filter state
  var selectedKategoriId = Rxn<int>(); // null = semua kategori

  // Cart (list of DataProduk)
  var cartItems = <DataProduk>[].obs;

  // Derived: jumlah total item di keranjang - gunakan worker/getter biasa
  int get cartCount => cartItems.length;

  @override
  void onInit() {
    super.onInit();
    fetchProduk();
    fetchKategori();
  }

  // ── Fetch Kategori ─────────────────────────────────────────
  Future<void> fetchKategori() async {
    try {
      final response = await _katService.getKategori();
      if (response?.data != null) {
        kategoriList.assignAll(response!.data!);
      }
    } catch (e) {
      print("Error fetch kategori: $e");
    }
  }

  // ── Fetch Produk (dengan filter opsional) ──────────────────
  Future<void> fetchProduk({int? kategoriId, String? search}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _service.getProduk(
        kategoriId: kategoriId ?? selectedKategoriId.value,
        search: search,
      );

      if (result != null && result.data != null) {
        produkList.value = result.data!;
      } else {
        produkList.clear();
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
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

  // ── Cart Operations ────────────────────────────────────────
  void addToCart(DataProduk produk) {
    cartItems.add(produk);
    Get.snackbar(
      '🛒 Ditambahkan!',
      '${produk.namaProduk} masuk ke keranjang',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0077B6).withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
    );
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems.removeAt(index);
    }
  }

  void clearCart() => cartItems.clear();
}