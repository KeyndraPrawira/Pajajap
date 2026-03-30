// lib/pages/driver/views/delivery_send_view.dart
import 'package:dio/dio.dart';
import 'package:e_pasar/app/data/models/pasar_model.dart';
import 'package:e_pasar/pages/driver/controllers/delivery_controller.dart';
import 'package:e_pasar/pages/user/controllers/pasar_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class DeliverySendView extends StatefulWidget {
  const DeliverySendView({Key? key}) : super(key: key);

  @override
  State<DeliverySendView> createState() => _DeliverySendViewState();
}

class _DeliverySendViewState extends State<DeliverySendView>
    with TickerProviderStateMixin {
  final PasarController _pasarC = Get.find<PasarController>();
  final DeliveryController _orderC = Get.find<DeliveryController>();
  late final MapController _mapController;
  final Dio _dio = Dio();
  late Worker _pasarWorker;
  bool _workerInitialized = false;

  List<LatLng> _routePoints = [];

  // Drag state
  double _sheetHeight = 0;
  double _minSheetHeight = 0;
  double _maxSheetHeight = 0;
  double _dragStartY = 0;
  double _dragStartHeight = 0;
  late AnimationController _snapAnimController;
  late Animation<double> _snapAnim;

  // PiP threshold
  static const double _pipThreshold = 0.65;

  DataPasar? get _pasar =>
      _pasarC.pasarList.isNotEmpty ? _pasarC.pasarList.first : null;

  LatLng get _buyerLocation {
    final lat = _orderC.orderData.value?.latitude;
    final lng = _orderC.orderData.value?.longitude;
    if (lat != null && lng != null) return LatLng(lat, lng);
    return const LatLng(-6.2088, 106.8456);
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _snapAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    if (_pasarC.pasarList.isNotEmpty) {
      _getRoute();
    } else {
      _workerInitialized = true;
      _pasarWorker = ever(_pasarC.pasarList, (_) {
        if (mounted) {
          setState(() {});
          _getRoute();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenH = MediaQuery.of(context).size.height;
    if (_sheetHeight == 0) {
      _minSheetHeight = screenH * 0.28;
      _maxSheetHeight = screenH * 0.88;
      _sheetHeight = screenH * 0.38;
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _snapAnimController.dispose();
    if (_workerInitialized) _pasarWorker.dispose();
    super.dispose();
  }

  Future<void> _getRoute() async {
    if (_pasar == null) return;
    if (_pasar!.latitude == null || _pasar!.longitude == null) return;
    try {
      final response = await _dio.get(
        'https://router.project-osrm.org/route/v1/driving/'
        '${_buyerLocation.longitude},${_buyerLocation.latitude};'
        '${_pasar!.longitude!},${_pasar!.latitude!}',
        queryParameters: {'overview': 'full', 'geometries': 'geojson'},
      );
      if (response.statusCode == 200) {
        final coords =
            response.data['routes'][0]['geometry']['coordinates'] as List;
        if (mounted) {
          setState(() {
            _routePoints = coords
                .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Gagal ambil rute: $e');
    }
  }

  void _onDragStart(DragStartDetails d) {
    _dragStartY = d.globalPosition.dy;
    _dragStartHeight = _sheetHeight;
    _snapAnimController.stop();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final delta = _dragStartY - d.globalPosition.dy;
    setState(() {
      _sheetHeight =
          (_dragStartHeight + delta).clamp(_minSheetHeight, _maxSheetHeight);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    final screenH = MediaQuery.of(context).size.height;
    final ratio = _sheetHeight / screenH;
    final velocity = d.primaryVelocity ?? 0;

    double target;
    if (velocity < -600) {
      target = _maxSheetHeight;
    } else if (velocity > 600) {
      target = _minSheetHeight;
    } else if (ratio > 0.6) {
      target = _maxSheetHeight;
    } else if (ratio > 0.28) {
      target = screenH * 0.38;
    } else {
      target = _minSheetHeight;
    }

    _snapAnim = Tween<double>(begin: _sheetHeight, end: target).animate(
      CurvedAnimation(parent: _snapAnimController, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() => _sheetHeight = _snapAnim.value);
      });

    _snapAnimController
      ..reset()
      ..forward();
  }

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  // ── Dialog konfirmasi sebelum eksekusi ──
  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Color(0xFF0077B6)),
            SizedBox(width: 8),
            Text(
              'Konfirmasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Apakah pesanan ini sudah sampai ke pembeli?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Tidak',
              style: TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _orderC.completeDelivery();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0077B6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Lanjut',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap({BorderRadius? borderRadius}) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _buyerLocation,
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.e_pasar',
          ),
          if (_routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _routePoints,
                  strokeWidth: 4,
                  color: const Color(0xFF0077B6),
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              Marker(
                width: 110,
                height: 55,
                point: _buyerLocation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Tujuan',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                    const Icon(Icons.location_pin,
                        color: Colors.red, size: 26),
                  ],
                ),
              ),
              if (_pasar != null)
                Marker(
                  width: 110,
                  height: 55,
                  point: LatLng(_pasar!.latitude!, _pasar!.longitude!),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0077B6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _pasar!.namaPasar ?? 'Pasar',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.storefront,
                          color: Color(0xFF0077B6), size: 26),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final sheetRatio = _sheetHeight / screenH;
    final isPip = sheetRatio > _pipThreshold;
    final pipProgress =
        ((sheetRatio - _pipThreshold) / (1 - _pipThreshold)).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengiriman',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0077B6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        final order = _orderC.orderData.value;

        if (order == null) {
          if (!_orderC.isLoading.value) {
            final orderId = Get.arguments as int?;
            if (orderId != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _orderC.loadOrder(orderId);
              });
            }
          }
          return const Center(child: CircularProgressIndicator());
        }

        final details = order.orderDetails ?? [];
        final ongkir = order.ongkir ?? 0;
        final totalHargaBarang = order.totalHargaBarang ?? 0;
        final totalHarga = order.totalHarga ?? 0;

        return Stack(
          children: [
            // ── MAP BACKGROUND ──
            AnimatedOpacity(
              opacity: isPip ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Positioned.fill(child: _buildMap()),
            ),

            // ── MAP PiP ──
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              top: isPip ? 16 : -130,
              right: 16,
              child: AnimatedOpacity(
                opacity: isPip ? pipProgress : 0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  width: 150,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildMap(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),

            // ── DRAGGABLE SHEET ──
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: _sheetHeight,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black26,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                // SafeArea supaya tombol tidak ketutup navigation bar
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      // Handle drag
                      GestureDetector(
                        onVerticalDragStart: _onDragStart,
                        onVerticalDragUpdate: _onDragUpdate,
                        onVerticalDragEnd: _onDragEnd,
                        child: Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          color: Colors.transparent,
                          child: Center(
                            child: Container(
                              width: 44,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── BIAYA ──
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _BiayaCard(
                                    label: 'Ongkir',
                                    value: _formatRupiah(ongkir),
                                    color: const Color(0xFF0077B6),
                                    icon: Icons.delivery_dining,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _BiayaCard(
                                    label: 'Total Harga Barang yang dibeli',
                                    value: _formatRupiah(totalHargaBarang),
                                    color: Colors.green.shade600,
                                    icon: Icons.shopping_bag_outlined,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0077B6),
                                    Color(0xFF00B4D8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Tagihan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _formatRupiah(totalHarga),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Label daftar produk
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              'Daftar Produk',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0077B6)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${details.length} item',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF0077B6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // List produk — Expanded supaya tombol tidak overflow
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16),
                          itemCount: details.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final detail = details[index];
                            final produk = detail.produk;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    child: produk?.foto != null &&
                                            produk!.foto!.isNotEmpty
                                        ? Image.network(
                                            produk.foto!,
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _PlaceholderImg(),
                                          )
                                        : _PlaceholderImg(),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          produk?.namaProduk ??
                                              'Produk ${index + 1}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatRupiah(produk?.harga ??
                                              detail.hargaSatuan ??
                                              0),
                                          style: TextStyle(
                                            color: Colors.green.shade600,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0077B6)
                                          .withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'x${detail.jumlah ?? 0}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0077B6),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Tombol selesai — fixed di bawah, tidak overflow
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _showConfirmDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0077B6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              'Selesai Antar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
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
}

class _BiayaCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _BiayaCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey[500])),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderImg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, color: Colors.grey, size: 28),
    );
  }
}