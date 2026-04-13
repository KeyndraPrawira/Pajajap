// To parse this JSON data, do
//
//     final kategori = kategoriFromJson(jsonString);

import 'dart:convert';

import 'package:e_pasar/app/data/models/json_parsers.dart';

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
        message: asString(json["message"]),
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        status: asInt(json["status"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
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
        id: asInt(json["id"]),
        namaKategori: asString(json["nama_kategori"]),
        deskripsi: asString(json["deskripsi"]),
        createdAt: asDateTime(json["created_at"]),
        updatedAt: asDateTime(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama_kategori": namaKategori,
        "deskripsi": deskripsi,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
