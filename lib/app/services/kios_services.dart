import 'package:e_pasar/app/data/models/kios_model.dart';
import 'package:e_pasar/app/utils/api.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class KiosService extends GetxService {
  final storage = GetStorage();

  String? get _token => storage.read('token');

  // ================= GET KIOS =================
  Future<Kios?> getKios() async {
    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/kios'),
        headers: Api.headersWithAuth(_token!),
      );

      print('GET KIOS STATUS: ${response.statusCode}');
      print('GET KIOS BODY: ${response.body}');

      if (response.statusCode == 200) {
        return kiosFromJson(response.body);
      }
      return null;
    } catch (e) {
      print('🔥 GET KIOS ERROR: $e');
      return null;
    }
  }

  // ================= CREATE =================
  Future<bool> createKios({
    required String namaKios,
    required String lokasi,
    required String jamBuka,
    required String jamTutup,
    String? deskripsi,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/kios'),
        headers: Api.headersWithAuth(_token!),
        body: {
          'nama_kios': namaKios,
          'lokasi': lokasi,
          'jam_buka': jamBuka,
          'jam_tutup': jamTutup,
          'deskripsi': deskripsi ?? '',
        },
      );

      print('CREATE KIOS STATUS: ${response.statusCode}');
      print('CREATE KIOS BODY: ${response.body}');

      return response.statusCode == 201;
    } catch (e) {
      print('🔥 CREATE KIOS ERROR: $e');
      return false;
    }
  }

  // ================= UPDATE =================
  Future<bool> updateKios({
    required int id,
    required String namaKios,
    required String lokasi,
    required String jamBuka,
    required String jamTutup,
    String? deskripsi,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${Api.baseUrl}/kios/$id'),
        headers: Api.headersWithAuth(_token!),
        body: {
          'nama_kios': namaKios,
          'lokasi': lokasi,
          'jam_buka': jamBuka,
          'jam_tutup': jamTutup,
          'deskripsi': deskripsi ?? '',
        },
      );

      print('UPDATE KIOS STATUS: ${response.statusCode}');
      print('UPDATE KIOS BODY: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('🔥 UPDATE KIOS ERROR: $e');
      return false;
    }
  }

  // ================= DELETE =================
  Future<bool> deleteKios(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${Api.baseUrl}/kios/$id'),
        headers: Api.headersWithAuth(_token!),
      );

      print('DELETE KIOS STATUS: ${response.statusCode}');
      print('DELETE KIOS BODY: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('🔥 DELETE KIOS ERROR: $e');
      return false;
    }
  }
}
