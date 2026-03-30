import 'dart:async';
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:e_pasar/app/services/order_services.dart';
import 'package:e_pasar/app/services/profile_services.dart';
import 'package:e_pasar/app/services/user_services.dart';
import 'package:e_pasar/pages/driver/views/delivery_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';



class DriverController extends GetxController {
  final AuthService _authService = Get.find();
  
  final UserService userService = Get.put(UserService());
  
  var currentIndex = 0.obs;
  var isOnline = false.obs;
  var profileFoto = ''.obs;

  
  
@override
  void onInit() {
    super.onInit();
    loadIsOnline();
   
  }

  Future<void> loadIsOnline() async {
    try {
      final token = _authService.getToken();
      final profile = await ProfileService.getProfile(token!);
      isOnline.value = profile?.data?.isOnline ?? false;
      profileFoto.value = profile?.data?.fotoProfil ?? '';
    } catch (e) {
      print('Error loading is_online: $e');
      isOnline.value = false;
    }
  }



  Future<void> toggleOnline() async {
    try {
      final newStatus = !isOnline.value;
      await userService.setActive(newStatus);
      isOnline.value = newStatus;
      Get.snackbar('Status Updated', 'Status aktif berhasil diubah');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }


  
  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

    


  }



