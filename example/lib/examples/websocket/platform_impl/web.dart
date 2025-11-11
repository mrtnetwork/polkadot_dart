import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:example/examples/websocket/core/core.dart';

@JS("CustomEvent")
extension type CustomEvent._(JSObject _) implements WebEvent {
  external factory CustomEvent(String? type, EventInit? options);
  factory CustomEvent.create({
    required String? type,
    JSAny? detail,
    JSAny? data,
    bool bubbles = true,
    bool cancelable = false,
  }) {
    return CustomEvent(
      type,
      EventInit(
          bubbles: bubbles, cancelable: cancelable, detail: detail, data: data),
    );
  }
}
@JS("Event")
extension type WebEvent<TARGET extends JSAny?>._(JSObject _)
    implements EventInit<TARGET> {
  external factory WebEvent(String? type, EventInit<TARGET>? options);
  external String? get type;
}
@JS()
extension type EventInit<TARGET extends JSAny?>._(JSObject _)
    implements JSObject {
  external bool? get bubbles;
  external bool? get cancelable;
  external bool? get composed;
  external JSAny? get detail;
  external TARGET get target;
  external set bubbles(bool? bubbles);
  external set cancelable(bool? cancelable);
  external set composed(bool? composed);
  external set detail(JSAny? detail);
  external set data(JSAny? data);
  external factory EventInit(
      {bool? bubbles,
      bool? cancelable,
      bool? composed,
      JSAny? detail,
      JSAny? data});

  List<int>? detailBytes() {
    try {
      return List<int>.from(detail.dartify() as List);
    } catch (e) {
      return null;
    }
  }
}
@JS("Event")
extension type MessageEvent<T extends JSAny?>._(JSObject _)
    implements WebEvent {
  external factory MessageEvent();
  external T get data;
}
extension type WebEventStream._(JSObject _) {
  @JS("addEventListener")
  external void addEventListener(String type, JSFunction callback);
  @JS("removeEventListener")
  external void removeEventListener(String type, JSFunction callback);

  external void dispatchEvent(WebEvent event);

  Stream<T> stream<T>(String type) {
    final StreamController<T> controller = StreamController();
    final callback = (MessageEvent<JSAny?> event) {
      controller.add(event.data.dartify() as T);
    }.toJS;
    controller.onCancel = () {
      removeEventListener(type, callback);
    };
    addEventListener(type, callback);

    return controller.stream;
  }

  Stream<T> streamOnCustomEvent<T extends JSAny>(String type) {
    final StreamController<T> controller = StreamController();
    final callback = (CustomEvent event) {
      controller.add(event.detail as T);
    }.toJS;
    controller.onCancel = () {
      removeEventListener(type, callback);
    };
    addEventListener(type, callback);

    return controller.stream;
  }

  Stream<T> streamObject<T extends JSAny>(String type) {
    final StreamController<T> controller = StreamController();
    final callback = (JSAny content) {
      controller.add(content as T);
    }.toJS;
    controller.onCancel = () {
      removeEventListener(type, callback);
    };
    addEventListener(type, callback);

    return controller.stream;
  }
}

@JS("WebSocket")
extension type JSWebSocket._(JSObject _) implements JSObject, WebEventStream {
  external factory JSWebSocket(String url, [JSArray<JSString>? protocols]);
  factory JSWebSocket.create(String url, {List<String> protocols = const []}) {
    return JSWebSocket(url, protocols.map((e) => e.toJS).toList().toJS);
  }

  external int get readyState;
  external String get url;
  external void close([int? code, String? reason]);
  external void send(JSAny data);

  external set onerror(JSFunction? _);
  external set onclose(JSFunction? _);
  external set onmessage(JSFunction? _);
  external set onopen(JSFunction? _);

  bool get isOpen => readyState == 1;
  bool get isClosed => readyState == 3;

  void send_(List<int> bytes) {
    final data = Uint8List.fromList(bytes).buffer.toJS;
    send(data);
  }
}
extension type JSWebScoketCloseEvent._(JSObject _) implements JSAny {
  external int? get code;
  external String? get reason;
  external bool? get wasClean;
}
extension type JSWebScoketMessageEvent._(JSObject _)
    implements MessageEvent<JSString> {
  external JSString get data;
}

Future<PlatformWebScoket> connectSoc(
        {required String url,
        required Duration timeout,
        List<String>? protocols}) async =>
    await WebsocketWeb.connect(url: url, timeout: timeout);

class WebsocketWeb implements PlatformWebScoket {
  final JSWebSocket _socket;
  int? _closeCode;
  String? _closeReason;
  @override
  int? get closeCode => _closeCode;

  @override
  String? get closeReason => _closeReason;
  late final StreamController<String> _streamController =
      StreamController<String>()..onCancel = _onCloseStream;
  void _onCloseStream() {
    if (!_socket.isClosed) {
      _socket.close(1000, "closed by client.");
      _closeCode = 1000;
      _closeReason = "closed by client.";
    }
    _socket.onopen = null;
    _socket.onclose = null;
    _socket.onmessage = null;
    _socket.onopen = null;
  }

  Completer<WebsocketWeb>? _connectedCompleter = Completer<WebsocketWeb>();
  WebsocketWeb._(this._socket) {
    _socket.onopen = () {
      _connectedCompleter?.complete(this);
      _connectedCompleter = null;
    }.toJS;
    _socket.onmessage = (JSWebScoketMessageEvent msg) {
      _streamController.add(msg.data.toDart);
    }.toJS;
    _socket.onclose = (JSWebScoketCloseEvent event) {
      _closeCode = event.code;
      _closeReason = event.reason;
      _streamController.close();
      _connectedCompleter?.completeError(Exception("connection closed"));
      _connectedCompleter = null;
    }.toJS;
  }

  @override
  void close() {
    _streamController.close();
  }

  @override
  bool get isConnected => _socket.isOpen;
  @override
  Stream<String> get stream => _streamController.stream;

  static Future<WebsocketWeb> connect(
      {required String url,
      required Duration timeout,
      List<String> protocols = const []}) async {
    final socket =
        WebsocketWeb._(JSWebSocket.create(url, protocols: protocols));
    return await socket._connectedCompleter!.future.timeout(timeout);
  }

  @override
  void sink(List<int> message) {
    _socket.send_(message);
  }
}
