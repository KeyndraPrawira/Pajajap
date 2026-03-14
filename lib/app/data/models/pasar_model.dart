// To parse this JSON data, do
//
//     final pasar = pasarFromJson(jsonString);

import 'dart:convert';

Pasar pasarFromJson(String str) => Pasar.fromJson(json.decode(str));

String pasarToJson(Pasar data) => json.encode(data.toJson());

class Pasar {
    String? status;
    String? message;
    Data? data;

    Pasar({
        this.status,
        this.message,
        this.data,
    });

    factory Pasar.fromJson(Map<String, dynamic> json) => Pasar(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
    };
}

class Data {
    int? id;
    String? namaPasar;
    String? alamat;
    String? fotoPasar;
    int? ongkir;
    String? kontak;
    String? deskripsi;
    String? longitude;
    String? latitude;
    DateTime? createdAt;
    DateTime? updatedAt;

    Data({
        this.id,
        this.namaPasar,
        this.alamat,
        this.fotoPasar,
        this.ongkir,
        this.kontak,
        this.deskripsi,
        this.longitude,
        this.latitude,
        this.createdAt,
        this.updatedAt,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        namaPasar: json["nama_pasar"],
        alamat: json["alamat"],
        fotoPasar: json["foto_pasar"],
        ongkir: json["ongkir"],
        kontak: json["kontak"],
        deskripsi: json["deskripsi"],
        longitude: json["longitude"],
        latitude: json["latitude"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nama_pasar": namaPasar,
        "alamat": alamat,
        "foto_pasar": fotoPasar,
        "ongkir": ongkir,
        "kontak": kontak,
        "deskripsi": deskripsi,
        "longitude": longitude,
        "latitude": latitude,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
