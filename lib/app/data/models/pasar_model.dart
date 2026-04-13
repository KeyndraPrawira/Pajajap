// To parse this JSON data, do
//
//     final pasar = pasarFromJson(jsonString);

import 'dart:convert';

import 'package:e_pasar/app/data/models/json_parsers.dart';

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
        status: asString(json["status"]),
        message: asString(json["message"]),
        data: asMap(json["data"]) == null
            ? null
            : DataPasar.fromJson(asMap(json["data"])!),
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
        id: asInt(json["id"]),
        namaPasar: asString(json["nama_pasar"]),
        alamat: asString(json["alamat"]),
        fotoPasar: asString(json["foto_pasar"]),
        ongkir: asInt(json["ongkir"]),
        minimalOngkir: asInt(json["minimal_ongkir"]),
        biayaLayanan: asInt(json["biaya_layanan"]),
        biayaBeratBarang: asInt(json["biaya_berat_barang"]),
        kontak: asString(json["kontak"]),
        deskripsi: asString(json["deskripsi"]),
        longitude: asDouble(json["longitude"]),
        latitude: asDouble(json["latitude"]),
        createdAt: asDateTime(json["created_at"]),
        updatedAt: asDateTime(json["updated_at"]),
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
