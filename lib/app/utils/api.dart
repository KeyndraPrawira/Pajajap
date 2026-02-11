// lib/app/utils/api.dart
class Api {
  static const String baseUrl = 'http://localhost:8000/api';
  
  static Map<String, String> get headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static Map<String, String> headersWithAuth(String token) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}