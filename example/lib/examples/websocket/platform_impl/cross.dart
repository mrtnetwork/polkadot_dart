import 'package:example/examples/websocket/core/core.dart';

Future<PlatformWebScoket> connectSoc(
        {required String url,
        required Duration timeout,
        List<String>? protocols}) =>
    throw UnsupportedError(
        'Cannot create a instance without dart:js_interop or dart:io.');
