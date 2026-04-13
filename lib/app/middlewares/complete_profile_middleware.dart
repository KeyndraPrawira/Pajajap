import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CompleteProfileMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthService>()) {
      return const RouteSettings(name: AppRoutes.LOGIN);
    }

    final authService = Get.find<AuthService>();

    if (!authService.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.LOGIN);
    }

    if (!authService.isProfileIncomplete) {
      return RouteSettings(name: _getHomeRouteForRole(authService.getRole()));
    }

    return null;
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
