import 'dart:typed_data';
import 'package:e_pasar/app/data/models/produk_model.dart';
import 'package:e_pasar/app/utils/api.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ProdukService {
  final box = GetStorage();

  String? get token => box.read("token");

  /// ===============================
  /// 🔹 GET ALL PRODUK
  /// ===============================
  Future<Produk?> getProduk({
    int? kategoriId,
    String? search,
  }) async {
    String url = "${Api.baseUrl}/produk";

    Map<String, String> queryParams = {};

    if (kategoriId != null) {
      queryParams["kategori_id"] = kategoriId.toString();
    }

    if (search != null && search.isNotEmpty) {
      queryParams["search"] = search;
    }

    if (queryParams.isNotEmpty) {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      url = uri.toString();
    }

    final response = await http.get(
      Uri.parse(url),
      headers: Api.headers,
    );
    print("=== PRODUK SERVICE ===");
    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");
    print("errorMessage: ${response.reasonPhrase}");

    if (response.statusCode == 200) {
      return produkFromJson(response.body);
    } else {
      throw Exception("Gagal ambil produk");
    }
  }

  /// ===============================
  /// 🔹 CREATE PRODUK
  /// ===============================
  Future<bool> createProduk({
    required String namaProduk,
    required int kategoriId,
    required int harga,
    required int stok,
    required int beratSatuan,
    String? deskripsi,
    Uint8List? fotoBytes,
    String? fotoFilename,
  }) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("${Api.baseUrl}/produk"),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields["nama_produk"] = namaProduk;
    request.fields["kategori_id"] = kategoriId.toString();
    request.fields["harga"] = harga.toString();
    request.fields["stok"] = stok.toString();
    request.fields["berat_satuan"] = beratSatuan.toString();
    request.fields["deskripsi"] = deskripsi ?? "";

    // debug log semua fields sebelum kirim create
    print('📤 createProduk fields: ${request.fields}');

    if (fotoBytes != null && fotoFilename != null) {
      request.files.add(
        http.MultipartFile.fromBytes("foto", fotoBytes, filename: fotoFilename),
      );
    }

    var response = await request.send();

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception("Gagal tambah produk");
    }
  }

  /// ===============================
  /// 🔹 UPDATE PRODUK
  /// ===============================
  Future<bool> updateProduk({
    required int id,
    required String namaProduk,
    required int kategoriId,
    required int kiosId,
    required int harga,
    required int stok,
    required int beratSatuan,
    String? deskripsi,
    Uint8List? fotoBytes,
    String? fotoFilename,
  }) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("${Api.baseUrl}/produk/$id?_method=PUT"),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields["nama_produk"] = namaProduk;
    request.fields["kategori_id"] = kategoriId.toString();
    request.fields["kios_id"] = kiosId.toString();
    request.fields["harga"] = harga.toString();
    request.fields["stok"] = stok.toString();
    request.fields["berat_satuan"] = beratSatuan.toString();
    request.fields["deskripsi"] = deskripsi ?? "";

    // debug log semua fields sebelum kirim update
    print('📤 updateProduk fields: ${request.fields}');

    if (fotoBytes != null && fotoFilename != null) {
      request.files.add(
        http.MultipartFile.fromBytes("foto", fotoBytes, filename: fotoFilename),
      );
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Gagal update produk");
    }
  }

  /// ===============================
  /// 🔹 DELETE PRODUK
  /// ===============================
  Future<bool> deleteProduk(int id) async {
    final response = await http.delete(
      Uri.parse("${Api.baseUrl}/produk/$id"),
      headers: Api.headersWithAuth(token!),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Gagal hapus produk");
    }
  }
}
