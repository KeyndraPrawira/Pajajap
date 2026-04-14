// lib/app/pages/pedagang/views/kios_edit_view.dart
import 'dart:typed_data';
import 'package:e_pasar/app/utils/api.dart';
import 'package:e_pasar/pages/pedagang/views/widgets/pedagang_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/pedagang_controller.dart';

class KiosEditView extends StatefulWidget {
  const KiosEditView({Key? key}) : super(key: key);

  @override
  State<KiosEditView> createState() => _KiosEditViewState();
}

class _KiosEditViewState extends State<KiosEditView> {
  final PedagangController controller = Get.find<PedagangController>();

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaKiosController;
  late TextEditingController _lokasiController;
  late TextEditingController _deskripsiController;
  late TextEditingController _jamBukaController;
  late TextEditingController _jamTutupController;

  final _selectedImage = Rxn<XFile>();
  final ImagePicker _picker = ImagePicker();

  String? _currentFotoUrl; // Untuk simpan foto yang sudah ada

  @override
  void initState() {
    super.initState();

    // Load data kios yang akan diedit
    final kios = controller.myKios.value;

    _namaKiosController = TextEditingController(text: kios?.namaKios ?? '');
    _lokasiController = TextEditingController(text: kios?.lokasi ?? '');
    _deskripsiController = TextEditingController(text: kios?.deskripsi ?? '');
    _jamBukaController = TextEditingController(text: kios?.jamBuka ?? '');
    _jamTutupController = TextEditingController(text: kios?.jamTutup ?? '');

    _currentFotoUrl = kios?.fotoKios;
  }

  @override
  void dispose() {
    _namaKiosController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    _jamBukaController.dispose();
    _jamTutupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PedagangUi.pageBackground,
      appBar: AppBar(
        title: const Text('Edit Kios'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: PedagangUi.darkGreen,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Form Content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Foto Kios Section
                      _buildFotoSection(),
                      const SizedBox(height: 24),

                      // Informasi Kios Section
                      _buildSectionTitle('Informasi Kios'),
                      const SizedBox(height: 12),
                      _buildNamaKiosField(),
                      const SizedBox(height: 16),
                      _buildLokasiField(),
                      const SizedBox(height: 16),

                      // Jam Operasional Section
                      _buildSectionTitle('Jam Operasional'),
                      const SizedBox(height: 12),
                      _buildJamOperasionalFields(),
                      const SizedBox(height: 24),

                      // Deskripsi Section
                      _buildSectionTitle('Deskripsi'),
                      const SizedBox(height: 12),
                      _buildDeskripsiField(),
                      const SizedBox(height: 32),

                      // Submit Button
                      _buildSubmitButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            PedagangUi.darkGreen,
            PedagangUi.midGreen,
            PedagangUi.lightGreen,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Edit Kios',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Perbarui informasi kios Anda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== FOTO SECTION ====================
  Widget _buildFotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Foto Kios'),
        const SizedBox(height: 12),
        Obx(() => _buildImagePicker()),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _selectedImage.value != null
            ? _buildNewSelectedImage()
            : _buildCurrentOrPlaceholderImage(),
      ),
    );
  }

  // Gambar baru yang dipilih
  Widget _buildNewSelectedImage() {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          color: Colors.grey[200],
          child: FutureBuilder<Uint8List>(
            future: _selectedImage.value!.readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Row(
            children: [
              _buildIconButton(
                icon: Icons.edit,
                color: PedagangUi.darkGreen,
                onPressed: _showImageSourceDialog,
              ),
              const SizedBox(width: 8),
              _buildIconButton(
                icon: Icons.delete,
                color: Colors.red,
                onPressed: () => _selectedImage.value = null,
              ),
            ],
          ),
        ),
        // Label "Foto Baru"
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: PedagangUi.midGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Foto Baru',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Gambar lama atau placeholder
  Widget _buildCurrentOrPlaceholderImage() {
    if (_currentFotoUrl != null && _currentFotoUrl!.isNotEmpty) {
      // Ada foto lama
      return Stack(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[200],
            child: Image.network(
              '${Api.baseImageUrl}${_currentFotoUrl!}',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                );
              },
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: _buildIconButton(
              icon: Icons.edit,
              color: PedagangUi.darkGreen,
              onPressed: _showImageSourceDialog,
            ),
          ),
        ],
      );
    } else {
      // Belum ada foto
      return InkWell(
        onTap: _showImageSourceDialog,
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: PedagangUi.inputFill,
            border: Border.all(
              color: PedagangUi.inputBorder,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PedagangUi.lightGreen.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 48,
                  color: PedagangUi.darkGreen,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tambah Foto Kios',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Klik untuk memilih foto',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        iconSize: 20,
      ),
    );
  }

  // ==================== FORM FIELDS ====================
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: PedagangUi.darkGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNamaKiosField() {
    return TextFormField(
      controller: _namaKiosController,
      decoration: PedagangUi.inputDecoration(
        labelText: 'Nama Kios *',
        hintText: 'Contoh: Toko Sayur Segar',
        prefixIcon:
            const Icon(Icons.store_outlined, color: PedagangUi.darkGreen),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Nama kios wajib diisi';
        }
        if (value.length < 3) {
          return 'Nama kios minimal 3 karakter';
        }
        return null;
      },
    );
  }

  Widget _buildLokasiField() {
    return TextFormField(
      controller: _lokasiController,
      decoration: PedagangUi.inputDecoration(
        labelText: 'Lokasi/Alamat *',
        hintText: 'Contoh: Blok A No. 12',
        prefixIcon:
            const Icon(Icons.location_on_outlined, color: PedagangUi.darkGreen),
      ),
      maxLines: 2,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lokasi wajib diisi';
        }
        return null;
      },
    );
  }

  Widget _buildJamOperasionalFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _jamBukaController,
            decoration: PedagangUi.inputDecoration(
              labelText: 'Jam Buka *',
              hintText: '08:00',
              prefixIcon:
                  const Icon(Icons.access_time, color: PedagangUi.darkGreen),
            ),
            readOnly: true,
            onTap: () => _selectTime(context, _jamBukaController),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Wajib diisi';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _jamTutupController,
            decoration: PedagangUi.inputDecoration(
              labelText: 'Jam Tutup *',
              hintText: '17:00',
              prefixIcon:
                  const Icon(Icons.access_time, color: PedagangUi.darkGreen),
            ),
            readOnly: true,
            onTap: () => _selectTime(context, _jamTutupController),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Wajib diisi';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeskripsiField() {
    return TextFormField(
      controller: _deskripsiController,
      decoration: PedagangUi.inputDecoration(
        labelText: 'Deskripsi Kios',
        hintText: 'Ceritakan tentang kios Anda...',
        prefixIcon:
            const Icon(Icons.description_outlined, color: PedagangUi.darkGreen),
        alignLabelWithHint: true,
      ),
      maxLines: 4,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: PedagangUi.darkGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_outlined, size: 24),
            SizedBox(width: 8),
            Text(
              'Simpan Perubahan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== IMAGE PICKER DIALOG ====================
  Future<void> _showImageSourceDialog() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pilih Sumber Foto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSourceOption(
                    icon: Icons.photo_library,
                    label: 'Galeri',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
                
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: PedagangUi.darkGreen),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PICK IMAGE ====================
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1080,
      );

      if (image != null) {
        _selectedImage.value = image;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih gambar: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ==================== TIME PICKER ====================
  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final String formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      controller.text = formattedTime;
    }
  }

  // ==================== SUBMIT FORM ====================
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      Get.snackbar(
        'Peringatan',
        'Mohon lengkapi semua data yang wajib diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
      );
      return;
    }

    // Validate jam buka < jam tutup
    final jamBuka = _jamBukaController.text;
    final jamTutup = _jamTutupController.text;

    if (jamBuka.compareTo(jamTutup) >= 0) {
      Get.snackbar(
        'Peringatan',
        'Jam tutup harus lebih besar dari jam buka',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
      );
      return;
    }

    // Konfirmasi
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.save_outlined, color: PedagangUi.darkGreen),
            SizedBox(width: 12),
            Text('Konfirmasi'),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin menyimpan perubahan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ya, Simpan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Convert XFile to bytes for upload
    Uint8List? imageBytes;
    String? imageName;
    if (_selectedImage.value != null) {
      imageBytes = await _selectedImage.value!.readAsBytes();
      imageName = _selectedImage.value!.name;
    }

    final kios = controller.myKios.value;

    // Call controller to update kios
    await controller.editKios(
      kiosId: kios!.id!,
      namaKios: _namaKiosController.text.trim(),
      lokasi: _lokasiController.text.trim(),
      jamBuka: _jamBukaController.text.trim(),
      jamTutup: _jamTutupController.text.trim(),
      deskripsi: _deskripsiController.text.trim().isNotEmpty
          ? _deskripsiController.text.trim()
          : null,
      fotoKiosBytes: imageBytes,
      fotoKiosFilename: imageName,
    );
  }
}
