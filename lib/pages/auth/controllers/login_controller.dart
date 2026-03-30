// lib/pages/auth/controllers/login_controller.dart
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find();
  final box = GetStorage();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final rememberMe = false.obs;

  void togglePasswordVisibility() => obscurePassword.value = !obscurePassword.value;

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
    rememberMe.value ? box.write('remember', true) : box.remove('remember');
  }

  Future<void> login() async {
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

    isLoading.value = true;
    try {
      final auth = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (auth != null && auth.user != null) {
        box.write('token', auth.token);
        box.write('role', auth.user!.role);
        emailController.clear();
        passwordController.clear();
        Get.snackbar('Berhasil', 'Selamat datang ${auth.user!.name}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green, colorText: Colors.white);
        _navigateBasedOnRole(auth.user!.role ?? 'user');
      } else {
        Get.snackbar('Login Gagal', 'Email atau password salah',
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

  void goToRegister() {
    emailController.clear();
    passwordController.clear();
    Get.offNamed(AppRoutes.REGISTER);
  }

  void forgotPassword() {
    Get.snackbar('Info', 'Fitur lupa password akan segera hadir',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue, colorText: Colors.white);
  }

  void _navigateBasedOnRole(String role) {
    switch (role.toLowerCase()) {
      case 'pedagang': Get.offAllNamed(AppRoutes.PEDAGANG_HOME); break;
      case 'driver': Get.offAllNamed(AppRoutes.DRIVER_HOME); break;
      default: Get.offAllNamed(AppRoutes.USER_HOME);
    }
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
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}