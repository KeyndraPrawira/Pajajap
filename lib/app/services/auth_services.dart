import 'dart:convert';

import 'package:e_pasar/app/data/models/register_model.dart';
import 'package:e_pasar/app/data/models/user_model.dart';
import 'package:e_pasar/app/utils/api.dart';
import 'package:e_pasar/pages/auth/controllers/login_controller.dart';
import 'package:e_pasar/pages/auth/controllers/register_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService extends GetxService {
  static const String _googleClientId =
      '932089823808-6vf353e923aqro5drpgdfp6e0gk88f2a.apps.googleusercontent.com';

  final storage = GetStorage();
  final GoogleSignIn _googleSignIn = kIsWeb
      ? GoogleSignIn(
          clientId: _googleClientId,
          scopes: ['email', 'profile'],
        )
      : GoogleSignIn(
          serverClientId: _googleClientId,
          scopes: ['email', 'profile'],
        );

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

        await storage.write('token', jsonData['token']);
        await storage.write('role', auth.user?.role);
        await storage.write('user_id', auth.user?.id);
        await storage.write('user_name', auth.user?.name);
        await storage.write('user_email', auth.user?.email);
        await storage.write('user_phone', auth.user?.nomorTelepon);

        return auth;
      }

      return null;
    } catch (e) {
      print('LOGIN ERROR: $e');
      return null;
    }
  }

  Future<RegisterResponse> register({
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
          'nomor_telepon': nomortelepon,
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      );

      print('REGISTER STATUS: ${response.statusCode}');
      print('REGISTER BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = registerResponseFromJson(response.body);
        result.success ??= true;
        result.message ??= 'Kode OTP telah dikirim ke email Anda.';
        result.data ??= RegisterData(email: email);
        return result;
      }

      return RegisterResponse(
        success: false,
        message: _extractErrorMessage(
          response.body,
          fallback: 'Registrasi gagal. Status code: ${response.statusCode}',
        ),
        data: RegisterData(email: email),
      );
    } catch (e) {
      print('REGISTER ERROR: $e');
      return RegisterResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
        data: RegisterData(email: email),
      );
    }
  }

  Future<VerifyOtpResponse> verifyRegisterOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/register/verify-otp'),
        headers: Api.headers,
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      print('VERIFY OTP STATUS: ${response.statusCode}');
      print('VERIFY OTP BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = verifyOtpResponseFromJson(response.body);
        result.success ??= true;
        result.message ??= 'Registrasi berhasil. Selamat datang!';
        final user = result.data?.user;
        final token = result.data?.token;

        if (token != null && token.isNotEmpty && user != null) {
          await storage.write('token', token);
          await storage.write('role', user.role);
          await storage.write('user_id', user.id);
          await storage.write('user_name', user.name);
          await storage.write('user_email', user.email);
          await storage.write('user_phone', user.nomorTelepon);
        }

        return result;
      }

      return VerifyOtpResponse(
        success: false,
        message: _extractErrorMessage(
          response.body,
          fallback: 'Verifikasi OTP gagal. Status code: ${response.statusCode}',
        ),
      );
    } catch (e) {
      print('VERIFY OTP ERROR: $e');
      return VerifyOtpResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<RegisterResponse> resendRegisterOtp({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/register/resend-otp'),
        headers: Api.headers,
        body: jsonEncode({'email': email}),
      );

      print('RESEND OTP STATUS: ${response.statusCode}');
      print('RESEND OTP BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = registerResponseFromJson(response.body);
        result.success ??= true;
        result.message ??= 'Kode OTP baru telah dikirim ke email Anda.';
        result.data ??= RegisterData(email: email);
        return result;
      }

      return RegisterResponse(
        success: false,
        message: _extractErrorMessage(
          response.body,
          fallback:
              'Gagal mengirim ulang OTP. Status code: ${response.statusCode}',
        ),
        data: RegisterData(email: email),
      );
    } catch (e) {
      print('RESEND OTP ERROR: $e');
      return RegisterResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
        data: RegisterData(email: email),
      );
    }
  }

  Future<RegisterResponse> cancelRegistration({
    required String email,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${Api.baseUrl}/register/cancel'),
        headers: Api.headers,
        body: jsonEncode({'email': email}),
      );

      print('CANCEL REGISTRATION STATUS: ${response.statusCode}');
      print('CANCEL REGISTRATION BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = registerResponseFromJson(response.body);
        result.success ??= true;
        result.message ??= 'Registrasi berhasil dibatalkan.';
        return result;
      }

      return RegisterResponse(
        success: false,
        message: _extractErrorMessage(
          response.body,
          fallback:
              'Gagal membatalkan registrasi. Status code: ${response.statusCode}',
        ),
      );
    } catch (e) {
      print('CANCEL REGISTRATION ERROR: $e');
      return RegisterResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      await _googleSignIn.signOut();

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

      final response = await http.post(
        Uri.parse('${Api.baseUrl}/google-login'),
        headers: Api.headers,
        body: jsonEncode({'id_token': idToken}),
      );

      print('GOOGLE LOGIN STATUS: ${response.statusCode}');
      print('GOOGLE LOGIN BODY: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final user = (jsonData['user'] as Map<String, dynamic>? ?? {});

        await storage.write('token', jsonData['token'] ?? '');
        await storage.write('role', user['role'] ?? 'user');
        await storage.write('user_id', user['id']);
        await storage.write('user_name', user['name'] ?? '');
        await storage.write('user_email', user['email'] ?? '');
        await storage.write('user_phone', user['nomor_telepon'] ?? '');

        return {
          'success': true,
          'is_new_user': jsonData['is_new_user'] ?? false,
          'token': jsonData['token'],
          'user': user,
          'message': jsonData['message'] ?? 'Login Google berhasil',
        };
      }

      final errorData = jsonDecode(response.body);
      return {
        'success': false,
        'message': errorData['message'] ?? 'Google login gagal',
      };
    } catch (e) {
      print('GOOGLE LOGIN ERROR: $e');
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

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

        await storage.write('user_name', jsonData['user']['name'] ?? '');
        await storage.write(
            'user_phone', jsonData['user']['nomor_telepon'] ?? '');

        return {'success': true, 'message': 'Profil berhasil dilengkapi'};
      }

      final errorData = jsonDecode(response.body);
      return {
        'success': false,
        'message': errorData['message'] ?? 'Gagal melengkapi profil',
      };
    } catch (e) {
      print('COMPLETE PROFILE ERROR: $e');
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  Future<void> logout() async {
    try {
      final token = getToken();
      if (token != null && token.isNotEmpty) {
        await http.post(
          Uri.parse('${Api.baseUrl}/logout'),
          headers: Api.headersWithAuth(token),
        );
      }

      await _googleSignIn.signOut();
    } catch (e) {
      print('LOGOUT ERROR: $e');
    } finally {
      await storage.remove('token');
      await storage.remove('role');
      await storage.remove('user_id');
      await storage.remove('user_name');
      await storage.remove('user_email');
      await storage.remove('user_phone');

      if (Get.isRegistered<LoginController>()) {
        Get.delete<LoginController>(force: true);
      }
      if (Get.isRegistered<RegisterController>()) {
        Get.delete<RegisterController>(force: true);
      }
    }
  }

  Future<bool> validateToken() async {
    try {
      final token = storage.read('token');

      if (token == null || token.isEmpty) {
        return false;
      }

      final response = await http
          .get(
        Uri.parse('${Api.baseUrl}/user'),
        headers: Api.headersWithAuth(token),
      )
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('VALIDATE TOKEN TIMEOUT');
          return http.Response('timeout', 408);
        },
      );

      print('VALIDATE TOKEN STATUS: ${response.statusCode}');

      if (response.statusCode == 200) {
        return true;
      }

      await logout();
      return false;
    } catch (e) {
      print('VALIDATE TOKEN ERROR: $e');
      return false;
    }
  }

  String? _extractErrorMessage(String responseBody,
      {required String fallback}) {
    try {
      final error = errorResponseFromJson(responseBody);
      return error.allErrors;
    } catch (_) {
      try {
        final jsonData = jsonDecode(responseBody) as Map<String, dynamic>;
        return jsonData['message']?.toString() ?? fallback;
      } catch (_) {
        return fallback;
      }
    }
  }

  String? getToken() => storage.read('token');
  String? getRole() => storage.read('role');
  int? getUserId() => storage.read('user_id');
  String? getUserName() => storage.read('user_name');
  String? getUserEmail() => storage.read('user_email');
  String? getUserPhone() => storage.read('user_phone');
  bool get isLoggedIn => storage.read('token') != null;

  bool get isProfileIncomplete {
    final name = (getUserName() ?? '').trim();
    final phone = (getUserPhone() ?? '').trim();
    return name.isEmpty || phone.isEmpty;
  }
}
