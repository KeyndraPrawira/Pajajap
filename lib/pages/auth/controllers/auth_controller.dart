// lib/app/modules/auth/controllers/auth_controller.dart
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find();
  final box = GetStorage();
  String get token => box.read('token') ?? '';

  // TEXT CONTROLLERS
  final teleponController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  // STATES
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final rememberMe = false.obs;
  final agreeToPolicy = false.obs;

  // ================= TOGGLE =================

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;

    if (rememberMe.value) {
      box.write('remember', true);
    } else {
      box.remove('remember');
    }
  }

  void toggleAgreeToPolicy(bool? value) {
    agreeToPolicy.value = value ?? false;
  }

  // ================= CHECK LOGIN =================

  

  // ================= LOGIN =================

  Future<void> login() async {
    if (validateEmail(emailController.text) != null) {
      Get.snackbar(
        'Validasi Gagal',
        validateEmail(emailController.text)!,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (validatePassword(passwordController.text) != null) {
      Get.snackbar(
        'Validasi Gagal',
        validatePassword(passwordController.text)!,
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
        // SIMPAN TOKEN & ROLE
        box.write('token', auth.token);
        box.write('role', auth.user!.role);

        emailController.clear();
        passwordController.clear();

        Get.snackbar(
          'Berhasil',
          'Login berhasil! Selamat datang ${auth.user!.name}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        _navigateBasedOnRole(auth.user!.role ?? 'user');
      } else {
        Get.snackbar(
          'Login Gagal',
          'Email atau password salah',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ================= REGISTER =================

  Future<void> register() async {
    if (validateName(nameController.text) != null) {
      Get.snackbar(
        'Validasi Gagal',
        validateName(nameController.text)!,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (validateTelepon(teleponController.text) != null) {
      Get.snackbar(
        'Validasi Gagal',
        validateTelepon(teleponController.text)!,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (validateEmail(emailController.text) != null) {
      Get.snackbar(
        'Validasi Gagal',
        validateEmail(emailController.text)!,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (validatePassword(passwordController.text) != null) {
      Get.snackbar(
        'Validasi Gagal',
        validatePassword(passwordController.text)!,
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
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        teleponController.clear();
        agreeToPolicy.value = false;

        Get.snackbar(
          'Berhasil',
          'Registrasi berhasil! Silakan login',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offNamed(AppRoutes.LOGIN);
      } else {
        Get.snackbar(
          'Registrasi Gagal',
          result['message'] ?? 'Terjadi kesalahan',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ================= NAVIGATION =================

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

  void goToRegister() {
    emailController.clear();
    passwordController.clear();
    Get.offNamed(AppRoutes.REGISTER);
  }

  void goToLogin() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    teleponController.clear();
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
    );
  }
  void checkLogin() {
    final token = box.read('token');
    final role = box.read('role');

    if (token != null && token.toString().isNotEmpty) {
      _navigateBasedOnRole(role ?? 'user');
    } else {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  // ================= VALIDATION =================

  String? validateTelepon(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    if (!GetUtils.isPhoneNumber(value)) {
      return 'Format nomor telepon tidak valid';
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

  @override
  void onClose() {
    teleponController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.onClose();
  }
}