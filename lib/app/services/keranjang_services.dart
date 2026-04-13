import 'dart:convert';
import 'package:e_pasar/app/data/models/keranjang_model.dart';
import 'package:e_pasar/app/utils/api.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class KeranjangServices {
  final box = GetStorage();

  String? get token => box.read("token");

  // ── GET ALL KERANJANG ──────────────────────────────────────
  Future<Keranjang?> getKeranjang() async {
    try {
      if (token == null) {
        print("❌ [KERANJANG] Token null, user belum login");
        throw Exception("Token tidak ditemukan");
      }

      final uri = Uri.parse("${Api.baseUrl}/keranjang");
      print("📡 [GET KERANJANG] URL: $uri");
      print("📡 [GET KERANJANG] Token: $token");

      final response = await http.get(
        uri,
        headers: Api.headersWithAuth(token!),
      );

      print("📥 [GET KERANJANG] Status: ${response.statusCode}");
      print("📥 [GET KERANJANG] Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print("📦 [GET KERANJANG] Decoded: $decoded");
        print("📦 [GET KERANJANG] data type: ${decoded['data'].runtimeType}");
        return Keranjang.fromJson(decoded);
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized - token tidak valid atau expired");
      } else {
        throw Exception(
            "Gagal ambil keranjang (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("💥 [GET KERANJANG] Exception: $e");
      rethrow;
    }
  }

  // ── ADD TO KERANJANG ───────────────────────────────────────
  Future<Keranjang?> addToKeranjang({
    required String produkId,
    required String jumlah,
    required int hargaTotal,
  }) async {
    try {
      if (token == null) throw Exception("Token tidak ditemukan");

      final uri = Uri.parse("${Api.baseUrl}/keranjang/$produkId");
      print("📡 [ADD KERANJANG] URL: $uri");
      print("📡 [ADD KERANJANG] Body: jumlah=$jumlah");

      final response = await http.post(
        uri,
        headers: Api.headersWithAuth(token!),
        body: json.encode({"jumlah": jumlah}),
      );

      print("📥 [ADD KERANJANG] Status: ${response.statusCode}");
      print("📥 [ADD KERANJANG] Body: ${response.body}");

      if (response.statusCode == 200) {
        return Keranjang.fromJson(json.decode(response.body));
      } else if (response.statusCode == 403) {
        throw Exception("Akses ditolak - hanya role 'user' yang bisa");
      } else if (response.statusCode == 404) {
        throw Exception("Produk tidak ditemukan");
      } else {
        throw Exception(
            "Gagal tambah keranjang (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("💥 [ADD KERANJANG] Exception: $e");
      rethrow;
    }
  }

  // ── UPDATE KERANJANG ───────────────────────────────────────
  Future<Keranjang?> updateKeranjang({
    required int id,
    required String produkId,
    required String jumlah,
    required int hargaTotal,
  }) async {
    try {
      if (token == null) throw Exception("Token tidak ditemukan");

      final uri = Uri.parse("${Api.baseUrl}/keranjang/$id");
      print("📡 [UPDATE KERANJANG] URL: $uri");

      final response = await http.put(
        uri,
        headers: Api.headersWithAuth(token!),
        body: json.encode({"jumlah": jumlah}),
      );

      print("📥 [UPDATE KERANJANG] Status: ${response.statusCode}");
      print("📥 [UPDATE KERANJANG] Body: ${response.body}");

      if (response.statusCode == 200) {
        return Keranjang.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            "Gagal update keranjang (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("💥 [UPDATE KERANJANG] Exception: $e");
      rethrow;
    }
  }

  // ── DELETE KERANJANG ───────────────────────────────────────
  Future<bool> deleteKeranjang(int id) async {
    try {
      if (token == null) throw Exception("Token tidak ditemukan");

      final uri = Uri.parse("${Api.baseUrl}/keranjang/$id");
      print("📡 [DELETE KERANJANG] URL: $uri");

      final response = await http.delete(
        uri,
        headers: Api.headersWithAuth(token!),
      );

      print("📥 [DELETE KERANJANG] Status: ${response.statusCode}");
      print("📥 [DELETE KERANJANG] Body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("💥 [DELETE KERANJANG] Exception: $e");
      rethrow;
    }
  }
}
