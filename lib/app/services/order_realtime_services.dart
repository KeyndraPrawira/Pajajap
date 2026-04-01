import 'dart:convert';

import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class OrderRealTimeService {
  PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  final Function(Map<String, dynamic>) onOrderUpdate;
  
  OrderRealTimeService({required this.onOrderUpdate});
  
  Future<void> connect() async {
    try {
      await _pusher.init(
        apiKey: 'YOUR_APP_KEY',
        cluster: 'mt1',
        // ✅ VERSI 2.2.1: onEvent nerima PusherEvent
        onEvent: (PusherEvent event) {
          print('📨 Event: ${event.eventName}');
          print('📦 Data: ${event.data}');
          
          // Cek OrderUpdated
          if (event.eventName == 'App\\Events\\OrderUpdated') {
            try {
              final Map<String, dynamic> eventData = json.decode(event.data);
              final orderData = eventData['order'] ?? eventData;
              onOrderUpdate(Map<String, dynamic>.from(orderData));
            } catch (e) {
              print('Parse error: $e');
            }
          }
        },
        onSubscriptionSucceeded: (String channelName, dynamic response) {
          print('✅ Subscribed: $channelName');
        },
        onError: (String message, int? code, dynamic e) {
          print('❌ Error: $message');
        },
      );
      
      await _pusher.subscribe(channelName: 'orders');
      await _pusher.connect();
      
    } catch (e) {
      print('💥 Init error: $e');
    }
  }
  
  Future<void> disconnect() async {
    try {
      await _pusher.unsubscribe(channelName: 'orders');
      await _pusher.disconnect();
    } catch (e) {
      print('Disconnect error: $e');
    }
  }
}