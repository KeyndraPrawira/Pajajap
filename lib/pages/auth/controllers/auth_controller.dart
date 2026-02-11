// lib/app/modules/auth/controllers/auth_controller.dart
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AuthController extends GetxController {
  final AuthService _authService = Get.find();

  // SHARED PROPERTIES (bisa dipake login & register)
  final teleponController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  
  // OBSERVABLE STATES
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final rememberMe = false.obs;
  final agreeToPolicy = false.obs;

  // ==================== TOGGLE METHODS ====================
  
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  void toggleAgreeToPolicy(bool? value) {
    agreeToPolicy.value = value ?? false;
  }

  // ==================== LOGIN METHOD ====================
  
  Future<void> login() async {
    // Validasi fields
    if (validateEmail(emailController.text) != null) {
      Get.snackbar(
        'Validasi Gagal',
        validateEmail(emailController.text) ?? 'Email tidak valid',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    
    if (validatePassword(passwordController.text) != null) {
      Get.snackbar(
        'Validasi Gagal',
        validatePassword(passwordController.text) ?? 'Password tidak valid',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final auth = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (auth != null && auth.user != null) {
        Get.snackbar(
          'Berhasil',
          'Login berhasil! Selamat datang ${auth.user!.name}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
        );
        
        _navigateBasedOnRole(auth.user!.role ?? '');
      } else {
        Get.snackbar(
          'Login Gagal',
          'Email atau password salah. Silakan coba lagi.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== REGISTER METHOD ====================
  
  Future<void> register() async {
    // Validasi fields
    if (validateName(nameController.text) != null) {
      Get.snackbar(
        'Validasi Gagal',
        validateName(nameController.text) ?? 'Nama tidak valid',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    
    if (validateTelepon(teleponController.text) != null) {
      Get.snackbar(
        'Validasi Gagal',
        validateTelepon(teleponController.text) ?? 'Nomor telepon tidak valid',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    
    if (validateEmail(emailController.text) != null) {
      Get.snackbar(
        'Validasi Gagal',
        validateEmail(emailController.text) ?? 'Email tidak valid',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    
    if (validatePassword(passwordController.text) != null) {
      Get.snackbar(
        'Validasi Gagal',
        validatePassword(passwordController.text) ?? 'Password tidak valid',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (!agreeToPolicy.value) {
      Get.snackbar(
        'Perhatian',
        'Anda harus menyetujui kebijakan privasi terlebih dahulu',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
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
        // Clear form
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        agreeToPolicy.value = false;

        Get.snackbar(
          'Berhasil',
          'Registrasi berhasil! Silakan login dengan akun Anda',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );
        
        Get.offNamed(AppRoutes.LOGIN);
      } else {
        Get.snackbar(
          'Registrasi Gagal',
          result['message'] ?? 'Terjadi kesalahan',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== NAVIGATION ====================
  
  void _navigateBasedOnRole(String role) {
    switch (role.toLowerCase()) {
      case 'pedagang':
        Get.offAllNamed(AppRoutes.PEDAGANG_HOME);
        break;
      case 'driver':
        Get.offAllNamed(AppRoutes.DRIVER_HOME);
        break;
      case 'user':
      default:
        Get.offAllNamed(AppRoutes.USER_HOME);
        break;
    }
  }

  void goToRegister() {
    // Clear form sebelum pindah (jika controller masih valid)
    if (!emailController.text.isEmpty) emailController.clear();
    if (!passwordController.text.isEmpty) passwordController.clear();
    Get.offNamed(AppRoutes.REGISTER);
  }

  void goToLogin() {
    // Clear form sebelum pindah (jika controller masih valid)
    if (!nameController.text.isEmpty) nameController.clear();
    if (!emailController.text.isEmpty) emailController.clear();
    if (!passwordController.text.isEmpty) passwordController.clear();
    agreeToPolicy.value = false;
    Get.offNamed(AppRoutes.LOGIN);
  }

  void forgotPassword() {
    Get.snackbar(
      'Info',
      'Fitur lupa password akan segera hadir',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    );
  }

  // ==================== VALIDATION ====================
  String? validateTelepon(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    
    return null;
  }
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }
}