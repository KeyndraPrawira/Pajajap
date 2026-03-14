// lib/app/services/kios_services.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:e_pasar/app/data/models/kios_model.dart';
import 'package:e_pasar/app/utils/api.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class KiosService extends GetxService {
  final storage = GetStorage();

  String? get _token => storage.read('token');

  // ================= GET MY KIOS (untuk pedagang) =================
  Future<List<DataKios>> getMyKios() async {
    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/kios/me'), // ✅ Endpoint khusus pedagang
        headers: Api.headersWithAuth(_token!),
      );

      print('GET MY KIOS STATUS: ${response.statusCode}');
      print('GET MY KIOS BODY: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> decoded = json.decode(response.body);
        
        final kiosList = decoded.map((json) => DataKios.fromJson(json)).toList();
        
        print('✅ PARSED MY KIOS: ${kiosList.length} kios found');
        
        // Debug setiap kios
        for (var kios in kiosList) {
          print('📦 KIOS: ID=${kios.id}, Name=${kios.namaKios}, UserID=${kios.userId}, Foto=${kios.fotoKios}');
        }
        
        return kiosList;
      }
      
      print('❌ GET MY KIOS FAILED: Status ${response.statusCode}');
      return [];
    } catch (e) {
      print('🔥 GET MY KIOS ERROR: $e');
      return [];
    }
  }

  // ================= GET KIOS =================
 Future<List<DataKios>> getKios() async {
  final response = await http.get(
    Uri.parse('${Api.baseUrl}/kios'),
    headers: Api.headersWithAuth(_token!),
  );

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);

    return List<DataKios>.from(
      decoded.map((x) => DataKios.fromJson(x)),
    );
  }

  return [];
}

  // ================= CREATE (WITH FILE UPLOAD) =================
  Future<bool> createKios({
    required String namaKios,
    required String lokasi,
    required String jamBuka,
    required String jamTutup,
    String? deskripsi,
    Uint8List? fotoKiosBytes,
    String? fotoKiosFilename,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Api.baseUrl}/kios'),
      );

      // Add headers (WITHOUT Content-Type)
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      });

      // Add fields
      request.fields['nama_kios'] = namaKios;
      request.fields['lokasi'] = lokasi;
      request.fields['jam_buka'] = jamBuka;
      request.fields['jam_tutup'] = jamTutup;

      if (deskripsi != null && deskripsi.isNotEmpty) {
        request.fields['deskripsi'] = deskripsi;
      }

      // Add file if exists
      if (fotoKiosBytes != null && fotoKiosFilename != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'foto_kios',
            fotoKiosBytes,
            filename: fotoKiosFilename,
          ),
        );
      }

      print('CREATE KIOS FIELDS: ${request.fields}');
      print('CREATE KIOS FILES: ${request.files.length}');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('CREATE KIOS STATUS: ${response.statusCode}');
      print('CREATE KIOS BODY: ${response.body}');

      if (response.statusCode == 201) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        Get.snackbar(
          'Error',
          errorData['message'] ?? 'Gagal membuat kios',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      print('🔥 CREATE KIOS ERROR: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // ================= UPDATE (WITH FILE UPLOAD) =================
  Future<bool> updateKios({
    required int id,
    required String namaKios,
    required String lokasi,
    required String jamBuka,
    required String jamTutup,
    String? kontak,
    String? deskripsi,
    Uint8List? fotoKiosBytes,
    String? fotoKiosFilename,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST', // Laravel uses POST with _method for PUT
        Uri.parse('${Api.baseUrl}/kios/$id'),
      );

      // Add headers (WITHOUT Content-Type)
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      });

      // Add _method for Laravel
      request.fields['_method'] = 'PUT';

      // Add fields
      request.fields['nama_kios'] = namaKios;
      request.fields['lokasi'] = lokasi;
      request.fields['jam_buka'] = jamBuka;
      request.fields['jam_tutup'] = jamTutup;

      if (kontak != null && kontak.isNotEmpty) {
        request.fields['kontak'] = kontak;
      }

      if (deskripsi != null && deskripsi.isNotEmpty) {
        request.fields['deskripsi'] = deskripsi;
      }

      // Add file if exists
      if (fotoKiosBytes != null && fotoKiosFilename != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'foto_kios',
            fotoKiosBytes,
            filename: fotoKiosFilename,
          ),
        );
      }

      print('UPDATE KIOS FIELDS: ${request.fields}');
      print('UPDATE KIOS FILES: ${request.files.length}');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('TOKEN UPDATE: $_token');
      print('UPDATE KIOS STATUS: ${response.statusCode}');
      print('UPDATE KIOS BODY: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        Get.snackbar(
          'Error',
          errorData['message'] ?? 'Gagal mengupdate kios',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      print('🔥 UPDATE KIOS ERROR: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
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

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        Get.snackbar(
          'Error',
          errorData['message'] ?? 'Gagal menghapus kios',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      print('🔥 DELETE KIOS ERROR: $e');
      return false;
    }
  }
}