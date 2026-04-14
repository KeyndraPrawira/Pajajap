// lib/app/modules/user/views/user_profile_view.dart
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:e_pasar/pages/user/controllers/profile_controller.dart';
import 'package:e_pasar/pages/user/views/edit_profile_view.dart';
import 'package:e_pasar/pages/user/views/user_order_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileView extends StatelessWidget {
  const UserProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final profileC = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Buyer'),
        backgroundColor: const Color(0xFF0077B6),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Profile Header ──
          Obx(() {
            final profile = profileC.dataProfile.value;
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 47,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: profile?.fotoProfil != null
                          ? NetworkImage(profile!.fotoProfil.toString())
                          : null,
                      child: profile?.fotoProfil == null
                          ? const Icon(Icons.person,
                              size: 60, color: Color(0xFF0077B6))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nama
                  Text(
                    profile?.name ?? authService.getUserName() ?? 'User',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Email
                  Text(
                    profile?.email ?? authService.getUserEmail() ?? '-',
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),

                  // Nomor telepon
                  Text(
                    profile?.nomorTelepon ?? '-',
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),

                  // Alamat (kalau sudah ada)
                  if (profile?.alamat?.alamatLengkap != null) ...[
                    const SizedBox(height: 10),
                    const Divider(color: Colors.white30),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            profile!.alamat!.alamatLengkap!,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white70),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 10),
                    // Belum ada alamat
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_off,
                              color: Colors.white70, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Alamat belum diatur',
                            style:
                                TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // ── Menu Items ──
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile & Alamat',
            subtitle: 'Ubah nama, telepon, dan lokasi pengiriman',
            onTap: () async {
              await Get.to(() => const EditProfileView());
              // Refresh profile setelah kembali dari edit
              profileC.getProfile();
            },
          ),

          _buildMenuItem(
            icon: Icons.shopping_bag_outlined,
            title: 'Pesanan Saya',
            onTap: () {
              Get.to(UserOrderView());
            },
          ),

         

         

          // ── Logout ──
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Keluar',
            isDestructive: true,
            onTap: () {
              Get.dialog(AlertDialog(
                title: const Text('Konfirmasi'),
                content: const Text('Apakah Anda yakin ingin keluar?'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await authService.logout();
                      Get.toNamed(AppRoutes.LOGIN);
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Keluar',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF0077B6),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey))
            : null,
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive ? Colors.red : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
