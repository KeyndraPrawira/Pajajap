// driver_wallet_service.dart
import 'dart:convert';
import 'package:e_pasar/app/data/models/driver_wallet_model.dart';
import 'package:http/http.dart' as http;

class DriverWalletService {
  final String baseUrl;
  final String token;

  DriverWalletService({
    required this.baseUrl,
    required this.token,
  });

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<DriverWalletResponse> getWallet() async {
    final url = Uri.parse('$baseUrl/driver/wallet');
    final res = await http.get(url, headers: _headers);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_extractError(res));
    }

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    return DriverWalletResponse.fromJson(jsonMap);
  }

  Future<DriverWalletTransactionResponse> getTransactions() async {
    final url = Uri.parse('$baseUrl/driver/wallet/transactions');
    final res = await http.get(url, headers: _headers);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_extractError(res));
    }

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    return DriverWalletTransactionResponse.fromJson(jsonMap);
  }

  Future<DriverWithdrawalResponse> getWithdrawals() async {
    final url = Uri.parse('$baseUrl/driver/wallet/withdrawals');
    final res = await http.get(url, headers: _headers);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_extractError(res));
    }

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    return DriverWithdrawalResponse.fromJson(jsonMap);
  }

  Future<void> createWithdrawal(int amount) async {
    final url = Uri.parse('$baseUrl/driver/wallet/withdrawals');
    final res = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'amount': amount}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_extractError(res));
    }
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
