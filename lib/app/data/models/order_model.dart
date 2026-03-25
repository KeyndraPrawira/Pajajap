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
    String? latitude;
    String? longitude;
    String? jarakKm;
    int? ongkir;
    int? totalHarga;
    DateTime? updatedAt;
    DateTime? createdAt;
    int? id;
    List<OrderDetail>? orderDetails;

    DataOrder({
        this.kodePesanan,
        this.buyerId,
        this.driverId,
        this.status,
        this.alamatPengiriman,
        this.latitude,
        this.longitude,
        this.jarakKm,
        this.ongkir,
        this.totalHarga,
        this.updatedAt,
        this.createdAt,
        this.id,
        this.orderDetails,
    });

    factory DataOrder.fromJson(Map<String, dynamic> json) => DataOrder(
        kodePesanan: json["kode_pesanan"],
        buyerId: json["buyer_id"],
        driverId: json["driver_id"],
        status: json["status"],
        alamatPengiriman: json["alamat_pengiriman"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        jarakKm: json["jarak_km"],
        ongkir: json["ongkir"],
        totalHarga: json["total_harga"],
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        id: json["id"],
        orderDetails: json["order_details"] == null ? [] : List<OrderDetail>.from(json["order_details"]!.map((x) => OrderDetail.fromJson(x))),
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
        "ongkir": ongkir,
        "total_harga": totalHarga,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "id": id,
        "order_details": orderDetails == null ? [] : List<dynamic>.from(orderDetails!.map((x) => x.toJson())),
    };
}

class OrderDetail {
    int? id;
    int? orderId;
    int? produkId;
    int? kiosId;
    String? status;
    int? hargaSatuan;
    int? jumlah;
    int? subtotalHarga;
    dynamic catatan;
    DateTime? createdAt;
    DateTime? updatedAt;

    OrderDetail({
        this.id,
        this.orderId,
        this.produkId,
        this.kiosId,
        this.status,
        this.hargaSatuan,
        this.jumlah,
        this.subtotalHarga,
        this.catatan,
        this.createdAt,
        this.updatedAt,
    });

    factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
        id: json["id"],
        orderId: json["order_id"],
        produkId: json["produk_id"],
        kiosId: json["kios_id"],
        status: json["status"],
        hargaSatuan: json["harga_satuan"],
        jumlah: json["jumlah"],
        subtotalHarga: json["subtotal_harga"],
        catatan: json["catatan"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "produk_id": produkId,
        "kios_id": kiosId,
        "status": status,
        "harga_satuan": hargaSatuan,
        "jumlah": jumlah,
        "subtotal_harga": subtotalHarga,
        "catatan": catatan,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
