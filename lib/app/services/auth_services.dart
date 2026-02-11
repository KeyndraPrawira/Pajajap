// lib/app/data/services/auth_service.dart
import 'dart:convert';
import 'package:e_pasar/app/data/models/user_model.dart';
import 'package:e_pasar/app/utils/api.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AuthService extends GetxService {
  final storage = GetStorage();

  // ==================== LOGIN ====================
  Future<Auth?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/login'),
        headers: Api.headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('LOGIN STATUS: ${response.statusCode}');
      print('LOGIN BODY: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final auth = Auth.fromJson(jsonData);

        // Simpan token & user info
        await storage.write('token', auth.token ?? '');
        await storage.write('role', auth.user?.role ?? '');
        await storage.write('user_id', auth.user?.id ?? '');
        await storage.write('user_name', auth.user?.name ?? '');
        await storage.write('user_email', auth.user?.email ?? '');

        return auth;
      }

      return null;
    } catch (e) {
      print('🔥 LOGIN ERROR: $e');
      return null;
    }
  }

  // ==================== REGISTER ====================
  Future<Map<String, dynamic>> register({
    required String nomortelepon,
    required String name,
    required String email,
    required String password,
    
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/register'),
        headers: Api.headers,
        body: jsonEncode({
          'nomor_telepon':nomortelepon,
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password, // Laravel biasanya butuh ini
        }),
      );

      print('REGISTER STATUS: ${response.statusCode}');
      print('REGISTER BODY: ${response.body}');

      // Status 200 atau 201 berarti berhasil
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Registrasi berhasil!',
        };
      }

      // Handle error response dari API
      try {
        final errorData = jsonDecode(response.body);
        
        // Cek strukturnya sesuai Laravel error response
        if (errorData is Map && errorData.containsKey('errors')) {
          final errors = errorData['errors'] as Map<String, dynamic>;
          String errorMessage = '';
          
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMessage += '${value[0]}\n';
            }
          });
          
          return {
            'success': false,
            'message': errorMessage.isNotEmpty 
              ? errorMessage.trim()
              : (errorData['message'] ?? 'Registrasi gagal. Silakan coba lagi.'),
          };
        } else if (errorData is Map && errorData.containsKey('message')) {
          return {
            'success': false,
            'message': errorData['message'],
          };
        }
      } catch (e) {
        // Jika parsing JSON gagal, gunakan pesan generik
      }

      return {
        'success': false,
        'message': 'Registrasi gagal. Status code: ${response.statusCode}',
      };
    } catch (e) {
      print('🔥 REGISTER ERROR: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // ==================== VALIDATE TOKEN ====================
  Future<bool> validateToken() async {
    try {
      final token = storage.read('token');

      if (token == null || token.isEmpty) {
        return false;
      }

      final response = await http.get(
        Uri.parse('${Api.baseUrl}/user'),
        headers: Api.headersWithAuth(token),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('🔥 VALIDATE TOKEN TIMEOUT');
          return http.Response('timeout', 408);
        },
      );

      print('VALIDATE TOKEN STATUS: ${response.statusCode}');

      if (response.statusCode == 200) {
        return true;
      } else {
        // Token invalid, clear storage
        await logout();
        return false;
      }
    } catch (e) {
      print('🔥 VALIDATE TOKEN ERROR: $e');
      return false;
    }
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    try {
      final token = storage.read('token');
      
      // Optional: hit logout endpoint di backend
      if (token != null && token.isNotEmpty) {
        await http.post(
          Uri.parse('${Api.baseUrl}/logout'),
          headers: Api.headersWithAuth(token),
        );
      }
    } catch (e) {
      print('🔥 LOGOUT ERROR: $e');
    } finally {
      // Clear local storage
      await storage.remove('token');
      await storage.remove('role');
      await storage.remove('user_id');
      await storage.remove('user_name');
      await storage.remove('user_email');
    }
  }

  // ==================== GETTERS ====================
  String? getToken() => storage.read('token');
  String? getRole() => storage.read('role');
  int? getUserId() => storage.read('user_id');
  String? getUserName() => storage.read('user_name');
  String? getUserEmail() => storage.read('user_email');
  bool get isLoggedIn => storage.read('token') != null;
}