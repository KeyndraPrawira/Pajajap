# TODO: Implementasi Realtime Mencari Driver

## Status: 📋 Belum dimulai

### Step 1: Buat TODO.md [✅ DONE]

### Step 2: Update mencari_driver_view.dart
- [ ] Hapus semua polling code (Timer.periodic, _pollingTimer)
- [ ] Tambah OrderRealTimeService listener spesifik per orderId
- [ ] Implement _handleOrderUpdate: cek driver_id && status=='dalam_proses' → UserDeliveryView
- [ ] Update _batalkanOrder: disconnect realtime
- [ ] Update initState & dispose
- [ ] Test lokal: flutter run

### Step 3: Verifikasi & Clean
- [ ] Cek navigasi dari checkout_controller.dart ke route ini
- [ ] Hapus/arsipkan mencari_driver_realtime_view.dart (duplikat)
- [ ] Run flutter analyze && dart format .

### Step 4: Unit Test
- [ ] Buat test_realtime_listener.dart
- [ ] Test case: driver accept → navigasi otomatis

### Step 5: Complete
- [ ] Jalankan app end-to-end: checkout → mencari driver → driver accept → delivery view
- [ ] Update TODO.md selesai → attempt_completion

**Next: Edit file utama**
