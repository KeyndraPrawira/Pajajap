// To parse this JSON data, do
//
//     final empty = profileFromJson(jsonString);

import 'dart:convert';

Profile profileFromJson(String str) => Profile.fromJson(json.decode(str));

String profileToJson(Profile data) => json.encode(data.toJson());

class Profile {
    DataProfile? data;

    Profile({
        this.data,
    });

    factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        data: json["data"] == null ? null : DataProfile.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
    };
}

class DataProfile {
    int? id;
    String? username;
    String? email;
    dynamic emailVerifiedAt;
    String? role;
    String? nomorTelepon;
    dynamic fotoProfil;
    dynamic rememberToken;
    DateTime? createdAt;
    DateTime? updatedAt;
    Alamat? alamat;

    DataProfile({
        this.id,
        this.username,
        this.email,
        this.emailVerifiedAt,
        this.role,
        this.nomorTelepon,
        this.fotoProfil,
        this.rememberToken,
        this.createdAt,
        this.updatedAt,
        this.alamat,
    });

    factory DataProfile.fromJson(Map<String, dynamic> json) => DataProfile(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"],
        role: json["role"],
        nomorTelepon: json["nomor_telepon"],
        fotoProfil: json["foto_profil"],
        rememberToken: json["remember_token"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        alamat: json["alamat"] == null ? null : Alamat.fromJson(json["alamat"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "email": email,
        "email_verified_at": emailVerifiedAt,
        "role": role,
        "nomor_telepon": nomorTelepon,
        "foto_profil": fotoProfil,
        "remember_token": rememberToken,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "alamat": alamat?.toJson(),
    };
}

class Alamat {
    int? id;
    int? userId;
    String? alamatLengkap;
    double? longitude;
    double? latitude;
    DateTime? createdAt;
    DateTime? updatedAt;

    Alamat({
        this.id,
        this.userId,
        this.alamatLengkap,
        this.longitude,
        this.latitude,
        this.createdAt,
        this.updatedAt,
    });

    factory Alamat.fromJson(Map<String, dynamic> json) => Alamat(
        id: json["id"],
        userId: json["user_id"],
        alamatLengkap: json["alamat_lengkap"],
        longitude: double.tryParse(json["longitude"]?.toString() ?? '') ?? 0.0,
        latitude: double.tryParse(json["latitude"]?.toString() ?? '') ?? 0.0,
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "alamat_lengkap": alamatLengkap,
        "longitude": longitude,
        "latitude": latitude,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
