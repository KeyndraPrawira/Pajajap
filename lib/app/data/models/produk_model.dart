import 'dart:convert';

import 'package:e_pasar/app/data/models/json_parsers.dart';

Produk produkFromJson(String str) => Produk.fromJson(json.decode(str));

String produkToJson(Produk data) => json.encode(data.toJson());

class Produk {
  String? status;
  String? message;
  List<DataProduk>? data;

  Produk({
    this.status,
    this.message,
    this.data,
  });

  factory Produk.fromJson(Map<String, dynamic> json) => Produk(
        status: asString(json["status"]),
        message: asString(json["message"]),
        data: json["data"] == null
            ? []
            : List<DataProduk>.from(
                json["data"]!.map((x) => DataProduk.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class DataProduk {
  int? id;
  String? namaProduk;
  int? kategoriId;
  int? harga;
  String? deskripsi;
  int? stok;
  String? foto;
  int? beratSatuan; // int sesuai tipe kolom DB
  int? kiosId;

  DateTime? createdAt;
  DateTime? updatedAt;
  Kios? kios;

  DataProduk({
    this.id,
    this.namaProduk,
    this.kategoriId,
    this.harga,
    this.deskripsi,
    this.stok,
    this.foto,
    this.beratSatuan,
    this.kiosId,
    this.createdAt,
    this.updatedAt,
    this.kios,
  });

  factory DataProduk.fromJson(Map<String, dynamic> json) => DataProduk(
        id: asInt(json["id"]),
        namaProduk: asString(json["nama_produk"]),
        kategoriId: asInt(json["kategori_id"]),
        harga: asInt(json["harga"]),
        deskripsi: asString(json["deskripsi"]),
        stok: asInt(json["stok"]),
        foto: asString(json["foto"]),
        beratSatuan: asInt(json["berat_satuan"]),
        kiosId: asInt(json["kios_id"]),
        createdAt: asDateTime(json["created_at"]),
        updatedAt: asDateTime(json["updated_at"]),
        kios: asMap(json["kios"]) == null
            ? null
            : Kios.fromJson(asMap(json["kios"])!),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama_produk": namaProduk,
        "kategori_id": kategoriId,
        "harga": harga,
        "deskripsi": deskripsi,
        "stok": stok,
        "foto": foto,
        "berat_satuan": beratSatuan,
        "kios_id": kiosId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "kios": kios?.toJson(),
      };
}

class Kios {
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

  Kios({
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

  factory Kios.fromJson(Map<String, dynamic> json) => Kios(
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
