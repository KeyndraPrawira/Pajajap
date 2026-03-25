// To parse this JSON data, do
//
//     final pasar = pasarFromJson(jsonString);

import 'dart:convert';

Pasar pasarFromJson(String str) => Pasar.fromJson(json.decode(str));

String pasarToJson(Pasar data) => json.encode(data.toJson());

class Pasar {
    String? status;
    String? message;
    DataPasar? data;

    Pasar({
        this.status,
        this.message,
        this.data,
    });

    factory Pasar.fromJson(Map<String, dynamic> json) => Pasar(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : DataPasar.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
    };
}

class DataPasar {
    int? id;
    String? namaPasar;
    String? alamat;
    String? fotoPasar;
    int? ongkir;
    int? minimalOngkir;
    int? biayaLayanan;
    int? biayaBeratBarang;
    String? kontak;
    String? deskripsi;
    double? longitude;
    double? latitude;
    DateTime? createdAt;
    DateTime? updatedAt;

    DataPasar({
        this.id,
        this.namaPasar,
        this.alamat,
        this.fotoPasar,
        this.ongkir,
        this.minimalOngkir,
        this.biayaLayanan,
        this.biayaBeratBarang,
        this.kontak,
        this.deskripsi,
        this.longitude,
        this.latitude,
        this.createdAt,
        this.updatedAt,
    });

    factory DataPasar.fromJson(Map<String, dynamic> json) => DataPasar(
        id: json["id"],
        namaPasar: json["nama_pasar"],
        alamat: json["alamat"],
        fotoPasar: json["foto_pasar"],
        ongkir: json["ongkir"],
        minimalOngkir: json["minimal_ongkir"],
        biayaLayanan: json["biaya_layanan"],
        biayaBeratBarang: json["biaya_berat_barang"],
        kontak: json["kontak"],
        deskripsi: json["deskripsi"],
        longitude: double.tryParse(json["longitude"]?.toString() ?? ""),
        latitude: double.tryParse(json["latitude"]?.toString() ?? ""),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nama_pasar": namaPasar,
        "alamat": alamat,
        "foto_pasar": fotoPasar,
        "ongkir": ongkir,
        "minimal_ongkir": minimalOngkir,
        "biaya_layanan": biayaLayanan,
        "biaya_berat_barang": biayaBeratBarang,
        "kontak": kontak,
        "deskripsi": deskripsi,
        "longitude": longitude,
        "latitude": latitude,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
