// lib/app/utils/distance_utils.dart
import 'dart:math';

class DistanceUtils {
  /// Menghitung jarak antara dua koordinat dalam kilometer
  /// Menggunakan formula Haversine
  static double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const double earthRadius = 6371; // Radius bumi dalam kilometer

    // Konversi derajat ke radian
    double lat1Rad = _degreesToRadians(lat1);
    double lon1Rad = _degreesToRadians(lon1);
    double lat2Rad = _degreesToRadians(lat2);
    double lon2Rad = _degreesToRadians(lon2);

    // Perbedaan koordinat
    double dLat = lat2Rad - lat1Rad;
    double dLon = lon2Rad - lon1Rad;

    // Formula Haversine
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Konversi derajat ke radian
  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Format jarak ke string yang mudah dibaca
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      // Jika kurang dari 1 km, tampilkan dalam meter
      int meters = (distanceKm * 1000).round();
      return '${meters}m';
    } else if (distanceKm < 10) {
      // Jika kurang dari 10 km, tampilkan dengan 1 desimal
      return '${distanceKm.toStringAsFixed(1)} km';
    } else {
      // Jika lebih dari 10 km, tampilkan sebagai bilangan bulat
      return '${distanceKm.round()} km';
    }
  }

  /// Hitung estimasi waktu tempuh (km/jam)
  static String estimateTravelTime(double distanceKm, double speedKmh) {
    double timeHours = distanceKm / speedKmh;
    if (timeHours < 1) {
      int minutes = (timeHours * 60).round();
      return '${minutes} menit';
    } else {
      int hours = timeHours.floor();
      int minutes = ((timeHours - hours) * 60).round();
      if (minutes == 0) {
        return '${hours} jam';
      } else {
        return '${hours} jam ${minutes} menit';
      }
    }
  }
}