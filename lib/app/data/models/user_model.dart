// To parse this JSON data, do
//
//     final auth = authFromJson(jsonString);

import 'dart:convert';

Auth authFromJson(String str) => Auth.fromJson(json.decode(str));

String authToJson(Auth data) => json.encode(data.toJson());

class Auth {
    String? token;
    UserData? user;

    Auth({
        this.token,
        this.user,
    });

    factory Auth.fromJson(Map<String, dynamic> json) => Auth(
        token: json["token"],
        user: json["user"] == null ? null : UserData.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "user": user?.toJson(),
    };
}

class UserData {
    int? id;
    String? name;
    String? email;
    dynamic emailVerifiedAt;
    String? password;
    String? role;
    String? nomorTelepon;
    dynamic rememberToken;
    DateTime? createdAt;
    DateTime? updatedAt;

    UserData({
        this.id,
        this.name,
        this.email,
        this.emailVerifiedAt,
        this.password,
        this.role,
        this.nomorTelepon,
        this.rememberToken,
        this.createdAt,
        this.updatedAt,
    });

    factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"],
        password: json["password"],
        role: json["role"],
        nomorTelepon: json["nomor_telepon"],
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
        "role": role,
        "nomor_telepon": nomorTelepon,
        "remember_token": rememberToken,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}

