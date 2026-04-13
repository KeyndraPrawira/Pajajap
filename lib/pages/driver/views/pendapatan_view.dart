import 'package:e_pasar/app/data/models/driver_wallet_model.dart';
import 'package:e_pasar/pages/driver/controllers/driver_wallet_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PendapatanView extends GetView<DriverWalletController> {
  const PendapatanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Pendapatan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        actions: [
          Obx(
            () => IconButton(
              onPressed: controller.isLoadingWallet.value ||
                      controller.isLoadingTransactions.value ||
                      controller.isLoadingWithdrawals.value
                  ? null
                  : controller.refreshAll,
              icon: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final wallet = controller.wallet.value;
        final recentTransactions = controller.transactions.take(5).toList();
        final recentWithdrawals = controller.withdrawals.take(5).toList();
        final isInitialLoading =
            controller.isLoadingWallet.value && wallet == null;

        return RefreshIndicator(
          onRefresh: controller.refreshAll,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (isInitialLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 120),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                _buildBalanceCard(wallet),
                const SizedBox(height: 16),
                _buildSummaryRow(wallet),
                const SizedBox(height: 16),
                _buildWithdrawCard(context, wallet),
                const SizedBox(height: 16),
                _buildTodayIncomeChart(),
                const SizedBox(height: 16),
                _buildWithdrawHistory(recentWithdrawals),
                const SizedBox(height: 16),
                _buildTransactionHistory(recentTransactions),
                if (controller.errorMessage.value.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBalanceCard(DriverWalletData? wallet) {
    final availableBalance = wallet?.availableBalance ?? 0;
    final totalBalance = wallet?.balance ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo Tersedia',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.formatRupiah(availableBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Saldo wallet total ${controller.formatRupiah(totalBalance)}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(DriverWalletData? wallet) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Total Masuk',
            value: controller.formatRupiah(wallet?.totalEarned ?? 0),
            icon: Icons.savings_outlined,
            accentColor: const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Sudah Cair',
            value: controller.formatRupiah(wallet?.totalWithdrawn ?? 0),
            icon: Icons.account_balance_wallet_outlined,
            accentColor: const Color(0xFF1565C0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Pending',
            value:
                controller.formatRupiah(wallet?.pendingWithdrawalAmount ?? 0),
            icon: Icons.hourglass_top_rounded,
            accentColor: const Color(0xFFEF6C00),
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawCard(BuildContext context, DriverWalletData? wallet) {
    final availableBalance = wallet?.availableBalance ?? 0;
    final pendingAmount = wallet?.pendingWithdrawalAmount ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Request Withdraw',
            subtitle: 'Ajukan pencairan saldo driver langsung dari halaman ini.',
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo bisa ditarik: ${controller.formatRupiah(availableBalance)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pending withdraw: ${controller.formatRupiah(pendingAmount)}',
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Obx(
              () => ElevatedButton.icon(
                onPressed: availableBalance <= 0 ||
                        controller.isSubmittingWithdrawal.value
                    ? null
                    : () => _showWithdrawDialog(context, availableBalance),
                icon: controller.isSubmittingWithdrawal.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.arrow_circle_up_outlined),
                label: Text(
                  controller.isSubmittingWithdrawal.value
                      ? 'Mengirim Request...'
                      : 'Ajukan Withdraw',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayIncomeChart() {
    final spots = controller.todayIncomeSpots;
    final hasTodayIncome = spots.any((spot) => spot.y > 0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _SectionTitle(
                  title: 'Pendapatan Hari Ini',
                  subtitle: 'Grafik berdasarkan transaksi kredit per jam.',
                ),
              ),
              Text(
                controller.formatRupiah(controller.todayIncome),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!hasTodayIncome)
            Container(
              height: 200,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Belum ada pemasukan hari ini.',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 23,
                  minY: 0,
                  maxY: controller.todayIncomeMaxY,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: controller.todayIncomeMaxY / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.15),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.08),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 4,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${value.toInt().toString().padLeft(2, '0')}:00',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 52,
                        interval: controller.todayIncomeMaxY / 4,
                        getTitlesWidget: (value, meta) => Text(
                          _compactCurrency(value),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: const Color(0xFF4CAF50),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF4CAF50).withOpacity(0.28),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWithdrawHistory(List<DriverWithdrawalItem> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Riwayat Withdraw',
            subtitle: '5 request terbaru yang pernah diajukan driver.',
          ),
          const SizedBox(height: 12),
          if (controller.isLoadingWithdrawals.value && items.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (items.isEmpty)
            const _EmptyState(message: 'Belum ada riwayat withdraw.')
          else
            ...items.map((item) {
              final statusColor =
                  controller.withdrawalStatusColor(item.status);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.outbox_outlined,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.formatRupiah(item.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(item.createdAt),
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                          if ((item.notes ?? '').isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              item.notes!,
                              style: const TextStyle(
                                color: Color(0xFF4B5563),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        controller.withdrawalStatusLabel(item.status),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory(List<DriverWalletTransaction> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Transaksi Terbaru',
            subtitle: 'Mutasi saldo wallet driver terbaru.',
          ),
          const SizedBox(height: 12),
          if (controller.isLoadingTransactions.value && items.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (items.isEmpty)
            const _EmptyState(message: 'Belum ada transaksi wallet.')
          else
            ...items.map((item) {
              final isCredit = item.type == 'credit';
              final amountColor = controller.transactionColor(item.type);
              final prefix = isCredit ? '+' : '-';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: amountColor.withOpacity(0.12),
                      child: Icon(
                        isCredit
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color: amountColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.description.isEmpty
                                ? 'Transaksi wallet'
                                : item.description,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(item.createdAt),
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$prefix${controller.formatRupiah(item.amount)}',
                      style: TextStyle(
                        color: amountColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _showWithdrawDialog(
    BuildContext context,
    int availableBalance,
  ) async {
    final amountController = TextEditingController();

    await Get.dialog(
      AlertDialog(
        title: const Text('Request Withdraw'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo tersedia ${controller.formatRupiah(availableBalance)}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Nominal withdraw',
                hintText: 'Contoh: 50000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: availableBalance > 0
                    ? () {
                        amountController.text = availableBalance.toString();
                      }
                    : null,
                child: const Text('Tarik Semua'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Batal'),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isSubmittingWithdrawal.value
                  ? null
                  : () async {
                      final amount = int.tryParse(
                            amountController.text
                                .replaceAll(RegExp(r'[^0-9]'), ''),
                          ) ??
                          0;

                      if (amount <= 0) {
                        Get.snackbar(
                          'Gagal',
                          'Masukkan nominal withdraw yang valid.',
                        );
                        return;
                      }

                      Get.back();
                      await controller.createWithdrawal(amount);
                    },
              child: controller.isSubmittingWithdrawal.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Kirim'),
            ),
          ),
        ],
      ),
      barrierDismissible: !controller.isSubmittingWithdrawal.value,
    );

    amountController.dispose();
  }

  String _formatDate(String raw) {
    final parsed = DateTime.tryParse(raw)?.toLocal();
    if (parsed == null) {
      return raw;
    }

    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(parsed);
  }

  String _compactCurrency(double value) {
    if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)}jt';
    }

    if (value >= 1000) {
      return 'Rp ${(value / 1000).round()}k';
    }

    return 'Rp ${value.toInt()}';
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: accentColor.withOpacity(0.12),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
