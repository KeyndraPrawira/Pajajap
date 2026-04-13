import 'package:e_pasar/app/data/models/keranjang_model.dart';
import 'package:e_pasar/app/services/keranjang_services.dart';
import 'package:get/get.dart';

class KeranjangController extends GetxController {
  final KeranjangServices _keranjangServices = KeranjangServices();

  // ─── State ───────────────────────────────────────────────
  final RxList<DataKeranjang> keranjangList = <DataKeranjang>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isActionLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // ─── Computed ────────────────────────────────────────────
  int get totalHarga =>
      keranjangList.fold(0, (sum, item) => sum + (item.hargaTotal ?? 0));

  int get totalItem => keranjangList.length;

  // ─── Lifecycle ───────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchKeranjang();
  }

  // ─── GET Keranjang ────────────────────────────────────────
  Future<void> fetchKeranjang() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _keranjangServices.getKeranjang();

      if (result?.data != null) {
        keranjangList.assignAll(result!.data!);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Gagal mengambil keranjang',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── ADD to Keranjang ─────────────────────────────────────
  Future<void> addToKeranjang({
    required String produkId,
    required int jumlah,
    required int hargaTotal,
  }) async {
    try {
      isActionLoading.value = true;
      errorMessage.value = '';

      final result = await _keranjangServices.addToKeranjang(
        produkId: produkId,
        jumlah: jumlah.toString(),
        hargaTotal: hargaTotal,
      );

      if (result?.data != null && result!.data!.isNotEmpty) {
        final newItem = result.data!.first;
        final existingIndex = keranjangList
            .indexWhere((item) => item.produkId == newItem.produkId);

        if (existingIndex != -1) {
          keranjangList[existingIndex] = newItem;
        } else {
          keranjangList.add(newItem);
        }

        Get.snackbar(
          'Berhasil',
          result.message ?? 'Produk ditambahkan ke keranjang',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Gagal menambahkan ke keranjang',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  // ─── UPDATE Keranjang ─────────────────────────────────────
  Future<void> updateKeranjang({
    required int id,
    required String produkId,
    required int jumlah,
    required int hargaTotal,
  }) async {
    try {
      isActionLoading.value = true;
      errorMessage.value = '';

      final result = await _keranjangServices.updateKeranjang(
        id: id,
        produkId: produkId,
        jumlah: jumlah.toString(),
        hargaTotal: hargaTotal,
      );

      if (result?.data != null && result!.data!.isNotEmpty) {
        final updatedItem = result.data!.first;
        final index =
            keranjangList.indexWhere((item) => item.id == updatedItem.id);

        if (index != -1) {
          keranjangList[index] = updatedItem;
        }

        Get.snackbar(
          'Berhasil',
          result.message ?? 'Keranjang berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Gagal memperbarui keranjang',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  // ─── DELETE Keranjang ─────────────────────────────────────
  Future<void> deleteKeranjang(int id) async {
    try {
      isActionLoading.value = true;
      errorMessage.value = '';

      final success = await _keranjangServices.deleteKeranjang(id);

      if (success) {
        keranjangList.removeWhere((item) => item.id == id);
        Get.snackbar(
          'Berhasil',
          'Produk dihapus dari keranjang',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Gagal menghapus dari keranjang',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  // ─── INCREMENT / DECREMENT helper ────────────────────────
  Future<void> incrementItem(DataKeranjang item, int hargaSatuan) async {
    final newJumlah = (int.tryParse(item.jumlah ?? '1') ?? 1) + 1;
    updateKeranjang(
      id: item.id!,
      produkId: item.produkId!,
      jumlah: newJumlah,
      hargaTotal: newJumlah * hargaSatuan,
    );
    ;
  }

  Future<void> decrementItem(DataKeranjang item, int hargaSatuan) async {
    final currentJumlah = int.tryParse(item.jumlah ?? '1') ?? 1;

    if (currentJumlah <= 1) {
      await deleteKeranjang(item.id!);
    } else {
      final newJumlah = currentJumlah - 1;
      await updateKeranjang(
        id: item.id!,
        produkId: item.produkId!,
        jumlah: newJumlah,
        hargaTotal: newJumlah * hargaSatuan,
      );
    }
  }

  // ─── Clear local cart ─────────────────────────────────────
  void clearKeranjang() {
    keranjangList.clear();
  }
}
