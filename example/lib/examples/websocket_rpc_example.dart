import 'dart:async';

import 'package:blockchain_utils/service/models/params.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:example/examples/websocket/core/core.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

enum SocketStatus { connect, disconnect, pending, event }

class SocketRequestCompleter {
  SocketRequestCompleter(this.params, this.id);
  final Completer completer = Completer();
  final List<int> params;
  final int id;
}

class WebsocketSubscriptionEvent {
  final String method;
  final Map<String, dynamic> result;
  final String subscription;
  const WebsocketSubscriptionEvent(
      {required this.method, required this.result, required this.subscription});
  factory WebsocketSubscriptionEvent.fromJson(Map<String, dynamic> json) {
    return WebsocketSubscriptionEvent(
        method: json["method"],
        result: json["params"]["result"],
        subscription: json["params"]["subscription"]);
  }
}

class WebSocketServiceEvent {
  final SocketStatus status;
  final WebsocketSubscriptionEvent? event;
  const WebSocketServiceEvent({required this.status, this.event});
}

class WebSocketService {
  WebSocketService({required this.url});

  final StreamController<WebSocketServiceEvent> _controller =
      StreamController<WebSocketServiceEvent>.broadcast();
  Stream<WebSocketServiceEvent> get stream => _controller.stream;
  final String url;

  PlatformWebScoket? _socket;
  SocketStatus _status = SocketStatus.disconnect;
  StreamSubscription<String>? _subscription;
  bool get isConnected => _status == SocketStatus.connect;

  final Map<int, SocketRequestCompleter> _requests = {};
  void _add(List<int> message) {
    _socket?.sink(message);
  }

  void _onClose({SocketStatus status = SocketStatus.disconnect}) {
    _status = status;
    _subscription?.cancel().catchError((e) {});
    _socket?.close();
    _subscription = null;
    _socket = null;
    _controller.add(WebSocketServiceEvent(status: status));
  }

  void disposeService() => _onClose();

  Map<String, dynamic>? onMessge(String event) {
    final Map<String, dynamic> decode = StringUtils.toJson(event);
    // print("decode $decode");
    if (decode.containsKey("id")) {
      final int id = int.parse(decode["id"]!.toString());
      final request = _requests.remove(id);
      request?.completer.complete(decode);
      if (request != null) {
        return null;
      }
    } else if (decode.containsKey("method") && decode.containsKey("params")) {
      final event = WebsocketSubscriptionEvent.fromJson(decode);
      _controller
          .add(WebSocketServiceEvent(status: SocketStatus.event, event: event));
    }
    return decode;
  }

  Future<void> connect(Duration timeout) async {
    if (_status != SocketStatus.disconnect) return;
    _status = SocketStatus.pending;
    _controller.add(WebSocketServiceEvent(status: _status));
    try {
      final result = await () async {
        try {
          final socket =
              await PlatformWebScoket.connect(url: url, timeout: timeout);
          return socket;
        } catch (e) {
          return null;
        }
      }();
      if (result != null) {
        _status = SocketStatus.connect;
        _socket = result;
        _subscription =
            _socket?.stream.cast<String>().listen(onMessge, onDone: _onClose);
      } else {
        _status = SocketStatus.disconnect;
        throw Exception("connect to server failed");
      }
    } finally {
      _controller.add(WebSocketServiceEvent(status: _status));
    }
  }

  Future<Map<String, dynamic>> addMessage(
      SocketRequestCompleter message, Duration timeout) async {
    try {
      await connect(timeout);
      _requests[message.id] = message;
      _add(message.params);
      final result = await message.completer.future.timeout(timeout);
      return result;
    } finally {
      _requests.remove(message.id);
    }
  }
}

class SubstrateWebsocketService extends WebSocketService
    with SubstrateServiceProvider {
  SubstrateWebsocketService(
      {required super.url, this.defaultTimeOut = const Duration(seconds: 30)});

  final Duration defaultTimeOut;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(SubstrateRequestDetails params,
      {Duration? timeout}) async {
    final SocketRequestCompleter message =
        SocketRequestCompleter(params.body()!, params.requestID);
    final r = await addMessage(message, timeout ?? defaultTimeOut);
    return params.toResponse(r);
  }
}
