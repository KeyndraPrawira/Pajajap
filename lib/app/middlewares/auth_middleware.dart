// lib/app/middlewares/role_middleware.dart
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  final String requiredRole;

  AuthMiddleware({required this.requiredRole});

  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // Cek login dulu
    if (!authService.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.LOGIN);
    }

    if (route != AppRoutes.COMPLETE_PROFILE &&
        authService.isProfileIncomplete) {
      return const RouteSettings(name: AppRoutes.COMPLETE_PROFILE);
    }

    // Cek role cocok atau tidak
    final userRole = authService.getRole()?.toLowerCase();

    if (userRole != requiredRole.toLowerCase()) {
      // Role tidak cocok, redirect ke home sesuai role user
      return RouteSettings(name: _getHomeRouteForRole(userRole));
    }

    return null; // Role cocok, boleh akses
  }

  String _getHomeRouteForRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'pedagang':
        return AppRoutes.PEDAGANG_HOME;
      case 'driver':
        return AppRoutes.DRIVER_HOME;
      case 'user':
      default:
        return AppRoutes.USER_HOME;
    }
  }
}
