import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/pages/auth/controllers/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class RegisterOtpView extends GetView<RegisterController> {
  const RegisterOtpView({super.key});

  static const _primaryColor = Color(0xFF0D47A1);
  static const _accentColor = Color(0xFF1E88E5);

  @override
  Widget build(BuildContext context) {
    controller.syncPendingEmailFromArgs();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.pendingEmail.value.trim().isEmpty) {
        Get.snackbar(
          'Sesi OTP Tidak Ditemukan',
          'Silakan lakukan registrasi kembali untuk mendapatkan kode OTP.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        Get.offNamed(AppRoutes.REGISTER);
      }
    });

    return WillPopScope(
      onWillPop: () async {
        Get.snackbar(
          'Registrasi Belum Selesai',
          'Selesaikan OTP atau batalkan registrasi terlebih dahulu.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F8FC),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 18,
                          color: _primaryColor,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Halaman dikunci sampai OTP selesai atau registrasi dibatalkan.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (controller.isCancelLoading.value)
                          const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [_primaryColor, _accentColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Masukkan OTP',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Kami sudah mengirim 6 digit kode verifikasi ke email yang kamu daftarkan.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email tujuan',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F8FB),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            controller.pendingEmail.value,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Kode OTP',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: controller.otpController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          maxLength: 6,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Masukkan 6 digit OTP',
                            counterText: '',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFD),
                            prefixIcon: const Icon(Icons.password_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onFieldSubmitted: (_) {
                            if (!controller.isOtpLoading.value) {
                              controller.verifyOtp();
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Belum menerima email? Cek folder spam atau kirim ulang kode OTP.',
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: controller.isOtpLoading.value ||
                                    controller.isCancelLoading.value
                                ? null
                                : controller.verifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                            ),
                            child: controller.isOtpLoading.value
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Verifikasi dan Masuk',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: controller.isResendOtpLoading.value ||
                                    controller.isCancelLoading.value
                                ? null
                                : controller.resendOtp,
                            child: controller.isResendOtpLoading.value
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Kirim ulang OTP',
                                    style: TextStyle(
                                      color: _primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: controller.isCancelLoading.value ||
                                    controller.isOtpLoading.value
                                ? null
                                : controller.cancelRegistration,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: controller.isCancelLoading.value
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Batalkan registrasi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
