import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/driver_controller.dart';

class DriverHomeView extends GetView<DriverController> {
  const DriverHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Beranda Driver',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        actions: [
          Obx(() => Badge(
            isLabelVisible: controller.pendingOrders.isNotEmpty,
            label: Text('${controller.pendingOrders.length}'),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: controller.refreshData,
            ),
          )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.pollPendingOrders,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saldo Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF4CAF50), const Color(0xFF81C784)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo Saat Ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                      controller.balance.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    )),
                    const SizedBox(height: 4),
                    const Text(
                      'Klik refresh untuk update',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pending Orders Section
              Obx(() {
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
                        Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('Tidak ada order baru', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        Text('Order akan muncul otomatis\\ndi sini saat ada buyer baru', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500)),
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
                        const Text('Order Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('${orders.length} order', style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...orders.map((order) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: ValueKey(order['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.close, color: Colors.white, size: 28),
                        ),
                        onDismissed: (_) => controller.ignoreOrder(order['id']),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
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
                                  // Left: PFP (placeholder)
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.blue.shade300, width: 2),
                                    ),
                                    child: Icon(Icons.person, color: Colors.blue.shade600, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  // Center: Name + Alamat + Jarak
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (order['buyer']?['name'] ?? 'Nama Buyer') as String,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          order['alamat_pengiriman'] ?? 'Alamat lengkap',
                                          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on_outlined, size: 16, color: Colors.green),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${order['jarak_km'] ?? 0} km',
                                              style: TextStyle(fontSize: 14, color: Colors.green.shade700),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Right: Ongkir
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () => controller.ignoreOrder(order['id']),
                                      child: const Text('Abaikan', style: TextStyle(color: Colors.grey, fontSize: 16)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () => controller.acceptOrder(order['id']),
                                      child: const Text('Terima Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )).toList(),
                  ],
                );
              }),

              // Income Chart
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(top: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pendapatan Hari Ini',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: Obx(() => LineChart(
                        LineChartData(
                          gridData: const FlGridData(
                            show: true,
                            drawVerticalLine: true,
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) => Text('${value.toInt()}:00', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: controller.incomeSpots,
                              isCurved: true,
                              color: const Color(0xFF4CAF50),
                              barWidth: 3,
                            ),
                          ],
                        ),
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

