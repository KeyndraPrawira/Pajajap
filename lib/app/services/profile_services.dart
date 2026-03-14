import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/api.dart';
import '../data/models/profile_model.dart';

class ProfileService {

  /// ambil profile user
  static Future<Profile?> getProfile(String token) async {

    final res = await http.get(
      Uri.parse('${Api.baseUrl}/profile'),
      headers: Api.headersWithAuth(token),
    );

    if (res.statusCode == 200) {
      return profileFromJson(res.body);
    }

    return null;
  }

  /// update nama dan nomor telepon
  static Future<bool> updateProfile(
    String token,
    String username,
    String nomorTelepon,
  ) async {

    final res = await http.put(
      Uri.parse('${Api.baseUrl}/profile'),
      headers: Api.headersWithAuth(token),
      body: jsonEncode({
        "username": username,
        "nomor_telepon": nomorTelepon
      }),
    );

    return res.statusCode == 200;
  }

  /// set atau update alamat
  static Future<bool> setAlamat(
    String token,
    String alamat,
    double latitude,
    double longitude,
  ) async {

    final res = await http.post(
      Uri.parse('${Api.baseUrl}/profile/alamat'),
      headers: Api.headersWithAuth(token),
      body: jsonEncode({
        "alamat_lengkap": alamat,
        "latitude": latitude,
        "longitude": longitude
      }),
    );

    return res.statusCode == 200;
  }
  static Future<bool> updatePassword(
  String token,
  String currentPassword,
  String newPassword,
  String confirmPassword,
) async {

  final res = await http.put(
    Uri.parse('${Api.baseUrl}/profile/password'),
    headers: Api.headersWithAuth(token),
    body: jsonEncode({
      "current_password": currentPassword,
      "new_password": newPassword,
      "new_password_confirmation": confirmPassword
    }),
  );

  if (res.statusCode == 200) {
    return true;
  } else {
    print(res.body);
    return false;
  }
}
  }