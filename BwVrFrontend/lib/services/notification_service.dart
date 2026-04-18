import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'auth_service.dart';
import 'dart:html' as html;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _changeController = StreamController<String>.broadcast();
  Stream<String> get changeStream => _changeController.stream;

  html.EventSource? _eventSource;
  bool _isConnected = false;

  void init() {
    if (_isConnected) return;
    _connect();
  }

  void _connect() {
    final token = AuthService().token;
    if (token == null) return;

    // In a real production app, you might need to pass token via query param for EventSource
    // or use a polyfill that supports headers. For now, we'll use query param if needed, 
    // but standard EventSource doesn't support headers.
    final url = '${AppConfig.apiBaseUrl}/notifications/subscribe?token=$token';
    
    try {
      _eventSource = html.EventSource(url);
      
      _eventSource!.onOpen.listen((_) {
        debugPrint('[SSE] Connected');
        _isConnected = true;
      });

      _eventSource!.onError.listen((e) {
        debugPrint('[SSE] Error or Closed. Reconnecting...');
        _isConnected = false;
        _eventSource?.close();
        Future.delayed(const Duration(seconds: 5), () => _connect());
      });

      _eventSource!.onMessage.listen((event) {
        debugPrint('[SSE] Message: ${event.data}');
      });

      // Listen for custom "CHANGE" event
      _eventSource!.addEventListener('CHANGE', (event) {
        final html.MessageEvent msg = event as html.MessageEvent;
        debugPrint('[SSE] CHANGE Event: ${msg.data}');
        _changeController.add(msg.data.toString());
      });

    } catch (e) {
      debugPrint('[SSE] Exception: $e');
      Future.delayed(const Duration(seconds: 5), () => _connect());
    }
  }

  void dispose() {
    _eventSource?.close();
    _changeController.close();
  }
}
