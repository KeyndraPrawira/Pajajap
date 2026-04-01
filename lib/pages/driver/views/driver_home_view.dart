import 'package:e_pasar/pages/driver/controllers/driver_controller.dart';
import 'package:e_pasar/pages/driver/controllers/order_driver_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pendapatan_view.dart';

class DriverHomeView extends GetView<OrderDriverController> {
   DriverHomeView({super.key});
  final driver = DriverController();

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
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  driver.isOnline.value ? Icons.power_settings_new : Icons.power_settings_new_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.pollPendingOrders,
        child: Obx(() => IndexedStack(
          index: driver.currentIndex.value,
          children: [
            // Beranda - Orders only
            RefreshIndicator(
              onRefresh: controller.pollPendingOrders,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _buildOrdersList(controller),
                ],
              ),
            ),
            // Pendapatan
            const PendapatanView(),
          ],
        )),
      ),
    );
  }

  Widget _buildOrdersList(OrderDriverController controller) {
    return Obx(() {
      final orders = controller.pendingOrders;
      if (orders.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Tidak ada order baru', style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 8),
              Text('Order akan muncul otomatis di sini saat ada buyer baru', 
                textAlign: TextAlign.center, 
                style: TextStyle(color: Colors.grey)),
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
              Text('Order Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('${orders.length} order', style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          ...orders.map((order) => Container(
            margin: EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: ValueKey(order['id']),
              direction: DismissDirection.endToStart,
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.close, color: Colors.white, size: 28),
              ),
              onDismissed: (_) => controller.ignoreOrder(order['id']),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue.shade300, width: 2),
                          ),
                          child: Icon(Icons.person, color: Colors.blue, size: 24),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (order['buyer']?['name'] ?? 'Nama Buyer') as String,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                order['alamat_pengiriman'] ?? 'Alamat lengkap',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 16, color: Colors.green),
                                  SizedBox(width: 4),
                                  Text(
                                    '${order['jarak_km'] ?? 0} km',
                                    style: TextStyle(fontSize: 14, color: Colors.green),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            'Rp ${(order['ongkir'] ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => controller.ignoreOrder(order['id']),
                            child: Text('Abaikan', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
onPressed: controller.loadingOrders[order['id']] == true 
                              ? null 
                              : () => controller.acceptOrder(order['id']),
                            child: controller.loadingOrders[order['id']] == true 
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text('Terima Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
        ],
      );
  });
  }
}

