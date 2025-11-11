import 'dart:async';
import 'dart:io';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:example/examples/websocket/core/core.dart';

Future<PlatformWebScoket> connectSoc(
        {required String url,
        required Duration timeout,
        List<String>? protocols}) async =>
    await WebsocketIO.connect(url: url, timeout: timeout);

class WebsocketIO implements PlatformWebScoket {
  final WebSocket _socket;
  late StreamController<String>? _streamController = StreamController<String>()
    ..onCancel = _onCloseStream;
  void _onCloseStream() {
    _socket.close(1000, "closed by client.");
  }

  @override
  bool get isConnected => _socket.readyState == WebSocket.open;
  WebsocketIO._(this._socket) {
    _socket.listen(
      (dynamic data) {
        if (data is String) {
          _streamController?.add(data);
        } else if (data is List) {
          final toStr = StringUtils.decode(data.cast());
          _streamController?.add(toStr);
        }
      },
      onDone: () {
        close();
      },
      onError: (dynamic error) {
        _streamController?.addError(error);
      },
    );
  }

  @override
  void close() {
    _streamController?.close();
    _streamController = null;
  }

  @override
  Stream<String> get stream {
    final stream = _streamController?.stream;
    if (stream == null) {
      throw Exception("socket closed.");
    }
    return stream;
  }

  static Future<WebsocketIO> connect(
      {required String url,
      required Duration timeout,
      List<String>? protocols}) async {
    final socket =
        await WebSocket.connect(url, protocols: protocols).timeout(timeout);
    return WebsocketIO._(socket);
  }

  @override
  void sink(List<int> message) {
    _socket.add(message);
  }

  @override
  int? get closeCode => _socket.closeCode;

  @override
  String? get closeReason => _socket.closeReason;
}
