// To parse this JSON data, do
//
//     final auth = authFromJson(jsonString);

import 'dart:convert';

Auth authFromJson(String str) => Auth.fromJson(json.decode(str));

String authToJson(Auth data) => json.encode(data.toJson());

class Auth {
    String? token;
    DataUser? user;

    Auth({
        this.token,
        this.user,
    });

    factory Auth.fromJson(Map<String, dynamic> json) => Auth(
        token: json["token"],
        user: json["data"] == null ? null : DataUser.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "data": user?.toJson(),
    };
}

class DataUser {
    int? id;
    String? name;
    String? email;
    dynamic emailVerifiedAt;
    String? password;
    dynamic googleId;
    String? role;
    String? nomorTelepon;
    dynamic fotoProfil;
    bool? isOnline;
    dynamic rememberToken;
    DateTime? createdAt;
    DateTime? updatedAt;

    DataUser({
        this.id,
        this.name,
        this.email,
        this.emailVerifiedAt,
        this.password,
        this.googleId,
        this.role,
        this.nomorTelepon,
        this.fotoProfil,
        this.isOnline,
        this.rememberToken,
        this.createdAt,
        this.updatedAt,
    });

    factory DataUser.fromJson(Map<String, dynamic> json) => DataUser(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"],
        password: json["password"],
        googleId: json["google_id"],
        role: json["role"],
        nomorTelepon: json["nomor_telepon"],
        fotoProfil: json["foto_profil"],
        isOnline: json["is_online"],
        rememberToken: json["remember_token"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "email_verified_at": emailVerifiedAt,
        "password": password,
        "google_id": googleId,
        "role": role,
        "nomor_telepon": nomorTelepon,
        "foto_profil": fotoProfil,
        "is_online": isOnline,
        "remember_token": rememberToken,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
