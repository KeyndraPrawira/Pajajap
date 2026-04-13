import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class OrderRealTimeService {
  final Function(Map<String, dynamic>) onOrderUpdate;
  final String path;

  DatabaseReference? _ref;
  StreamSubscription<DatabaseEvent>? _addedSub;
  StreamSubscription<DatabaseEvent>? _changedSub;
  StreamSubscription<DatabaseEvent>? _removedSub;

  OrderRealTimeService({
    required this.onOrderUpdate,
    this.path = 'orders',
  });

  Future<void> connect() async {
    try {
      _ref = FirebaseDatabase.instance.ref(path);

      _addedSub = _ref!.onChildAdded.listen(_handleSnapshot);
      _changedSub = _ref!.onChildChanged.listen(_handleSnapshot);
      // Di dalam fungsi connect()
     
      _removedSub = _ref!.onChildRemoved.listen((event) {
        final key = event.snapshot.key;
        onOrderUpdate({
          'id': int.tryParse(key ?? '') ?? key,
          '_deleted': true,
        });
      });

      print('✅ Firebase connected on path: $path');
    } catch (e) {
      print('💥 Firebase init error: $e');
    }
  }

  void _handleSnapshot(DatabaseEvent event) {
    try {
      final raw = event.snapshot.value;
      if (raw == null || raw is! Map) return;

      final data = _normalizeMap(raw);
      data['id'] ??=
          int.tryParse(event.snapshot.key ?? '') ?? event.snapshot.key;

      print('📨 Firebase update [$path/${event.snapshot.key}]');
      print('📦 Data: $data');

      onOrderUpdate(data);
    } catch (e) {
      print('Parse Firebase error: $e');
    }
  }

  Map<String, dynamic> _normalizeMap(Map raw) {
    return raw.map((key, value) {
      return MapEntry(key.toString(), _normalizeValue(value));
    });
  }

  dynamic _normalizeValue(dynamic value) {
    if (value is Map) return _normalizeMap(value);
    if (value is List) return value.map(_normalizeValue).toList();
    return value;
  }

  Future<void> disconnect() async {
    try {
      await _addedSub?.cancel();
      await _changedSub?.cancel();
      await _removedSub?.cancel();
      _addedSub = null;
      _changedSub = null;
      _removedSub = null;
      _ref = null;
    } catch (e) {
      print('Disconnect error: $e');
    }
  }
}
