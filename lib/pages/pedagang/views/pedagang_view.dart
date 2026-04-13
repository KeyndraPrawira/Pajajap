// lib/app/modules/user/views/user_home_view.dart
import 'package:e_pasar/pages/pedagang/views/pedagang_home_view.dart';
import 'package:e_pasar/pages/pedagang/views/pedagang_profile_view.dart';
import 'package:e_pasar/pages/pedagang/controllers/pedagang_controller.dart';
import 'package:e_pasar/pages/pedagang/views/produk_list_view.dart';
import 'package:e_pasar/pages/pedagang/views/widgets/pedagang_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PedagangView extends StatelessWidget {
  const PedagangView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PedagangController>();

    return Obx(() => Scaffold(
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: [
              const PedagangHomeView(),
              const ProdukListView(),
              const PedagangProfileView(),
            ],
          ),
          backgroundColor: PedagangUi.pageBackground,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            selectedItemColor: PedagangUi.midGreen,
            unselectedItemColor: PedagangUi.textSubtle,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 12,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                activeIcon: Icon(Icons.shopping_cart),
                label: 'Produk',
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
