import 'package:e_pasar/app/data/models/kategori_model.dart';
import 'package:e_pasar/app/utils/api.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;


class KategoriService {
  final box = GetStorage();

  String? get token => box.read("token");

  /// ===============================
  /// 🔹 GET ALL KATEGORI 
  /// ===============================
  Future<Kategori?> getKategori() async {
    final response = await http.get(
      Uri.parse("${Api.baseUrl}/kategori"),
      headers: Api.headersWithAuth(token!),
    );
    
    if (response.statusCode == 200) {
      return kategoriFromJson(response.body);
    } else {
      throw Exception("Gagal ambil kategori");
    }
  }
}