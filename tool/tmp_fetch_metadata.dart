// ignore_for_file: avoid_print
// Fetch state_getMetadata via WS and save SCALE hex to /tmp/meta/<slug>.hex
// Usage: dart run tool/tmp_fetch_metadata.dart <slug> <wss-endpoint>
import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final slug = args[0];
  final endpoint = args[1];
  final ws = await WebSocket.connect(
    endpoint,
  ).timeout(const Duration(seconds: 60));
  final completer = Completer<String>();
  final buf = StringBuffer();
  ws.listen((msg) {
    buf.write(msg as String);
    try {
      final m = jsonDecode(buf.toString()) as Map;
      if (m['id'] == 1) {
        if (m.containsKey('error')) {
          completer.completeError(m['error']);
        } else {
          completer.complete(m['result'] as String);
        }
      }
    } catch (_) {
      // fragment: keep buffering
    }
  }, onError: completer.completeError);
  ws.add(
    jsonEncode({
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'state_getMetadata',
      'params': [],
    }),
  );
  try {
    final hex = await completer.future.timeout(const Duration(seconds: 180));
    await File('/tmp/meta/$slug.hex').create(recursive: true);
    await File('/tmp/meta/$slug.hex').writeAsString(hex);
    final ver = hex.substring(8, 10);
    print('OK $slug len=${hex.length} versionByte=0x$ver');
  } catch (e) {
    print('FAIL $slug ${'$e'.split('\n').first}');
  } finally {
    await ws.close();
    exit(0);
  }
}
