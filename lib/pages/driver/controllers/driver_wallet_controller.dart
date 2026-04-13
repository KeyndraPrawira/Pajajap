import 'package:e_pasar/app/data/models/driver_wallet_model.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:e_pasar/app/services/driver_wallet_services.dart';
import 'package:e_pasar/app/utils/api.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverWalletController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  late final DriverWalletService _walletService;

  final RxBool isLoadingWallet = false.obs;
  final RxBool isLoadingTransactions = false.obs;
  final RxBool isLoadingWithdrawals = false.obs;
  final RxBool isSubmittingWithdrawal = false.obs;
  final Rxn<DriverWalletData> wallet = Rxn<DriverWalletData>(null);
  final RxList<DriverWalletTransaction> transactions =
      <DriverWalletTransaction>[].obs;
  final RxList<DriverWithdrawalItem> withdrawals = <DriverWithdrawalItem>[].obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _walletService = DriverWalletService(
      baseUrl: Api.baseUrl,
      token: _authService.getToken() ?? '',
    );
    refreshAll();
  }

  Future<void> fetchWallet({bool showSnackbarOnError = false}) async {
    isLoadingWallet.value = true;
    errorMessage.value = '';

    try {
      final response = await _walletService.getWallet();
      wallet.value = response.data;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      if (showSnackbarOnError) {
        Get.snackbar('Gagal', errorMessage.value);
      }
    } finally {
      isLoadingWallet.value = false;
    }
  }

  Future<void> fetchTransactions({bool showSnackbarOnError = false}) async {
    isLoadingTransactions.value = true;
    errorMessage.value = '';

    try {
      final response = await _walletService.getTransactions();
      transactions.assignAll(response.data);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      if (showSnackbarOnError) {
        Get.snackbar('Gagal', errorMessage.value);
      }
    } finally {
      isLoadingTransactions.value = false;
    }
  }

  Future<void> fetchWithdrawals({bool showSnackbarOnError = false}) async {
    isLoadingWithdrawals.value = true;
    errorMessage.value = '';

    try {
      final response = await _walletService.getWithdrawals();
      withdrawals.assignAll(response.data);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      if (showSnackbarOnError) {
        Get.snackbar('Gagal', errorMessage.value);
      }
    } finally {
      isLoadingWithdrawals.value = false;
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([
      fetchWallet(),
      fetchTransactions(),
      fetchWithdrawals(),
    ]);
  }

  Future<void> createWithdrawal(int amount) async {
    if (amount <= 0) {
      Get.snackbar('Gagal', 'Nominal penarikan harus lebih dari 0.');
      return;
    }

    final availableBalance = wallet.value?.availableBalance ?? 0;
    if (amount > availableBalance) {
      Get.snackbar(
        'Gagal',
        'Nominal penarikan melebihi saldo yang bisa ditarik.',
      );
      return;
    }

    isSubmittingWithdrawal.value = true;
    errorMessage.value = '';

    try {
      await _walletService.createWithdrawal(amount);
      Get.snackbar('Berhasil', 'Permintaan penarikan berhasil dibuat.');
      await Future.wait([
        fetchWallet(),
        fetchTransactions(),
        fetchWithdrawals(),
      ]);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar('Gagal', errorMessage.value);
    } finally {
      isSubmittingWithdrawal.value = false;
    }
  }

  String formatRupiah(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final positionFromEnd = text.length - i;
      buffer.write(text[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'Rp $buffer';
  }

  Color transactionColor(String type) {
    return type == 'credit' ? Colors.green : Colors.red;
  }

  int get todayIncome {
    final now = DateTime.now();
    return transactions
        .where((item) {
          if (item.type != 'credit') {
            return false;
          }

          final createdAt = DateTime.tryParse(item.createdAt)?.toLocal();
          if (createdAt == null) {
            return false;
          }

          return createdAt.year == now.year &&
              createdAt.month == now.month &&
              createdAt.day == now.day;
        })
        .fold<int>(0, (total, item) => total + item.amount);
  }

  List<FlSpot> get todayIncomeSpots {
    final now = DateTime.now();
    final hourlyIncome = List<int>.filled(24, 0);

    for (final item in transactions) {
      if (item.type != 'credit') {
        continue;
      }

      final createdAt = DateTime.tryParse(item.createdAt)?.toLocal();
      if (createdAt == null) {
        continue;
      }

      final isToday = createdAt.year == now.year &&
          createdAt.month == now.month &&
          createdAt.day == now.day;

      if (!isToday) {
        continue;
      }

      hourlyIncome[createdAt.hour] += item.amount;
    }

    return List<FlSpot>.generate(
      hourlyIncome.length,
      (index) => FlSpot(index.toDouble(), hourlyIncome[index].toDouble()),
    );
  }

  double get todayIncomeMaxY {
    final spots = todayIncomeSpots;
    if (spots.every((spot) => spot.y == 0)) {
      return 1;
    }

    final maxValue = spots
        .map((spot) => spot.y)
        .reduce((current, next) => current > next ? current : next);

    return maxValue * 1.2;
  }

  Color withdrawalStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String withdrawalStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'pending':
        return 'Menunggu';
      default:
        return status;
    }
  }
}
