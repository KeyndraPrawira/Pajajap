// lib/app/services/pasar_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api.dart';
import '../data/models/pasar_model.dart';

class PasarService {
  /// Ambil daftar pasar
  static Future<Pasar?> getPasarList() async {
  final res = await http.get(
    Uri.parse('${Api.baseUrl}/pasar'),
    headers: Api.headers,
  );
  print("=== PASAR SERVICE ===");
  print("Status: ${res.statusCode}");
  print("Body: ${res.body}");
  if (res.statusCode == 200) {
    return pasarFromJson(res.body);
  }
  return null;
}

  /// Ambil detail pasar berdasarkan ID
  static Future<Pasar?> getPasarDetail(int pasarId) async {
    final res = await http.get(
      Uri.parse('${Api.baseUrl}/pasar/$pasarId'),
      headers: Api.headers,
    );

    if (res.statusCode == 200) {
      return pasarFromJson(res.body);
    }

    return null;
  }
}