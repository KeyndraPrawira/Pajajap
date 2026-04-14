// lib/pages/user/views/app_info_view.dart
import 'package:flutter/material.dart';

class AppInfoView extends StatelessWidget {
  const AppInfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        title: const Text('Info Aplikasi'),
        backgroundColor: const Color(0xFF0077B6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header / Hero
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF0077B6),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      size: 52,
                      color: Color(0xFF0077B6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pajajap',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pasar Digital Jember',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Versi 1.0.0',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tentang Aplikasi
            _SectionCard(
              icon: Icons.info_outline_rounded,
              title: 'Tentang Aplikasi',
              child: const Text(
                'Pajajap adalah aplikasi pasar digital yang menghubungkan pembeli dengan pedagang di pasar tradisional Jember. '
                'Temukan produk segar, cek harga, dan pesan langsung dari pasar terdekat dengan mudah.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Fitur Utama
            _SectionCard(
              icon: Icons.star_outline_rounded,
              title: 'Fitur Utama',
              child: Column(
                children: const [
                  _FeatureItem(
                    icon: Icons.location_on_rounded,
                    color: Color(0xFF0077B6),
                    title: 'Pasar Terdekat',
                    subtitle: 'Temukan pasar berdasarkan lokasi kamu',
                  ),
                  _FeatureItem(
                    icon: Icons.shopping_basket_rounded,
                    color: Colors.orange,
                    title: 'Belanja Produk',
                    subtitle: 'Browse & pesan produk dari pedagang pasar',
                  ),
                  _FeatureItem(
                    icon: Icons.local_shipping_rounded,
                    color: Colors.green,
                    title: 'Info Ongkir',
                    subtitle: 'Cek ongkos kirim dari setiap pasar',
                  ),
                  _FeatureItem(
                    icon: Icons.access_time_rounded,
                    color: Colors.purple,
                    title: 'Estimasi Waktu',
                    subtitle: 'Perkiraan waktu tempuh ke pasar tujuan',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Informasi Teknis
            _SectionCard(
              icon: Icons.build_outlined,
              title: 'Informasi Teknis',
              child: Column(
                children: const [
                  _InfoRow(label: 'Platform', value: 'Android & iOS'),
                  _InfoRow(label: 'Versi Aplikasi', value: '1.0.0'),
                  _InfoRow(label: 'Framework', value: 'Flutter'),
                  _InfoRow(label: 'Backend', value: 'Laravel REST API'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Kontak & Dukungan
            _SectionCard(
              icon: Icons.support_agent_rounded,
              title: 'Kontak & Dukungan',
              child: Column(
                children: const [
                  _InfoRow(label: 'Email', value: 'support@pajajap.id'),
                  _InfoRow(label: 'Wilayah', value: 'Jember, Jawa Timur'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Text(
                '© 2025 Pajajap. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF0077B6), size: 22),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF023E58),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF023E58),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF023E58),
            ),
          ),
        ],
      ),
    );
  }
}