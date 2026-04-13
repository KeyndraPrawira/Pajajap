import 'dart:convert';

import 'package:e_pasar/app/data/models/json_parsers.dart';

Keranjang keranjangFromJson(String str) => Keranjang.fromJson(json.decode(str));

String keranjangToJson(Keranjang data) => json.encode(data.toJson());

class Keranjang {
  int? status;
  String? message;
  List<DataKeranjang>? data; // selalu List, handle both array & single object

  Keranjang({
    this.status,
    this.message,
    this.data,
  });

  factory Keranjang.fromJson(Map<String, dynamic> json) {
    List<DataKeranjang>? parsedData;

    if (json["data"] is List) {
      // index() → array
      parsedData = List<DataKeranjang>.from(
        (json["data"] as List)
            .map((x) => DataKeranjang.fromJson(asMap(x) ?? const {})),
      );
    } else if (json["data"] is Map) {
      // store() / update() → single object, wrap jadi list
      parsedData = [DataKeranjang.fromJson(asMap(json["data"]) ?? const {})];
    }

    return Keranjang(
      status: asInt(json["status"]),
      message: asString(json["message"]),
      data: parsedData,
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data != null
            ? List<dynamic>.from(data!.map((x) => x.toJson()))
            : null,
      };
}

class DataKeranjang {
  int? id;
  int? userId;
  String? produkId;
  String? jumlah;
  int? hargaTotal;
  DateTime? updatedAt;
  DateTime? createdAt;
  Produk? produk;

  DataKeranjang({
    this.id,
    this.userId,
    this.produkId,
    this.jumlah,
    this.hargaTotal,
    this.updatedAt,
    this.createdAt,
    this.produk,
  });

  factory DataKeranjang.fromJson(Map<String, dynamic> json) => DataKeranjang(
        id: asInt(json["id"]),
        userId: asInt(json["user_id"]),
        produkId: asString(json["produk_id"]),
        jumlah: asString(json["jumlah"]),
        hargaTotal: asInt(json["harga_total"]),
        updatedAt: asDateTime(json["updated_at"]),
        createdAt: asDateTime(json["created_at"]),
        produk: asMap(json["produk"]) == null
            ? null
            : Produk.fromJson(asMap(json["produk"])!),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "produk_id": produkId,
        "jumlah": jumlah,
        "harga_total": hargaTotal,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "produk": produk?.toJson(),
      };
}

class Produk {
  int? id;
  String? nama;
  int? harga;
  String? foto;
  double? berat_satuan;
  String? deskripsi;

  Produk({
    this.id,
    this.nama,
    this.harga,
    this.foto,
    this.berat_satuan,
    this.deskripsi,
  });

  factory Produk.fromJson(Map<String, dynamic> json) => Produk(
        id: asInt(json["id"]),
        nama: asString(json["nama"]) ?? asString(json["nama_produk"]),
        harga: asInt(json["harga"]),
        foto: asString(json["foto"]),
        berat_satuan: asDouble(json["berat_satuan"]),
        deskripsi: asString(json["deskripsi"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "harga": harga,
        "foto": foto,
        "berat_satuan": berat_satuan,
        "deskripsi": deskripsi,
      };
}
