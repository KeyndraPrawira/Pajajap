import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../utils/api.dart';

class UserService {
  final box = GetStorage();

  String? get token => box.read('token');

  Future<Map<String, dynamic>> setActive(bool isOnline) async {
    try {
      if (token == null) throw Exception('No token found');

      final uri = Uri.parse('${Api.baseUrl}/set-active');

      final response = await http.post(
        uri,
        headers: Api.headersWithAuth(token!),
        body: json.encode({'is_online': isOnline}),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return {'success': true, 'data': decoded};
      } else {
        throw Exception('Failed to set active status (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error setting active status: $e');
    }
  }
}
