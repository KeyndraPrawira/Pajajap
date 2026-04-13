import 'package:e_pasar/pages/driver/controllers/driver_controller.dart';
import 'package:e_pasar/pages/driver/controllers/order_driver_controller.dart';
import 'package:e_pasar/pages/driver/views/pendapatan_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverHomeView extends GetView<OrderDriverController> {
  const DriverHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final orderController = Get.find<OrderDriverController>();
    final DriverController driverController = Get.find<DriverController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: const CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFF1E88E5),
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: const SizedBox(),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        toolbarHeight: 80,
        actions: [
          Obx(() => Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: driverController.toggleOnline,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: driverController.isOnline.value
                          ? Colors.green
                          : Colors.grey,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      controller.isOnline.value
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
            onRefresh: () => orderController.refreshData(),
            child: IndexedStack(
              index: controller.currentIndex.value,
              children: [
                OrdersTab(orderController: orderController),
                const PendapatanView(),
              ],
            ),
          )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF1E88E5),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment_outlined),
                activeIcon: Icon(Icons.assignment),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.payments_outlined),
                activeIcon: Icon(Icons.payments),
                label: 'Pendapatan',
              ),
            ],
          )),
    );
  }
}

class OrdersTab extends StatelessWidget {
  final OrderDriverController orderController;
  const OrdersTab({super.key, required this.orderController});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => orderController.refreshData(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Obx(() {
            final orders = orderController.pendingOrders;

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
                    Icon(Icons.assignment_outlined,
                        size: 64, color: Colors.grey),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Order Baru',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
                ...orders
                    .map((order) => OrderCard(
                          order: order,
                          controller: orderController,
                        ))
                    .toList(),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final OrderDriverController controller;

  const OrderCard({
    super.key,
    required this.order,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
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
      onDismissed: (_) => controller.ignoreOrder(orderId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFF1565C0), width: 2),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
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
                          order['alamat_pengiriman']?.toString() ??
                              'Alamat lengkap',
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Rp ${(order['ongkir'] ?? 0).toString()}',
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
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
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
