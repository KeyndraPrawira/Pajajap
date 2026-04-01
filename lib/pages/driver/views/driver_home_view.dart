import 'package:e_pasar/pages/driver/controllers/driver_controller.dart';
import 'package:e_pasar/pages/driver/controllers/order_driver_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pendapatan_view.dart';

import 'package:e_pasar/pages/driver/controllers/driver_controller.dart';
import 'package:e_pasar/pages/driver/controllers/order_driver_controller.dart';
import 'package:e_pasar/pages/driver/views/pendapatan_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverHomeView extends GetView<OrderDriverController> {
  DriverHomeView({super.key});
  
  final driver = Get.find<DriverController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage('https://via.placeholder.com/60'),
          child: Icon(Icons.person),
        ),
        title: const SizedBox(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF4FC3F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Obx(() => Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: driver.toggleOnline,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: driver.isOnline.value ? Colors.green : Colors.grey,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  driver.isOnline.value 
                    ? Icons.power_settings_new 
                    : Icons.power_settings_new_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          )),
        ],
      ),
      body: Obx(() => RefreshIndicator(
        onRefresh: controller.refreshData, // ✅ FIXED
        child: IndexedStack(
          index: driver.currentIndex.value,
          children: [
            // Tab 1: Orders
            RefreshIndicator(
              onRefresh: controller.refreshData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _buildOrdersSection(controller),
                ],
              ),
            ),
            // Tab 2: Pendapatan
            const PendapatanView(),
          ],
        ),
      )),
    );
  }

  Widget _buildOrdersSection(OrderDriverController controller) {
    return Obx(() {
      final orders = controller.pendingOrders;
      
      if (orders.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Tidak ada order baru', 
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Order akan muncul otomatis di sini\nsaat ada buyer baru', 
                textAlign: TextAlign.center, 
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Baru', 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${orders.length} order',
                  style: TextStyle(
                    fontSize: 14, 
                    color: Colors.green.shade800, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Orders List
          ...orders.map((order) => _buildOrderCard(controller, order)).toList(),
        ],
      );
    });
  }

  Widget _buildOrderCard(OrderDriverController controller, Map<String, dynamic> order) {
    final orderId = order['id'] as int;
    final isLoading = controller.loadingOrders[orderId] ?? false;
    
    return Dismissible(
      key: ValueKey(orderId),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.close, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => controller.ignoreOrder(orderId), // ✅ Method dipanggil
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Buyer & Location
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade300, Colors.blue.shade500],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue.shade600, width: 2),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['buyer']?['name']?.toString() ?? 'Nama Buyer',
                          style: const TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order['alamat_pengiriman']?.toString() ?? 'Alamat lengkap',
                          style: TextStyle(
                            fontSize: 14, 
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, 
                                size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              '${order['jarak_km'] ?? 0} km',
                              style: TextStyle(
                                fontSize: 14, 
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Ongkir
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, 
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Rp ${(order['ongkir'] ?? 0).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      onPressed: () => controller.ignoreOrder(orderId),
                      child: const Text(
                        'Abaikan',
                        style: TextStyle(
                          fontSize: 16, 
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: isLoading 
                          ? null 
                          : () => controller.acceptOrder(orderId),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, 
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text(
                              'Terima Order',
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}