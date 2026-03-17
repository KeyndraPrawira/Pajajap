import 'package:e_pasar/pages/user/controllers/profile_controller.dart';
import 'package:e_pasar/pages/user/views/map_picker_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({Key? key}) : super(key: key);

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final ProfileController _profileC = Get.find<ProfileController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _alamatController;

  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    // Mengambil data awal dari controller secara eksplisit
    final profile = _profileC.dataProfile.value;
    
    _nameController = TextEditingController(text: profile?.username ?? '');
    _phoneController = TextEditingController(text: profile?.nomorTelepon ?? '');
    _alamatController = TextEditingController(text: profile?.alamat?.alamatLengkap ?? '');
    _latitude = profile?.alamat?.latitude;
    _longitude = profile?.alamat?.longitude;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Logika pick image bisa diimplementasikan di controller
    // Contoh pemanggilan: _profileC.pickImage();
    Get.snackbar(
      'Info',
      'Fitur pilih foto profil akan membuka galeri/kamera',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _pickFromMap() async {
    final result = await Get.to(() => const MapPickerView());
    if (result != null && result is Map) {
      setState(() {
        _alamatController.text = result['alamat'] ?? '';
        _latitude = result['latitude'];
        _longitude = result['longitude'];
      });
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    
    await _profileC.updateProfile(
      _nameController.text.trim(),
      _phoneController.text.trim(),
    );

    if (_alamatController.text.isNotEmpty) {
      await _profileC.setAlamat(
        _alamatController.text.trim(),
        _latitude ?? 0.0,
        _longitude ?? 0.0,
      );
    }
    
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (_profileC.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Pastikan controller terupdate jika dataProfile berubah di background
        final profile = _profileC.dataProfile.value;
        if (_nameController.text.isEmpty && profile?.username != null) {
          _nameController.text = profile!.username!;
        }

        return CustomScrollView(
          slivers: [
            // AppBar dengan Gradient Biru-Hijau
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: const Color(0xFF0077B6),
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0077B6), Color(0xFF06D6A0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 47,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: profile?.fotoProfil != null 
                                    ? NetworkImage(profile!.fotoProfil!) 
                                    : null,
                                child: profile?.fotoProfil == null
                                    ? const Icon(Icons.person, size: 60, color: Color(0xFF0077B6))
                                    : null,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Color(0xFF0077B6),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        profile?.username ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              title: const Text('Edit Profile'),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section: Data Diri
                      _sectionCard(
                        title: 'Data Diri',
                        icon: Icons.person_outline,
                        color: const Color(0xFF0077B6),
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: 'Nama',
                            icon: Icons.badge_outlined,
                            validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Nomor Telepon',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (v) => v == null || v.isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Section: Alamat
                      _sectionCard(
                        title: 'Alamat Pengiriman',
                        icon: Icons.location_on_outlined,
                        color: const Color(0xFF06D6A0),
                        children: [
                          _buildTextField(
                            controller: _alamatController,
                            label: 'Alamat Lengkap',
                            icon: Icons.map_outlined,
                            maxLines: 3,
                            readOnly: false,
                          ),
                          const SizedBox(height: 12),

                          if (_latitude != null)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF06D6A0).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.gps_fixed, size: 14, color: Color(0xFF06D6A0)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Koordinat: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF06D6A0)),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _pickFromMap,
                              icon: const Icon(Icons.map_outlined),
                              label: Text(_latitude == null ? 'Pilih Lokasi dari Peta' : 'Ubah Lokasi Peta'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF06D6A0),
                                side: const BorderSide(color: Color(0xFF06D6A0)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Tombol Simpan dengan Gradient
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0077B6), Color(0xFF06D6A0)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: _simpan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Simpan Perubahan',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0077B6)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0077B6), width: 2),
        ),
      ),
    );
  }
}