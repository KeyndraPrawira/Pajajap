// lib/app/utils/api.dart
class Api {
  static const devUrl =
      'https://perseveringly-coxal-chandler.ngrok-free.dev/api';
  static const baseUrl = 'https://pajajap.web.id/api';
  static const baseImageUrl = 'https://pajajap.web.id/storage/';
  static Map<String, String> get headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };

  static Map<String, String> headersWithAuth(String token) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true'
      };
}
