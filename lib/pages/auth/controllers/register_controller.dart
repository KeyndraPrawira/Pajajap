// lib/pages/auth/controllers/register_controller.dart
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class RegisterController extends GetxController {
  final AuthService _authService = Get.find();

  final nameController = TextEditingController();
  final teleponController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final agreeToPolicy = false.obs;

  void togglePasswordVisibility() => obscurePassword.value = !obscurePassword.value;
  void toggleAgreeToPolicy(bool? value) => agreeToPolicy.value = value ?? false;

  Future<void> register() async {
    if (validateName(nameController.text) != null) {
      Get.snackbar('Validasi Gagal', validateName(nameController.text)!,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (validateTelepon(teleponController.text) != null) {
      Get.snackbar('Validasi Gagal', validateTelepon(teleponController.text)!,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (validateEmail(emailController.text) != null) {
      Get.snackbar('Validasi Gagal', validateEmail(emailController.text)!,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (validatePassword(passwordController.text) != null) {
      Get.snackbar('Validasi Gagal', validatePassword(passwordController.text)!,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (!agreeToPolicy.value) {
      Get.snackbar('Perhatian', 'Anda harus menyetujui kebijakan privasi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final result = await _authService.register(
        nomortelepon: teleponController.text,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (result['success'] == true) {
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        teleponController.clear();
        agreeToPolicy.value = false;
        Get.snackbar('Berhasil', 'Registrasi berhasil! Silakan login',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green, colorText: Colors.white);
        Get.offNamed(AppRoutes.LOGIN);
      } else {
        Get.snackbar('Registrasi Gagal', result['message'] ?? 'Terjadi kesalahan',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    teleponController.clear();
    agreeToPolicy.value = false;
    Get.offNamed(AppRoutes.LOGIN);
  }

  // Tambah di RegisterController
Future<void> loginWithGoogle() async {
  isLoading.value = true;
  try {
    final result = await _authService.loginWithGoogle();
    if (result['success'] == true) {
      if (result['is_new_user'] == true) {
        Get.offNamed(AppRoutes.COMPLETE_PROFILE);
      } else {
        _navigateBasedOnRole(box.read('role') ?? 'user');
      }
    } else {
      Get.snackbar('Login Gagal', result['message'] ?? 'Google login gagal',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red, colorText: Colors.white);
    }
  } catch (e) {
    Get.snackbar('Error', 'Terjadi kesalahan: ${e.toString()}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red, colorText: Colors.white);
  } finally {
    isLoading.value = false;
  }
}

// Tambah juga getter box
final box = GetStorage(); // ← tambah ini di atas

// Tambah _navigateBasedOnRole
void _navigateBasedOnRole(String role) {
  switch (role.toLowerCase()) {
    case 'pedagang': Get.offAllNamed(AppRoutes.PEDAGANG_HOME); break;
    case 'driver': Get.offAllNamed(AppRoutes.DRIVER_HOME); break;
    default: Get.offAllNamed(AppRoutes.USER_HOME);
  }
}
  String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Nama tidak boleh kosong';
    if (value.length < 3) return 'Nama minimal 3 karakter';
    return null;
  }

  String? validateTelepon(String? value) {
    if (value == null || value.isEmpty) return 'Nomor telepon tidak boleh kosong';
    if (!GetUtils.isPhoneNumber(value)) return 'Format nomor telepon tidak valid';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
    if (!GetUtils.isEmail(value)) return 'Format email tidak valid';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
    if (value.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  @override
  void onClose() {
    nameController.dispose();
    teleponController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}