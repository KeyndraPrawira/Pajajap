// To parse this JSON data, do
//
//     final order = orderFromJson(jsonString);

import 'dart:convert';

import 'package:e_pasar/app/data/models/json_parsers.dart';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
  String? status;
  String? message;
  DataOrder? dataOrder;

  Order({
    this.status,
    this.message,
    this.dataOrder,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        status: asString(json["status"]),
        message: asString(json["message"]),
        dataOrder: asMap(json["dataOrder"]) == null
            ? null
            : DataOrder.fromJson(asMap(json["dataOrder"])!),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "dataOrder": dataOrder?.toJson(),
      };
}

class DataOrder {
  int? id;
  String? kodePesanan;
  int? buyerId;
  int? driverId;
  String? status;
  String? metodePembayaran;
  String? alamatPengiriman;
  double? latitude;
  double? longitude;
  String? jarakKm;
  int? totalHargaBarang;
  int? ongkir;
  int? totalHarga;
  int? driverEarningAmount;
  dynamic driverWalletCreditedAt;
  dynamic catatan;
  dynamic deletedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? paymentStatus;
  dynamic paymentReference;
  dynamic paymentToken;
  dynamic paymentUrl;
  dynamic paymentType;
  dynamic paidAt;
  List<OrderDetail>? orderDetails;
  Buyer? buyer;
  Buyer? driver;

  DataOrder({
    this.id,
    this.kodePesanan,
    this.buyerId,
    this.driverId,
    this.status,
    this.metodePembayaran,
    this.alamatPengiriman,
    this.latitude,
    this.longitude,
    this.jarakKm,
    this.totalHargaBarang,
    this.ongkir,
    this.totalHarga,
    this.driverEarningAmount,
    this.driverWalletCreditedAt,
    this.catatan,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.paymentStatus,
    this.paymentReference,
    this.paymentToken,
    this.paymentUrl,
    this.paymentType,
    this.paidAt,
    this.orderDetails,
    this.buyer,
    this.driver,
  });

  factory DataOrder.fromJson(Map<String, dynamic> json) => DataOrder(
        id: asInt(json["id"]),
        kodePesanan: asString(json["kode_pesanan"]),
        buyerId: asInt(json["buyer_id"]),
        driverId: asInt(json["driver_id"]),
        status: asString(json["status"]),
        metodePembayaran: asString(json["metode_pembayaran"]),
        alamatPengiriman: asString(json["alamat_pengiriman"]),
        latitude: asDouble(json["latitude"]),
        longitude: asDouble(json["longitude"]),
        jarakKm: asString(json["jarak_km"]),
        totalHargaBarang: asInt(json["total_harga_barang"]),
        ongkir: asInt(json["ongkir"]),
        totalHarga: asInt(json["total_harga"]),
        driverEarningAmount: asInt(json["driver_earning_amount"]),
        driverWalletCreditedAt: json["driver_wallet_credited_at"],
        catatan: json["catatan"],
        deletedAt: json["deleted_at"],
        createdAt: asDateTime(json["created_at"]),
        updatedAt: asDateTime(json["updated_at"]),
        paymentStatus: asString(json["payment_status"]),
        paymentReference: json["payment_reference"],
        paymentToken: json["payment_token"],
        paymentUrl: json["payment_url"],
        paymentType: json["payment_type"],
        paidAt: json["paid_at"],
        orderDetails: json["order_details"] == null
            ? []
            : List<OrderDetail>.from(
                json["order_details"]!.map((x) => OrderDetail.fromJson(x))),
        buyer: asMap(json["buyer"]) == null
            ? null
            : Buyer.fromJson(asMap(json["buyer"])!),
        driver: asMap(json["driver"]) == null
            ? null
            : Buyer.fromJson(asMap(json["driver"])!),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "kode_pesanan": kodePesanan,
        "buyer_id": buyerId,
        "driver_id": driverId,
        "status": status,
        "metode_pembayaran": metodePembayaran,
        "alamat_pengiriman": alamatPengiriman,
        "latitude": latitude,
        "longitude": longitude,
        "jarak_km": jarakKm,
        "total_harga_barang": totalHargaBarang,
        "ongkir": ongkir,
        "total_harga": totalHarga,
        "driver_earning_amount": driverEarningAmount,
        "driver_wallet_credited_at": driverWalletCreditedAt,
        "catatan": catatan,
        "deleted_at": deletedAt,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "payment_status": paymentStatus,
        "payment_reference": paymentReference,
        "payment_token": paymentToken,
        "payment_url": paymentUrl,
        "payment_type": paymentType,
        "paid_at": paidAt,
        "order_details": orderDetails == null
            ? []
            : List<dynamic>.from(orderDetails!.map((x) => x.toJson())),
        "buyer": buyer?.toJson(),
        "driver": driver?.toJson(),
      };
}

class Buyer {
  int? id;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  String? password;
  dynamic googleId;
  String? role;
  String? nomorTelepon;
  dynamic fotoProfil;
  bool? isOnline;
  dynamic rememberToken;
  DateTime? createdAt;
  DateTime? updatedAt;
  DriverInfo? driverInfo;

  Buyer({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.password,
    this.googleId,
    this.role,
    this.nomorTelepon,
    this.fotoProfil,
    this.isOnline,
    this.rememberToken,
    this.createdAt,
    this.updatedAt,
    this.driverInfo,
  });

  factory Buyer.fromJson(Map<String, dynamic> json) => Buyer(
        id: asInt(json["id"]),
        name: asString(json["name"]),
        email: asString(json["email"]),
        emailVerifiedAt: json["email_verified_at"],
        password: asString(json["password"]),
        googleId: json["google_id"],
        role: asString(json["role"]),
        nomorTelepon: asString(json["nomor_telepon"]),
        fotoProfil: json["foto_profil"],
        isOnline: asBool(json["is_online"]),
        rememberToken: json["remember_token"],
        createdAt: asDateTime(json["created_at"]),
        updatedAt: asDateTime(json["updated_at"]),
        driverInfo: asMap(json["driver_info"]) == null
            ? null
            : DriverInfo.fromJson(asMap(json["driver_info"])!),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "email_verified_at": emailVerifiedAt,
        "password": password,
        "google_id": googleId,
        "role": role,
        "nomor_telepon": nomorTelepon,
        "foto_profil": fotoProfil,
        "is_online": isOnline,
        "remember_token": rememberToken,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "driver_info": driverInfo?.toJson(),
      };
}

class DriverInfo {
  int? id;
  int? userId;
  String? nomorKendaraan;
  String? jenisKendaraan;
  String? fotoKendaraan;
  String? status;
  dynamic verificationNotes;
  dynamic verifiedBy;
  dynamic verifiedAt;
  DateTime? createdAt;
  DateTime? updatedAt;

  DriverInfo({
    this.id,
    this.userId,
    this.nomorKendaraan,
    this.jenisKendaraan,
    this.fotoKendaraan,
    this.status,
    this.verificationNotes,
    this.verifiedBy,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) => DriverInfo(
        id: asInt(json["id"]),
        userId: asInt(json["user_id"]),
        nomorKendaraan: asString(json["nomor_kendaraan"]),
        jenisKendaraan: asString(json["jenis_kendaraan"]),
        fotoKendaraan: asString(json["foto_kendaraan"]),
        status: asString(json["status"]),
        verificationNotes: json["verification_notes"],
        verifiedBy: json["verified_by"],
        verifiedAt: json["verified_at"],
        createdAt: asDateTime(json["created_at"]),
        updatedAt: asDateTime(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "nomor_kendaraan": nomorKendaraan,
        "jenis_kendaraan": jenisKendaraan,
        "foto_kendaraan": fotoKendaraan,
        "status": status,
        "verification_notes": verificationNotes,
        "verified_by": verifiedBy,
        "verified_at": verifiedAt,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class OrderDetail {
  int? id;
  int? orderId;
  int? produkId;
  int? kiosId;
  String? status;
  dynamic produkPenggantiId;
  int? hargaSatuan;
  int? jumlah;
  int? subtotalHarga;
  dynamic catatanDriver;
  DateTime? createdAt;
  DateTime? updatedAt;
  Produk? produk;

  OrderDetail({
    this.id,
    this.orderId,
    this.produkId,
    this.kiosId,
    this.status,
    this.produkPenggantiId,
    this.hargaSatuan,
    this.jumlah,
    this.subtotalHarga,
    this.catatanDriver,
    this.createdAt,
    this.updatedAt,
    this.produk,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
        id: asInt(json["id"]),
        orderId: asInt(json["order_id"]),
        produkId: asInt(json["produk_id"]),
        kiosId: asInt(json["kios_id"]),
        status: asString(json["status"]),
        produkPenggantiId: json["produk_pengganti_id"],
        hargaSatuan: asInt(json["harga_satuan"]),
        jumlah: asInt(json["jumlah"]),
        subtotalHarga: asInt(json["subtotal_harga"]),
        catatanDriver: json["catatan_driver"],
        createdAt: asDateTime(json["created_at"]),
        updatedAt: asDateTime(json["updated_at"]),
        produk: asMap(json["produk"]) == null
            ? null
            : Produk.fromJson(asMap(json["produk"])!),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "produk_id": produkId,
        "kios_id": kiosId,
        "status": status,
        "produk_pengganti_id": produkPenggantiId,
        "harga_satuan": hargaSatuan,
        "jumlah": jumlah,
        "subtotal_harga": subtotalHarga,
        "catatan_driver": catatanDriver,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "produk": produk?.toJson(),
      };
}

class Produk {
  int? id;
  String? namaProduk;
  int? kategoriId;
  int? harga;
  String? deskripsi;
  int? stok;
  String? foto;
  int? beratSatuan;
  int? kiosId;
  DateTime? createdAt;
  DateTime? updatedAt;
  Kios? kios;

  Produk({
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

  factory Produk.fromJson(Map<String, dynamic> json) => Produk(
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
  String? status;
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
    this.status,
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
        status: asString(json["status"]),
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
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
