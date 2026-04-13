// lib/app/modules/user/views/user_home_view.dart
import 'package:e_pasar/pages/user/controllers/user_controller.dart';
import 'package:e_pasar/pages/user/views/user_home_view.dart';
import 'package:e_pasar/pages/user/views/user_order_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'user_profile_view.dart';

class UserView extends StatelessWidget {
  const UserView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();

    final List<Widget> pages = [
      UserHomeView(),
      const UserOrderView(),
      const UserProfileView(),
    ];

    return Obx(() => Scaffold(
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            selectedItemColor: const Color(0xFF0D47A1),
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notes_outlined),
                activeIcon: Icon(Icons.notes),
                label: 'Pesanan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ));
  }
}
