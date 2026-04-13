import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_pasar/app/data/models/produk_model.dart';
import 'package:e_pasar/app/data/models/kategori_model.dart';
import 'package:e_pasar/app/services/produk_services.dart';
import 'package:e_pasar/app/services/kategori_services.dart';
import 'package:e_pasar/pages/pedagang/controllers/produk_controller.dart';

class ProdukFormController extends GetxController {
  final ProdukService _service = ProdukService();
  final KategoriService _katService = KategoriService();

  final formKey = GlobalKey<FormState>();

  // Input Controllers
  final namaProdukC = TextEditingController();
  final hargaC = TextEditingController();
  final stokC = TextEditingController();
  final beratSatuanC = TextEditingController();
  final deskripsiC = TextEditingController();

  // Observables
  final RxList<Datum> kategoriList = <Datum>[].obs;
  final RxnInt selectedKategoriId = RxnInt();
  final selectedFotoBytes = Rxn<Uint8List>();
  final RxnString selectedFotoName = RxnString();
  final RxBool isSubmitting = false.obs;
  final RxBool isLoadingKategori = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Gunakan onReady atau sedikit delay untuk memastikan controller sudah siap
    fetchKategori();
  }

  Future<void> fetchKategori() async {
    try {
      isLoadingKategori(true);
      print("Memulai proses fetch kategori..."); // Debug Log

      final response = await _katService.getKategori();

      if (response != null && response.data != null) {
        kategoriList.assignAll(response.data!);
        print(
            "Berhasil mengambil ${kategoriList.length} kategori"); // Debug Log

        // Cek isi data pertama jika ada
        if (kategoriList.isNotEmpty) {
          print("Contoh kategori pertama: ${kategoriList[0].namaKategori}");
        }
      } else {
        print("Response kategori kosong atau null"); // Debug Log
      }
    } catch (e) {
      print("Terjadi error saat fetch kategori: $e"); // Debug Log
      Get.snackbar(
          "Error Kategori", "Gagal memuat daftar kategori: ${e.toString()}",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingKategori(false);
      // Memaksa UI untuk refresh jika perlu
      kategoriList.refresh();
    }
  }

  void fillFormForEdit(DataProduk produk) {
    namaProdukC.text = produk.namaProduk ?? '';
    hargaC.text = produk.harga?.toString() ?? '';
    stokC.text = produk.stok?.toString() ?? '';
    beratSatuanC.text = produk.beratSatuan?.toString() ?? '';
    deskripsiC.text = produk.deskripsi ?? '';
    selectedKategoriId.value = produk.kategoriId;
  }

  void clearForm() {
    namaProdukC.clear();
    hargaC.clear();
    stokC.clear();
    beratSatuanC.clear();
    deskripsiC.clear();
    selectedKategoriId.value = null;
    selectedFotoBytes.value = null;
  }

  Future<void> submitCreate() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedKategoriId.value == null) {
      Get.snackbar("Peringatan", "Pilih kategori produk",
          backgroundColor: Colors.orange.shade100);
      return;
    }

    try {
      isSubmitting(true);
      Uint8List? fotoBytes = selectedFotoBytes.value;
      String? fotoName = selectedFotoName.value ?? 'foto.jpg';

      // debug log berat satuan
      final beratText = beratSatuanC.text.trim();
      print('📦 SUBMIT CREATE berat_satuan="${beratText}"');
      final beratParsed = int.tryParse(beratText);
      if (beratParsed == null) {
        throw Exception('Nilai berat satuan tidak valid: "$beratText"');
      }

      await _service.createProduk(
        namaProduk: namaProdukC.text.trim(),
        kategoriId: selectedKategoriId.value!,
        harga: int.parse(hargaC.text.trim()),
        stok: int.parse(stokC.text.trim()),
        beratSatuan: beratParsed,
        deskripsi: deskripsiC.text.trim(),
        fotoBytes: fotoBytes,
        fotoFilename: fotoName,
      );

      // Refresh list di ProdukController utama
      if (Get.isRegistered<ProdukController>()) {
        Get.find<ProdukController>().fetchProduk();
      }

      Get.back();
      Get.snackbar("Sukses", "Produk berhasil ditambahkan",
          backgroundColor: Colors.green.shade100);
    } catch (e) {
      print("Error submit create: $e");
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red.shade100);
    } finally {
      isSubmitting(false);
    }
  }

  Future<void> submitUpdate(DataProduk produk) async {
    if (!formKey.currentState!.validate()) return;
    if (selectedKategoriId.value == null) {
      Get.snackbar("Peringatan", "Pilih kategori produk");
      return;
    }

    try {
      isSubmitting(true);
      Uint8List? fotoBytes = selectedFotoBytes.value;
      String? fotoName = selectedFotoName.value ?? 'foto.jpg';

      // debug log berat satuan
      final beratText = beratSatuanC.text.trim();
      print('📦 SUBMIT UPDATE berat_satuan="${beratText}"');
      final beratParsed = int.tryParse(beratText);
      if (beratParsed == null) {
        throw Exception('Nilai berat satuan tidak valid: "$beratText"');
      }

      await _service.updateProduk(
        id: produk.id!,
        kiosId: produk.kiosId!,
        namaProduk: namaProdukC.text.trim(),
        kategoriId: selectedKategoriId.value!,
        harga: int.parse(hargaC.text.trim()),
        stok: int.parse(stokC.text.trim()),
        beratSatuan: beratParsed,
        deskripsi: deskripsiC.text.trim(),
        fotoBytes: fotoBytes,
        fotoFilename: fotoName,
      );

      if (Get.isRegistered<ProdukController>()) {
        Get.find<ProdukController>().fetchProduk();
      }

      Get.back();
      Get.snackbar("Sukses", "Produk berhasil diperbarui",
          backgroundColor: Colors.green.shade100);
    } catch (e) {
      print("Error submit update: $e");
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red.shade100);
    } finally {
      isSubmitting(false);
    }
  }
}
