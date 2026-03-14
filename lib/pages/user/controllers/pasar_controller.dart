// lib/pages/user/controllers/pasar_controller.dart
import 'package:e_pasar/app/data/models/pasar_model.dart';
import 'package:e_pasar/app/services/pasar_services.dart';
import 'package:e_pasar/app/utils/distance_utils.dart';
import 'package:get/get.dart';

class PasarController extends GetxController {
  var pasarList = <Data>[].obs;
  var isLoading = false.obs;
  var userLatitude = 0.0.obs;
  var userLongitude = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    getPasarList();
  }

  /// Ambil daftar pasar
  Future<void> getPasarList() async {
    try {
      isLoading.value = true;
      final result = await PasarService.getPasarList();

      if (result != null && result.data != null) {
        pasarList.value = [result.data!];
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Set koordinat user untuk perhitungan jarak
  void setUserLocation(double latitude, double longitude) {
    userLatitude.value = latitude;
    userLongitude.value = longitude;
  }

  /// Hitung jarak dari user ke pasar tertentu
  double getDistanceToPasar(Data pasar) {
    if (pasar.latitude == null || pasar.longitude == null) {
      return 0.0;
    }

    try {
      final pasarLat = double.parse(pasar.latitude!);
      final pasarLng = double.parse(pasar.longitude!);

      return DistanceUtils.calculateDistance(
        userLatitude.value,
        userLongitude.value,
        pasarLat,
        pasarLng,
      );
    } catch (e) {
      return 0.0;
    }
  }

  /// Format jarak untuk display
  String getFormattedDistance(Data pasar) {
    final distance = getDistanceToPasar(pasar);
    return DistanceUtils.formatDistance(distance);
  }

  /// Estimasi waktu tempuh (dengan asumsi kecepatan motor 30 km/jam)
  String getEstimatedTime(Data pasar) {
    final distance = getDistanceToPasar(pasar);
    return DistanceUtils.estimateTravelTime(distance, 30.0); // 30 km/jam
  }
}