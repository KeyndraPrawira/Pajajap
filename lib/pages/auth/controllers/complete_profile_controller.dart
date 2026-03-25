// lib/pages/auth/controllers/complete_profile_controller.dart
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CompleteProfileController extends GetxController {
  final AuthService _authService = Get.find();
  final box = GetStorage();

  final nameController = TextEditingController();
  final teleponController = TextEditingController();
  final isLoading = false.obs;

  Future<void> completeProfile() async {
    if (nameController.text.isEmpty) {
      Get.snackbar('Validasi Gagal', 'Nama tidak boleh kosong',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (teleponController.text.isEmpty) {
      Get.snackbar('Validasi Gagal', 'Nomor telepon tidak boleh kosong',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final result = await _authService.completeProfile(
        name: nameController.text.trim(),
        nomorTelepon: teleponController.text.trim(),
      );

      if (result['success'] == true) {
        Get.snackbar('Berhasil', 'Profil berhasil dilengkapi!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        final role = box.read('role') ?? 'user';
        _navigateBasedOnRole(role);
      } else {
        Get.snackbar('Gagal', result['message'] ?? 'Gagal melengkapi profil',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _navigateBasedOnRole(String role) {
    switch (role.toLowerCase()) {
      case 'pedagang':
        Get.offAllNamed(AppRoutes.PEDAGANG_HOME);
        break;
      case 'driver':
        Get.offAllNamed(AppRoutes.DRIVER_HOME);
        break;
      default:
        Get.offAllNamed(AppRoutes.USER_HOME);
        break;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    teleponController.dispose();
    super.onClose();
  }
}