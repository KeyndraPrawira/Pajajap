import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class RegisterController extends GetxController {
  final AuthService _authService = Get.find();
  final box = GetStorage();

  // Inisialisasi controller di sini, bukan di onInit,
  // agar tidak ada masalah saat di-recreate oleh GetX.
  late TextEditingController nameController;
  late TextEditingController teleponController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController otpController;

  final isLoading = false.obs;
  final isOtpLoading = false.obs;
  final isResendOtpLoading = false.obs;
  final isCancelLoading = false.obs;
  final obscurePassword = true.obs;
  final agreeToPolicy = false.obs;
  final pendingEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Selalu buat ulang controller di onInit agar tidak pernah
    // menggunakan instance yang sudah di-dispose.
    nameController = TextEditingController();
    teleponController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    otpController = TextEditingController();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleAgreeToPolicy(bool? value) {
    agreeToPolicy.value = value ?? false;
  }

  void syncPendingEmailFromArgs() {
    final args = Get.arguments;
    if (args is Map) {
      final email = (args['email'] ?? '').toString().trim();
      if (email.isNotEmpty) {
        pendingEmail.value = email;
      }
    }
  }

  // ===========================================================================
  // Register — Step 1
  // ===========================================================================

  Future<void> register() async {
    if (validateName(nameController.text) != null) {
      _showSnackbar('Validasi Gagal', validateName(nameController.text)!,
          isError: true);
      return;
    }
    if (validateTelepon(teleponController.text) != null) {
      _showSnackbar('Validasi Gagal', validateTelepon(teleponController.text)!,
          isError: true);
      return;
    }
    if (validateEmail(emailController.text) != null) {
      _showSnackbar('Validasi Gagal', validateEmail(emailController.text)!,
          isError: true);
      return;
    }
    if (validatePassword(passwordController.text) != null) {
      _showSnackbar(
          'Validasi Gagal', validatePassword(passwordController.text)!,
          isError: true);
      return;
    }
    if (!agreeToPolicy.value) {
      _showSnackbar('Perhatian', 'Anda harus menyetujui kebijakan privasi',
          isWarning: true);
      return;
    }

    isLoading.value = true;
    try {
      final result = await _authService.register(
        nomortelepon: teleponController.text.trim(),
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (result.success == true) {
        pendingEmail.value = result.data?.email ?? emailController.text.trim();
        otpController.clear();

        _showSnackbar(
          'OTP Terkirim',
          result.message ?? 'Kode OTP telah dikirim ke email Anda.',
          isSuccess: true,
        );

        Get.toNamed(
        AppRoutes.REGISTER_OTP,
        arguments: {'email': pendingEmail.value},
      );
      } else {
        _showSnackbar(
          'Registrasi Gagal',
          result.message ?? 'Terjadi kesalahan',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackbar('Error', 'Terjadi kesalahan: ${e.toString()}',
          isError: true);
    } finally {
      _safeSetLoading(isLoading, false);
    }
  }

  // ===========================================================================
  // Verify OTP — Step 2
  // ===========================================================================

  Future<void> verifyOtp() async {
    final email = pendingEmail.value.trim();
    final otp = otpController.text.trim();

    if (email.isEmpty) {
      _showSnackbar('Validasi Gagal', 'Email verifikasi tidak ditemukan',
          isWarning: true);
      return;
    }

    if (otp.length != 6 || !GetUtils.isNumericOnly(otp)) {
      _showSnackbar('Validasi Gagal', 'Kode OTP harus 6 digit angka',
          isWarning: true);
      return;
    }

    isOtpLoading.value = true;
    try {
      final result = await _authService.verifyRegisterOtp(
        email: email,
        otp: otp,
      );

      if (result.success == true) {
        _showSnackbar(
          'Berhasil',
          result.message ?? 'Registrasi berhasil. Selamat datang!',
          isSuccess: true,
        );

        _clearRegisterForm();
        pendingEmail.value = '';
        _navigateBasedOnRole(box.read('role') ?? 'user');
      } else {
        _showSnackbar(
          'Verifikasi Gagal',
          result.message ?? 'Kode OTP tidak valid atau sudah kedaluwarsa',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackbar('Error', 'Terjadi kesalahan: ${e.toString()}',
          isError: true);
    } finally {
      _safeSetLoading(isOtpLoading, false);
    }
  }

  // ===========================================================================
  // Resend OTP
  // ===========================================================================

  Future<void> resendOtp() async {
    final email = pendingEmail.value.trim();

    if (email.isEmpty) {
      _showSnackbar('Validasi Gagal', 'Email verifikasi tidak ditemukan',
          isWarning: true);
      return;
    }

    isResendOtpLoading.value = true;
    try {
      final result = await _authService.resendRegisterOtp(email: email);

      _showSnackbar(
        result.success == true ? 'Berhasil' : 'Gagal',
        result.message ??
            (result.success == true
                ? 'Kode OTP baru telah dikirim'
                : 'Gagal mengirim ulang OTP'),
        isSuccess: result.success == true,
        isError: result.success != true,
      );
    } catch (e) {
      _showSnackbar('Error', 'Terjadi kesalahan: ${e.toString()}',
          isError: true);
    } finally {
      _safeSetLoading(isResendOtpLoading, false);
    }
  }

  // ===========================================================================
  // Cancel Registration
  // ===========================================================================

  Future<void> cancelRegistration() async {
    final email = pendingEmail.value.trim();

    if (email.isEmpty) {
      _goBackToRegister();
      return;
    }

    isCancelLoading.value = true;
    try {
      final result = await _authService.cancelRegistration(email: email);

      if (result.success == true) {
        _showSnackbar(
          'Registrasi Dibatalkan',
          result.message ?? 'Registrasi berhasil dibatalkan.',
          isSuccess: true,
        );
        _goBackToRegister();
        return;
      }

      _showSnackbar(
        'Gagal Membatalkan Registrasi',
        result.message ?? 'Silakan coba lagi.',
        isError: true,
      );
    } catch (e) {
      debugPrint('CANCEL REGISTRATION ERROR: $e');
      _showSnackbar(
        'Gagal Membatalkan Registrasi',
        'Terjadi kesalahan: ${e.toString()}',
        isError: true,
      );
    } finally {
      _safeSetLoading(isCancelLoading, false);
    }
  }

  void _goBackToRegister() {
    pendingEmail.value = '';
    otpController.clear();
    Get.offNamed(AppRoutes.REGISTER);
  }

  // ===========================================================================
  // Navigation & Auth
  // ===========================================================================

  void goToLogin() {
    _clearRegisterForm();
    pendingEmail.value = '';
    otpController.clear();
    Get.offNamed(AppRoutes.LOGIN);
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      final result = await _authService.loginWithGoogle();
      if (result['success'] == true) {
        final user = result['user'] as Map<String, dynamic>?;
        final userName = ((user?['name'] ?? '') as String).trim();

        _showSnackbar(
          'Berhasil',
          'Selamat datang ${userName.isEmpty ? 'Pengguna' : userName}',
          isSuccess: true,
        );

        if (_authService.isProfileIncomplete || result['is_new_user'] == true) {
          Get.offAllNamed(AppRoutes.COMPLETE_PROFILE);
        } else {
          _navigateBasedOnRole(box.read('role') ?? 'user');
        }
      } else {
        _showSnackbar(
          'Login Gagal',
          result['message'] ?? 'Google login gagal',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackbar('Error', 'Terjadi kesalahan: ${e.toString()}',
          isError: true);
    } finally {
      _safeSetLoading(isLoading, false);
    }
  }

  // ===========================================================================
  // Validators
  // ===========================================================================

  String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Nama tidak boleh kosong';
    if (value.length < 3) return 'Nama minimal 3 karakter';
    return null;
  }

  String? validateTelepon(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
    if (!GetUtils.isEmail(value)) return 'Format email tidak valid';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
    if (value.length < 8) return 'Password minimal 8 karakter';
    if (!RegExp(r'(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password harus mengandung huruf besar, huruf kecil, dan angka';
    }
    return null;
  }

  // ===========================================================================
  // Private helpers
  // ===========================================================================

  void _clearRegisterForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    teleponController.clear();
    otpController.clear();
    agreeToPolicy.value = false;
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
    }
  }

  /// Set loading state hanya kalau controller belum di-close.
  void _safeSetLoading(RxBool target, bool value) {
    if (!isClosed) target.value = value;
  }

  void _showSnackbar(
    String title,
    String message, {
    bool isSuccess = false,
    bool isError = false,
    bool isWarning = false,
  }) {
    Color bg = Colors.orange;
    if (isSuccess) bg = Colors.green;
    if (isError) bg = Colors.red;
    if (isWarning) bg = Colors.orange;

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: bg,
      colorText: Colors.white,
    );
  }

  // ===========================================================================
  // Lifecycle
  // ===========================================================================

  @override
  void onClose() {
    nameController.dispose();
    teleponController.dispose();
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
