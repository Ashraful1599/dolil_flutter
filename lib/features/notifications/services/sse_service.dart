import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/notification_model.dart';

class SseService {
  StreamController<NotificationModel>? _controller;
  StreamSubscription? _sub;
  int _retryMs = 2000;
  bool _active = false;

  Stream<NotificationModel> connect(String token) {
    _controller = StreamController<NotificationModel>.broadcast();
    _active = true;
    _startListening(token);
    return _controller!.stream;
  }

  void _startListening(String token) async {
    if (!_active) return;
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.apiBaseUrl.endsWith('/') ? '' : ''}/notifications/stream?token=${Uri.encodeComponent(token)}');
      final request = http.Request('GET', url);
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';

      final client = http.Client();
      final response = await client.send(request);

      StringBuffer buf = StringBuffer();
      _sub = response.stream.transform(utf8.decoder).listen(
        (chunk) {
          buf.write(chunk);
          final text = buf.toString();
          final events = text.split('\n\n');
          for (int i = 0; i < events.length - 1; i++) {
            _processEvent(events[i]);
          }
          buf.clear();
          buf.write(events.last);
        },
        onDone: () => _reconnect(token),
        onError: (_) => _reconnect(token),
        cancelOnError: true,
      );
      _retryMs = 2000; // Reset backoff
    } catch (_) {
      _reconnect(token);
    }
  }

  void _processEvent(String eventText) {
    for (final line in eventText.split('\n')) {
      if (line.startsWith('data: ')) {
        final jsonStr = line.substring(6).trim();
        if (jsonStr.isEmpty || jsonStr == 'ping') continue;
        try {
          final json = jsonDecode(jsonStr);
          final notification = NotificationModel.fromJson(json);
          _controller?.add(notification);
        } catch (_) {}
      }
    }
  }

  void _reconnect(String token) async {
    if (!_active) return;
    await Future.delayed(Duration(milliseconds: _retryMs));
    _retryMs = (_retryMs * 2).clamp(2000, 30000);
    _startListening(token);
  }

  void dispose() {
    _active = false;
    _sub?.cancel();
    _controller?.close();
  }
}
