// To parse this JSON data, do
//
//     final order = orderFromJson(jsonString);

import 'dart:convert';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
    DataOrder? data;

    Order({
        this.data,
    });

    factory Order.fromJson(Map<String, dynamic> json) => Order(
        data: json["data"] == null ? null : DataOrder.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
    };
}

class DataOrder {
    String? kodePesanan;
    int? buyerId;
    int? driverId;
    String? status;
    String? alamatPengiriman;
    double? latitude;
    double? longitude;
    String? jarakKm;
    int? totalHargaBarang;
    int? ongkir;
    int? totalHarga;
    DateTime? updatedAt;
    DateTime? createdAt;
    int? id;
    List<OrderDetail>? orderDetails;
    Buyer? buyer;

    DataOrder({
        this.kodePesanan,
        this.buyerId,
        this.driverId,
        this.status,
        this.alamatPengiriman,
        this.latitude,
        this.longitude,
        this.jarakKm,
        this.totalHargaBarang,
        this.ongkir,
        this.totalHarga,
        this.updatedAt,
        this.createdAt,
        this.id,
        this.orderDetails,
        this.buyer,
    });

    factory DataOrder.fromJson(Map<String, dynamic> json) => DataOrder(
        kodePesanan: json["kode_pesanan"].toString(),
        buyerId: json["buyer_id"],
        driverId: json["driver_id"],
        status: json["status"],
        alamatPengiriman: json["alamat_pengiriman"],
      
        latitude: double.tryParse(json["latitude"]?.toString() ?? '') ?? 0.0,
        longitude: double.tryParse(json["longitude"]?.toString() ?? '') ?? 0.0,
        jarakKm: json["jarak_km"],
        totalHargaBarang: json["total_harga_barang"],
        ongkir: json["ongkir"],
        totalHarga: json["total_harga"],
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        id: json["id"],
        orderDetails: json["order_details"] == null ? [] : List<OrderDetail>.from(json["order_details"]!.map((x) => OrderDetail.fromJson(x))),
        buyer: json["buyer"] == null ? null : Buyer.fromJson(json["buyer"]),
    );

    Map<String, dynamic> toJson() => {
        "kode_pesanan": kodePesanan,
        "buyer_id": buyerId,
        "driver_id": driverId,
        "status": status,
        "alamat_pengiriman": alamatPengiriman,
        "latitude": latitude,
        "longitude": longitude,
        "jarak_km": jarakKm,
        "total_harga_barang": totalHargaBarang,
        "ongkir": ongkir,
        "total_harga": totalHarga,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "id": id,
        "order_details": orderDetails == null ? [] : List<dynamic>.from(orderDetails!.map((x) => x.toJson())),
        "buyer": buyer?.toJson(),
    };
}

class OrderDetail {
    int? id;
    int? orderId;
    int? produkId;
    int? kiosId;
    String? status;
    String? catatanDriver;
    int? hargaSatuan;
    int? jumlah;
    int? subtotalHarga;
    dynamic catatan;
    DateTime? createdAt;
    DateTime? updatedAt;
    Produk? produk;

    OrderDetail({
        this.id,
        this.orderId,
        this.produkId,
        this.kiosId,
        this.status,
        this.catatanDriver,
        this.hargaSatuan,
        this.jumlah,
        this.subtotalHarga,
        this.catatan,
        this.createdAt,
        this.updatedAt,
        this.produk,
    });

    factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
        id: json["id"],
        orderId: json["order_id"],
        produkId: json["produk_id"],
        kiosId: json["kios_id"],
        status: json["status"],
        catatanDriver: json["catatan_driver"],
        hargaSatuan: json["harga_satuan"],
        jumlah: json["jumlah"],
        subtotalHarga: json["subtotal_harga"],
        catatan: json["catatan"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        produk: json["produk"] == null ? null : Produk.fromJson(json["produk"]), // ← tambah ini
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "produk_id": produkId,
        "kios_id": kiosId,
        "status": status,
        "catatan_driver": catatanDriver,
        "harga_satuan": hargaSatuan,
        "jumlah": jumlah,
        "subtotal_harga": subtotalHarga,
        "catatan": catatan,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "produk": produk?.toJson(), // ← tambah ini
        
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
  });
 
  factory Produk.fromJson(Map<String, dynamic> json) => Produk(
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

class Buyer {
    int? id;
    String? name;
    String? email;
    dynamic emailVerifiedAt;
    dynamic googleId;
    String? role;
    String? nomorTelepon;
    dynamic fotoProfil;
    bool? isOnline;
    dynamic rememberToken;
    DateTime? createdAt;
    DateTime? updatedAt;

    Buyer({
        this.id,
        this.name,
        this.email,
        this.emailVerifiedAt,
        this.googleId,
        this.role,
        this.nomorTelepon,
        this.fotoProfil,
        this.isOnline,
        this.rememberToken,
        this.createdAt,
        this.updatedAt,
    });

    factory Buyer.fromJson(Map<String, dynamic> json) => Buyer(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"],
        googleId: json["google_id"],
        role: json["role"],
        nomorTelepon: json["nomor_telepon"],
        fotoProfil: json["foto_profil"],
        rememberToken: json["remember_token"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "email_verified_at": emailVerifiedAt,
        "google_id": googleId,
        "role": role,
        "nomor_telepon": nomorTelepon,
        "foto_profil": fotoProfil,
        "remember_token": rememberToken,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
