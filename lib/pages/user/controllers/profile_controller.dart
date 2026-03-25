import 'package:e_pasar/app/data/models/profile_model.dart';
import 'package:e_pasar/app/services/pasar_services.dart';
import 'package:e_pasar/app/services/profile_services.dart';
import 'package:e_pasar/pages/auth/controllers/auth_controller.dart';
import 'package:e_pasar/pages/user/controllers/pasar_controller.dart';
import 'package:get/get.dart';


class ProfileController extends GetxController {

  var isLoading = false.obs;
  var dataProfile = Rxn<DataProfile>();
  var profile = Rxn<Profile>();
 final authC = Get.find<AuthController>();
String get token => authC.box.read('token') ?? '';

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  

  /// ambil data profile
 Future<void> getProfile() async {
  try {
    isLoading.value = true;
    print("=== GET PROFILE ===");

    final result = await ProfileService.getProfile(token);
    print("Result: $result");

    if (result != null) {
      profile.value = result;           // ✅ Profile (wrapper)
      dataProfile.value = result.data;  // ✅ DataProfile (isi)
      print("Nama: ${dataProfile.value?.name}");
      print("Alamat: ${dataProfile.value?.alamat?.alamatLengkap}");
    }
  } catch (e) {
    print("ERROR: $e");
    Get.snackbar("Error", e.toString());
  } finally {
    isLoading.value = false;
  }
}
  /// update nama dan nomor telepon
  Future<void> updateProfile(
  String name,
  String nomorTelepon,
) async {

  try {

    isLoading.value = true;

    final success = await ProfileService.updateProfile(
      token,
      name,
      nomorTelepon,
    );

    if (success) {
      await getProfile();
    }

  } finally {
    isLoading.value = false;
  }

}

  /// simpan alamat dari map
 Future<void> setAlamat(
  String alamat,
  double latitude,
  double longitude,
  double jarakKm,
) async {

  try {

    isLoading.value = true;

    final success = await ProfileService.setAlamat(
      token,
      alamat,
      latitude,
      longitude,
      jarakKm
    );

    if (success) {
      await getProfile();
      // Update koordinat user untuk perhitungan jarak
      _updateUserLocation(latitude, longitude);
    }

  } catch (e) {
    Get.snackbar("Error", e.toString());
  } finally {
    isLoading.value = false;
  }

}

  /// Update koordinat user untuk perhitungan jarak
  void _updateUserLocation(double latitude, double longitude) {
    // Cari controller pasar dan update koordinat
    if (Get.isRegistered<PasarController>()) {
      final pasarController = Get.find<PasarController>();
      pasarController.setUserLocation(latitude, longitude);
    }
  }

  /// update password
  Future<void> updatePassword(
  String currentPassword,
  String newPassword,
  String confirmPassword,
) async {

  try {

    isLoading.value = true;

    await ProfileService.updatePassword(
      token,
      currentPassword,
      newPassword,
      confirmPassword,
    );

    Get.snackbar("Berhasil", "Password berhasil diperbarui");

  } catch (e) {
    Get.snackbar("Error", e.toString());
  } finally {
    isLoading.value = false;
  }

}

}