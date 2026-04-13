// To parse this JSON data, do
//
//     final kios = kiosFromJson(jsonString);

import 'dart:convert';

import 'package:e_pasar/app/data/models/json_parsers.dart';

Kios kiosFromJson(String str) => Kios.fromJson(json.decode(str));

String kiosToJson(Kios data) => json.encode(data.toJson());

class Kios {
  List<DataKios>? kios;
  int? status;
  String? message;

  Kios({
    this.kios,
    this.status,
    this.message,
  });

  factory Kios.fromJson(Map<String, dynamic> json) => Kios(
        kios: json["kios"] == null
            ? []
            : List<DataKios>.from(
                json["kios"]!.map((x) => DataKios.fromJson(x))),
        status: asInt(json["status"]),
        message: asString(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "kios": kios == null
            ? []
            : List<dynamic>.from(kios!.map((x) => x.toJson())),
        "status": status,
        "message": message,
      };
}

class DataKios {
  int? id;
  int? pasarId;
  String? namaKios;
  String? lokasi;
  int? userId;
  String? jamBuka;
  String? jamTutup;
  String? deskripsi;
  String? fotoKios;
  DateTime? createdAt;
  DateTime? updatedAt;

  DataKios({
    this.id,
    this.pasarId,
    this.namaKios,
    this.lokasi,
    this.userId,
    this.jamBuka,
    this.jamTutup,
    this.deskripsi,
    this.fotoKios,
    this.createdAt,
    this.updatedAt,
  });

  factory DataKios.fromJson(Map<String, dynamic> json) => DataKios(
        id: asInt(json["id"]),
        pasarId: asInt(json["pasar_id"]),
        namaKios: asString(json["nama_kios"]),
        lokasi: asString(json["lokasi"]),
        userId: asInt(json["user_id"]),
        jamBuka: asString(json["jam_buka"]),
        jamTutup: asString(json["jam_tutup"]),
        deskripsi: asString(json["deskripsi"]),
        fotoKios: asString(json["foto_kios"]),
        createdAt: asDateTime(json["created_at"]),
        updatedAt: asDateTime(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "pasar_id": pasarId,
        "nama_kios": namaKios,
        "lokasi": lokasi,
        "user_id": userId,
        "jam_buka": jamBuka,
        "jam_tutup": jamTutup,
        "deskripsi": deskripsi,
        "foto_kios": fotoKios,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
