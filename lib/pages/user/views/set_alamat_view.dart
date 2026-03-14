// lib/pages/user/views/set_alamat_view.dart
import 'package:e_pasar/pages/user/controllers/profile_controller.dart';
import 'package:e_pasar/pages/user/views/map_picker_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class SetAlamatView extends StatefulWidget {
  const SetAlamatView({Key? key}) : super(key: key);

  @override
  State<SetAlamatView> createState() => _SetAlamatViewState();
}

class _SetAlamatViewState extends State<SetAlamatView> {
  final ProfileController profileController = Get.find<ProfileController>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill if alamat exists
    final alamat = profileController.profile.value?.data?.alamat;
    if (alamat != null) {
      _alamatController.text = alamat.alamatLengkap ?? '';
      _latitudeController.text = alamat.latitude?.toString() ?? '';
      _longitudeController.text = alamat.longitude?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _alamatController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Alamat'),
        backgroundColor: const Color(0xFF0077B6),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveAlamat,
            child: const Text(
              'Simpan',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (profileController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Alamat Lengkap
              TextFormField(
                controller: _alamatController,
                decoration: InputDecoration(
                  labelText: 'Alamat Lengkap',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF0077B6), width: 2),
                  ),
                  hintText: 'Masukkan alamat lengkap Anda',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Latitude
              TextFormField(
                controller: _latitudeController,
                decoration: InputDecoration(
                  labelText: 'Latitude',
                  prefixIcon: const Icon(Icons.gps_fixed_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF0077B6), width: 2),
                  ),
                  hintText: 'Contoh: -6.2088',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Latitude tidak boleh kosong';
                  }
                  final lat = double.tryParse(value);
                  if (lat == null || lat < -90 || lat > 90) {
                    return 'Latitude tidak valid (-90 sampai 90)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Longitude
              TextFormField(
                controller: _longitudeController,
                decoration: InputDecoration(
                  labelText: 'Longitude',
                  prefixIcon: const Icon(Icons.gps_fixed_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF0077B6), width: 2),
                  ),
                  hintText: 'Contoh: 106.8456',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Longitude tidak boleh kosong';
                  }
                  final lng = double.tryParse(value);
                  if (lng == null || lng < -180 || lng > 180) {
                    return 'Longitude tidak valid (-180 sampai 180)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Pilih dari Map Button
              ElevatedButton.icon(
                onPressed: _pickFromMap,
                icon: const Icon(Icons.map_outlined),
                label: const Text('Pilih dari Peta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0077B6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF0077B6).withOpacity(0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tips:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0077B6),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Pastikan alamat lengkap dan akurat\n'
                      '• Koordinat GPS akan digunakan untuk pengiriman\n'
                      '• Klik "Pilih dari Peta" untuk mendapatkan koordinat otomatis',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _pickFromMap() async {
    final LatLng? selectedLocation = await Get.to(() => const MapPickerView());
    if (selectedLocation != null) {
      setState(() {
        _latitudeController.text = selectedLocation.latitude.toString();
        _longitudeController.text = selectedLocation.longitude.toString();
      });
      Get.snackbar('Berhasil', 'Koordinat berhasil dipilih dari peta');
    }
  }

  void _saveAlamat() {
    if (_formKey.currentState!.validate()) {
      final alamat = _alamatController.text.trim();
      final latitude = double.parse(_latitudeController.text.trim());
      final longitude = double.parse(_longitudeController.text.trim());

      profileController.setAlamat(alamat, latitude, longitude).then((_) {
        Get.back();
        Get.snackbar('Berhasil', 'Alamat berhasil disimpan');
      });
    }
  }
}