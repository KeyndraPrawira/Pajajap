import 'dart:convert';

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
        (json["data"] as List).map((x) => DataKeranjang.fromJson(x)),
      );
    } else if (json["data"] is Map) {
      // store() / update() → single object, wrap jadi list
      parsedData = [DataKeranjang.fromJson(json["data"])];
    }

    return Keranjang(
      status: json["status"],
      message: json["message"],
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
        id: json["id"],
        userId: json["user_id"],
        produkId: json["produk_id"]?.toString(),
        jumlah: json["jumlah"]?.toString(),
        hargaTotal: json["harga_total"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        produk:
            json["produk"] == null ? null : Produk.fromJson(json["produk"]),
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
  String? deskripsi;

  Produk({
    this.id,
    this.nama,
    this.harga,
    this.foto,
    this.deskripsi,
  });

  factory Produk.fromJson(Map<String, dynamic> json) => Produk(
        id: json["id"],
        nama: json["nama"],
        harga: json["harga"],
        foto: json["foto"],
        deskripsi: json["deskripsi"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "harga": harga,
        "foto": foto,
        "deskripsi": deskripsi,
      };
}