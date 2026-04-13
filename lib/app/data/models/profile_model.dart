// To parse this JSON data, do
//
//     final empty = profileFromJson(jsonString);

import 'dart:convert';

import 'package:e_pasar/app/data/models/json_parsers.dart';

Profile profileFromJson(String str) => Profile.fromJson(json.decode(str));

String profileToJson(Profile data) => json.encode(data.toJson());

class Profile {
  DataProfile? data;

  Profile({
    this.data,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        data: asMap(json["data"]) == null
            ? null
            : DataProfile.fromJson(asMap(json["data"])!),
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
      };
}

class DataProfile {
  int? id;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  String? role;
  String? nomorTelepon;
  dynamic fotoProfil;
  bool? isOnline;
  dynamic rememberToken;
  DateTime? createdAt;
  DateTime? updatedAt;
  Alamat? alamat;

  DataProfile({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.role,
    this.nomorTelepon,
    this.fotoProfil,
    this.rememberToken,
    this.isOnline,
    this.createdAt,
    this.updatedAt,
    this.alamat,
  });

  factory DataProfile.fromJson(Map<String, dynamic> json) => DataProfile(
        id: asInt(json["id"]),
        name: asString(json["name"]),
        email: asString(json["email"]),
        emailVerifiedAt: json["email_verified_at"],
        role: asString(json["role"]),
        nomorTelepon: asString(json["nomor_telepon"]),
        fotoProfil: json["foto_profil"],
        isOnline: asBool(json["is_online"]),
        rememberToken: json["remember_token"],
        createdAt: asDateTime(json["created_at"]),
        updatedAt: asDateTime(json["updated_at"]),
        alamat: asMap(json["alamat"]) == null
            ? null
            : Alamat.fromJson(asMap(json["alamat"])!),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "email_verified_at": emailVerifiedAt,
        "role": role,
        "nomor_telepon": nomorTelepon,
        "foto_profil": fotoProfil,
        "remember_token": rememberToken,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "alamat": alamat?.toJson(),
        "is_online": isOnline,
      };
}

class Alamat {
  int? id;
  int? userId;
  String? alamatLengkap;
  double? longitude;
  double? latitude;
  double? jarakKm;
  DateTime? createdAt;
  DateTime? updatedAt;

  Alamat({
    this.id,
    this.userId,
    this.alamatLengkap,
    this.longitude,
    this.latitude,
    this.jarakKm,
    this.createdAt,
    this.updatedAt,
  });

  factory Alamat.fromJson(Map<String, dynamic> json) => Alamat(
        id: asInt(json["id"]),
        userId: asInt(json["user_id"]),
        alamatLengkap: asString(json["alamat_lengkap"]),
        longitude: asDouble(json["longitude"]),
        latitude: asDouble(json["latitude"]),
        jarakKm: asDouble(json["jarak_km"]),
        createdAt: asDateTime(json["created_at"]),
        updatedAt: asDateTime(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "alamat_lengkap": alamatLengkap,
        "longitude": longitude,
        "latitude": latitude,
        "jarak_km": jarakKm,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
