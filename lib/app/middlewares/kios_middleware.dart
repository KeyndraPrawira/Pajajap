import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/pages/pedagang/controllers/pedagang_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KiosMiddleware extends GetMiddleware {

  @override
  RouteSettings? redirect(String? route) {
    final controller = Get.find<PedagangController>();

    if (controller.hasKios.value == true) {
      return const RouteSettings(name: AppRoutes.PEDAGANG_HOME);
    }

    return null; // boleh masuk
  }
}
