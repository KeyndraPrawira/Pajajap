// lib/pages/user/views/map_picker_view.dart
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
  LatLng? _selectedLocation;
  final MapController _mapController = MapController();

  // Default location (Jakarta)
  final LatLng _defaultLocation = const LatLng(-6.2088, 106.8456);

  @override
  void initState() {
    super.initState();
    _selectedLocation = _defaultLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
        backgroundColor: const Color(0xFF0077B6),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _confirmLocation,
            child: const Text(
              'Pilih',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _defaultLocation,
              zoom: 13.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.e_pasar',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Current Location Button
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: const Color(0xFF0077B6),
              child: const Icon(Icons.my_location),
            ),
          ),

          // Info Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Koordinat Terpilih:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0077B6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedLocation != null
                        ? 'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}\nLng: ${_selectedLocation!.longitude.toStringAsFixed(6)}'
                        : 'Belum dipilih',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ketuk pada peta untuk memilih lokasi',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
  }

  void _getCurrentLocation() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Error', 'Izin lokasi ditolak');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Error', 'Izin lokasi ditolak permanen. Silakan aktifkan di pengaturan');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final currentLatLng = LatLng(position.latitude, position.longitude);

      _mapController.move(currentLatLng, 15.0);
      setState(() {
        _selectedLocation = currentLatLng;
      });

      Get.snackbar('Berhasil', 'Lokasi saat ini berhasil didapatkan');
    } catch (e) {
      Get.snackbar('Error', 'Gagal mendapatkan lokasi: ${e.toString()}');
    }
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      Get.back(result: _selectedLocation);
    } else {
      Get.snackbar('Error', 'Silakan pilih lokasi terlebih dahulu');
    }
  }
}