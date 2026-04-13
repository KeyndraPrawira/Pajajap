import 'package:e_pasar/app/data/models/json_parsers.dart';

// driver_wallet_models.dart
class DriverWalletResponse {
  final String status;
  final String message;
  final DriverWalletData data;

  DriverWalletResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DriverWalletResponse.fromJson(Map<String, dynamic> json) {
    return DriverWalletResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: DriverWalletData.fromJson(asMap(json['data']) ?? const {}),
    );
  }
}

class DriverWalletData {
  final int? walletId;
  final int? driverId;
  final int balance;
  final int availableBalance;
  final int pendingWithdrawalAmount;
  final int totalEarned;
  final int totalWithdrawn;
  final String? lastTransactionAt;
  final List<DriverWalletTransaction> recentTransactions;

  DriverWalletData({
    this.walletId,
    this.driverId,
    required this.balance,
    required this.availableBalance,
    required this.pendingWithdrawalAmount,
    required this.totalEarned,
    required this.totalWithdrawn,
    this.lastTransactionAt,
    required this.recentTransactions,
  });

  factory DriverWalletData.fromJson(Map<String, dynamic> json) {
    final recentTransactionsJson =
        (json['recent_transactions'] as List<dynamic>?) ?? const [];

    return DriverWalletData(
      walletId: asInt(json['wallet_id']),
      driverId: asInt(json['driver_id']),
      balance: asInt(json['balance']) ?? 0,
      availableBalance: asInt(json['available_balance']) ?? 0,
      pendingWithdrawalAmount: asInt(json['pending_withdrawal_amount']) ?? 0,
      totalEarned: asInt(json['total_earned']) ?? 0,
      totalWithdrawn: asInt(json['total_withdrawn']) ?? 0,
      lastTransactionAt: json['last_transaction_at']?.toString(),
      recentTransactions: recentTransactionsJson
          .map((e) => DriverWalletTransaction.fromJson(asMap(e) ?? const {}))
          .toList(),
    );
  }
}

class DriverWalletTransactionResponse {
  final String status;
  final String message;
  final List<DriverWalletTransaction> data;
  final int? currentPage;
  final int? lastPage;
  final int? total;

  DriverWalletTransactionResponse({
    required this.status,
    required this.message,
    required this.data,
    this.currentPage,
    this.lastPage,
    this.total,
  });

  factory DriverWalletTransactionResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final pageData =
        rawData is Map<String, dynamic> ? rawData : <String, dynamic>{};
    final list = rawData is List<dynamic>
        ? rawData
        : (pageData['data'] as List<dynamic>?) ?? const [];

    return DriverWalletTransactionResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: list
          .map((e) => DriverWalletTransaction.fromJson(asMap(e) ?? const {}))
          .toList(),
      currentPage: asInt(pageData['current_page']),
      lastPage: asInt(pageData['last_page']),
      total: asInt(pageData['total']),
    );
  }
}

class DriverWalletTransaction {
  final int id;
  final String type; // credit / debit
  final int amount;
  final String description;
  final int? balanceBefore;
  final int? balanceAfter;
  final String? referenceType;
  final int? referenceId;
  final Map<String, dynamic>? metadata;
  final String createdAt;

  DriverWalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    this.balanceBefore,
    this.balanceAfter,
    this.referenceType,
    this.referenceId,
    this.metadata,
    required this.createdAt,
  });

  factory DriverWalletTransaction.fromJson(Map<String, dynamic> json) {
    return DriverWalletTransaction(
      id: asInt(json['id']) ?? 0,
      type: json['type']?.toString() ?? '',
      amount: asInt(json['amount']) ?? 0,
      description: json['description']?.toString() ?? '',
      balanceBefore: asInt(json['balance_before']),
      balanceAfter: asInt(json['balance_after']),
      referenceType: json['reference_type']?.toString(),
      referenceId: asInt(json['reference_id']),
      metadata: asMap(json['metadata']),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class DriverWithdrawalResponse {
  final String status;
  final String message;
  final List<DriverWithdrawalItem> data;

  DriverWithdrawalResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DriverWithdrawalResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final list = rawData is List<dynamic>
        ? rawData
        : ((rawData as Map<String, dynamic>?)?['data'] as List<dynamic>?) ??
            const [];

    return DriverWithdrawalResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: list
          .map((e) => DriverWithdrawalItem.fromJson(asMap(e) ?? const {}))
          .toList(),
    );
  }
}

class DriverWithdrawalItem {
  final int id;
  final int amount;
  final String status; // pending / approved / rejected
  final String? notes;
  final String createdAt;

  DriverWithdrawalItem({
    required this.id,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.notes,
  });

  factory DriverWithdrawalItem.fromJson(Map<String, dynamic> json) {
    return DriverWithdrawalItem(
      id: asInt(json['id']) ?? 0,
      amount: asInt(json['amount']) ?? 0,
      status: json['status']?.toString() ?? '',
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
