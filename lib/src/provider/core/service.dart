import 'dart:async';

import 'base.dart';

/// A mixin for providing substrate JSON-RPC service functionality.
mixin SubstrateRPCService {
  /// Represents the URL endpoint for JSON-RPC calls.
  String get url;

  /// Makes a JSON-RPC call with the specified [params] and optional [timeout].
  /// Returns a Future<Map<String, dynamic>> representing the JSON-RPC response.
  Future<Map<String, dynamic>> call(SubstrateRequestDetails params,
      [Duration? timeout]);
}
