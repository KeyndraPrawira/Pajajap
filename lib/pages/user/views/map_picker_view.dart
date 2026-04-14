// lib/pages/user/views/map_picker_view.dart
import 'package:dio/dio.dart';
import 'package:e_pasar/app/data/models/pasar_model.dart';
import 'package:e_pasar/pages/user/controllers/pasar_controller.dart';
import 'package:e_pasar/pages/user/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MapPickerView extends StatefulWidget {
  const MapPickerView({Key? key}) : super(key: key);

  @override
  State<MapPickerView> createState() => _MapPickerViewState();
}

class _MapPickerViewState extends State<MapPickerView> {
  final PasarController _pasarC = Get.find<PasarController>();
  final ProfileController _profileC = Get.find<ProfileController>();
  late final MapController _mapController;
  final Dio _dio = Dio();
  late Worker _pasarWorker;
  bool _hasPasarWorker = false;

  LatLng _selectedLocation = const LatLng(-6.2088, 106.8456);
  String _selectedAddress = 'Geser peta untuk memilih lokasi';
  bool _isLoadingAddress = false;
  double _jarakKm = 0.0;
  int _totalOngkir = 0;
  List<LatLng> _routePoints = [];

  DataPasar? get _pasar =>
      _pasarC.pasarList.isNotEmpty ? _pasarC.pasarList.first : null;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initLocationFromProfile();

    if (_pasarC.pasarList.isNotEmpty) {
      _refreshPasarState();
      _getRoute(); // ✅
    } else {
      _hasPasarWorker = true;
      _pasarWorker = ever(_pasarC.pasarList, (_) {
        if (!mounted) {
          return;
        } else {
          setState(() {});
          _refreshPasarState();
          _getRoute(); // ✅
        }
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    if (_hasPasarWorker) _pasarWorker.dispose();
    super.dispose();
  }

  void _initLocationFromProfile() {
    final alamat = _profileC.dataProfile.value?.alamat;
    if ((alamat?.alamatLengkap ?? '').isNotEmpty) {
      _selectedAddress = alamat!.alamatLengkap!;
    }
    if (alamat?.latitude != null && alamat?.longitude != null) {
      _selectedLocation = LatLng(alamat!.latitude!, alamat.longitude!);
      _getAddressFromLatLng(_selectedLocation);
    }
    _refreshPasarState();
  }

  void _refreshPasarState() {
    _hitungOngkir();
    _getRoute();
  }

  void _hitungOngkir() {
    if (_pasar == null) return;
    if (_pasar!.latitude == null || _pasar!.longitude == null) return;

    final distance = Distance();
    final double meter = distance.as(
      LengthUnit.Meter,
      _selectedLocation,
      LatLng(_pasar!.latitude!, _pasar!.longitude!),
    );

    final double km = meter / 1000;
    final int minimal = _pasar!.minimalOngkir ?? 0;
    final int perKm = _pasar!.ongkir ?? 0;

    setState(() {
      _jarakKm = double.parse(km.toStringAsFixed(1));
      if (km <= 1) {
        _totalOngkir = minimal;
      } else {
        final double sisaKm = km - 1;
        _totalOngkir = minimal + (sisaKm * perKm).ceil();
      }
    });
  }

  // ✅ Ambil rute dari OSRM
  Future<void> _getRoute() async {
    if (_pasar == null) return;
    if (_pasar!.latitude == null || _pasar!.longitude == null) {
      if (mounted && _routePoints.isNotEmpty) {
        setState(() => _routePoints = []);
      }
      return;
    }

    try {
      final response = await _dio.get(
        'https://router.project-osrm.org/route/v1/driving/'
        '${_selectedLocation.longitude},${_selectedLocation.latitude};'
        '${_pasar!.longitude!},${_pasar!.latitude!}',
        queryParameters: {'overview': 'full', 'geometries': 'geojson'},
      );

      if (response.statusCode == 200) {
        final coords =
            response.data['routes'][0]['geometry']['coordinates'] as List;
        if (!mounted) return;
        setState(() {
          _routePoints = coords
              .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Gagal ambil rute: $e');
    }
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    if (!mounted) return;
    setState(() => _isLoadingAddress = true);
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': latLng.latitude,
          'lon': latLng.longitude,
          'format': 'json',
        },
        options: Options(headers: {'User-Agent': 'ePasar/1.0'}),
      );
      if (!mounted) return;
      setState(() => _selectedAddress =
          response.data['display_name'] ?? 'Alamat tidak ditemukan');
    } catch (e) {
      if (!mounted) return;
      setState(() => _selectedAddress = 'Gagal mendapatkan alamat');
    } finally {
      if (mounted) {
        setState(() => _isLoadingAddress = false);
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Error', 'Izin lokasi ditolak');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Error', 'Aktifkan izin lokasi di pengaturan');
      return;
    }
    final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final latLng = LatLng(pos.latitude, pos.longitude);
    _mapController.move(latLng, 16.0);
    setState(() => _selectedLocation = latLng);
    await _getAddressFromLatLng(latLng);
    _hitungOngkir();
    _getRoute(); // ✅
  }

  void _gunakanLokasi() {
    Get.back(result: {
      'alamat': _selectedAddress,
      'alamat_lengkap': _selectedAddress,
      'latitude': _selectedLocation.latitude,
      'longitude': _selectedLocation.longitude,
      'jarakKm': _jarakKm,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
        backgroundColor: const Color(0xFF0077B6),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 15.0,
              onMapEvent: (event) {
                if (event is MapEventMove) {
                  setState(() => _selectedLocation = event.camera.center);
                }
                if (event is MapEventMoveEnd) {
                  _getAddressFromLatLng(event.camera.center);
                  _refreshPasarState();
                  _getRoute(); // ✅
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.e_pasar',
              ),

              // ✅ Garis rute
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

              // Marker pasar
              if (_pasar?.latitude != null && _pasar?.longitude != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 120,
                      height: 60,
                      point: LatLng(_pasar!.latitude!, _pasar!.longitude!),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0077B6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _pasar!.namaPasar ?? 'Pasar',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.storefront,
                              color: Color(0xFF0077B6), size: 28),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Pin merah tengah
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_pin, size: 48, color: Colors.red),
                SizedBox(height: 44),
              ],
            ),
          ),

          // Tombol GPS
          Positioned(
            bottom: 230,
            right: 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: const Color(0xFF0077B6),
              child: const Icon(Icons.my_location),
            ),
          ),

          // Panel bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  _isLoadingAddress
                      ? const CircularProgressIndicator()
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_selectedAddress,
                                  style: const TextStyle(fontSize: 13),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.straighten,
                            size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${_jarakKm.toStringAsFixed(1)} km dari pasar',
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                      ]),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0077B6), Color(0xFF06D6A0)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoadingAddress ? null : _gunakanLokasi,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Gunakan Lokasi Ini',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
