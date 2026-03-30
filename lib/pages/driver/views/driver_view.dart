import 'package:e_pasar/pages/driver/views/driver_active_order_view.dart';
import 'package:e_pasar/pages/driver/views/riwayat_view.dart';
import 'package:e_pasar/pages/profile/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'driver_home_view.dart';
import 'pendapatan_view.dart';
import '../controllers/driver_controller.dart';

class DriverView extends GetView<DriverController> {
  const DriverView({super.key});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children:  [
          DriverHomeView(),
          DriverActiveOrderView(),
          PendapatanView(),
          RiwayatView(),
          ProfileView()

        ],
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: (index) => controller.currentIndex.value = index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor:  const Color.fromARGB(255, 14, 128, 18),
                unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.bike_scooter_outlined),
            activeIcon: Icon(Icons.bike_scooter),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'Pendapatan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_outlined),
            activeIcon: Icon(Icons.note),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      )),
    );
  }
}

