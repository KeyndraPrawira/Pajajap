// midtrans_service.dart
import 'dart:convert';
import 'package:e_pasar/app/data/models/midtrans_model.dart';
import 'package:http/http.dart' as http;

class MidtransService {
  final String baseUrl;
  final String token;

  MidtransService({
    required this.baseUrl,
    required this.token,
  });

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<MidtransPaymentResponse> createPayment(int orderId) async {
    final url = Uri.parse('$baseUrl/orders/$orderId/payment/midtrans');
    final res = await http.post(url, headers: _headers);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_extractError(res));
    }

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    return MidtransPaymentResponse.fromJson(jsonMap);
  }

  Future<MidtransPaymentResponse> getPaymentStatus(int orderId) async {
    final url = Uri.parse('$baseUrl/orders/$orderId/payment/status');
    final res = await http.get(url, headers: _headers);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_extractError(res));
    }

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    return MidtransPaymentResponse.fromJson(jsonMap);
  }

  String _extractError(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map && body['message'] != null) {
        return body['message'].toString();
      }
    } catch (_) {}
    return 'Request gagal (${res.statusCode})';
  }
}
