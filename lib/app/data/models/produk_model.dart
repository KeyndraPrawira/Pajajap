import 'dart:convert';

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
        status: json["status"],
        message: json["message"],
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
  });

  factory DataProduk.fromJson(Map<String, dynamic> json) => DataProduk(
        id: json["id"],
        namaProduk: json["nama_produk"],
        kategoriId: json["kategori_id"],
        harga: json["harga"],
        deskripsi: json["deskripsi"],
        stok: json["stok"],
        foto: json["foto"],
        beratSatuan: json["berat_satuan"],
        kiosId: json["kios_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
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
      };
}