// lib/app/services/order_service.dart

import 'dart:convert';
import 'package:e_pasar/app/services/order_realtime_services.dart';
import 'package:e_pasar/app/utils/api.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class OrderService {
  final box = GetStorage();
  OrderRealTimeService? _realTimeService;

  String? get token => box.read('token');
  void initRealTime(Function(Map<String, dynamic>) onOrderUpdate) {
    _realTimeService = OrderRealTimeService(onOrderUpdate: onOrderUpdate);
  }
  Future<void> connectRealTime() async {
    if (_realTimeService != null) {
      await _realTimeService!.connect();
    }
  }
  Future<void> disconnectRealTime() async {
    await _realTimeService?.disconnect();
  }

  bool get isRealTimeConnected => _realTimeService != null;

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
            final uri = Uri.parse('${Api.baseUrl}/orders/$id');
      final response = await http.get(
        uri,
        headers: Api.headersWithAuth(token!),
      );
      print('💥 [DETAIL ORDER] Exception: $e');
           print('📥 [MY ORDERS] Body: ${response.body}');
      rethrow;
    }
  }

  // ── PENDING ORDERS FOR DRIVER ─────────────────────────────────
  // GET /api/orders/pending
  Future<List<dynamic>> getPendingOrders() async {
    try {
      if (token == null) throw Exception('Token tidak ditemukan');

      final uri = Uri.parse('${Api.baseUrl}/orders/available');
      print('📡 [PENDING ORDERS] URL: $uri');

      final response = await http.get(
        uri,
        headers: Api.headersWithAuth(token!),
      );

      print('📥 [PENDING ORDERS] Status: ${response.statusCode}');
      print('📥 [PENDING ORDERS] Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['data'] as List<dynamic>;
      } else {
        throw Exception('Gagal ambil pending orders (${response.statusCode})');
      }
    } catch (e) {
      print('💥 [PENDING ORDERS] Exception: $e');
      return [];
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

  Future<Map<String, dynamic>> processedOrder(int orderId) async {
    try {
      if (token == null) throw Exception('Token tidak ditemukan');

      final uri = Uri.parse('${Api.baseUrl}/orders/$orderId/processed');
      print('📡 [PROCESSED ORDER] URL: $uri');

      final response = await http.post(
        uri,
        headers: Api.headersWithAuth(token!),
      );

      print('📥 [PROCESSED ORDER] Status: ${response.statusCode}');
      print('📥 [PROCESSED ORDER] Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return {'success': true, 'data': decoded['data']};
      } else if (response.statusCode == 403) {
        throw Exception('Hanya driver yang dapat memproses order');
      } else if (response.statusCode == 400) {
        throw Exception('Order belum diterima atau sudah diproses');
      } else if (response.statusCode == 404) {
        throw Exception('Order tidak ditemukan');
      } else {
        final decoded = json.decode(response.body);
        throw Exception(decoded['message'] ?? 'Gagal proses order');
      }
    } catch (e) {
      print('💥 [PROCESSED ORDER] Exception: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateItemStatus(int orderId, String status,
      {String? catatan}) async {
    try {
      if (token == null) throw Exception('Token tidak ditemukan');
      final uri = Uri.parse('${Api.baseUrl}/order-item/$orderId');
      print('📡 [UPDATE ITEM STATUS] URL: $uri');

      final body = <String, dynamic>{'status': status};
      if (catatan != null && catatan.isNotEmpty) {
        body['catatan'] = catatan;
      }

      final response = await http.patch(
        uri,
        headers: {
          ...Api.headersWithAuth(token!),
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      print('📥 [UPDATE ITEM STATUS] Status: ${response.statusCode}');
      print('📥 [UPDATE ITEM STATUS] Body: ${response.body}');
      final decoded = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': decoded['data']};
      } else if (response.statusCode == 403) {
        throw Exception('Bukan driver / bukan order kamu');
      } else if (response.statusCode == 422) {
        throw Exception(decoded['message'] ?? 'Validasi gagal');
      } else if (response.statusCode == 404) {
        throw Exception('Item tidak ditemukan');
      } else {
        throw Exception(decoded['message'] ?? 'Gagal update status');
      }
    } catch (e) {
      print('💥 [UPDATE ITEM STATUS] Exception: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> requestGanti(int itemId) async {
  try {
    if (token == null) throw Exception('Token tidak ditemukan');

    final uri = Uri.parse('${Api.baseUrl}/order-item/$itemId/request-ganti');
    print('📡 [REQUEST GANTI] URL: $uri');

    final response = await http.patch(
      uri,
      headers: Api.headersWithAuth(token!),
    );

    print('📥 [REQUEST GANTI] Status: ${response.statusCode}');
    print('📥 [REQUEST GANTI] Body: ${response.body}');

    final decoded = json.decode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'data': decoded['data']};
    } else if (response.statusCode == 403) {
      throw Exception('Bukan driver / bukan order kamu');
    } else if (response.statusCode == 400) {
      throw Exception(decoded['message'] ?? 'Item tidak bisa diproses');
    } else if (response.statusCode == 404) {
      throw Exception('Item tidak ditemukan');
    } else {
      throw Exception(decoded['message'] ?? 'Gagal request ganti');
    }
  } catch (e) {
    print('💥 [REQUEST GANTI] Exception: $e');
    rethrow;
  }
}

  Future<Map<String, dynamic>> pilihPengganti(int itemId, int produkId) async {
  try {
    if (token == null) throw Exception('Token tidak ditemukan');

    final uri = Uri.parse('${Api.baseUrl}/order-item/$itemId/pilih-pengganti');
    print('📡 [PILIH PENGGANTI] URL: $uri');

    final response = await http.patch(
      uri,
      headers: {
        ...Api.headersWithAuth(token!),
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'produk_pengganti_id': produkId,
      }),
    );

    print('📥 [PILIH PENGGANTI] Status: ${response.statusCode}');
    print('📥 [PILIH PENGGANTI] Body: ${response.body}');

    final decoded = json.decode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'data': decoded['data']};
    } else if (response.statusCode == 403) {
      throw Exception('Bukan user pemilik order');
    } else if (response.statusCode == 400) {
      throw Exception(decoded['message'] ?? 'Item tidak dalam kondisi menunggu');
    } else if (response.statusCode == 422) {
      throw Exception('Produk tidak valid');
    } else if (response.statusCode == 404) {
      throw Exception('Item tidak ditemukan');
    } else {
      throw Exception(decoded['message'] ?? 'Gagal pilih pengganti');
    }
  } catch (e) {
    print('💥 [PILIH PENGGANTI] Exception: $e');
    rethrow;
  }
}

Future<Map<String, dynamic>> tidakJadi(int itemId) async {
  try {
    if (token == null) throw Exception('Token tidak ditemukan');

    final uri = Uri.parse('${Api.baseUrl}/order-item/$itemId/tidak-jadi');
    print('📡 [TIDAK JADI] URL: $uri');

    final response = await http.patch(
      uri,
      headers: Api.headersWithAuth(token!),
    );

    print('📥 [TIDAK JADI] Status: ${response.statusCode}');
    print('📥 [TIDAK JADI] Body: ${response.body}');

    final decoded = json.decode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'data': decoded['data']};
    } else if (response.statusCode == 403) {
      throw Exception('Bukan user pemilik order');
    } else if (response.statusCode == 400) {
      throw Exception(decoded['message'] ?? 'Item tidak dalam kondisi menunggu');
    } else if (response.statusCode == 404) {
      throw Exception('Item tidak ditemukan');
    } else {
      throw Exception(decoded['message'] ?? 'Gagal membatalkan item');
    }
  } catch (e) {
    print('💥 [TIDAK JADI] Exception: $e');
    rethrow;
  }
}

  // Cek apakah driver punya active order
Future<List<dynamic>> getActiveOrder() async {
  try {
    if (token == null) return [];

    final uri = Uri.parse('${Api.baseUrl}/orders/active');
    final response = await http.get(uri, headers: Api.headersWithAuth(token!));

   
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded['data'] as List<dynamic>;
    }
    return [];
  } catch (e) {
    print('💥 [ACTIVE ORDER] Exception: $e');
    return [];
  }
}
  
  // KIRIM ORDER
  Future<Map<String, dynamic>> sendDelivery(int orderId) async {
    try {
      if (token == null) throw Exception('Token tidak ditemukan');

      final uri = Uri.parse('${Api.baseUrl}/orders/$orderId/send'); 
      print('📡 [SEND ORDER] URL: $uri');

      final response = await http.post(
        uri,
        headers: Api.headersWithAuth(token!),
      );

      print('📥 [SEND ORDER] Status: ${response.statusCode}');
      print('📥 [SEND ORDER] Body: ${response.body}');

      final decoded = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': decoded['data']};
      } else if (response.statusCode == 403) {
        throw Exception('Hanya driver yang dapat mengirim order');
      } else if (response.statusCode == 400) {
        // ← ini penting: backend return 400 kalau masih ada item pending
        throw Exception(decoded['message'] ?? 'Order tidak dapat dikirim');
      } else if (response.statusCode == 404) {
        throw Exception('Order tidak ditemukan');
      } else {
        throw Exception(decoded['message'] ?? 'Gagal kirim order');
      }
    } catch (e) {
      print('💥 [SEND ORDER] Exception: $e');
      rethrow;
    }
  }

  // ── COMPLETE DELIVERY (Driver) ───────────────────────────────
  Future<Map<String, dynamic>> completeDelivery(int orderId) async {
    try {
      if (token == null) throw Exception('Token tidak ditemukan');

      final uri = Uri.parse('${Api.baseUrl}/orders/$orderId/complete');
      print('📡 [COMPLETE DELIVERY] URL: $uri');

      final response = await http.post(
        uri,
        headers: Api.headersWithAuth(token!),
      );

      print('📥 [COMPLETE DELIVERY] Status: ${response.statusCode}');
      print('📥 [COMPLETE DELIVERY] Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return {'success': true, 'data': decoded['data']};
      } else if (response.statusCode == 403) {
        throw Exception('Hanya driver yang dapat menyelesaikan delivery');
      } else if (response.statusCode == 400) {
        throw Exception('Order belum diterima atau sudah selesai');
      } else if (response.statusCode == 404) {
        throw Exception('Order tidak ditemukan');
      } else {
        final decoded = json.decode(response.body);
        throw Exception(decoded['message'] ?? 'Gagal complete delivery');
      }
    } catch (e) {
      print('💥 [COMPLETE DELIVERY] Exception: $e');
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