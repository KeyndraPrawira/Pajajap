// lib/pages/user/views/edit_alamat_view.dart
import 'package:e_pasar/pages/user/controllers/profile_controller.dart';
import 'package:e_pasar/pages/user/views/map_picker_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class EditAlamatView extends StatefulWidget {
  const EditAlamatView({Key? key}) : super(key: key);

  @override
  State<EditAlamatView> createState() => _EditAlamatViewState();
}

class _EditAlamatViewState extends State<EditAlamatView> {
  final ProfileController profileController = Get.find<ProfileController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _alamatController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  @override
  void initState() {
    super.initState();
    _alamatController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    _loadAlamatData();
  }

  void _loadAlamatData() {
    final alamat = profileController.dataProfile.value?.alamat;
    if (alamat != null) {
      _alamatController.text = alamat.alamatLengkap ?? '';
      _latitudeController.text = alamat.latitude?.toStringAsFixed(6) ?? '';
      _longitudeController.text = alamat.longitude?.toStringAsFixed(6) ?? '';
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
        title: const Text('Ubah Alamat Pengiriman'),
        backgroundColor: const Color(0xFF00B4D8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (profileController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE0F7FA), Color(0xFFE8F5E9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B4D8).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_location_alt_outlined,
                            color: Color(0xFF00B4D8),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Sesuaikan Lokasi Anda',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0077B6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Alamat Lengkap
                  Text(
                    'Alamat Lengkap',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _alamatController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF00B4D8)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDEDEDE)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF00B4D8), width: 2),
                      ),
                      hintText: 'Masukkan alamat lengkap Anda',
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Alamat tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Koordinat GPS
                  Text(
                    'Koordinat GPS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Latitude',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _latitudeController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.gps_fixed_outlined, color: Color(0xFF06D6A0)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFDEDEDE)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFF06D6A0), width: 2),
                                ),
                                hintText: '-6.2088',
                                hintStyle: const TextStyle(color: Colors.grey),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Latitude tidak boleh kosong';
                                }
                                final lat = double.tryParse(value);
                                if (lat == null || lat < -90 || lat > 90) {
                                  return 'Tidak valid';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Longitude',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _longitudeController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.gps_fixed_outlined, color: Color(0xFF1B9AAA)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFDEDEDE)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFF1B9AAA), width: 2),
                                ),
                                hintText: '106.8456',
                                hintStyle: const TextStyle(color: Colors.grey),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Longitude tidak boleh kosong';
                                }
                                final lng = double.tryParse(value);
                                if (lng == null || lng < -180 || lng > 180) {
                                  return 'Tidak valid';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Pilih dari Peta Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickFromMap,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Pilih dari Peta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4D8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F8FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF00B4D8).withOpacity(0.3)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tips:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00B4D8),
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '• Pastikan alamat lengkap dan akurat\n'
                          '• Gunakan fitur peta untuk koordinat otomatis\n'
                          '• Koordinat digunakan untuk pengiriman',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Simpan Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveAlamat,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06D6A0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Simpan Alamat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void _pickFromMap() async {
    final LatLng? selectedLocation = await Get.to(() => const MapPickerView());
    if (selectedLocation != null) {
      setState(() {
        _latitudeController.text = selectedLocation.latitude.toStringAsFixed(6);
        _longitudeController.text = selectedLocation.longitude.toStringAsFixed(6);
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
