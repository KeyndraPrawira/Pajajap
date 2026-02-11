// lib/app/modules/pedagang/controllers/pedagang_controller.dart
import 'dart:io';
import 'package:e_pasar/app/data/models/kios_model.dart';
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';

import 'package:e_pasar/app/services/kios_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PedagangController extends GetxController {
  final AuthService _authService = Get.find();
  final KiosService _kiosService = KiosService();

  final currentIndex = 0.obs;
  
  // Kios related
  var kiosList = <DataKios>[].obs;
  var myKios = Rxn<DataKios>(); // Kios milik pedagang yang login
  var isLoading = false.obs;
  var hasKios = false.obs; // Flag apakah pedagang sudah punya kios
  var userId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    fetchKios();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId.value = prefs.getInt('user_id') ?? 0;
  }

  void changePage(int index) {
    currentIndex.value = index;
  }

  // ==================== KIOS FUNCTIONS ====================

  // Get all kios (untuk pedagang hanya dapat kios miliknya)
  Future<void> fetchKios() async {
    try {
      isLoading.value = true;
      final result = await _kiosService.getKios();
      if (result != null && result.kios != null) {
        kiosList.value = result.kios!;
        _checkPedagangKios();
      } else {
        kiosList.value = [];
        hasKios.value = false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data kios: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Check apakah pedagang sudah punya kios
  void _checkPedagangKios() {
    try {
      myKios.value = kiosList.firstWhere(
        (kios) => kios.userId == userId.value,
      );
      hasKios.value = true;
    } catch (e) {
      myKios.value = null;
      hasKios.value = false;
    }
  }

  // Redirect pedagang yang belum punya kios ke form tambah kios
  void checkAndRedirectToKiosForm() {
    if (!hasKios.value) {
      // Redirect ke form add kios
      Future.delayed(Duration.zero, () {
        Get.offAllNamed(AppRoutes.KIOS_ADD);
        Get.snackbar(
          'Informasi',
          'Silakan lengkapi data kios Anda terlebih dahulu',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      });
    }
  }

  // Check apakah pedagang bisa akses form add kios
  bool canAccessAddKiosForm() {
    if (hasKios.value) {
      Get.snackbar(
        'Informasi',
        'Anda sudah memiliki kios. Silakan edit kios yang sudah ada.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
      Get.back();
      return false;
    }
    return true;
  }

  // Create kios - Only for pedagang yang belum punya kios
  Future<void> addKios({
    required String namaKios,
    required String lokasi,
    required String jamBuka,
    required String jamTutup,
    String? deskripsi,
    File? fotoKios,
  }) async {
    // Check if pedagang already has kios
    if (hasKios.value) {
      Get.snackbar(
        'Informasi',
        'Anda sudah memiliki kios',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
      return;
    }

    try {
      isLoading.value = true;
      final success = await _kiosService.createKios(
        namaKios: namaKios,
        lokasi: lokasi,
        jamBuka: jamBuka,
        jamTutup: jamTutup,
        deskripsi: deskripsi,
        fotoKios: fotoKios,
      );
      
      if (success) {
        await fetchKios();
        // Redirect ke halaman pedagang home setelah berhasil buat kios
        Get.offAllNamed(AppRoutes.PEDAGANG_HOME);
        Get.snackbar(
          'Berhasil',
          'Kios berhasil dibuat! Selamat datang di E-Pasar',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menambah kios: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update kios - Only for pedagang yang punya kios
  Future<void> editKios({
    required int kiosId,
    required String namaKios,
    required String lokasi,
    required String jamBuka,
    required String jamTutup,
    String? kontak,
    String? deskripsi,
    File? fotoKios,
  }) async {
    // Check if kios belongs to this pedagang
    if (myKios.value?.id != kiosId) {
      Get.snackbar(
        'Akses Ditolak',
        'Anda hanya dapat mengedit kios milik Anda sendiri',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    try {
      isLoading.value = true;
      final success = await _kiosService.updateKios(
        kiosId: kiosId,
        namaKios: namaKios,
        lokasi: lokasi,
        jamBuka: jamBuka,
        jamTutup: jamTutup,
        kontak: kontak,
        deskripsi: deskripsi,
        fotoKios: fotoKios,
      );
      
      if (success) {
        await fetchKios();
        Get.back(); // Kembali ke halaman sebelumnya setelah berhasil
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengedit kios: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete kios - Only for pedagang yang punya kios
  Future<void> removeKios(int kiosId) async {
    // Check if kios belongs to this pedagang
    if (myKios.value?.id != kiosId) {
      Get.snackbar(
        'Akses Ditolak',
        'Anda hanya dapat menghapus kios milik Anda sendiri',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    // Konfirmasi sebelum hapus
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus kios ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Get.theme.colorScheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      isLoading.value = true;
      final success = await _kiosService.deleteKios(kiosId);
      
      if (success) {
        await fetchKios();
        // Setelah hapus kios, redirect ke form add kios lagi
        checkAndRedirectToKiosForm();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus kios: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh data kios
  Future<void> refreshKios() async {
    await fetchKios();
  }

  // ==================== AUTH FUNCTIONS ====================

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.LOGIN);
  }
}