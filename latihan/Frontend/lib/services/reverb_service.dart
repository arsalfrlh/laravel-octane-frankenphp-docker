import 'dart:convert';

import 'package:toko/services/api_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ReverbService {
  late WebSocketChannel _channel;
  final apiService = ApiService();
  String? socketId;

  Function(Map<String, dynamic>)? onMessage;

  void connect(int chatRoomId) {
    final wsUrl =
        "ws://10.0.2.2:8080/app/7agraacpgzetf6d4zhkt?protocol=7&client=flutter&version=1.0";

    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _channel.stream.listen((event) async {
      final data = jsonDecode(event);
      print("Data Event: $event");

      if (data['event'] == "pusher:connection_established") {
        final socketData = jsonDecode(data['data']);
        socketId = socketData['socket_id'];
        await subscribe(chatRoomId);
      }

      if (data['event'] == "pusher:ping") {
        _channel.sink.add(jsonEncode({"event": "pusher:pong"}));
      }

      if (data['event'] == "chatUpdated") {
        final payload = jsonDecode(data['data']);
        onMessage?.call(payload);
        print("Event: $payload");
      }

      if (data['event'] == 'pusher_internal:subscription_succeeded') {
        print("BERHASIL SUBSCRIBE ✅");
      }
    });
  }

  Future<void> subscribe(int chatRoomId) async {
    final response = await apiService.authBroadcast(
        socketId, "private-chat-room-$chatRoomId");
    print("Data Auth: $response");
    _channel.sink.add(jsonEncode({
      "event": "pusher:subscribe",
      "data": {
        "channel": "private-chat-room-$chatRoomId",
        "auth": response['auth'],
      }
    }));
  }
}
