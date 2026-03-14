import 'package:flutter/foundation.dart'; // Untuk mengecek platform Web
import 'package:e_pasar/app/data/models/produk_model.dart';
import 'package:e_pasar/pages/pedagang/controllers/produk_form_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProdukAddView extends GetView<ProdukFormController> {
  const ProdukAddView({super.key});

  @override
  Widget build(BuildContext context) {
    final DataProduk? produkEdit = Get.arguments;
    final bool isEdit = produkEdit != null;

    if (isEdit) {
      controller.fillFormForEdit(produkEdit);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Produk' : 'Tambah Produk Baru',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            controller.clearForm();
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Bagian Atas: Unggah Foto ---
            _buildImagePickerSection(context, isEdit, produkEdit),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Informasi Produk"),
                    const SizedBox(height: 12),
                    
                    _buildCustomTextField(
                      controller: controller.namaProdukC,
                      label: "Nama Produk",
                      hint: "Misal: Apel Fuji Segar",
                      icon: Icons.shopping_bag_rounded,
                    ),

                    _buildCategoryDropdown(),
                    const SizedBox(height: 20),

                    _sectionTitle("Detail Penjualan"),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildCustomTextField(
                            controller: controller.hargaC,
                            label: "Harga",
                            hint: "0",
                            prefixText: "Rp ",
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCustomTextField(
                            controller: controller.stokC,
                            label: "Stok",
                            hint: "0",
                            suffixText: "Unit",
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    _buildCustomTextField(
                      controller: controller.beratSatuanC,
                      label: "Berat Satuan",
                      hint: "0",
                      suffixText: "gram",
                      icon: Icons.scale_rounded,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Berat satuan wajib diisi';
                        if (int.tryParse(value) == null) return 'Berat harus berupa angka';
                        return null;
                      },
                    ),

                    _buildCustomTextField(
                      controller: controller.deskripsiC,
                      label: "Deskripsi Produk",
                      hint: "Ceritakan keunggulan produk Anda...",
                      maxLines: 4,
                      icon: Icons.notes_rounded,
                    ),

                    const SizedBox(height: 40),
                    
                    // --- Tombol Submit ---
                    Obx(() => Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E7D32).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: controller.isSubmitting.value
                            ? null
                            : () => isEdit 
                                ? controller.submitUpdate(produkEdit) 
                                : controller.submitCreate(),
                        child: controller.isSubmitting.value
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white, 
                                  strokeWidth: 3,
                                ),
                              )
                            : Text(
                                isEdit ? "SIMPAN PERUBAHAN" : "PUBLIKASIKAN PRODUK",
                                style: const TextStyle(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                      ),
                    )),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF455A64),
      ),
    );
  }

  Widget _buildImagePickerSection(BuildContext context, bool isEdit, DataProduk? produkEdit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Center(
        child: GestureDetector(
          onTap: () => _showImageSourceDialog(context),
          child: Obx(() {
            return Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Image Display
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: _displayImage(isEdit, produkEdit),
                  ),
                  // Edit Icon Overlay
                  Positioned(
                    bottom: -5,
                    right: -5,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _displayImage(bool isEdit, DataProduk? produkEdit) {
    // 1. Tampilkan file baru (Cross-platform)
    if (controller.selectedFotoBytes.value != null) {
      return Image.memory(
        controller.selectedFotoBytes.value!,
        fit: BoxFit.cover,
        width: 160,
        height: 160,
      );
    }

    // 2. Tampilkan foto lama jika mode edit
    if (isEdit && produkEdit?.foto != null) {
      return Image.network(
        "http://10.0.2.2:8000/storage/${produkEdit!.foto}",
        fit: BoxFit.cover,
        width: 160,
        height: 160,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
        ),
      );
    }

    // 3. Placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_rounded, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          const Text("Foto Produk", style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Kategori", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 8),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: controller.selectedKategoriId.value,
              hint: const Text("Pilih Kategori Produk"),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: controller.kategoriList.map((kat) {
                return DropdownMenuItem<int>(
                  value: kat.id,
                  child: Text(kat.namaKategori ?? '-'),
                );
              }).toList(),
              onChanged: (val) => controller.selectedKategoriId.value = val,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    String? prefixText,
    String? suffixText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal, fontSize: 14),
            prefixText: prefixText,
            suffixText: suffixText,
            prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF2E7D32), size: 20) : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
          validator: validator ?? (value) => value == null || value.isEmpty ? '$label wajib diisi' : null,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Wrap(
          children: [
           Center(
              child: Container(
                width: 40, height: 4, 
                decoration: BoxDecoration(color: Color(0xFFE0E0E0), borderRadius: BorderRadius.all(Radius.circular(2))),
              ),
            ),
            const SizedBox(height: 24, width: double.infinity),
            const Text("Pilih Foto Produk", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16, width: double.infinity),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.photo_library_rounded, color: Colors.blue.shade700),
              ),
              title: const Text("Ambil dari Galeri", style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async {
                Get.back();
                final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
                if (picked != null) {
                  final bytes = await picked.readAsBytes();
                  controller.selectedFotoBytes.value = bytes;
                  controller.selectedFotoName.value = picked.name;
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.camera_alt_rounded, color: Colors.orange.shade700),
              ),
              title: const Text("Gunakan Kamera", style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async {
                Get.back();
                final picked = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 70);
                if (picked != null) {
                  final bytes = await picked.readAsBytes();
                  controller.selectedFotoBytes.value = bytes;
                  controller.selectedFotoName.value = picked.name;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}