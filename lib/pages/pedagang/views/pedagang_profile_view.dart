import 'package:e_pasar/app/services/auth_services.dart';
import 'package:e_pasar/pages/pedagang/controllers/pedagang_controller.dart';
import 'package:e_pasar/pages/pedagang/views/kios_edit_view.dart';
import 'package:e_pasar/pages/pedagang/views/widgets/pedagang_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// lib/app/modules/user/views/user_profile_view.dart

class PedagangProfileView extends StatelessWidget {
  const PedagangProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final pedagangController = Get.find<PedagangController>();
    final userName = authService.getUserName() ?? 'Pedagang';
    final initials = userName.trim().isEmpty
        ? 'P'
        : userName.trim().substring(0, 1).toUpperCase();

    return Scaffold(
      backgroundColor: PedagangUi.pageBackground,
      body: Obx(() {
        final kios = pedagangController.myKios.value;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 290,
              pinned: true,
              elevation: 0,
              backgroundColor: PedagangUi.darkGreen,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: PedagangUi.heroGradient,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        top: -44,
                        right: -24,
                        child: Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -50,
                        left: -20,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white.withOpacity(0.18),
                                child: CircleAvatar(
                                  radius: 34,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      color: PedagangUi.darkGreen,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  authService.getUserEmail() ?? '-',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                kios?.namaKios ?? 'Data kios sedang dimuat',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Pedagang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: PedagangUi.textMain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: PedagangUi.heroDecoration(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.storefront_rounded,
                              label: 'Kios',
                              value: kios?.namaKios ?? 'Belum tersedia',
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.schedule_rounded,
                              label: 'Jam Operasional',
                              value:
                                  '${kios?.jamBuka ?? '-'} - ${kios?.jamTutup ?? '-'}',
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Informasi Akun',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: PedagangUi.textMain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: PedagangUi.cardDecoration(),
                      child: Column(
                        children: [
                          _buildMenuCard(
                            icon: Icons.person_outline_rounded,
                            title: 'Nama',
                            subtitle: userName,
                            onTap: () {},
                          ),
                          _buildMenuCard(
                            icon: Icons.phone_outlined,
                            title: 'Nomor Telepon',
                            subtitle: authService.getUserPhone() ?? '-',
                            onTap: () {},
                          ),
                          _buildMenuCard(
                            icon: Icons.badge_outlined,
                            title: 'Peran Akun',
                            subtitle: 'Pedagang',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Aksi Utama',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: PedagangUi.textMain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => pedagangController.changePage(1),
                            icon: const Icon(Icons.inventory_2_outlined),
                            label: const Text('Lihat Produk'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PedagangUi.darkGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Get.to(() => const KiosEditView())
                                ?.then((_) => pedagangController.refreshKios()),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit Kios'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PedagangUi.midGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: pedagangController.refreshKios,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Segarkan Data Kios'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PedagangUi.midGreen,
                          side: BorderSide(
                            color: PedagangUi.midGreen.withOpacity(0.22),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      decoration: PedagangUi.cardDecoration(),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () async {
                            final confirmed = await Get.dialog<bool>(
                              AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                title: const Text('Keluar dari akun?'),
                                content: const Text(
                                  'Anda akan keluar dari halaman pedagang dan perlu login lagi untuk masuk.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(result: false),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Get.back(result: true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: PedagangUi.danger,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Keluar'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              await pedagangController.logout();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: PedagangUi.danger.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.logout_rounded,
                                    color: PedagangUi.danger,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Keluar dari akun',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: PedagangUi.textMain,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Akhiri sesi dan kembali ke halaman login.',
                                        style: TextStyle(
                                          color: PedagangUi.textSubtle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: PedagangUi.textSubtle,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.82),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: PedagangUi.lightGreen.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: PedagangUi.darkGreen, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: PedagangUi.textSubtle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: PedagangUi.textMain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
