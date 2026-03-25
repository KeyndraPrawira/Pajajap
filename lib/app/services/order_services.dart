// lib/app/services/order_service.dart

import 'dart:convert';
import 'package:e_pasar/app/utils/api.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class OrderService {
  final box = GetStorage();

  String? get token => box.read('token');

  // ── CHECKOUT (Buyer) ───────────────────────────────────────
  // POST /api/orders
  Future<Map<String, dynamic>> checkout() async {
    try {
      if (token == null) throw Exception('Token tidak ditemukan');

      final uri = Uri.parse('${Api.baseUrl}/orders/checkout');
      print('📡 [CHECKOUT] URL: $uri');

      final response = await http.post(
        uri,
        headers: Api.headersWithAuth(token!),
      );

      print('📥 [CHECKOUT] Status: ${response.statusCode}');
      print('📥 [CHECKOUT] Body: ${response.body}');

      if (response.statusCode == 201) {
        final decoded = json.decode(response.body);
        return {'success': true, 'data': decoded['data']};
      } else if (response.statusCode == 400) {
        throw Exception('Keranjang kosong');
      } else if (response.statusCode == 404) {
        throw Exception('Alamat belum diset');
      } else {
        final decoded = json.decode(response.body);
        throw Exception(decoded['message'] ?? 'Checkout gagal');
      }
    } catch (e) {
      print('💥 [CHECKOUT] Exception: $e');
      rethrow;
    }
  }

  // ── MY ORDERS (Buyer) ──────────────────────────────────────
  // GET /api/orders/my
  Future<List<dynamic>> myOrders() async {
    try {
      if (token == null) throw Exception('Token tidak ditemukan');

      final uri = Uri.parse('${Api.baseUrl}/orders/my');
      print('📡 [MY ORDERS] URL: $uri');

      final response = await http.get(
        uri,
        headers: Api.headersWithAuth(token!),
      );

      print('📥 [MY ORDERS] Status: ${response.statusCode}');
      print('📥 [MY ORDERS] Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['data'] as List<dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - token tidak valid');
      } else {
        throw Exception('Gagal ambil data order (${response.statusCode})');
      }
    } catch (e) {
      print('💥 [MY ORDERS] Exception: $e');
      rethrow;
    }
  }

  // ── DETAIL ORDER ───────────────────────────────────────────
  // GET /api/orders/{id}
  Future<Map<String, dynamic>> detailOrder(int id) async {
    try {
      if (token == null) throw Exception('Token tidak ditemukan');

      final uri = Uri.parse('${Api.baseUrl}/orders/$id');
      print('📡 [DETAIL ORDER] URL: $uri');

      final response = await http.get(
        uri,
        headers: Api.headersWithAuth(token!),
      );

      print('📥 [DETAIL ORDER] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['data'];
      } else if (response.statusCode == 404) {
        throw Exception('Order tidak ditemukan');
      } else {
        throw Exception('Gagal ambil detail order (${response.statusCode})');
      }
    } catch (e) {
      print('💥 [DETAIL ORDER] Exception: $e');
      rethrow;
    }
  }

  // ── ACCEPT ORDER (Driver) ──────────────────────────────────
  // POST /api/orders/{id}/accept
  Future<Map<String, dynamic>> acceptOrder(int orderId) async {
    try {
      if (token == null) throw Exception('Token tidak ditemukan');

      final uri = Uri.parse('${Api.baseUrl}/orders/$orderId/accept');
      print('📡 [ACCEPT ORDER] URL: $uri');

      final response = await http.post(
        uri,
        headers: Api.headersWithAuth(token!),
      );

      print('📥 [ACCEPT ORDER] Status: ${response.statusCode}');
      print('📥 [ACCEPT ORDER] Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return {'success': true, 'data': decoded['data']};
      } else if (response.statusCode == 403) {
        throw Exception('Hanya driver yang dapat menerima order');
      } else if (response.statusCode == 400) {
        throw Exception('Order sudah diambil driver lain');
      } else if (response.statusCode == 404) {
        throw Exception('Order tidak ditemukan');
      } else {
        final decoded = json.decode(response.body);
        throw Exception(decoded['message'] ?? 'Gagal accept order');
      }
    } catch (e) {
      print('💥 [ACCEPT ORDER] Exception: $e');
      rethrow;
    }
  }

  // ── REQUEST CANCEL ─────────────────────────────────────────
  // POST /api/orders/{id}/cancel
  Future<Map<String, dynamic>> requestCancel({
    required int orderId,
    required String reason,
  }) async {
    try {
      if (token == null) throw Exception('Token tidak ditemukan');

      final uri = Uri.parse('${Api.baseUrl}/orders/$orderId/cancel');
      print('📡 [REQUEST CANCEL] URL: $uri');

      final response = await http.post(
        uri,
        headers: Api.headersWithAuth(token!),
        body: json.encode({'reason': reason}),
      );

      print('📥 [REQUEST CANCEL] Status: ${response.statusCode}');
      print('📥 [REQUEST CANCEL] Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return {'success': true, 'data': decoded['data']};
      } else if (response.statusCode == 400) {
        throw Exception('Order tidak dapat dibatalkan');
      } else if (response.statusCode == 403) {
        throw Exception('Tidak memiliki akses untuk membatalkan order ini');
      } else {
        final decoded = json.decode(response.body);
        throw Exception(decoded['message'] ?? 'Gagal request pembatalan');
      }
    } catch (e) {
      print('💥 [REQUEST CANCEL] Exception: $e');
      rethrow;
    }
  }

  // ── CONFIRM CANCEL ─────────────────────────────────────────
  // POST /api/orders/{id}/cancel/confirm
  Future<Map<String, dynamic>> confirmCancel({
    required int orderId,
    required String action, // 'approve' atau 'reject'
  }) async {
    try {
      if (token == null) throw Exception('Token tidak ditemukan');

      final uri =
          Uri.parse('${Api.baseUrl}/orders/$orderId/cancel/confirm');
      print('📡 [CONFIRM CANCEL] URL: $uri');
      print('📡 [CONFIRM CANCEL] Action: $action');

      final response = await http.post(
        uri,
        headers: Api.headersWithAuth(token!),
        body: json.encode({'action': action}),
      );

      print('📥 [CONFIRM CANCEL] Status: ${response.statusCode}');
      print('📥 [CONFIRM CANCEL] Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return {'success': true, 'data': decoded['data']};
      } else if (response.statusCode == 400) {
        throw Exception('Tidak ada permintaan pembatalan aktif');
      } else if (response.statusCode == 403) {
        throw Exception('Tidak berhak mengkonfirmasi permintaan ini');
      } else {
        final decoded = json.decode(response.body);
        throw Exception(decoded['message'] ?? 'Gagal konfirmasi pembatalan');
      }
    } catch (e) {
      print('💥 [CONFIRM CANCEL] Exception: $e');
      rethrow;
    }
  }
}