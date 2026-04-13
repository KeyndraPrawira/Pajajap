import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

class PaymentRealtimeService {
  PaymentRealtimeService({
    required this.orderId,
    required this.onOrderUpdate,
  });

  final int orderId;
  final void Function(Map<String, dynamic>) onOrderUpdate;

  DatabaseReference? _ref;
  StreamSubscription<DatabaseEvent>? _valueSub;

  Future<void> connect() async {
    try {
      _ref = FirebaseDatabase.instance.ref('orders/$orderId');
      _valueSub = _ref!.onValue.listen(_handleSnapshot);
      print('[PAYMENT][FIREBASE] connected orders/$orderId');
    } catch (e) {
      print('[PAYMENT][FIREBASE] connect error: $e');
    }
  }

  void _handleSnapshot(DatabaseEvent event) {
    try {
      final raw = event.snapshot.value;
      if (raw == null || raw is! Map) {
        return;
      }

      final data = _normalizeMap(raw);
      data['id'] ??= orderId;
      onOrderUpdate(data);
    } catch (e) {
      print('[PAYMENT][FIREBASE] parse error: $e');
    }
  }

  Map<String, dynamic> _normalizeMap(Map raw) {
    return raw.map((key, value) {
      return MapEntry(key.toString(), _normalizeValue(value));
    });
  }

  dynamic _normalizeValue(dynamic value) {
    if (value is Map) {
      return _normalizeMap(value);
    }
    if (value is List) {
      return value.map(_normalizeValue).toList();
    }
    return value;
  }

  Future<void> disconnect() async {
    try {
      await _valueSub?.cancel();
      _valueSub = null;
      _ref = null;
    } catch (e) {
      print('[PAYMENT][FIREBASE] disconnect error: $e');
    }
  }
}
