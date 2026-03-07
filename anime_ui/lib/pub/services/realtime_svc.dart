import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:anime_ui/pub/utils/url.dart' show kServerOrigin;

enum WSConnectionState { disconnected, connecting, connected, reconnecting }

class RealtimeWSService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  String? _token;
  final _eventController = StreamController<Map<String, dynamic>>.broadcast();
  final _statusController = StreamController<WSConnectionState>.broadcast();
  final _reconnectedController = StreamController<void>.broadcast();
  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;
  bool _manualClose = false;
  int _lastEventVersion = 0;

  /// 最新收到的事件 ID（来自 project_events 表的 BIGSERIAL id）
  int _lastEventId = 0;

  WSConnectionState _state = WSConnectionState.disconnected;

  bool get isConnected => _channel != null;
  Stream<Map<String, dynamic>> get events => _eventController.stream;
  Stream<WSConnectionState> get status => _statusController.stream;
  WSConnectionState get connectionState => _state;

  /// 重连成功后触发，供 Provider 调用补拉逻辑
  Stream<void> get onReconnected => _reconnectedController.stream;

  /// 获取最后收到的事件 ID（供补拉时使用）
  int get lastEventId => _lastEventId;

  void setToken(String? token) {
    final normalized = token?.trim();
    if (_token == normalized &&
        (_channel != null || _state == WSConnectionState.connecting)) {
      return;
    }
    _token = normalized;

    if (_token == null || _token!.isEmpty) {
      disconnect(manual: true);
      return;
    }
    connect();
  }

  void connect() {
    final token = _token;
    if (token == null || token.isEmpty) return;
    _manualClose = false;
    _connectNow();
  }

  void _connectNow() {
    final token = _token;
    if (token == null || token.isEmpty) return;

    _teardown();
    _setState(
      _reconnectAttempt == 0
          ? WSConnectionState.connecting
          : WSConnectionState.reconnecting,
    );
    final uri = _buildWsUri(token);
    debugPrint('WS connect: $uri');

    final wasReconnecting = _state == WSConnectionState.reconnecting;

    _channel = WebSocketChannel.connect(uri);
    _subscription = _channel!.stream.listen(
      (message) {
        try {
          final data = jsonDecode(message as String);
          final type = (data is Map<String, dynamic>) ? data['type'] : null;
          final version = (data is Map<String, dynamic>)
              ? data['version']
              : null;
          if (version is num) {
            final ver = version.toInt();
            if (ver <= _lastEventVersion) {
              return;
            }
            _lastEventVersion = ver;
          }

          // 追踪持久化事件 ID（来自 project_events 表）
          if (data is Map<String, dynamic>) {
            final eventId = data['eventId'] as int? ?? data['id'] as int?;
            if (eventId != null && eventId > _lastEventId) {
              _lastEventId = eventId;
            }
          }

          if (_state != WSConnectionState.connected) {
            _reconnectAttempt = 0;
            _setState(WSConnectionState.connected);
            if (wasReconnecting) {
              _reconnectedController.add(null);
            }
          }
          debugPrint('WS event: $type');
          if (data is Map<String, dynamic>) {
            _eventController.add(data);
          }
        } catch (e) {
          debugPrint('WS 消息解析失败: $e (raw: $message)');
        }
      },
      onDone: () {
        debugPrint('WS disconnected');
        _scheduleReconnect();
      },
      onError: (Object err, StackTrace st) {
        debugPrint('WS error: $err');
        _scheduleReconnect();
      },
      cancelOnError: true,
    );
  }

  void disconnect({bool manual = true}) {
    _manualClose = manual;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempt = 0;
    _teardown();
    _setState(WSConnectionState.disconnected);
  }

  void _teardown() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  void _scheduleReconnect() {
    _teardown();
    if (_manualClose || _token == null || _token!.isEmpty) {
      _setState(WSConnectionState.disconnected);
      return;
    }

    const backoffSeconds = [1, 2, 5, 10, 20, 30];
    final idx = _reconnectAttempt < backoffSeconds.length
        ? _reconnectAttempt
        : backoffSeconds.length - 1;
    final wait = Duration(seconds: backoffSeconds[idx]);
    _reconnectAttempt += 1;
    _setState(WSConnectionState.reconnecting);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(wait, _connectNow);
  }

  void _setState(WSConnectionState next) {
    if (_state == next) return;
    _state = next;
    _statusController.add(next);
  }

  Uri _buildWsUri(String token) {
    final wsOrigin = kServerOrigin.startsWith('https://')
        ? kServerOrigin.replaceFirst('https://', 'wss://')
        : kServerOrigin.replaceFirst('http://', 'ws://');
    return Uri.parse(
      '$wsOrigin/api/v1/ws',
    ).replace(queryParameters: {'token': token});
  }
}

final realtimeWS = RealtimeWSService();
