// lib/app/data/services/auth_service.dart
import 'dart:convert';
import 'package:e_pasar/app/data/models/user_model.dart';
import 'package:e_pasar/app/utils/api.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService extends GetxService {
  final storage = GetStorage();
  final GoogleSignIn _googleSignIn = kIsWeb
    ? GoogleSignIn(
        // Web: pakai clientId, TANPA serverClientId
        clientId: '1025180164382-2duj2m96kjle9aaspvato8d0m2naljc4.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      )
    : GoogleSignIn(
        // Android/iOS: pakai serverClientId, TANPA clientId
        serverClientId: '1025180164382-2duj2m96kjle9aaspvato8d0m2naljc4.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

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
         await  storage.write('token', jsonData['token']);
         await  storage.write('role', auth.user?.role);
         await  storage.write('user_id', auth.user?.id);
         await  storage.write('user_name', auth.user?.name);
        

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

  // ==================== GOOGLE LOGIN ==================== ← tambah ini
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      // Trigger popup Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Login dibatalkan'};
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final idToken = googleAuth.idToken;
      if (idToken == null) {
        return {'success': false, 'message': 'Gagal mendapatkan token Google'};
      }

      // Kirim id_token ke Laravel
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/google-login'),
        headers: Api.headers,
        body: jsonEncode({'id_token': idToken}),
      );

      print('GOOGLE LOGIN STATUS: ${response.statusCode}');
      print('GOOGLE LOGIN BODY: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Simpan token & user info (sama seperti login biasa)
        await storage.write('token', jsonData['token'] ?? '');
        await storage.write('role', jsonData['user']['role'] ?? '');
        await storage.write('user_id', jsonData['user']['id'] ?? '');
        await storage.write('user_name', jsonData['user']['name'] ?? '');
        await storage.write('user_email', jsonData['user']['email'] ?? '');

        return {
          'success': true,
          'is_new_user': jsonData['is_new_user'] ?? false,
          'token': jsonData['token'],
        };
      }

      final errorData = jsonDecode(response.body);
      return {
        'success': false,
        'message': errorData['message'] ?? 'Google login gagal',
      };

    } catch (e) {
      print('🔥 GOOGLE LOGIN ERROR: $e');
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // ==================== COMPLETE PROFILE ==================== ← tambah ini
  Future<Map<String, dynamic>> completeProfile({
    required String name,
    required String nomorTelepon,
  }) async {
    try {
      final token = getToken();

      final response = await http.post(
        Uri.parse('${Api.baseUrl}/complete-profile'),
        headers: Api.headersWithAuth(token!),
        body: jsonEncode({
          'name': name,
          'nomor_telepon': nomorTelepon,
        }),
      );

      print('COMPLETE PROFILE STATUS: ${response.statusCode}');
      print('COMPLETE PROFILE BODY: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Update storage dengan data terbaru
        await storage.write('user_name', jsonData['user']['name'] ?? '');

        return {'success': true, 'message': 'Profil berhasil dilengkapi'};
      }

      final errorData = jsonDecode(response.body);
      return {
        'success': false,
        'message': errorData['message'] ?? 'Gagal melengkapi profil',
      };
    } catch (e) {
      print('🔥 COMPLETE PROFILE ERROR: $e');
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    try {
      final token = getToken();
      if (token != null && token.isNotEmpty) {
        await http.post(
          Uri.parse('${Api.baseUrl}/logout'),
          headers: Api.headersWithAuth(token),
        );
      }

      // Sign out Google juga kalau login via Google
      await _googleSignIn.signOut(); // ← tambah ini
    } catch (e) {
      print('🔥 LOGOUT ERROR: $e');
    } finally {
      await storage.remove('token');
      await storage.remove('role');
      await storage.remove('user_id');
      await storage.remove('user_name');
      await storage.remove('user_email');
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



  

  // ==================== GETTERS ====================
  String? getToken() => storage.read('token');
  String? getRole() => storage.read('role');
  int? getUserId() => storage.read('user_id');
  String? getUserName() => storage.read('user_name');
  String? getUserEmail() => storage.read('user_email');
  bool get isLoggedIn => storage.read('token') != null;
}
