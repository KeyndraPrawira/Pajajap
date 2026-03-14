import 'dart:typed_data';
import 'package:e_pasar/pages/pedagang/controllers/produk_controller.dart';
import 'package:e_pasar/pages/pedagang/controllers/produk_form_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_pasar/app/data/models/produk_model.dart';

class ProdukEditView extends GetView<ProdukFormController> {
  const ProdukEditView({super.key});

  @override
  Widget build(BuildContext context) {
    final DataProduk? produkEdit = Get.arguments;
    final bool isEdit = produkEdit != null;

    // Inisialisasi form jika mode edit
    if (isEdit) {
      controller.fillFormForEdit(produkEdit);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            controller.clearForm();
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Upload Foto ---
              Center(
                child: GestureDetector(
                  onTap: () => _showImageSourceDialog(context),
                  child: Obx(() {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: controller.selectedFotoBytes.value != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(controller.selectedFotoBytes.value!, fit: BoxFit.cover),
                            )
                          : isEdit && produkEdit.foto != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    produkEdit.foto!, 
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50),
                                  ),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text("Klik untuk unggah foto"),
                                  ],
                                ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: controller.namaProdukC,
                label: "Nama Produk",
                hint: "Contoh: Sayur Bayam Segar",
                icon: Icons.shopping_bag_outlined,
              ),

              // --- Dropdown Kategori (Dinamis dari API) ---
              const Text("Kategori Produk", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: controller.selectedKategoriId.value,
                        hint: const Text("Pilih Kategori"),
                        // Mapping data dari kategoriList yang ada di controller
                        items: controller.kategoriList.map((kat) {
                          return DropdownMenuItem<int>(
                            value: kat.id,
                            child: Text(kat.namaKategori ?? '-'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          controller.selectedKategoriId.value = val;
                        },
                      ),
                    ),
                  )),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: controller.hargaC,
                      label: "Harga (Rp)",
                      hint: "0",
                      icon: Icons.money,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: controller.stokC,
                      label: "Stok",
                      hint: "0",
                      icon: Icons.inventory_2_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              _buildTextField(
                controller: controller.beratSatuanC,
                label: "Berat Satuan (gram)",
                hint: "Misal: 500",
                icon: Icons.monitor_weight_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Berat satuan wajib diisi';
                  if (int.tryParse(value) == null) return 'Berat harus berupa angka';
                  return null;
                },
              ),

              _buildTextField(
                controller: controller.deskripsiC,
                label: "Deskripsi Produk",
                hint: "Jelaskan detail produk Anda...",
                icon: Icons.description_outlined,
                maxLines: 3,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: controller.isSubmitting.value
                          ? null
                          : () => isEdit ? controller.submitUpdate(produkEdit) : controller.submitCreate(),
                      child: controller.isSubmitting.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(isEdit ? "SIMPAN PERUBAHAN" : "TAMBAH PRODUK",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper _buildTextField dan _showImageSourceDialog tetap sama...
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.blue.shade700),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: validator ?? (value) => value == null || value.isEmpty ? '$label wajib diisi' : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Galeri"),
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
              leading: const Icon(Icons.camera_alt),
              title: const Text("Kamera"),
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