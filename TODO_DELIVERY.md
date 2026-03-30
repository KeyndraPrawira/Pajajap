# Driver Delivery Page

**Information Gathered:**
- Order.data (kodePesanan, buyerId, alamatPengiriman, jarakKm, ongkir, totalHarga, orderDetails [produkId, kiosId, hargaSatuan, jumlah, subtotalHarga])
- DataKios (namaKios, lokasi)
- DataProduk (namaProduk, foto)
- DataUser (name)

**Plan:**
1. Create delivery_controller.dart: RxDataOrder orderData dummy
2. Create delivery_view.dart: Modal Scaffold AppBar close, top-right profile, center buyer info, ListView products (foto, nama, kios nama/lokasi, harga x jumlah), bottom gradient ongkir+total 'Selesai'
3. delivery_binding.dart
4. Add AppRoutes.DRIVER_DELIVERY = '/driver/delivery/:id'
5. Add GetPage DRIVER_DELIVERY
6. Add acceptOrder in driver_controller: accept API, Get.toNamed(DRIVER_DELIVERY, arguments: orderId)

**Current:**

