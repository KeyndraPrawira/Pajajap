// lib/app/modules/user/views/user_profile_view.dart
import 'package:e_pasar/app/routes/app_pages.dart';
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileView extends StatelessWidget {
  const UserProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0D47A1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: const Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  authService.getUserName() ?? 'User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  authService.getUserEmail() ?? 'email@example.com',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Menu Items
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              // TODO: Navigate to edit profile
            },
          ),
          
          _buildMenuItem(
            icon: Icons.shopping_bag_outlined,
            title: 'Pesanan Saya',
            onTap: () {
              // TODO: Navigate to orders
            },
          ),
          
          _buildMenuItem(
            icon: Icons.favorite_outline,
            title: 'Wishlist',
            onTap: () {
              // TODO: Navigate to wishlist
            },
          ),
          
          _buildMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Alamat',
            onTap: () {
              // TODO: Navigate to addresses
            },
          ),
          
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Pengaturan',
            onTap: () {
              // TODO: Navigate to settings
            },
          ),
          
          const SizedBox(height: 16),
          
          // Logout Button
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            isDestructive: true,
            onTap: () async {
              Get.dialog(
                AlertDialog(
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
                        Get.offAllNamed(AppRoutes.LOGIN);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF0D47A1),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive ? Colors.red : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}