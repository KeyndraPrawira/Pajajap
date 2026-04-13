import 'package:e_pasar/app/data/models/json_parsers.dart';

// midtrans_models.dart
class MidtransPaymentResponse {
  final String status;
  final String message;
  final MidtransPaymentData data;
  final bool? syncedFromMidtrans;
  final String? syncError;

  MidtransPaymentResponse({
    required this.status,
    required this.message,
    required this.data,
    this.syncedFromMidtrans,
    this.syncError,
  });

  factory MidtransPaymentResponse.fromJson(Map<String, dynamic> json) {
    final meta = asMap(json['meta']);
    return MidtransPaymentResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: MidtransPaymentData.fromJson(asMap(json['data']) ?? const {}),
      syncedFromMidtrans: asBool(meta?['synced_from_midtrans']),
      syncError: meta?['sync_error']?.toString(),
    );
  }
}

class MidtransPaymentData {
  final int orderId;
  final String? kodePesanan;
  final String? midtransOrderId;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? paymentType;
  final String? paymentToken;
  final String? paymentUrl;
  final int grossAmount;
  final String? paidAt;
  final String? clientKey;

  MidtransPaymentData({
    required this.orderId,
    this.kodePesanan,
    this.midtransOrderId,
    this.paymentMethod,
    this.paymentStatus,
    this.paymentType,
    this.paymentToken,
    this.paymentUrl,
    required this.grossAmount,
    this.paidAt,
    this.clientKey,
  });

  factory MidtransPaymentData.fromJson(Map<String, dynamic> json) {
    return MidtransPaymentData(
      orderId: asInt(json['order_id']) ?? 0,
      kodePesanan: json['kode_pesanan']?.toString(),
      midtransOrderId: json['midtrans_order_id']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      paymentType: json['payment_type']?.toString(),
      paymentToken: json['payment_token']?.toString(),
      paymentUrl: json['payment_url']?.toString(),
      grossAmount: asInt(json['gross_amount']) ?? 0,
      paidAt: json['paid_at']?.toString(),
      clientKey: json['client_key']?.toString(),
    );
  }
}
