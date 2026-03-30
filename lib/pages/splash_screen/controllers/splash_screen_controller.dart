// lib/app/modules/splash/controllers/splash_controller.dart
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:e_pasar/app/services/order_services.dart';
import 'package:e_pasar/pages/driver/views/delivery_view.dart';
import 'package:get/get.dart';


class SplashScreenController extends GetxController {
  late AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    print('🔵 SplashScreenController - onInit');
    _authService = Get.find();
    print('🔵 SplashScreenController - AuthService found');
  }

  @override
  void onReady() {
    super.onReady();
    print('🔵 SplashScreenController - onReady');
    _checkAuth();
  }

  Future<void> _checkAuth() async {
  await Future.delayed(const Duration(seconds: 2));

  final token = _authService.getToken();
  if (token != null && token.isNotEmpty) {
    final role = _authService.getRole();
    if (role != null && role.isNotEmpty) {
      await _navigateToHome(role); // ← tambah await
    } else {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  } else {
    Get.offAllNamed(AppRoutes.LOGIN);
  }
}

Future<void> _navigateToHome(String role) async {
  switch (role.toLowerCase()) {
    case 'driver':
      // Cek dulu apakah ada active order
      // await _checkDriverActiveOrder();
      break;
    case 'pedagang':
      Get.offAllNamed(AppRoutes.PEDAGANG_HOME);
      break;
    case 'user':
    default:
      Get.offAllNamed(AppRoutes.USER_HOME);
      break;
  }
}

// Future<void> _checkDriverActiveOrder() async {
//   try {
//     final orderService = Get.find<OrderService>();
//     final activeOrder = await orderService.getActiveOrder();

//     if (activeOrder != null) {
//       final status = activeOrder;
//       final driverId = activeOrder['driver_id'];

//       if ((status == 'dalam_proses' || status == 'dikirim') && driverId != null) {
//         print('🚗 Driver punya active order, redirect ke DeliveryView');
//         Get.offAll(() => const DeliveryView(), arguments: activeOrder['id']);
//         return;
//       }
//     }

//     // Tidak ada active order, ke home biasa
//     print('🏠 Tidak ada active order, ke Driver Home');
//     Get.offAllNamed(AppRoutes.DRIVER_HOME);
//   } catch (e) {
//     print('💥 Error check active order: $e');
//     // Kalau error, tetap ke home
//     Get.offAllNamed(AppRoutes.DRIVER_HOME);
//   }
// }
}