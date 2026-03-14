// lib/app/modules/pedagang/controllers/pedagang_controller.dart
import 'dart:typed_data';
import 'package:e_pasar/app/data/models/kios_model.dart';
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:e_pasar/app/services/kios_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PedagangController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final storage = GetStorage();
  final KiosService _kiosService = Get.find<KiosService>();


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
      _initData();
    }

    Future<void> _initData() async {
      await _loadUserData();
      await fetchKios();
    }



  // Load user data from GetStorage
  Future<void> _loadUserData() async {
    userId.value = storage.read('user_id') ?? 0;
    print('🔑 USER ID: ${userId.value}'); // Debug
  }

  void changePage(int index) {
    currentIndex.value = index;
  }

  // ==================== KIOS FUNCTIONS ====================

  // Get all kios (untuk pedagang hanya dapat kios miliknya)
 // Get all kios (untuk pedagang dapat kios miliknya dari /kios/me)
Future<void> fetchKios() async {
  try {
    isLoading.value = true;

    // ✅ Panggil endpoint khusus pedagang
    final result = await _kiosService.getMyKios();

    print('📦 FETCH MY KIOS RESULT: ${result.length} kios');

    if (result.isNotEmpty) {
      kiosList.value = result;
      myKios.value = result.first; // Pedagang cuma punya 1 kios
      hasKios.value = true;
      
      print('✅ FOUND MY KIOS: ${myKios.value?.namaKios}');
      print('📸 FOTO KIOS PATH: ${myKios.value?.fotoKios}');
      print('🔗 FULL URL: http://localhost:8000/storage/${myKios.value?.fotoKios}');
    } else {
      kiosList.value = [];
      myKios.value = null;
      hasKios.value = false;
      print('❌ NO KIOS DATA FOR THIS PEDAGANG');
    }

    print('✅ HAS KIOS: ${hasKios.value}');
  } catch (e) {
    print('❌ FETCH KIOS ERROR: $e');
    hasKios.value = false;
  } finally {
    isLoading.value = false;
  }

  // REDIRECT SETELAH FETCH SELESAI
  if (!hasKios.value && !isLoading.value) {
    Future.delayed(Duration.zero, () {
      Get.offAllNamed(AppRoutes.KIOS_ADD);
    });
  }
}
  // Check apakah pedagang sudah punya kios
 void _checkPedagangKios() {
  if (kiosList.isNotEmpty) {
    myKios.value = kiosList.first;
    hasKios.value = true;
  } else {
    myKios.value = null;
    hasKios.value = false;
  }
}


  // Redirect pedagang yang belum punya kios ke form tambah kios
  void checkAndRedirectToKiosForm() {
    print('🚀 CHECK AND REDIRECT - hasKios: ${hasKios.value}'); // Debug
    
    if (!hasKios.value) {
      // Redirect ke form add kios
      Future.delayed(Duration.zero, () {
        print('➡️ REDIRECTING TO KIOS ADD'); // Debug
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
    } else {
      print('✅ HAS KIOS - STAY ON HOME'); // Debug
    }
  }

  // Check apakah pedagang bisa akses form add kios
  bool canAccessAddKiosForm() {
    print('🔒 CAN ACCESS ADD FORM - hasKios: ${hasKios.value}'); // Debug
    
    if (hasKios.value) {
      Get.snackbar(
        'Informasi',
        'Anda sudah memiliki kios. Silakan edit kios yang sudah ada.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
      Get.offAllNamed(AppRoutes.PEDAGANG_HOME); // ✅ REDIRECT KE HOME, BUKAN Get.back()
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
    Uint8List? fotoKiosBytes,
    String? fotoKiosFilename,
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
        fotoKiosBytes: fotoKiosBytes,
        fotoKiosFilename: fotoKiosFilename,
      );
      
      if (success) {
        await fetchKios(); // Refresh data kios
        
        // Pastikan data sudah di-fetch sebelum redirect
        if (hasKios.value) {
          Get.offAllNamed(AppRoutes.PEDAGANG_HOME);
          Get.snackbar(
            'Berhasil',
            'Kios berhasil dibuat! Selamat datang di E-Pasar',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.primary,
            colorText: Get.theme.colorScheme.onPrimary,
          );
        }
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
    Uint8List? fotoKiosBytes,
    String? fotoKiosFilename,
  }) async {
    // Check if kios belongs to this pedagang
        if (myKios.value == null) {
          Get.snackbar(
            'Error',
            'Data kios belum dimuat',
          );
          return;
        }

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
        id: kiosId,
        namaKios: namaKios,
        lokasi: lokasi,
        jamBuka: jamBuka,
        jamTutup: jamTutup,
        deskripsi: deskripsi,
        fotoKiosBytes: fotoKiosBytes,
        fotoKiosFilename: fotoKiosFilename,
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
