import 'dart:convert';

import 'package:e_pasar/app/data/models/json_parsers.dart';

// ===========================================================================
// Top-level helpers
// ===========================================================================

RegisterResponse registerResponseFromJson(String str) =>
    RegisterResponse.fromJson(json.decode(str));

String registerResponseToJson(RegisterResponse data) =>
    json.encode(data.toJson());

VerifyOtpResponse verifyOtpResponseFromJson(String str) =>
    VerifyOtpResponse.fromJson(json.decode(str));

String verifyOtpResponseToJson(VerifyOtpResponse data) =>
    json.encode(data.toJson());

ErrorResponse errorResponseFromJson(String str) =>
    ErrorResponse.fromJson(json.decode(str));

String errorResponseToJson(ErrorResponse data) => json.encode(data.toJson());

// ===========================================================================
// 1. RegisterResponse
//    Dipakai untuk response: POST /api/register & POST /api/register/resend-otp
//
//    Success shape:
//    {
//      "success": true,
//      "message": "Kode OTP telah dikirim...",
//      "data": { "email": "user@example.com" }   ← hanya ada di /register
//    }
//
//    Error shape:
//    { "success": false, "message": "..." }
// ===========================================================================

class RegisterResponse {
  bool? success;
  String? message;
  RegisterData? data;

  RegisterResponse({
    this.success,
    this.message,
    this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
        success: asBool(json["success"]),
        message: asString(json["message"]),
        data: asMap(json["data"]) == null
            ? null
            : RegisterData.fromJson(asMap(json["data"])!),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class RegisterData {
  String? email;

  RegisterData({this.email});

  factory RegisterData.fromJson(Map<String, dynamic> json) => RegisterData(
        email: asString(json["email"]),
      );

  Map<String, dynamic> toJson() => {
        "email": email,
      };
}

// ===========================================================================
// 2. VerifyOtpResponse
//    Dipakai untuk response: POST /api/register/verify-otp
//
//    Success shape:
//    {
//      "success": true,
//      "message": "Registrasi berhasil...",
//      "data": {
//        "token": "1|abc...",
//        "token_type": "Bearer",
//        "user": {
//          "id": 1,
//          "name": "...",
//          "email": "...",
//          "nomor_telepon": "...",
//          "role": "user"
//        }
//      }
//    }
//
//    Error shape:
//    { "success": false, "message": "..." }
// ===========================================================================

class VerifyOtpResponse {
  bool? success;
  String? message;
  VerifyOtpData? data;

  VerifyOtpResponse({
    this.success,
    this.message,
    this.data,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) =>
      VerifyOtpResponse(
        success: asBool(json["success"]),
        message: asString(json["message"]),
        data: asMap(json["data"]) == null
            ? null
            : VerifyOtpData.fromJson(asMap(json["data"])!),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class VerifyOtpData {
  String? token;
  String? tokenType;
  UserData? user;

  VerifyOtpData({
    this.token,
    this.tokenType,
    this.user,
  });

  factory VerifyOtpData.fromJson(Map<String, dynamic> json) => VerifyOtpData(
        token: asString(json["token"]),
        tokenType: asString(json["token_type"]),
        user: asMap(json["user"]) == null
            ? null
            : UserData.fromJson(asMap(json["user"])!),
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "token_type": tokenType,
        "user": user?.toJson(),
      };
}

class UserData {
  int? id;
  String? name;
  String? email;
  String? nomorTelepon;
  String? role;

  UserData({
    this.id,
    this.name,
    this.email,
    this.nomorTelepon,
    this.role,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: asInt(json["id"]),
        name: asString(json["name"]),
        email: asString(json["email"]),
        nomorTelepon: asString(json["nomor_telepon"]),
        role: asString(json["role"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "nomor_telepon": nomorTelepon,
        "role": role,
      };
}

// ===========================================================================
// 3. ErrorResponse
//    Dipakai untuk semua response error (422, 429, 409, 500, dst.)
//
//    Validation error shape:
//    {
//      "success": false,
//      "message": "Data yang diberikan tidak valid.",
//      "errors": {
//        "email": ["Email sudah terdaftar."],
//        "password": ["Password minimal 8 karakter."]
//      }
//    }
//
//    General error shape:
//    { "success": false, "message": "..." }
// ===========================================================================

class ErrorResponse {
  bool? success;
  String? message;

  /// Key = nama field, Value = list pesan error untuk field tersebut.
  /// Null jika bukan validation error (misal: 429, 500, dst.)
  Map<String, List<String>>? errors;

  ErrorResponse({
    this.success,
    this.message,
    this.errors,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>>? parsedErrors;

    if (json["errors"] is Map) {
      parsedErrors = (json["errors"] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          value is List
              ? List<String>.from(value.map((e) => e.toString()))
              : [value.toString()],
        ),
      );
    }

    return ErrorResponse(
      success: asBool(json["success"]),
      message: asString(json["message"]),
      errors: parsedErrors,
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "errors": errors,
      };

  /// Ambil pesan error pertama untuk field tertentu.
  /// Contoh: errorResponse.firstError('email') → "Email sudah terdaftar."
  String? firstError(String field) => errors?[field]?.firstOrNull;

  /// Gabungkan semua pesan error menjadi satu string.
  /// Berguna untuk ditampilkan di SnackBar / dialog.
  String get allErrors {
    if (errors == null || errors!.isEmpty)
      return message ?? 'Terjadi kesalahan.';
    return errors!.values.expand((messages) => messages).join('\n');
  }
}
