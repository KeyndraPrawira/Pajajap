// lib/app/middlewares/guest_middleware.dart
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class GuestMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Jika AuthService belum didaftarkan oleh binding (mis. splash belum selesai),
    // jangan redirect — biarkan binding berjalan dulu.
    if (!Get.isRegistered<AuthService>()) {
      return null;
    }

    final authService = Get.find<AuthService>();

    if (authService.isLoggedIn) {
      final role = authService.getRole();

      switch (role?.toLowerCase()) {
        case 'pedagang':
          return const RouteSettings(name: AppRoutes.PEDAGANG_HOME);
        case 'driver':
          return const RouteSettings(name: AppRoutes.DRIVER_HOME);
        case 'user':
        default:
          return const RouteSettings(name: AppRoutes.USER_HOME);
      }
    }

    return null;
  }
}