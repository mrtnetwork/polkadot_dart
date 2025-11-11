import '../platform_impl/cross.dart'
    if (dart.library.js_interop) '../platform_impl/web.dart'
    if (dart.library.io) '../platform_impl/io.dart';

abstract class PlatformWebScoket {
  void close();
  void sink(List<int> message);
  Stream<String> get stream;
  bool get isConnected;

  static Future<PlatformWebScoket> connect(
          {required String url,
          required Duration timeout,
          List<String>? protocols}) async =>
      connectSoc(url: url, timeout: timeout, protocols: protocols);

  int? get closeCode;

  String? get closeReason;
}
