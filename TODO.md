# Driver Delivery Page (Take Product)

## Plan:
**Information Gathered:**
- No delivery views. OrderService.detailOrder loads full data (buyer, orderDetails.produk.kios)
- Backend checkout → orderDetails with produk.foto, nama_produk, kios.nama_kios, kios.lokasi (assume 'alamat')
- Layout: Modal Column → Profile(top-right) | Buyer info | Products List | Ongkir + Total (gradient)

**Files:**
1. controllers/delivery_controller.dart (load order by id)
2
