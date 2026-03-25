// lib/pages/driver/controllers/driver_controller.dart
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

class DriverController extends GetxController {
  final AuthService _authService = Get.find();

  // Dummy data for driver home
  var balance = 'Rp 250.000'.obs;
  var incomeSpots = <FlSpot>[].obs;

  @override
  void onInit() {
    super.onInit();
    generateDummyIncomeData();
  }

  void generateDummyIncomeData() {
    incomeSpots.clear();
    final now = DateTime.now();
    for (int hour = 8; hour <= 18; hour++) {
      final time = now.add(Duration(hours: hour - now.hour));
      final value = (50 + (hour * 20) + (20 * (hour.remainder(5)))).toDouble() * 1000; // Rp values
      incomeSpots.add(FlSpot(time.hour.toDouble(), value));
    }
    incomeSpots.refresh();
  }

  void refreshData() {
    // Simulate refresh
    balance.value = 'Rp ${250000 + (10000 * DateTime.now().millisecond ~/ 1000 % 10)}';
    generateDummyIncomeData();
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.LOGIN);
  }
}
