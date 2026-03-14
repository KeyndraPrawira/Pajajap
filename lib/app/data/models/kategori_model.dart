// To parse this JSON data, do
//
//     final kategori = kategoriFromJson(jsonString);

import 'dart:convert';

Kategori kategoriFromJson(String str) => Kategori.fromJson(json.decode(str));

String kategoriToJson(Kategori data) => json.encode(data.toJson());

class Kategori {
    String? message;
    List<Datum>? data;
    int? status;

    Kategori({
        this.message,
        this.data,
        this.status,
    });

    factory Kategori.fromJson(Map<String, dynamic> json) => Kategori(
        message: json["message"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "status": status,
    };
}

class Datum {
    int? id;
    String? namaKategori;
    String? deskripsi;
    DateTime? createdAt;
    DateTime? updatedAt;

    Datum({
        this.id,
        this.namaKategori,
        this.deskripsi,
        this.createdAt,
        this.updatedAt,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        namaKategori: json["nama_kategori"],
        deskripsi: json["deskripsi"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nama_kategori": namaKategori,
        "deskripsi": deskripsi,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
