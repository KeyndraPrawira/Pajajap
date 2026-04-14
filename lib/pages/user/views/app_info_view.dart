// lib/pages/user/views/pasar_list_view.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_pasar/pages/user/controllers/pasar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppInfoView extends StatelessWidget {
  const AppInfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PasarController controller = Get.find<PasarController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Aplikasi Pajajap'),
        backgroundColor: const Color(0xFF0077B6),
        foregroundColor: Colors.white,
      ),
      
    );
  }
}
